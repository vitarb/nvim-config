-- Fancier statusline
return {
	"numToStr/Comment.nvim",
	config = function()
		require('Comment').setup({
			ignore = '^$',
			toggler = {
				line = '<C-_>', -- <C-/> for single line comment in normal mode
				block = '<leader>/', -- <leader>/ for block comment in normal mode
			},
			opleader = {
				line = '<C-_>', -- <C-/> to comment each line in visual mode
				block = '<leader>/', -- <leader>/ for block comment in visual mode
			},
		})
	end,
}
