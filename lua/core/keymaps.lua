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
map("n", "<C-x>", "<cmd>qa<CR>", "Exit Neovim")

local kanagawa_variant = "wave"
map("n", "<leader>;", function()
	local next = kanagawa_variant == "wave" and "dragon" or "wave"
	local ok, kg = pcall(require, "kanagawa")
	if ok and kg.load then
		kg.load(next)
		kanagawa_variant = next
	end
end, "Toggle color variant")
