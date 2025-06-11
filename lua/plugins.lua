-- Minimal plugin list – Lazy handles itself
return {
	{
		"rebelot/kanagawa.nvim",
		name = "kanagawa",
		priority = 1000,
		config = function()
			require("kanagawa").setup({})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "lua", "bash", "python", "go", "rust", "c", "cpp" },
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
		"nvim-tree/nvim-web-devicons",
		lazy = true,
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
			require("Comment").setup({
				mappings = {
					basic = false,
					extra = false,
				},
			})
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({})
			local gs = require("gitsigns")
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup({})
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "VeryLazy",
		opts = {},
	},
	{
		"machakann/vim-highlightedyank",
		event = "VeryLazy",
		init = function()
			vim.g.highlightedyank_highlight_duration = 450
			vim.cmd([[hi! link HighlightedyankRegion YankFlash]])
		end,
	},
	-- minimal LSP setup powering the outline view
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = true,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = { "gopls", "rust_analyzer", "pyright", "lua_ls", "ts_ls" },
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lsp = require("lspconfig")
			for _, s in ipairs({ "gopls", "rust_analyzer", "pyright", "lua_ls", "ts_ls" }) do
				lsp[s].setup({})
			end
		end,
	},
}
