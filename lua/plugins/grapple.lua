return {
	"cbochs/grapple.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local map = require("helpers.keys").map
		map("n", "mm", require("grapple").toggle, "Toggle file bookmark")
		map("n", "m,", require("grapple").popup_tags, "Show bookmarks")
		map("n", "<tab>", require("grapple").cycle_forward, "Next boorkmark")
	end,
}
