local M = {}

function M.setup()
	-- Define default highlight for yank flash
	vim.api.nvim_set_hl(0, "YankFlash", {
		bg = "#ffcfaf",
		fg = "#1c1a19",
		bold = true,
		ctermbg = 216,
		ctermfg = 233,
		default = true,
	})
	if not vim.o.termguicolors then
		vim.cmd("hi! link YankFlash IncSearch")
	end
end

return M
