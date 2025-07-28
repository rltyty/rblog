local map = vim.keymap.set

local site = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
map({'n', 'v'}, '<leader>zd', ': !rm -rf ./public/ && hugodeploy ' .. site .. '<CR>', {desc = 'Build and deploy Hugo site.'})
map({'n', 'v'}, '<leader>zD', ': !rm -rf ./public && hugodeploy -D ' .. site .. '<CR>', {desc = 'Build and deploy Hugo site.'})
map({'n', 'v'}, '<leader>zn', ': !hugo new content --kind chapter notes/', {desc = 'Create a new note'})
