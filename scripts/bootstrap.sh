#!/usr/bin/env bash
set -euo pipefail

##############################################################################
# Paths & versions
##############################################################################
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

NVIM_VERSION="v0.11.2"                 # bump when upgrading Neovim
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS:$ARCH" in
  Linux:x86_64)  ASSET="nvim-linux-x86_64.tar.gz" ;;
  Linux:aarch64) ASSET="nvim-linux-arm64.tar.gz"  ;;
  Darwin:x86_64) ASSET="nvim-macos-x86_64.tar.gz" ;;
  Darwin:arm64)  ASSET="nvim-macos-arm64.tar.gz"  ;;
  *) echo "[bootstrap] Unsupported platform: $OS/$ARCH" >&2; exit 1 ;;
esac

NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${ASSET}"

TOOLS="$ROOT/.tools"
NVIM_DIR="$TOOLS/nvim"
BIN_DIR="$TOOLS/bin"
NVIM_BIN="$BIN_DIR/nvim"

##############################################################################
# Keep *all* Neovim state under .tools/  (swap, cache, etc.)
##############################################################################
export XDG_DATA_HOME="$TOOLS/data"
export XDG_STATE_HOME="$TOOLS/state"
export XDG_CACHE_HOME="$TOOLS/cache"
mkdir -p "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

# So that core.{lazy,keymaps,…} are found before plugins are loaded
export LUA_PATH="$ROOT/lua/?.lua;$ROOT/lua/?/init.lua;;"

say() { printf "\e[1;34m[bootstrap]\e[0m %s\n" "$*"; }

mkdir -p "$NVIM_DIR" "$BIN_DIR"

##############################################################################
# 1. Fetch & extract Neovim (cached)
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
  [[ -n $FOUND_BIN ]] || { echo "[bootstrap] nvim binary not found" >&2; exit 1; }
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
# 2. Everything (Lazy + Mason) in **one** headless run
##############################################################################
say "Syncing plugins & installing tools…"

lua_code=$(mktemp)
cat >"$lua_code" <<'LUA'
--------------------------------------------------------------------------------
-- 0. Helpers
--------------------------------------------------------------------------------
local function pkg_busy(pkg)
  if pkg.is_busy then        -- Mason ≤ v1.9
    return pkg:is_busy()
  elseif pkg.is_installing then -- Mason ≥ v2.0
    return pkg:is_installing()
  end
  return false
end
--------------------------------------------------------------------------------
-- 1. Sync Lazy (blocks until done, incl. nvim-treesitter compiles)
--------------------------------------------------------------------------------
require('lazy').sync{ wait = true }

--------------------------------------------------------------------------------
-- 2. Mason: ensure required packages
--------------------------------------------------------------------------------
pcall(function() require('mason').setup() end)
local registry = require('mason-registry')
registry.refresh()

local want = {
  -- LSP
  'lua-language-server','clangd','gopls','python-lsp-server','rust-analyzer',
  -- DAP
  'codelldb','delve',
  -- Formatters / linters
  'clang-format','stylua','jq','rustfmt','gofumpt','goimports',
}

-- Start installs if necessary
for _, name in ipairs(want) do
  local pkg = registry.get_package(name)
  if not pkg:is_installed() and not pkg_busy(pkg) then
    pkg:install()
  end
end

-- Wait (max 15 min) until every wanted package is installed
local deadline = os.time() + 900
while os.time() < deadline do
  local all_done = true
  for _, name in ipairs(want) do
    local pkg = registry.get_package(name)
    if not pkg:is_installed() or pkg_busy(pkg) then
      all_done = false
      break
    end
  end
  if all_done then break end
  vim.wait(250)   -- 0.25 s
end

-- Verify
for _, name in ipairs(want) do
  if not registry.get_package(name):is_installed() then
    error("Mason install failed for "..name)
  end
end
LUA

"$NVIM_BIN" --headless \
  --cmd "set rtp^=$ROOT packpath^=$ROOT" \
  -u "$ROOT/init.lua" +"luafile $lua_code" +'qa'

rm -f "$lua_code"

say "✅ bootstrap complete"


