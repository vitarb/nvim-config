
-- Ensure this repo's lua/ dir is on Lua & runtime path even when we are not
-- under ~/.config/nvim.
local repo = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')
package.path = table.concat({
  repo .. '/lua/?.lua',
  repo .. '/lua/?/init.lua',
  package.path,
}, ';')
vim.opt.runtimepath:prepend(repo)

if os.getenv("NVIM_OFFLINE_BOOT") == "1" then return end

-- Handle plugins with lazy.nvim
require("core.lazy")

-- General Neovim keymaps
require("core.keymaps")

-- Other options
require("core.options")
