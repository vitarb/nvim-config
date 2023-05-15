-- Zen mode with clear code in the middle of the screen.
return {
	"folke/zen-mode.nvim",
	config = function()
		require("zen-mode").setup {}
		local map = require("helpers.keys").map
		map({'n', 'v'}, '<F11>', ':ZenMode<CR>', "Files")
	end,
}
