vim.g.mapleader = "'"
vim.g.maplocalleader = "'"
if vim.env.NVIM_OFFLINE_BOOT == "1" then
	return
end
require("core.lazy")
require("core.keymaps")
