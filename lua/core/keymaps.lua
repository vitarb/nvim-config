local map = require("helpers.keys").map

-- Use ; as :
map('n', ';', ':')

-- Move by visual line
map('n', 'j', 'gj')
map('n', 'k', 'gk')

-- Copying and pasting 
map('v', '<leader>c', '"+y')
map('n', '<leader>c', '"+yy')
map('n', '<leader>v', '"+p')

-- Omni completion
map('i', '<C-space>', '<C-x><C-o>')
-- Center search results
map('n', 'n', 'nzz')
map('n', 'N', 'Nzz')
map('n', '*', '*zz')
map('n', '#', '#zz')
map('n', 'g*', 'g*zz')

-- Windows
map('n', '<leader>o', ':only<CR>')
map('n', '<C-c>', '<C-w>c')
map('n', '<left>', '<C-w>h')
map('n', '<down>', '<C-w>j')
map('n', '<up>', '<C-w>k')
map('n', '<right>', '<C-w>l')

-- Quick access to some common actions
map("n", "<leader>fw", "<cmd>w<cr>", "Write")
map("n", "<leader>fa", "<cmd>wa<cr>", "Write all")
map('n', '<C-s>', '<cmd>wa<cr>', 'Write all')
map("n", "<leader>qq", "<cmd>q<cr>", "Quit")
map("n", "<leader>qa", "<cmd>qa!<cr>", "Quit all")
map('n', '<C-x>', '<cmd>qa!<cr>', 'Quit all')
map("n", "<leader>dw", "<cmd>close<cr>", "Window")
map('n', '<leader>n', ':e <C-R>=expand("%:p:h") . "/"<CR>')

-- Diagnostic keymaps
map('n', 'gx', vim.diagnostic.open_float, "Show diagnostics under cursor")

-- Easier access to beginning and end of lines
map({"n", "v"}, "<M-h>", "^", "Go to beginning of line")
map({"n", "v"}, "<M-l>", "$", "Go to end of line")

-- Resize with arrows
map("n", "<C-Up>", ":resize +2<CR>")
map("n", "<C-Down>", ":resize -2<CR>")
map("n", "<C-Left>", ":vertical resize +2<CR>")
map("n", "<C-Right>", ":vertical resize -2<CR>")

-- Deleting buffers
local buffers = require("helpers.buffers")
map("n", "<leader>db", buffers.delete_this, "Current buffer")
map("n", "<leader>do", buffers.delete_others, "Other buffers")
map("n", "<leader>da", buffers.delete_all, "All buffers")

-- Navigate buffers
map("n", "<S-l>", ":bnext<CR>")
map("n", "<S-h>", ":bprevious<CR>")

-- Stay in indent mode
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Toggle theme between light and dark modes
map("n", "<leader>tt", function()
	if vim.o.background == "dark" then
		vim.o.background = "light"
	else
		vim.o.background = "dark"
	end
end, "Toggle between light and dark themes")

-- Clear after search
map("n", "<C-h>", "<cmd>nohl<cr>", "Clear highlights")
