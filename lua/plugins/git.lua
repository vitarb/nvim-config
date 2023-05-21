-- Git related plugins
return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {},
	},
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		config = function()
			require("git-conflict").setup({
				default_mappings = {
					ours = "go",
					theirs = "gt",
					none = "g0",
					both = "gb",
					next = "gn",
					prev = "gp",
				},
			})
		end,
	},
	{
		"tpope/vim-fugitive",
		config = function()
			local map = require("helpers.keys").map
			map("n", "<leader>ga", "<cmd>Git add %<cr>", "Stage the current file")
			map("n", "<C-M-a>", "<cmd>Git blame<cr>", "Show the blame")
			map("n", "<C-t>", "<cmd>Git pull --rebase<cr>", "Git pull rebase")
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		config = function()
			local map = require("helpers.keys").map
			map({ "n", "t", "v" }, "<C-k>", "<cmd>LazyGit<cr>", "LazyGit view")
			if vim.fn.executable("nvr") then
				vim.env.GIT_EDITOR = "nvr --remote-tab-wait +'set bufhidden=wipe'"
			end
		end,
	},
	{
		"Almo7aya/openingh.nvim",

		config = function()
			local map = require("helpers.keys").map
			map("n", "<leader>gg", "V:OpenInGHFile<cr><esc>", "Open file on github")
			map("v", "<leader>gg", ":OpenInGHFile<cr>", "Open file on github")
			map("n", "<leader>gr", ":OpenInGHRepo<cr>", "Open github repo")
		end,
	},
}
