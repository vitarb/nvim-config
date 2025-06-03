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
	map("n", "<leader>o", tb.lsp_document_symbols, "Document symbols")
	map("n", "<C-e>", tb.oldfiles, "Recent files")
	map("n", "<leader>s", tb.live_grep, "Search project")
end

map("n", "'1", "<cmd>NvimTreeToggle<CR>", "Toggle sidebar")
map("n", "<C-F4>", "<cmd>bdelete<CR>", "Close buffer")
map("n", "<D-w>", "<cmd>bdelete<CR>", "Close buffer")
map("n", "<M-Right>", "<cmd>bnext<CR>", "Next buffer")
map("n", "<M-Left>", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "<C-Tab>", "<cmd>bnext<CR>", "Next buffer")
map("n", "<C-S-Tab>", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "<leader>w", "<cmd>w<CR>", "Save file")
map("n", "<leader>x", "<cmd>q<CR>", "Close window")
map("n", "<leader>/", function()
	local ok, api = pcall(require, "Comment.api")
	if ok then
		api.toggle.linewise.current()
	end
end, "Toggle comment")
