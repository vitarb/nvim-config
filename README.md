# nvim-config

Nvim configuration for software development that uses lazy plugin manager and LSP integration for code actions.
Code navigation hotkeys are mostly inspired by Intellij.

List of configured languages (can be easily extended):
* C/C++ (requires compile_commands.json for clangd, consider using [bear](https://github.com/rizsotto/Bear) to auto-generate this file from make commands)
* Rust
* Go
* Python
* Lua

Configuration includes language server, code formatting, debugging support and git integration.

```
├──  lua
│   ├──  core
│   │   ├──  keymaps.lua           -- global key mappings
│   │   ├──  lazy.lua              -- lazy config and leader key
│   │   └──  options.lua           -- global options
│   ├──  helpers
│   │   ├──  buffers.lua
│   │   ├──  colorscheme.lua
│   │   └──  keys.lua
│   └──  plugins                  -- Plugin configurations (auto loaded by lazy)    
│       ├──  bufferline.lua        -- Tabs at the top of the screen
│       ├──  cmp.lua               -- Code completion
│       ├──  comment.lua           -- Commenting in the code
│       ├──  git.lua               -- Git plugins
│       ├──  hop.lua               -- Fast navigation inside of the buffer
│       ├──  lsp.lua               -- Language servers and code navigation hotkeys
│       ├──  lualine.lua           -- Status line
│       ├──  misc.lua              -- Some small plugins that don't require much configuration
│       ├──  neo-tree.lua          -- Project tree
│       ├──  null-ls.lua           -- LSP diagnostics, code actions
│       ├──  nvim-autopairs.lua    -- Automatically add matching brackets, quotes, etc.
│       ├──  nvim-dap.lua          -- Debug Adapter Protocol client implementation for Neovim.
│       ├──  nvim-surround.lua     -- Surround text with brackets or quotes.
│       ├──  symbols-outline.lua   -- File structure outline with functions and variables.
│       ├──  telescope.lua         -- Search files, buffers, grep and more.
│       ├──  themes.lua            -- Themes
│       ├──  toggleterm.lua        -- Integrated terminal
│       ├──  treesitter.lua        -- File structure awareness.
│       └──  which-key.lua         -- Displays a popup with possible key bindings of the command you started typing.
```

# Installation
## Requirements
* NVIM ≥ 0.10.0 is recommended (this config targets 0.10+; pin to 0.9.5 if you prefer stability)
  (see [installation instructions](https://github.com/neovim/neovim/wiki/Installing-Neovim)). Older builds may fail.
* lazygit for better git experience (see [installation instructions](https://github.com/jesseduffield/lazygit#installation))

## Steps
* [optional] Backup your current nvim config 
```
mv ~/.config/nvim/ ~/.config/nvim.bak
```
* Clone this repo into `~/.config/nvim`
```
git clone https://github.com/vitarb/nvim-config.git ~/.config/nvim
```
* launch nvim (Do not forget to create alias that maps vim to nvim in your shell otherwise you might be launching vanilla vim) -
lazy plugin manager should download and setup all plugins and tools automatically.
## Offline smoke test
After cloning, run `make smoke`.
It launches Neovim head-less with plugins disabled via `NVIM_OFFLINE_BOOT=1` and should print "SMOKE OK".

## Running full bootstrap
The bootstrap script places a private copy of Neovim under `.tools/bin`.  Optionally add it to your PATH:
```
export PATH="$(pwd)/.tools/bin:$PATH"
```
To fetch Neovim and all tools in advance (requires internet):
```
make setup-offline
```

Refresh plugins and tools on demand:
```
UPDATE=1 make setup-offline
```

Offline rebuilds can then use:
```
OFFLINE=1 make smoke
```


# Pros&Cons vs IDE
Similar:
* Editor capabilities - navigation, code completion, search, file structure, 
* Language support - by plugging in relevant language server you enable support for indexing, navgiation and basic refactorings.
* Git integration - thanks to lazygit (must be installed separately), you get nice git UI.
* Debugging - nvim-dap enables seamless integration with modern debuggers.

Pros:
* Consistency - same setup for all programming languages, no need to install new tools, just add language servers.
* Free - you can have same setup at work and at home without having to worry about recurring fees.
* Lightweight - doesn't require X server, can run on a remote machine via ssh or in docker container.
* Speed - most operations are much faster than in the IDE.
* Customizable - sky is the limit, especially if you are ready to write your own plugins.
* Incremental setup - you can gradually evolve your setup over time.
* Cool factor - your IDE is in your terminal, not the other way around.

Cons:
* Learning curve - somewhat high upfront investment is required to learn plugin ecosystem and relevant shortcuts.
* Refactorings - propriatory tools (especially Intellij) have better refactoring capabilities.
* Git conflict resolution - lazygit is nice, but Intellij's conflict resolution tool's magic wand button is unmatched.

# Shortcuts

Here are some common (non standard) shortcuts for a quick start (C - Control, M - Alt/Meta, S - Shift, leader - vim leader key):
## Help
* `<F1>` - interactive help menu for all shortcuts.
* `:help` - standard vim help.
## Navigation
* `<C-n>` - search and open files  
* `<C-e>` - open buffers
* `<C-f>` - grep project files
* `<C-b>` - go to definition
* `<C-M-b>` - go to references
* `<C-p>` - function parameters
* `<C-q>` - quick help
* `<M-F7>` - incoming calls
* `<leader><leader>` - LSP fuzzy search in the current buffer (for quick jump to function or variable).
* `<leader>j` - Toggle project tree

## Windows and buffers
* `← ↓ ↑ →` - move between open windows
* `H`/`L` - navigate left/right through open buffers
* `<leader>o` - Only keep current window, close the rest
* `<C-c>` - close current window

## Project management
* `<F12>` - File structure outline
* `<M-F12>` - Toggle terminal
* `<C-k>` - Lazy git dialogue (see lazygit [installation](https://github.com/jesseduffield/lazygit#installation))
* `<C-M-l>` - Format entire file (or selected block)
* `<F11>` - Toggle zen mode
* `<C-x>` - quick exit
* `<C-s>` - quick save
* `<C-/>` - comment line (works in visual mode too)
* `<M-k>`/`<M-j>` - move line(s) up/down

## Code actions
* `<S-F6>` - Rename symbol
* `<C-space>` - quick completion (using omnifunction)
* `<leader>space`- LSP code actions.

## Debugging
* `<S-F9>`- Start debugging
* `<C-F8>`- Toggle breakpoint
* `<F7>` - step into
* `<F8>` - step over
* `<S-F8>` - step out
* `<F9>` - continue
* `<C-F2>` - terminate session

Other plugin specific shortcuts can be located in corresponding plugins lua files and core/keymaps.lua
