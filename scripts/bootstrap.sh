#!/usr/bin/env bash
set -euo pipefail

##############################################################################
# Paths & versions
##############################################################################
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

NVIM_VERSION="v0.11.2"
OS="$(uname -s)"; ARCH="$(uname -m)"
case "$OS:$ARCH" in
  Linux:x86_64)   ASSET="nvim-linux-x86_64.tar.gz" ;;
  Linux:aarch64)  ASSET="nvim-linux-arm64.tar.gz"  ;;
  Darwin:x86_64)  ASSET="nvim-macos-x86_64.tar.gz" ;;
  Darwin:arm64)   ASSET="nvim-macos-arm64.tar.gz"  ;;
  *) echo "[bootstrap] Unsupported platform $OS/$ARCH" >&2; exit 1 ;;
esac
NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${ASSET}"

TOOLS="$ROOT/.tools"
NVIM_DIR="$TOOLS/nvim"
BIN_DIR="$TOOLS/bin"
NVIM_BIN="$BIN_DIR/nvim"

say() { printf '\e[1;34m[bootstrap]\e[0m %s\n' "$*"; }

mkdir -p "$NVIM_DIR" "$BIN_DIR"

##############################################################################
# 1.  Neovim binary (cached download + extract)
##############################################################################
STAMP="$NVIM_DIR/.installed-${NVIM_VERSION}-${ASSET}"
ARCHIVE="$NVIM_DIR/$ASSET"

if [[ ! -f $STAMP ]]; then
  say "Fetching Neovim $NVIM_VERSION …"
  curl -Lf --retry 3 -o "$ARCHIVE" "$NVIM_URL"

  say "Extracting …"
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
# 2.  Helper to run head-less Neovim in this repo
##############################################################################
nvim_h() {
  "$NVIM_BIN" --headless \
    --cmd "set rtp^=${ROOT} packpath^=${ROOT}" \
    --cmd "lua package.path='${ROOT}/lua/?.lua;${ROOT}/lua/?/init.lua;'..package.path" \
    -u "$ROOT/init.lua" +"$1" +qa >/dev/null
}

die_lua='local function die(msg) vim.api.nvim_err_writeln(msg); vim.cmd("cquit 1") end'

##############################################################################
# 3.  Lazy sync (fail-fast)
##############################################################################
say "Syncing Lazy plugins …"
sync_lua=$(mktemp)
cat >"$sync_lua" <<LUA
${die_lua}
local ok, err = pcall(function() require('lazy').sync{wait=true} end)
if not ok then die('Lazy sync failed: '..err) end
local stat = require('lazy').stats()
if stat.errors and #stat.errors > 0 then
  die('Lazy reported '..#stat.errors..' plugin error(s)')
end
LUA
nvim_h "luafile $sync_lua"; rm -f "$sync_lua"

##############################################################################
# 4.  Mason packages (respect host tool-chain)
##############################################################################
say "Installing Mason packages …"
mason_lua=$(mktemp)
cat >"$mason_lua" <<'LUA'
local function die(msg)
  vim.api.nvim_err_writeln(msg)
  vim.cmd('cquit 1')
end

pcall(function() require('mason').setup() end)
local ok, registry = pcall(require, 'mason-registry')
if not ok then die('mason-registry failed to load') end
registry.refresh()

local has_go = vim.fn.executable("go") == 1

local want = {
  -- always
  'lua-language-server','clangd','python-lsp-server','rust-analyzer',
  'clang-format','stylua','jq','rustfmt',
}

if has_go then
  vim.list_extend(want, {
    'gopls','codelldb','delve','goimports','gofumpt',
  })
else
  vim.notify('Go not found – skipping Go-based tools', vim.log.levels.WARN)
end

for _, name in ipairs(want) do
  local pkg = registry.get_package(name)
  if not pkg:is_installed() and not pkg:is_busy() then
    local ok_inst, err = pcall(function() pkg:install():wait() end)
    if not ok_inst then die('Failed to install '..name..': '..tostring(err)) end
  end
  if not pkg:is_installed() then die(name..' is still not installed') end
end
LUA
nvim_h "luafile $mason_lua"; rm -f "$mason_lua"

say "✅ bootstrap complete"

