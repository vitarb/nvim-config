require('hop').setup {
  quit_key = '<SPC>',
}

-- Hop mappings
map('n', 'f', ':HopWord<CR>')
map('n', '<C-g>', ':HopLine<CR>')
