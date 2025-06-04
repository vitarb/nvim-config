# Neovim mini-config (offline friendly)

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
- **nvim-telescope/telescope.nvim** – fuzzy finder powered by plenary
- **nvim-lualine/lualine.nvim** – sleek status line
- **nvim-tree/nvim-tree.lua** – simple file explorer
- **akinsho/bufferline.nvim** – tab-like buffer list

Additional plugins or language integrations will be documented here.

### Common hotkeys

* `<C-n>` – Find files
* `<leader>o` – Document symbols
* `<C-e>` – Recent files
* `<leader>s` – Search project
* `'1` – Toggle file explorer
* `'j` – Next buffer
* `'k` – Previous buffer
* `'q` – Close buffer
* `'Q` – Close all but current
* `'h` – Move buffer left
* `'l` – Move buffer right
* `<leader>w` – Save file
* `<leader>x` – Close window
* `<leader>/` – Toggle comment line
* `<leader>c` – Copy to clipboard
* `<leader>v` – Paste from clipboard
* `<C-x>` – Exit Vim

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
| `lint`          | Run Stylua and ShellCheck |
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

