return {
	"phaazon/hop.nvim",
	branch = "v2",
	config = function()
		require("hop").setup{}
		-- Hop mappings
		local map = require("helpers.keys").map
		map("n", "f", "<cmd>:HopWord<cr>", "Hop to word")
		map("n", "<C-g>", "<cmd>:HopLine<cr>", "Hop to line")
	end,
}

