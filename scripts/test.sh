#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Offline self-test
#  – runs Neovim head-less with the repo’s runtimepath
#  – fails fast on *any* non-zero exit or Lua/Vim error
#  – prints “TEST OK” on success
# ---------------------------------------------------------------------------

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NVIM="$ROOT/.tools/bin/nvim"

if [[ ! -x $NVIM ]]; then
	echo "❌ test: $NVIM not found (run \`make offline\` first)" >&2
	exit 1
fi

export NVIM_OFFLINE_BOOT=1

# run Neovim; capture both stdout & stderr
set +e
OUT="$("$NVIM" --headless \
	--cmd "set rtp^=$ROOT packpath^=$ROOT" \
	-u "$ROOT/init.lua" \
	+qa 2>&1)"
STATUS=$?
set -e

# non-zero exit?
if ((STATUS != 0)); then
	echo "$OUT"
	echo "❌ Neovim exited with status $STATUS" >&2
	exit $STATUS
fi

# did Neovim print any E-style error messages?
if echo "$OUT" | grep -E "E[0-9]{4}:" -q; then
	echo "$OUT"
	echo "❌ Neovim reported errors" >&2
	exit 1
fi

echo "TEST OK"
