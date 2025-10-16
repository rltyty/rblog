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
  trimmed=$(printf '%s\n' "$line" | awk '
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
  }')
  if [ -n "$trimmed" ]; then
    minddocs="$minddocs
$trimmed"
  fi
done < "$MINDMAP_MARKDOWN_LIST"

# Generate mind maps and copy to static/mindmaps
for md in $minddocs; do
  printf "Generate mindmap for: [%s].\n" "$md"
  markmap --no-open "$md"

  html=${md%.md}.html
  dir="$(dirname "$md")"
  rel_dir="${dir#content/notes}"
  mkdir -p "static/mindmaps/$rel_dir"
  cp "$html" "static/mindmaps/$rel_dir"
  # copy resources: PDF document
  find "$dir" -maxdepth 1 -type f -name '*.pdf' -exec cp {} "static/mindmaps/$rel_dir/" \;
  # copy resources: images
  if [ -d "$dir/images" ]; then
    mkdir -p "static/mindmaps/$rel_dir/images"
    cp -r "$dir/images/." "static/mindmaps/$rel_dir/images/"
  fi
done
