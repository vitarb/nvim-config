return {
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("trouble").setup({
				use_diagnostic_signs = true,
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
			local map = require("helpers.keys").map
			map("n", "<F35>", "<cmd>TroubleToggle<CR>", "Toggle trouble window") -- <C-F11>
		end,
	},
}
