local map = function(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- Leader is a single quote
vim.g.mapleader = "'"
vim.g.maplocalleader = "'"

local tb
do
	local ok, builtin = pcall(require, "telescope.builtin")
	if ok then
		tb = builtin
	end
end

if tb then
	map("n", "<C-n>", tb.find_files, "Navigate file")
	-- outline / symbol picker
	map("n", "<leader><leader>", tb.lsp_document_symbols, "Outline / symbols")
	map("n", "<C-e>", tb.buffers, "Open buffers")
	map("n", "<C-f>", tb.live_grep, "Search project")
end

map("n", "'1", "<cmd>NvimTreeToggle<CR>", "Toggle sidebar")
map("n", "'j", "<cmd>bnext<CR>", "Next buffer")
map("n", "'k", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "'q", "<cmd>bdelete<CR>", "Close buffer")
map("n", "'Q", function()
	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
			vim.api.nvim_buf_delete(buf, {})
		end
	end
end, "Close other buffers")
map("n", "'h", function()
	local ok, bl = pcall(require, "bufferline")
	if ok and bl.move then
		bl.move(-1)
	end
end, "Move buffer left")
map("n", "'l", function()
	local ok, bl = pcall(require, "bufferline")
	if ok and bl.move then
		bl.move(1)
	end
end, "Move buffer right")
local diag_on = false
vim.diagnostic.config({ virtual_text = diag_on, signs = diag_on })
map("n", "'dd", function()
	diag_on = not diag_on
	vim.diagnostic.config({ virtual_text = diag_on, signs = diag_on })
	print(diag_on and "Diagnostics ON" or "Diagnostics OFF")
end, "Toggle diagnostics")
map("n", "<C-Tab>", "<cmd>bnext<CR>", "Next buffer")
map("n", "<C-S-Tab>", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "<leader>w", "<cmd>w<CR>", "Save file")
map("n", "<leader>x", "<cmd>q<CR>", "Close window")
map({ "n", "v" }, "<leader>/", function()
	local ok, api = pcall(require, "Comment.api")
	if ok then
		api.toggle.linewise.current()
	end
end, "Toggle comment")
map("v", "<leader>c", '"+y', "Copy to clipboard")
map({ "n", "v" }, "<leader>v", '"+p', "Paste from clipboard")
map("n", "<C-x>", "<cmd>qa!<CR>", "Exit Neovim without saving")

local kanagawa_variants = { "wave", "dragon", "lotus" }
local kanagawa_index = 1
map("n", "<leader>;", function()
	kanagawa_index = kanagawa_index % #kanagawa_variants + 1
	local next = kanagawa_variants[kanagawa_index]
	local ok, kg = pcall(require, "kanagawa")
	if ok and kg.load then
		kg.load(next)
	end
end, "Cycle color variant")

-- LSP-specific mappings once a server is attached
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local function lspmap(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, noremap = true, silent = true, desc = desc })
		end
		lspmap("K", vim.lsp.buf.hover, "Hover docs")
		lspmap("gd", vim.lsp.buf.definition, "Go to definition")
		local tb_ok, tb = pcall(require, "telescope.builtin")
		if tb_ok then
			lspmap("gr", tb.lsp_references, "References")
		end
		lspmap("gR", vim.lsp.buf.rename, "Rename symbol")
		lspmap("<leader>a", vim.lsp.buf.code_action, "Code actions")
	end,
})
