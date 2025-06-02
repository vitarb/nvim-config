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
│   └── plugins.lua       # plugin list (empty for now)
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

This configuration intentionally stays tiny. Beyond the minimal plugin manager,
there are no extra plugins or language-specific tools configured yet. When new
plugins or language integrations are added, they will be documented here.

### Common hotkeys

No custom mappings are provided; all stock Neovim keys work as usual.

## Development

### Why keep the tool-chain here?

- **Deterministic builds** – `bootstrap.py` downloads the exact Neovim version
  and sets it up under `./.tools/bin`【F:bootstrap.py†L7-L23】.
- **Offline verification** – once `make offline` finished, `smoke` and `test`
  run without network access.
- **CI guard** – `.github/workflows/test.yml` repeats that sequence so broken
  offline builds are rejected【F:.github/workflows/test.yml†L18-L37】.

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

| Target          | Description                                                      |
|-----------------|------------------------------------------------------------------|
| `offline`       | Bootstrap Neovim and plugins (skipped with `OFFLINE=1`)【F:Makefile†L6-L14】 |
| `smoke`         | Headless start; prints `SMOKE OK` on success【F:Makefile†L16-L20】 |
| `test`          | Headless full config test; fails on any error【F:Makefile†L23-L30】 |
| `clean`         | Remove downloaded tools and caches【F:Makefile†L32-L36】 |
| `docker-image`  | Build dev image (Ubuntu 22.04)【F:Makefile†L38-L45】 |

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
variables set【F:.github/workflows/test.yml†L18-L37】. If any target fails,
CI blocks the change.

