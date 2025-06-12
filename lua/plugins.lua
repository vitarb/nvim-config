-- Minimal plugin list – Lazy handles itself
if vim.fn.executable("rg") == 0 then
	vim.schedule(function()
		vim.notify("ripgrep not found – install it for :Telescope live_grep", vim.log.levels.WARN)
	end)
end
return {
	{ import = "plugins.ui" },
	{ import = "plugins.coding" },
	{ import = "plugins.lsp" },
}
