local M = {}
local function noop()
	print("NOOP")
end

local ok, close_buffers = pcall(require, "close_buffers")
if ok then
	M.delete_this = function()
		close_buffers.delete({ type = "this" })
	end
	M.delete_all = function()
		close_buffers.delete({ type = "all", force = true })
	end
	M.delete_others = function()
		close_buffers.delete({ type = "other", force = true })
	end
else
	M.delete_this = function()
		vim.cmd.bdelete()
	end
	M.delete_all = noop
	M.delete_others = noop
end

M.close_current = function()
  if #vim.api.nvim_list_wins() == 1 then
    -- If it's the last window, close buffer
    vim.api.nvim_command('bd')
  else
    -- If it's not the last window, close window
    vim.api.nvim_command('close')
  end
end

return M
