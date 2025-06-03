local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
vim.opt.rtp:prepend(root)
vim.g.mapleader = "'"
vim.g.maplocalleader = "'"
if vim.env.NVIM_OFFLINE_BOOT == "1" then
	return
end
require("core.lazy")
require("core.keymaps")
