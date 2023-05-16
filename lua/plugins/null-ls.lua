return {
	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					-- Automatically registered by mason-null-ls
				},
			})
		end,
	},
	{ -- Configure mason-null-ls as a primary source.
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"jose-elias-alvarez/null-ls.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = { "clang-format", "stylua", "jq", "rustfmt", "gofmt" },
				automatic_installation = false,
				handlers = {},
			})
		end,
	},
}
