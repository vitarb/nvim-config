require('hop').setup {quit_key = '<SPC>'}

-- Hop mappings
vim.keymap.set('n', 'f', ':HopWord<CR>')
vim.keymap.set('n', '<C-g>', ':HopLine<CR>')
