require('Comment').setup()

-- Toggle line-wise comment
vim.api.nvim_set_keymap('n', '<C-_>', ':normal gcc<CR>j', {noremap = true})
vim.api.nvim_set_keymap('v', '<C-_>', ':normal gcc<CR>', {noremap = true})

-- Toggle block-wise comment
-- vim.api.nvim_set_keymap('n', '<TBD>', ':normal gbc<CR>', {noremap = true})
-- vim.api.nvim_set_keymap('v', '<TBD>', ':normal gb<CR>', {noremap = true})
