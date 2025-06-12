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

local gs
do
	local ok, gitsigns = pcall(require, "gitsigns")
	if ok then
		gs = gitsigns
	end
end

if tb then
	map("n", "<C-n>", tb.find_files, "Navigate file")
	map("n", "<leader>ff", function()
		tb.find_files({ hidden = true })
	end, "Find files")
	map("n", "<leader>fg", tb.live_grep, "Live grep")
	-- outline / symbol picker
	map("n", "<leader><leader>", tb.lsp_document_symbols, "Outline / symbols")
	map("n", "<C-e>", tb.buffers, "Open buffers")
	map("n", "<C-f>", tb.live_grep, "Search project")
end

map("n", "<leader>1", "<cmd>NvimTreeToggle<CR>", "Toggle sidebar")
map("n", "<leader>j", "<cmd>bnext<CR>", "Next buffer")
map("n", "<leader>k", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "<leader>q", "<cmd>bdelete<CR>", "Close buffer")
map("n", "<leader>Q", function()
	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
			vim.api.nvim_buf_delete(buf, {})
		end
	end
end, "Close other buffers")
map("n", "<leader>h", function()
	local ok, bl = pcall(require, "bufferline")
	if ok and bl.move then
		bl.move(-1)
	end
end, "Move buffer left")
map("n", "<leader>l", function()
	local ok, bl = pcall(require, "bufferline")
	if ok and bl.move then
		bl.move(1)
	end
end, "Move buffer right")
local diag_modes = { "none", "virtual", "full" }
local diag_index = 1
local function apply_diag()
	local mode = diag_modes[diag_index]
	vim.diagnostic.config({
		virtual_text = mode ~= "none",
		signs = mode == "full",
	})
	print("Diagnostics: " .. mode)
end
apply_diag()
map("n", "<leader>dd", function()
	diag_index = diag_index % #diag_modes + 1
	apply_diag()
end, "Cycle diagnostics")
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

if gs then
	map("n", "<leader>gh", gs.stage_hunk, "Stage hunk")
	map("n", "<leader>gl", gs.reset_hunk, "Reset hunk")
	map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
end

local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
	wk.register({
		f = { name = "find" },
		g = { name = "git" },
		d = { name = "diagnostics" },
	}, { prefix = "<leader>" })
end
