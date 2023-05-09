-- GUI
vim.opt.termguicolors = true
vim.o.background = "dark" -- "dark" or "light"
vim.cmd("colorscheme gruvbox")
vim.opt.foldenable = false -- disable folding
vim.opt.ttyfast = true -- enable fast redraws
vim.opt.number = true -- Show line numbers
vim.opt.autoindent = true -- Enable autoindent
vim.opt.scrolloff = 10 -- Keep space below and above cursor visible after search

-- Tabs 
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

-- Search
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.gdefault = true

-- Permanent undo
vim.o.undodir = '~/.vimdid'
vim.o.undofile = true
