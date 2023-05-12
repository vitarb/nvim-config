-- Leader key
vim.g.mapleader = "'"

-- Use ; as :
vim.api.nvim_set_keymap('n', ';', ':', {noremap = true})

-- Ctrl+h to stop searching
vim.api.nvim_set_keymap('v', '<C-h>', ':nohlsearch<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-h>', ':nohlsearch<CR>', {noremap = true})

-- Jump to start and end of line using the home row keys
vim.api.nvim_set_keymap('n', 'H', '^', {noremap = true})
vim.api.nvim_set_keymap('n', 'L', '$', {noremap = true})

-- Move by visual line
vim.api.nvim_set_keymap('n', 'j', 'gj', {noremap = true})
vim.api.nvim_set_keymap('n', 'k', 'gk', {noremap = true})

-- Copying and pasting 
vim.api.nvim_set_keymap('v', '<leader>c', '"+y', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>c', '"+yy', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>v', '"+p', {noremap = true})

-- Save and quit
vim.api.nvim_set_keymap('n', '<C-x>', ':confirm qall<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>n', ':e ' .. vim.fn.expand('%:p:h') .. '/', {noremap = true})

-- Center search results
vim.api.nvim_set_keymap('n', 'n', 'nzz', {silent = true})
vim.api.nvim_set_keymap('n', 'N', 'Nzz', {silent = true})
vim.api.nvim_set_keymap('n', '*', '*zz', {silent = true})
vim.api.nvim_set_keymap('n', '#', '#zz', {silent = true})
vim.api.nvim_set_keymap('n', 'g*', 'g*zz', {silent = true})

-- Windows
vim.api.nvim_set_keymap('n', '<leader>o', ':only<CR>',
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-c>', '<C-w>c', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<left>', '<C-w>h', {noremap = true})
vim.api.nvim_set_keymap('n', '<down>', '<C-w>j', {noremap = true})
vim.api.nvim_set_keymap('n', '<up>', '<C-w>k', {noremap = true})
vim.api.nvim_set_keymap('n', '<right>', '<C-w>l', {noremap = true})
