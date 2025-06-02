#!/usr/bin/env bash
set -euo pipefail

##############################################################################
# Paths & versions
##############################################################################
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

NVIM_VERSION="v0.11.2"                 # update here when bumping Neovim
OS="$(uname -s)"
ARCH="$(uname -m)"

# ── map uname → asset suffix ────────────────────────────────────────────────
case "$OS:$ARCH" in
  Linux:x86_64)   ASSET="nvim-linux-x86_64.tar.gz" ;;
  Linux:aarch64)  ASSET="nvim-linux-arm64.tar.gz"  ;;
  Darwin:x86_64)  ASSET="nvim-macos-x86_64.tar.gz" ;;
  Darwin:arm64)   ASSET="nvim-macos-arm64.tar.gz"  ;;
  *)
    echo "[bootstrap] Unsupported platform: $OS $ARCH" >&2
    exit 1
    ;;
esac

NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${ASSET}"

TOOLS="$ROOT/.tools"
NVIM_DIR="$TOOLS/nvim"                 # holds archives & extracted dirs
BIN_DIR="$TOOLS/bin"
NVIM_BIN="$BIN_DIR/nvim"

say() { printf "\e[1;34m[bootstrap]\e[0m %s\n" "$*"; }

mkdir -p "$NVIM_DIR" "$BIN_DIR"

##############################################################################
# 1. Download & extract Neovim once
##############################################################################
STAMP="$NVIM_DIR/.installed-${NVIM_VERSION}-${ASSET}"
ARCHIVE="$NVIM_DIR/$ASSET"

if [[ ! -f $STAMP ]]; then
  say "Fetching Neovim $NVIM_VERSION for $OS/$ARCH …"
  curl -Lf --retry 3 -o "$ARCHIVE" "$NVIM_URL"

  say "Extracting …"
  # clean previous extraction of any version
  rm -rf "$NVIM_DIR/extracted"
  mkdir -p "$NVIM_DIR/extracted"
  tar -xzf "$ARCHIVE" -C "$NVIM_DIR/extracted"

  # find the freshly-unpacked nvim binary
  FOUND_BIN=$(find "$NVIM_DIR/extracted" -path '*/bin/nvim' -type f | head -n1)
  if [[ -z $FOUND_BIN ]]; then
    echo "[bootstrap] nvim binary not found inside archive" >&2
    exit 1
  fi
  ln -sf "$FOUND_BIN" "$NVIM_BIN"
  touch "$STAMP"
else
  say "Neovim cached – skipping download"
  # ensure symlink still exists
  [[ -x $NVIM_BIN ]] || {
    FOUND_BIN=$(find "$NVIM_DIR/extracted" -path '*/bin/nvim' -type f | head -n1)
    ln -sf "$FOUND_BIN" "$NVIM_BIN"
  }
fi

##############################################################################
# Helper: run headless nvim with repo init.lua
##############################################################################
nvim_h() {
  "$NVIM_BIN" --headless \
    --cmd "set rtp^=${ROOT} packpath^=${ROOT}" \
    -u "$ROOT/init.lua" +"$1" +qa
}

##############################################################################
# 2. Sync Lazy plugins
##############################################################################
say "Syncing Lazy plugins …"
nvim_h $'lua local ok,err=pcall(function() require("lazy").sync{wait=true} end)
       if not ok then vim.api.nvim_err_writeln(err); vim.cmd("cquit 1") end'

##############################################################################
# 3. Install Mason packages (blocking, errors downgraded to warnings)
##############################################################################
say "Installing Mason packages …"

tmp_lua="$(mktemp)"
cat >"$tmp_lua" <<'LUA'
pcall(function() require('mason').setup() end)
require('mason-registry').refresh()

local want = {
  -- LSP servers
  'lua-language-server', 'clangd', 'gopls',
  'python-lsp-server', 'rust-analyzer',
  -- DAP adapters
  'codelldb', 'delve',
  -- formatters / linters
  'clang-format', 'stylua', 'jq', 'rustfmt', 'gofumpt', 'goimports',
}

local ok, err = pcall(vim.cmd, 'MasonInstall --sync ' .. table.concat(want, ' '))
if not ok then
  io.stderr:write(('MasonInstall error: %s\n'):format(err))
  os.exit(1)
end
LUA

nvim_h "luafile $tmp_lua"
rm -f "$tmp_lua"

say "✅ bootstrap complete"

