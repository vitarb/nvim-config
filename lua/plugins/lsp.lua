local ensure_servers = { "rust_analyzer", "pyright", "lua_ls", "ts_ls" }
if vim.fn.executable("go") == 1 then
	table.insert(ensure_servers, 1, "gopls")
end

local server_commands = {
	gopls = "gopls",
	rust_analyzer = "rust-analyzer",
	pyright = "pyright-langserver",
	lua_ls = "lua-language-server",
	ts_ls = "typescript-language-server",
}

return {
	-- minimal LSP setup powering the outline view
	{
		"mason-org/mason.nvim",
		build = ":MasonUpdate",
		opts = {
			providers = { "mason.providers.registry-api" },
		},
		config = function(_, opts)
			require("mason").setup(opts)
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = ensure_servers,
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
			for server, command in pairs(server_commands) do
				if vim.fn.executable(command) == 1 then
					vim.lsp.config(server, opts)
					vim.lsp.enable(server)
				end
			end
		end,
	},
}
