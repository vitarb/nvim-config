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

-- Windows
vim.keymap.set('n', '<leader><leader>', ':only<CR>', {noremap = true})
