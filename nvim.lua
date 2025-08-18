local map = vim.keymap.set

local site = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

-- for Hugo operations: deploy, clean, new content
map({'n', 'v'}, '<leader>zl', ': !rm -rf ./public && hugo -D server <CR>', {desc = 'Local deploy.'})

map({'n', 'v'}, '<leader>zd', ': !rm -rf ./public/ && hugodeploy ' .. site .. '<CR>', {desc = 'Build and deploy Hugo site.'})

map({'n', 'v'}, '<leader>zD', ': !rm -rf ./public && hugodeploy -D ' .. site .. '<CR>', {desc = 'Build and deploy Hugo site (Draft).'})

map({'n', 'v'}, '<leader>zn', ': !hugo new content --kind chapter notes/', {desc = 'Create a new note'})

map({'n', 'v'}, '<leader>zC', ': !hugoclean<CR>', {desc = 'Clean the site build'})

-- for markdown input
map({'n'}, '<leader>ze', 'a****<ESC>hi', {desc = 'Insert an emphasized word', noremap = true})
map({'n'}, '<leader>zi', 'a******<ESC>hhi', {desc = 'Insert an italic word', noremap = true})
map({'n'}, '<leader>zt', 'a``<ESC>i', {desc = 'Insert an inline code', noremap = true})
map({'n'}, '<leader>zc', 'o```<CR>```<ESC>O', {desc = 'Insert a code block', noremap = true})
map({'n'}, '<leader>zp', 'o![](<./images/>)<ESC>2hi', {desc = 'Insert an image', noremap = true})

