-- Minimal plugin list – Lazy handles itself
return {
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "lua", "bash", "python", "go", "rust", "cpp" },
				highlight = { enable = true },
				indent = { enable = true },
				incremental_selection = { enable = true },
			})
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local actions = require("telescope.actions")
			require("telescope").setup({
				defaults = {
					layout_config = { width = 0.9 },
					mappings = { i = { ["<Esc>"] = actions.close } },
				},
			})
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", function()
				builtin.find_files({ hidden = true })
			end, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = false,
					theme = "auto",
				},
			})
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		config = function()
			require("nvim-tree").setup({
				view = { width = 35 },
				renderer = { group_empty = true },
				filters = { dotfiles = false },
			})
			vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle tree" })
		end,
	},
}
