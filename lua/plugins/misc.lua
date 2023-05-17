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
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
}
