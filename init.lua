local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
if not string.find(vim.o.rtp, root, 1, true) then
	vim.opt.rtp:prepend(root)
end
vim.g.mapleader = "'"
vim.g.maplocalleader = "'"
if vim.env.NVIM_OFFLINE_BOOT == "1" then
	return
end
require("core.lazy")
require("core.keymaps")
