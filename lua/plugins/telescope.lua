-- Telescope fuzzy finding (all the things)
return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-u>"] = false,
							["<C-d>"] = false,
						},
					},
				},
			})

			-- Enable telescope fzf native, if installed
			pcall(require("telescope").load_extension, "fzf")

			local map = require("helpers.keys").map
			local builtin = require('telescope.builtin')
			map('n', '<C-n>', builtin.find_files, "Files")
			map('n', '<C-f>', builtin.live_grep, "Grep")
			map('n', '<C-e>', builtin.buffers, "Buffers")
			map('n', '<C-t>', builtin.help_tags, "Help")

			map("n", "<leader>/", function()
				-- You can pass additional configuration to telescope to change theme, layout, etc.
				require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, "Search in current buffer")

			map("n", "<leader>sh", builtin.help_tags, "Help")
			map("n", "<leader>sw", builtin.grep_string, "Current word")
			map("n", "<leader>sd", builtin.diagnostics, "Diagnostics")
			map("n", "<leader>sk", builtin.keymaps, "Search keymaps")
		end,
	},
}
