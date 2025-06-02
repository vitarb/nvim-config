#!/usr/bin/env bash
set -euo pipefail

##############################################################################
# Paths & versions
##############################################################################
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

NVIM_VERSION="v0.10.0"
NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage"

TOOLS="$ROOT/.tools"
NVIM_DIR="$TOOLS/nvim"
NVIM_APP="$NVIM_DIR/nvim.appimage"
BIN_DIR="$TOOLS/bin"
NVIM_BIN="$BIN_DIR/nvim"

say() { printf "\e[1;34m[bootstrap]\e[0m %s\n" "$*"; }

mkdir -p "$NVIM_DIR" "$BIN_DIR"

##############################################################################
# 1. Download Neovim once
##############################################################################
if [[ ! -x $NVIM_APP ]]; then
  say "Downloading Neovim …"
  curl -L --retry 3 -o "$NVIM_APP" "$NVIM_URL"
  chmod +x "$NVIM_APP"
fi

##############################################################################
# 2. Make Neovim runnable even if FUSE is missing
##############################################################################
if "$NVIM_APP" --version >/dev/null 2>&1; then
  # FUSE present – use AppImage as-is
  say "Neovim AppImage runnable (FUSE present)"
  ln -sf "$NVIM_APP" "$NVIM_BIN"
else
  # FUSE absent – extract once, then point NVIM_BIN at the inner nvim
  say "FUSE not available – extracting AppImage …"
  EXTRACT_DIR="$NVIM_DIR/extracted"
  if [[ ! -d $EXTRACT_DIR/squashfs-root ]]; then
    mkdir -p "$EXTRACT_DIR"
    (cd "$EXTRACT_DIR" && "$NVIM_APP" --appimage-extract >/dev/null)
  fi
  ln -sf "$EXTRACT_DIR/squashfs-root/usr/bin/nvim" "$NVIM_BIN"
fi

##############################################################################
# Helper: run headless nvim with repo init.lua
##############################################################################
nvim_h() { \
  "$NVIM_BIN" --headless \
    -u "$ROOT/init.lua" \
    --cmd "set runtimepath+=${ROOT}" \
    +"$1" +qa; }

##############################################################################
# 3. Sync Lazy plugins
##############################################################################
say "Syncing Lazy plugins …"
nvim_h "lua require('lazy').sync{wait=true}"

##############################################################################
# 4. Install Mason packages (blocking, errors downgraded to warnings)
##############################################################################
say "Installing Mason packages …"

tmp_lua="$(mktemp)"
cat >"$tmp_lua" <<'LUA'
pcall(function() require('mason').setup() end)        -- ensure Mason initialised
require('mason-registry').refresh()                  -- fresh index

local want = {
  -- LSP servers
  'lua-language-server', 'clangd', 'gopls',
  'python-lsp-server', 'rust-analyzer',
  -- DAP adapters
  'codelldb', 'delve',
  -- Formatters / linters
  'clang-format', 'stylua', 'jq', 'rustfmt', 'gofumpt', 'goimports',
}

local cmd = 'MasonInstall --sync ' .. table.concat(want, ' ')
local ok, err = pcall(vim.cmd, cmd)
if not ok then
  vim.notify(('MasonInstall warning: %s'):format(err), vim.log.levels.WARN)
end
LUA

nvim_h "luafile $tmp_lua"
rm -f "$tmp_lua"

say "✅ bootstrap complete"

