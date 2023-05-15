# nvim-config

Nvim configuration for software development that uses lazy plugin manager.
Code navigation hotkeys are inspired by Intellij.
```
├──  lua
│   ├──  core
│   │   ├──  keymaps.lua           -- global key mappings
│   │   ├──  lazy.lua              -- lazy config and leader key
│   │   └──  options.lua           -- global options
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

# Shortcuts

Here are some common (non standard) shortcuts for a quick start:
* `<C-n>` - search and open files  
* `<C-e>` - open buffers
* `<C-f>` - grep project files
* `<C-b>` - go to definition
* `<C-M-b>` - go to references
* `<C-p>` - function parameters
* `<C-q>` - quick help
* `<C-space>` - quick completion (using omnifunction)
* `<leader><leader>` - LSP fuzzy search in the current buffer (for quick jump to function or variable).
* `<F12>` - File structure outline
* `<F11>` - Toggle zen mode
* Arrow keys - move between open windows
* `H`/`L` - navigate left/right through open buffers.
* `<C-c>` - close current window.
* `<leader>o` - close all windows except current.
* `<C-x>` - quick exit
* `<C-s>` - quick save
* `<C-/>` - comment line

Other plugin specific shortcuts can be located in corresponding plugins lua files and core/keymaps.lua
