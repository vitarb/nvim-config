vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "YankFlash", timeout = 200, on_visual = true })
		vim.defer_fn(function()
			vim.highlight.on_yank({ higroup = "YankFlash", timeout = 200, on_visual = true })
		end, 220)
	end,
})
