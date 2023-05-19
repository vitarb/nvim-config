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
			local Terminal = require("toggleterm.terminal").Terminal
			local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

			function _lazygit_toggle()
				lazygit:toggle()
			end

			vim.api.nvim_set_keymap(
				"n",
				"<leader>g",
				"<cmd>lua _lazygit_toggle()<CR>",
				{ noremap = true, silent = true }
			)
		end,
	},
}
