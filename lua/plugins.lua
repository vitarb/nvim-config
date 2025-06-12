-- luacheck: globals vim
-- Minimal plugin list – Lazy handles itself
if vim.fn.executable("rg") == 0 then
	vim.schedule(function()
		vim.notify("ripgrep not found – install it for :Telescope live_grep", vim.log.levels.WARN)
	end)
end
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
		event = { "BufReadPost", "BufNewFile" },
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
		cmd = { "Telescope" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local actions = require("telescope.actions")
			require("telescope").setup({
				defaults = {
					layout_config = { width = 0.9 },
					mappings = { i = { ["<Esc>"] = actions.close } },
				},
			})
			-- builtin functions can be used externally if needed
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
		cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
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
			-- gitsigns instance available as needed
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
		"echasnovski/mini.nvim",
		version = "*",
		config = function()
			require("mini.icons").setup()
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "VeryLazy",
		opts = {},
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
