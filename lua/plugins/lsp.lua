return {
	-- minimal LSP setup powering the outline view
	{
		"mason-org/mason.nvim",
		build = ":MasonUpdate",
		config = true,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = { "gopls", "rust_analyzer", "pyright", "lua_ls", "ts_ls" },
			automatic_enable = false,
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local opts = require("modules.lsp").setup()
			for _, s in ipairs({ "gopls", "rust_analyzer", "pyright", "lua_ls", "ts_ls" }) do
				vim.lsp.config(s, opts)
				vim.lsp.enable(s)
			end
		end,
	},
}
