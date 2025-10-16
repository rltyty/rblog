#!/bin/sh

set -e

# TODO: It’d be better to move this task from the Git pre-commit hook to a
# GitHub workflow, so that the repository doesn’t have to track changes to the
# Markmap HTML output.

MINDMAP_MARKDOWN_LIST="hooks/mindmap.list"
# Ensure file list exists
if [ ! -f "$MINDMAP_MARKDOWN_LIST" ]; then
  echo "Warning: $MINDMAP_MARKDOWN_LIST not found — skipping Markmap generation."
  exit 0
fi

# Read mindmap doc pathes into an array (ignore comments and empty lines)
minddocs=""
while IFS= read -r line; do
  # 1) remove leading whitespace
  # 2) remove "#..." comment (except # in quotes "", '')
  # 3) remove trailing whitespaces left after removing comment
  # 4) ignore empty lines
  # NOTE: [[:space:]] is POSIX portable works for all variants of grep, sed,
  # awk, etc. \s is PCRE only, not POSIX.
  trimmed=$(awk '
  {
    line = $0
    inquote2 = 0
    inquote1 = 0
    out = ""
    for (i = 1; i <= length(line); i++) {
      c = substr(line, i, 1)
      if (c == "\"") inquote2 = !inquote2
      else if (c == "'"'"'" ) inquote1 = !inquote1
      else if (c == "#" && !inquote2 && !inquote1) break
      out = out c
    }
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", out)
    print out
  }' <<< "$line")
  if [ -n "$trimmed" ]; then
    minddocs="$minddocs
$trimmed"
  fi
done < "$MINDMAP_MARKDOWN_LIST"

# Find all staged Markdown files in Added/Copied/Modified/Renamed
staged_md_files=$(git diff --cached --name-only --diff-filter=ACMR | grep '\.md$' || true)

# Exit early if no markdown changes
[ -z "$staged_md_files" ] && exit 0

# Update mindmaps for files appear in both minddocs and staged_md_files
IFS='
'
for f in $staged_md_files; do
  for md in $minddocs; do
    f_lc=$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')
    md_lc=$(printf '%s' "$md" | tr '[:upper:]' '[:lower:]')
    if [ "$f_lc" = "$md_lc" ]; then
      printf "Update mindmaps for: [%s].\n" "$md"
      markmap --no-open "$md"
      git add "${md%.md}.html"
      break
    fi
  done
done
unset IFS
