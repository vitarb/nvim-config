-- LSP Configuration & Plugins
return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"j-hui/fidget.nvim",
			"folke/neodev.nvim",
			"RRethy/vim-illuminate",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Quick access via keymap
			require("helpers.keys").map("n", "<leader>M", "<cmd>Mason<cr>", "Show Mason")

			-- Neodev setup before LSP config
			require("neodev").setup()

			-- Turn on LSP status information
			require("fidget").setup()

			-- Set up cool signs for diagnostics
			local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			-- Diagnostic config
			local config = {
				virtual_text = false,
				signs = {
					active = signs,
				},
				update_in_insert = true,
				underline = true,
				severity_sort = true,
				float = {
					focusable = true,
					style = "minimal",
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
				},
			}
			vim.diagnostic.config(config)

			-- This function gets run when an LSP connects to a particular buffer.
			local on_attach = function(client, bufnr)
				local lsp_map = require("helpers.keys").lsp_map
				local ts = require("telescope.builtin")
				lsp_map("n", "<leader>r", vim.lsp.buf.rename, bufnr, "Rename symbol")
				lsp_map("n", "<leader><space>", vim.lsp.buf.code_action, bufnr, "Code action")
				lsp_map("n", "<leader>ld", vim.lsp.buf.type_definition, bufnr, "Type definition")
				lsp_map("n", "<C-p>", vim.lsp.buf.signature_help, bufnr, "Signature help")
				lsp_map("n", "gd", vim.lsp.buf.definition, bufnr, "Goto Definition")
				lsp_map("n", "<C-b>", vim.lsp.buf.definition, bufnr, "Goto Definition")
				lsp_map("n", "<C-M-b>", ts.lsp_references, bufnr, "Goto References")
				lsp_map("n", "gr", ts.lsp_references, bufnr, "Goto References")
				lsp_map("n", "gi", ts.lsp_incoming_calls, bufnr, "Incoming calls")
				lsp_map("n", "<leader><leader>", ts.lsp_document_symbols, bufnr, "Document symbols")
				lsp_map("n", "<C-M-i>", vim.lsp.buf.implementation, bufnr, "Goto Implementation")
				lsp_map("n", "<C-q>", vim.lsp.buf.hover, bufnr, "Hover Documentation")
				lsp_map("n", "gD", vim.lsp.buf.declaration, bufnr, "Goto Declaration")
				lsp_map({"n", "v", "i"}, "<C-M-l>", vim.lsp.buf.format, bufnr, "Format")

				-- Attach and configure vim-illuminate
				require("illuminate").on_attach(client)
			end

			-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			-- Clangd has an issue if offsetEncodings is not set, while rust-analyzer fails if it is.
			-- https://github.com/AstroNvim/AstroNvim/issues/1013
			local clangd_capabilities = vim.tbl_deep_extend("keep", capabilities, {
				offsetEncoding = "utf-8",
			})

			local lspconfig = require("lspconfig")
			-- C
			lspconfig.clangd.setup({
				on_attach = on_attach,
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--completion-style=bundled",
				},
				capabilities = clangd_capabilities,
			})

			-- Rust
			lspconfig.rust_analyzer.setup({
				on_attach = on_attach,
				-- Server-specific settings. See `:help lspconfig-setup`
				settings = { ["rust-analyzer"] = {} },
				capabilities = capabilities,
			})

			-- Lua
			lspconfig.lua_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			})

			-- Python
			lspconfig.pylsp.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					pylsp = {
						plugins = {
							flake8 = {
								enabled = true,
								maxLineLength = 88, -- Black's line length
							},
							-- Disable plugins overlapping with flake8
							pycodestyle = {
								enabled = false,
							},
							mccabe = {
								enabled = false,
							},
							pyflakes = {
								enabled = false,
							},
							-- Use Black as the formatter
							autopep8 = {
								enabled = false,
							},
						},
					},
				},
			})
		end,
	},
}
