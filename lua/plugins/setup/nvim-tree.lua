require('nvim-tree').setup({})

-- Nvim hotkeys
vim.keymap.set('n', '<leader>t', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>f', ':NvimTreeFindFile<CR>')
