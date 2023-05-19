return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				shade_terminals = false,
				insert_mappings = true,
				terminal_mappings = true,
			})
			local map = require("helpers.keys").map
			map({ "n", "t" }, "<F60>", "<cmd>:ToggleTerm<CR>", "Terminal") -- <M-F12> to toggle terminal
		end,
	},
}
