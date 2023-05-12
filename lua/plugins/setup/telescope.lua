require('telescope').setup {}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-n>', builtin.find_files, {})
vim.keymap.set('n', '<C-f>', builtin.live_grep, {})
vim.keymap.set('n', '<C-e>', builtin.buffers, {})
vim.keymap.set('n', '<C-t>', builtin.help_tags, {})
vim.keymap.set('n', '<leader><leader>', builtin.lsp_document_symbols, {})
