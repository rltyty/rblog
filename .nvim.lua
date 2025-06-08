local map = vim.keymap.set

local site = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
map({'n', 'v'}, '<leader>zd', ': !hugodeploy ' .. site .. '<CR>', {desc = 'Build and deploy Hugo site.'})
