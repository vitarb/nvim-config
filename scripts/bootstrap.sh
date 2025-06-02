#!/usr/bin/env bash
set -euo pipefail

##############################################################################
# Paths & versions
##############################################################################
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

NVIM_VERSION="v0.11.2"                 # bump here when upgrading Neovim
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS:$ARCH" in
  Linux:x86_64)   ASSET="nvim-linux-x86_64.tar.gz" ;;
  Linux:aarch64)  ASSET="nvim-linux-arm64.tar.gz"  ;;
  Darwin:x86_64)  ASSET="nvim-macos-x86_64.tar.gz" ;;
  Darwin:arm64)   ASSET="nvim-macos-arm64.tar.gz"  ;;
  *)  echo "[bootstrap] Unsupported platform: $OS/$ARCH" >&2; exit 1 ;;
esac
NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${ASSET}"

TOOLS="$ROOT/.tools"
NVIM_DIR="$TOOLS/nvim"                 # archives & extracted dirs live here
BIN_DIR="$TOOLS/bin"
NVIM_BIN="$BIN_DIR/nvim"

: "${GOPROXY:=direct}"
export GOPROXY

say() { printf "\e[1;34m[bootstrap]\e[0m %s\n" "$*"; }

mkdir -p "$NVIM_DIR" "$BIN_DIR"

##############################################################################
# 1. Download & extract Neovim (cached)
##############################################################################
STAMP="$NVIM_DIR/.installed-${NVIM_VERSION}-${ASSET}"
ARCHIVE="$NVIM_DIR/$ASSET"

if [[ ! -f $STAMP ]]; then
  say "Fetching Neovim $NVIM_VERSION ($ASSET)…"
  curl -Lf --retry 3 -o "$ARCHIVE" "$NVIM_URL"

  say "Extracting…"
  rm -rf "$NVIM_DIR/extracted"
  mkdir -p "$NVIM_DIR/extracted"
  tar -xzf "$ARCHIVE" -C "$NVIM_DIR/extracted"

  FOUND_BIN=$(find "$NVIM_DIR/extracted" -path '*/bin/nvim' -type f | head -n1)
  [[ -n $FOUND_BIN ]] || { echo "[bootstrap] nvim binary not found in archive" >&2; exit 1; }
  ln -sf "$FOUND_BIN" "$NVIM_BIN"
  touch "$STAMP"
else
  say "Neovim cached – skipping download"
  [[ -x $NVIM_BIN ]] || {
    FOUND_BIN=$(find "$NVIM_DIR/extracted" -path '*/bin/nvim' -type f | head -n1)
    ln -sf "$FOUND_BIN" "$NVIM_BIN"
  }
fi

##############################################################################
# Helper: run headless nvim with repo on the runtimepath
##############################################################################
nvim_h() {
  "$NVIM_BIN" --headless \
    --cmd "set rtp^=${ROOT} packpath^=${ROOT}" \
    -u "$ROOT/init.lua" +"$1" +qa >/dev/null
}

##############################################################################
# 2. Sync Lazy plugins (+treesitter, etc.)
##############################################################################
say "Syncing Lazy plugins…"
nvim_h "lua require('lazy').sync{wait=true}; local s=require('lazy').stats(); if s.errors and #s.errors>0 then error('Lazy sync had errors') end"

##############################################################################
# 3. Install Mason packages (blocking, fail-on-error)
##############################################################################
say "Installing Mason packages…"

tmp_lua="$(mktemp)"
cat >"$tmp_lua" <<'LUA'
-- ensure the Mason plugin is **loaded** (Lazy keeps most plugins event-lazy)
local lazyOk, lazy = pcall(require, 'lazy')
if not lazyOk then
  error('lazy.nvim not found on runtimepath')
end
lazy.load({ plugins = { 'mason.nvim', 'mason-lspconfig.nvim', 'mason-nvim-dap.nvim' }, wait = true })

-- now Mason is available:
local masonOk, mason = pcall(require, 'mason')
if not masonOk then
  error('mason.nvim failed to load even after lazy.load()')
end
mason.setup()

local registryOk, registry = pcall(require, 'mason-registry')
if not registryOk then
  error('mason-registry module not found – is mason.nvim installed?')
end
registry.refresh()

local want = {
  -- LSP servers
  'lua-language-server', 'clangd', 'gopls',
  'python-lsp-server', 'rust-analyzer',
  -- DAP adapters
  'codelldb', 'delve',
  -- formatters / linters
  'clang-format', 'stylua', 'jq', 'rustfmt', 'gofumpt', 'goimports',
}

-- synchronously install everything; abort on any failure
local ok, err = pcall(vim.cmd, 'MasonInstall --sync ' .. table.concat(want, ' '))
if not ok then
  error(('MasonInstall failed: %s'):format(err))
end
LUA

# any non-zero exit bubbles up thanks to `set -e`
nvim_h "luafile $tmp_lua"
rm -f "$tmp_lua"

say "✅ bootstrap complete"

