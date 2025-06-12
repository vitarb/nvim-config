-- luacheck: globals vim
vim.api.nvim_create_user_command("UpdateAll", function()
	vim.cmd("Lazy sync")
	vim.cmd("MasonUpdate")
end, { desc = "Sync plugins and Mason packages" })
