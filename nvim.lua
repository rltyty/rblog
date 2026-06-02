local map = vim.keymap.set

local site = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

-- for Hugo operations: deploy, clean, new content
map({'n', 'v'}, '<leader>zl', ': !rm -rf ./public && hugo -D server <CR>', {desc = 'Local deploy.'})

map({'n', 'v'}, '<leader>zd', ': !rm -rf ./public/ && hugodeploy ' .. site .. '<CR>', {desc = 'Build and deploy Hugo site.'})

map({'n', 'v'}, '<leader>zD', ': !rm -rf ./public && hugodeploy -D ' .. site .. '<CR>', {desc = 'Build and deploy Hugo site (Draft).'})

map({'n', 'v'}, '<leader>zW', ': !gh workflow run .github/workflows/deploy.yml --ref dev <CR>', {desc = 'Manually trigger Github deploy workfow'})

map({'n', 'v'}, '<leader>zn', ': !hugo new content --kind chapter notes/', {desc = 'Create a new note'})

map({'n', 'v'}, '<leader>zC', ': !hugoclean<CR>', {desc = 'Clean the site build'})

-- for markdown input
map({'n'}, '<leader>ze', 'a****<ESC>hi', {desc = 'Insert an emphasized word', noremap = true})
map({'n'}, '<leader>zi', 'a******<ESC>hhi', {desc = 'Insert an italic word', noremap = true})
map({'n'}, '<leader>zt', 'a``<ESC>i', {desc = 'Insert an inline code', noremap = true})
map({'n'}, '<leader>zc', 'o```<CR>```<ESC>O', {desc = 'Insert a code block', noremap = true})
map({'n'}, '<leader>zp', 'o![](<./images/>)<ESC>2hi', {desc = 'Insert an image', noremap = true})

-- Automatic LastMod update
-- AIGC: OpenAI
local group = vim.api.nvim_create_augroup("HugoLastMod", { clear = true })

local function strip_lastmod(lines)
  local result = {}

  for _, line in ipairs(lines) do
    if not line:match("^lastmod:%s*") then
      table.insert(result, line)
    end
  end

  return result
end

local function content_changed(buf)
  local filename = vim.api.nvim_buf_get_name(buf)

  -- New file: consider it changed
  if vim.fn.filereadable(filename) == 0 then
    return true
  end

  local disk_lines = vim.fn.readfile(filename)
  local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  disk_lines = strip_lastmod(disk_lines)
  buf_lines = strip_lastmod(buf_lines)

  return not vim.deep_equal(disk_lines, buf_lines)
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.md",
  callback = function(args)
    local buf = args.buf
    local filename = vim.api.nvim_buf_get_name(buf)

    -- Only Hugo content files
    if not filename:match("/content/") then
      return
    end

    -- Skip if content is effectively unchanged
    if not content_changed(buf) then
      return
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    -- Must have YAML front matter
    if lines[1] ~= "---" then
      return
    end

    local frontmatter_end

    for i = 2, #lines do
      if lines[i] == "---" then
        frontmatter_end = i
        break
      end
    end

    if not frontmatter_end then
      return
    end

    local timestamp = os.date("%Y-%m-%dT%H:%M:%S%z")
    timestamp = timestamp:gsub("(%d%d)$", ":%1") -- +0800 -> +08:00

    for i = 2, frontmatter_end - 1 do
      if lines[i]:match("^lastmod:%s*") or lines[i]:match("^lastMod:%s*") then
        lines[i] = "lastmod: " .. timestamp
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        return
      end
    end
  end,
})
