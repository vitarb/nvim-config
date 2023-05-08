require("symbols-outline").setup()

-- Map <F12> to :SymbolsOutline<CR> in Normal mode
vim.api.nvim_set_keymap('n', '<F12>', ':SymbolsOutline<CR>', {noremap = true})
