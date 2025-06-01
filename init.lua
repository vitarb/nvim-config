if os.getenv("NVIM_OFFLINE_BOOT") == "1" then return end

-- Handle plugins with lazy.nvim
require("core.lazy")

-- General Neovim keymaps
require("core.keymaps")

-- Other options
require("core.options")
