return {
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
			local opts = require("modules.lsp").setup()
			for _, s in ipairs({ "gopls", "rust_analyzer", "pyright", "lua_ls", "ts_ls" }) do
				lsp[s].setup(opts)
			end
		end,
	},
}
