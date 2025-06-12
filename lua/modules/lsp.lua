local M = {}

function M.setup()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local ok, cmp = pcall(require, "cmp_nvim_lsp")
	if ok and cmp.default_capabilities then
		capabilities = cmp.default_capabilities(capabilities)
	end

	local function on_attach(_, bufnr)
		local function map(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = desc })
		end
		map("K", vim.lsp.buf.hover, "Hover docs")
		map("gd", vim.lsp.buf.definition, "Go to definition")
		local tb_ok, tb = pcall(require, "telescope.builtin")
		if tb_ok then
			map("gr", tb.lsp_references, "References")
		end
		map("gR", vim.lsp.buf.rename, "Rename symbol")
		map("<leader>a", vim.lsp.buf.code_action, "Code actions")
	end

	return {
		capabilities = capabilities,
		on_attach = on_attach,
	}
end

return M
