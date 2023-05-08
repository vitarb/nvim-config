-- Leader key
vim.g.mapleader = "'"

-- Use ; as :
vim.keymap.set('n', ';', ':', {noremap = true})

-- Ctrl+h to stop searching
vim.keymap.set('v', '<C-h>', ':nohlsearch<CR>', {noremap = true})
vim.keymap.set('n', '<C-h>', ':nohlsearch<CR>', {noremap = true})

-- Jump to start and end of line using the home row keys
vim.keymap.set('n', 'H', '^', {noremap = true})
vim.keymap.set('n', 'L', '$', {noremap = true})

-- Left and right can switch buffers
vim.keymap.set('n', '<left>', ':bp<CR>', {noremap = true})
vim.keymap.set('n', '<right>', ':bn<CR>', {noremap = true})

-- Move by visual line
vim.keymap.set('n', 'j', 'gj', {noremap = true})
vim.keymap.set('n', 'k', 'gk', {noremap = true})

-- Copying and pasting 
vim.api.nvim_set_keymap('v', '<leader>c', '"+y<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>v', '"+p<CR>', {noremap = true})

-- Save and quit
vim.keymap.set('n', '<C-x>', ':confirm qall<CR>', {noremap = true})
vim.keymap.set('n', '<C-s>', ':w<CR>', {noremap = true})

-- Center search results
vim.keymap.set('n', 'n', 'nzz', {silent = true})
vim.keymap.set('n', 'N', 'Nzz', {silent = true})
vim.keymap.set('n', '*', '*zz', {silent = true})
vim.keymap.set('n', '#', '#zz', {silent = true})
vim.keymap.set('n', 'g*', 'g*zz', {silent = true})

