vim.api.nvim_set_hl(0, "YankFlash", {
	bg = "#ffe8d0",
	fg = "#1c1a19",
	bold = true,
	default = true,
})
if not vim.o.termguicolors then
	vim.cmd("hi! link YankFlash Visual")
end
