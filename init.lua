local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
vim.opt.rtp:prepend(root)
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path
vim.g.mapleader = "'"
vim.g.maplocalleader = "'"
vim.opt.number = true -- absolute line numbers
vim.opt.relativenumber = true -- relative line numbers
local udir = vim.fn.stdpath("cache") .. "/undo"
vim.fn.mkdir(udir, "p")
vim.o.undofile, vim.o.undodir = true, udir
if vim.env.CI == "true" then
	vim.notify = function() end
end
if vim.env.NVIM_OFFLINE_BOOT == "1" then
	return
end
require("core.lazy")
require("core.keymaps")
if vim.fn.has("termguicolors") == 1 then
	vim.o.termguicolors = true
end
vim.cmd.colorscheme("kanagawa")
require("core.autocmds")
require("core.highlight")
vim.highlight.on_yank({ higroup = "YankFlash", timeout = 250 })
require("core.update")
