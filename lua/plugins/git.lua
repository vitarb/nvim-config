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
					ours = "co",
					theirs = "ct",
					none = "c0",
					both = "cb",
					next = "cn",
					prev = "cp",
				},
			})
		end,
	},
	{
		"tpope/vim-fugitive",
		config = function()
			local map = require("helpers.keys").map
			map("n", "<leader>ga", "<cmd>Git add %<cr>", "Stage the current file")
			map("n", "<leader>gb", "<cmd>Git blame<cr>", "Show the blame")
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
}
