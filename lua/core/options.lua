local opts = {
	-- Tabs
	shiftwidth = 4,
	tabstop = 4,
	expandtab = true,
	wrap = false,
	-- Colors
	termguicolors = true,
	-- Line numbers
	number = true,
	relativenumber = true,
	-- Search
	incsearch = true,
	ignorecase = true,
	smartcase = true,
	gdefault = true,
	-- Permanent undo
	undofile = true,
	undodir = vim.fn.expand("~/.vim/undo"),
}

-- Set options from table
for opt, val in pairs(opts) do
	vim.o[opt] = val
end

-- Set other options
local colorscheme = require("helpers.colorscheme")
vim.cmd.colorscheme(colorscheme)
