-- Minimal plugin list – Lazy handles itself
return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
	},
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
			-- keymap moved to core/keymaps.lua
		end,
	},
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		config = function()
			require("bufferline").setup({
				options = { separator_style = "thin" },
			})
		end,
	},
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		config = function()
			require("Comment").setup({})
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({})
			local gs = require("gitsigns")
			vim.keymap.set("n", "'gh", gs.stage_hunk, { desc = "Stage hunk" })
			vim.keymap.set("n", "'gl", gs.reset_hunk, { desc = "Reset hunk" })
			vim.keymap.set("n", "'gp", gs.preview_hunk, { desc = "Preview hunk" })
		end,
	},
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		config = function()
			local persistence = require("persistence")
			persistence.setup({})
			vim.api.nvim_create_autocmd("VimLeavePre", {
				callback = function()
					persistence.save()
				end,
			})
			vim.keymap.set("n", "'sr", function()
				persistence.load({ last = true })
			end, { desc = "Restore last session" })
		end,
	},
}
