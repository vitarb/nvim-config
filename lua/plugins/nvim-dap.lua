return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",
		"rcarriga/nvim-notify",
		"theHamsta/nvim-dap-virtual-text",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("mason-nvim-dap").setup({
			ensure_installed = { "cppdbg" },
		})
		local dap = require("dap")
		local ui = require("dapui")
		ui.setup({})
		dap.set_log_level("INFO") -- Helps when configuring DAP, see logs with :DapShowLog

		-- For details on how to setup additional adapters look at this wiki:
		-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
		-- Generally all you need is to add the tool to the mason-nvim-dap install list and add adapter config below.
		dap.adapters.cppdbg = {
			id = "cppdbg",
			type = "executable",
			command = vim.fn.stdpath("data") .. "/mason/bin/OpenDebugAD7",
		}
		dap.configurations.cpp = {
			{
				name = "Launch file",
				type = "cppdbg",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopAtEntry = true,
			},
			{
				name = "Attach to gdbserver :1234",
				type = "cppdbg",
				request = "launch",
				MIMode = "gdb",
				miDebuggerServerAddress = "localhost:1234",
				miDebuggerPath = "/usr/bin/gdb",
				cwd = "${workspaceFolder}",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
			},
		}
		dap.configurations.c = dap.configurations.cpp
		-- vim.fn.sign_define("DapBreakpoint", { text = "🐞" })

		-- Start debugging session:
		-- Note that modifiers on F keys can be handled differently on different systems.
		-- In order to get correct values, press C^v in the insert mode and then desired combo.
		vim.keymap.set("n", "<F21>", function() -- <S-F9>
			dap.continue()
			ui.toggle({})
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>=", false, true, true), "n", false) -- Spaces buffers evenly
		end)

		-- Set breakpoints, get variable values, step into/out of functions, etc.
		vim.keymap.set("n", "<F25>", require("dap.ui.widgets").hover) -- <C-F1>
		vim.keymap.set("n", "<F9>", dap.continue)
		vim.keymap.set("n", "<F32>", dap.toggle_breakpoint) -- <C-F8>
		vim.keymap.set("n", "<F8>", dap.step_over)
		vim.keymap.set("n", "<F7>", dap.step_into)
		vim.keymap.set("n", "<F20>", dap.step_out) -- <S-F8>
		vim.keymap.set("n", "<leader>dc", function()
			dap.clear_breakpoints()
			require("notify")("Breakpoints cleared", "warn")
		end)

		-- Close debugger and clear breakpoints
		vim.keymap.set("n", "<F26>", function() -- <C-F2>
			dap.clear_breakpoints()
			ui.toggle({})
			dap.terminate()
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>=", false, true, true), "n", false)
			require("notify")("Debugger session ended", "warn")
		end)

		-- DAP mappings
		local map = require("helpers.keys").map
		map("n", "<leader>dt", require("dapui").toggle, "Toggle debugger")

		require("nvim-dap-virtual-text").setup({
			all_references = true, -- show virtual text on all all references of the variable (not only definitions)
			highlight_changed_variables = false, -- do not highlight changed values with NvimDapVirtualTextChanged
		})
	end,
}
