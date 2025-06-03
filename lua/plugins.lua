-- Minimal plugin list – Lazy handles itself
return {
	"nvim-treesitter/nvim-treesitter",
	{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	"nvim-lualine/lualine.nvim",
	"nvim-tree/nvim-tree.lua",
}
