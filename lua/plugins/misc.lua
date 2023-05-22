-- Miscelaneous fun stuff
return {
	-- Move stuff with <M-j> and <M-k> in both normal and visual mode
	{
		"echasnovski/mini.move",
		config = function()
			require("mini.move").setup()
		end,
	},
	-- Better buffer closing actions. Available via the buffers helper.
	{
		"kazhala/close-buffers.nvim",
		opts = {
			preserve_window_layout = { "this", "nameless" },
		},
	},
	{
		"rcarriga/nvim-notify",
		config = function()
			vim.notify = require("notify") -- Other plugins can use the notification windows by setting it as your default notify function
		end,
	},
	{
		"folke/zen-mode.nvim",
		config = function()
			require("zen-mode").setup({})
			local map = require("helpers.keys").map
			map({ "n", "v" }, "<F11>", ":ZenMode<CR>", "Files")
		end,
	},
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
}
