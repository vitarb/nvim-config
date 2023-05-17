return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			{ "williamboman/mason-lspconfig.nvim" },
		},
		config = function()
			-- Set up Mason before anything else
			require("mason").setup()
			-- Setup language servers
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"clangd",
					"gopls",
					"pylsp",
					"rust_analyzer",
				},
				automatic_installation = true,
			})
		end,
	},
}
