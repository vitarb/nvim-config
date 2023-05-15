# nvim-config

Nvim configuration for software development that uses lazy plugin manager.
Code navigation hotkeys are inspired by Intellij.
```
├──  lua
│   ├──  core
│   │   ├──  keymaps.lua       -- global key mappings
│   │   ├──  lazy.lua          -- lazy config and leader key
│   │   └──  options.lua       -- global options
│   ├──  helpers
│   │   ├──  buffers.lua
│   │   ├──  colorscheme.lua
│   │   └──  keys.lua
│   └──  plugins                   -- Plugin configurations (auto loaded by lazy)    
│       ├──  bufferline.lua        -- Tabs at the top of the screen
│       ├──  cmp.lua               -- Code completion
│       ├──  comment.lua           -- Commenting in the code
│       ├──  git.lua               -- Git plugins
│       ├──  harpoon.lua           -- Fast navigation between selected buffers
│       ├──  hop.lua               -- Fast navigation inside of the buffer
│       ├──  lsp.lua               -- Language servers and code navigation hotkeys
│       ├──  lualine.lua           -- Status line
│       ├──  misc.lua              -- Some small plugins that don't require much configuration
│       ├──  neo-tree.lua          -- Project tree
│       ├──  null-ls.lua           -- LSP diagnostics, code actions
│       ├──  nvim-autopairs.lua    -- Automatically add matching brackets, quotes, etc.
│       ├──  nvim-surround.lua     -- Surround text with brackets or quotes.
│       ├──  symbols-outline.lua   -- File structure outline with functions and variables.
│       ├──  telescope.lua         -- Search files, buffers, grep and more.
│       ├──  themes.lua            -- Themes
│       ├──  treesitter.lua        -- File structure awareness.
│       ├──  which-key.lua         -- Displays a popup with possible key bindings of the command you started typing.
│       └──  zen.lua               -- Zen mode for coding with no distractions.
```
