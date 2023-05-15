-- Zen mode with clear code in the middle of the screen.
return {
	"ThePrimeagen/harpoon",
	dependencies = { "nvim-telescope/telescope.nvim" },
	config = function()
		require("harpoon").setup {}
		require("telescope").load_extension('harpoon')
		-- Harpoon mappings
		local map = require("helpers.keys").map
		map("n", "<leader>ha", require("harpoon.mark").add_file, "Harpoon add")
		map("n", "<leader>hr", require("harpoon.mark").rm_file, "Harpoon remove")
		map("n", "<tab>", require("harpoon.ui").nav_next, "Harpoon next")
		map("n", "<S-tab>", require("harpoon.ui").nav_prev, "Harpoon prev")
		map("n", "<leader><tab>", "<cmd>Telescope harpoon marks<CR>", "Harpoon marks")
	end,
}
