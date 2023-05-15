-- Fancier statusline
return {
	"simrat39/symbols-outline.nvim",
	config = function()
		require("symbols-outline").setup{}
		vim.api.nvim_set_keymap('n', '<F12>', ':SymbolsOutline<CR>', {noremap = true})
	end,
}

