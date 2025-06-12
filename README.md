# Neovim mini-config

A tiny Neovim configuration with its own pinned binary.  Everything lives in
this repository so a clone can be bootstrapped and tested without Internet
access.  Continuous integration repeats the same steps to ensure the setup
remains reproducible.

```
.
├── bootstrap.py          # one-shot downloader for Neovim
├── Makefile              # offline/smoke/test helpers
├── init.lua              # entry point
├── lua/
│   ├── core/lazy.lua     # minimal plugin manager
│   └── plugins.lua       # starter plugin list
├── scripts/
│   ├── smoke_test.sh     # quick check
│   └── test.sh           # full headless test
└── .github/workflows/
    └── test.yml          # CI verifying the same steps
```

# Usage

Clone this repository anywhere and point Neovim to it.  The typical approach is
to make it your `$HOME/.config/nvim`:

```bash
git clone https://github.com/yourname/nvim-config.git ~/.config/nvim
```

You can also keep the repo elsewhere and symlink it:

```bash
ln -s /path/to/nvim-config ~/.config/nvim
```

After bootstrap (see the *Development* section) the repo provides its own
Neovim binary under `./.tools/bin/nvim`.

To make it your system-wide `nvim` either run the binary directly or place a
symlink somewhere in your `PATH`:

```bash
ln -s /path/to/nvim-config/.tools/bin/nvim ~/bin/nvim
```

### Plugins and language support

This configuration intentionally stays tiny. A handful of popular plugins are bundled out of the box:

- **nvim-treesitter/nvim-treesitter** – Modern syntax highlighting (and more)
- **rebelot/kanagawa.nvim** – Japanese-themed color scheme
- **nvim-telescope/telescope.nvim** – fuzzy finder powered by plenary
- **nvim-lualine/lualine.nvim** – sleek status line
- **nvim-tree/nvim-tree.lua** – simple file explorer
- **akinsho/bufferline.nvim** – tab-like buffer list
- **lewis6991/gitsigns.nvim** – Git decorations
- **folke/which-key.nvim** – displays available keybindings
- **echasnovski/mini.nvim** – icon library used by which-key
- **lukas-reineke/indent-blankline.nvim** – indentation guides
- **stevearc/conform.nvim** – auto formatting framework
- **williamboman/mason.nvim** – LSP package manager
- **williamboman/mason-lspconfig.nvim** – Mason integration for LSP
- **neovim/nvim-lspconfig** – built-in LSP configurations

Additional plugins or language integrations will be documented here.

### Language-Server Integration

`mason.nvim` auto-installs servers for Go, Rust, Python, Lua, and TypeScript.
LSP provides diagnostics, *Go to definition*, *Hover*, code actions, rename and
more out of the box. Extra hotkeys below expose these features.

### Editor behaviour

Line numbers (absolute and relative) are enabled by default.
Undo history persists across sessions, and yanked text briefly highlights using the built-in `IncSearch` group.
Diagnostics are disabled by default; press `<leader>dd` to cycle between none, virtual text, and signs.

### Common hotkeys

* `<C-n>` – Find files
* `<leader><leader>` – Outline / symbols
* Press `<leader>` to see all bindings (powered by *which-key*)
* `K` – Hover docs
* `gd` – Jump to definition
* `gr` – References (Telescope)
* `gR` – Rename symbol
* `<leader>a` – Code actions
* `<C-e>` – Open buffers
* `<C-f>` – Search project
* `<leader>ff` – Find files
* `<leader>fg` – Live grep
* `<leader>1` – Toggle file explorer
* `<leader>j` – Next buffer
* `<leader>k` – Previous buffer
* `<C-Tab> / <C-S-Tab>` – Next / previous buffer
* `<leader>q` – Close buffer
* `<leader>Q` – Close all but current
* `<leader>h` – Move buffer left
* `<leader>l` – Move buffer right
* `<leader>dd` – Cycle diagnostics (off by default)
* `<leader>w` – Save file
* `<leader>x` – Close window
* `<leader>/` – Toggle comment line
* `<leader>c` – Copy to clipboard
* `<leader>v` – Paste from clipboard
* `<C-x>` – Exit without saving
* `<leader>;` – Cycle color variants
* `<leader>gh` – Stage Git hunk
* `<leader>gl` – Reset Git hunk
* `<leader>gp` – Preview Git hunk
* Use stock `Ctrl-w` motions for splits

## Development

### Why keep the tool-chain here?

- **Deterministic builds** – `bootstrap.py` downloads the exact Neovim version
  and sets it up under `./.tools/bin`.
- **Offline verification** – once `make offline` finished, `smoke` and `test`
  run without network access.
- **CI guard** – `.github/workflows/test.yml` repeats that sequence so broken
  offline builds are rejected.

### Local user

```bash
# clone and bootstrap with Internet
git clone <this repo> nvim-config
cd nvim-config
make offline             # downloads Neovim and the plugin manager

# afterwards you can work without network
OFFLINE=1 make smoke     # quick binary check
OFFLINE=1 make test      # full headless test
```

Launch Neovim via `./.tools/bin/nvim` or continue using `nvim` from your PATH
after linking it as shown above.

### Headless agent (no Internet)

When cloning in an environment without network, skip the bootstrap and only run
offline targets:

```bash
OFFLINE=1 make smoke
OFFLINE=1 make test
```

## Make targets

| Target          | Description |
|-----------------|-------------------------------------------------------------|
| `offline`       | Bootstrap Neovim and plugins (skipped with `OFFLINE=1`) |
| `smoke`         | Headless start; prints `SMOKE OK` on success |
| `test`          | Headless full config test; fails on any error |
| `lint`          | Run Luacheck, Stylua and ShellCheck |
| `clean`         | Remove downloaded tools and caches |
| `docker-image`  | Build dev image (Ubuntu 22.04) |

You can run any of these inside Docker by prefixing `DOCKER=1`.

## Docker workflow

The optional Dockerfile provides all build tools. Use:

```bash
DOCKER=1 make offline  # builds inside the container
DOCKER=1 make test
```

## CI

GitHub Actions performs the same bootstrap and offline tests:
`make offline` once online, then `make smoke` and `make test` with `OFFLINE=1`
variables set. If any target fails,
CI blocks the change.

Optionally install [pre-commit](https://pre-commit.com/) to run the same linters automatically: `pip install pre-commit && pre-commit install`.

