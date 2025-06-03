#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Offline self-test – extended
#   • starts Neovim head-less with full plugins
#   • sequentially opens one buffer for each listed file-type
#   • aborts on *any* error or non-zero exit
#   • prints “TEST OK” on success
# -----------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM="$ROOT/.tools/bin/nvim"

[[ -x $NVIM ]] || {
	echo "❌ test: $NVIM not found (run \`make offline\` first)"
	exit 1
}

export NVIM_OFFLINE_BOOT=1 # we still want plugins, just no network pokes

# -----------------------------------------------------------------------------
# 1.  Create tiny scratch files (lives in tmpfs, auto-deleted)
# -----------------------------------------------------------------------------
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

declare -A SNIPPET=(
	[lua]='print("hello")'
	[python]='print("hello")'
	[go]='package main; func main(){}'
	[rust]='fn main(){}'
	[c]='int main() {return 0;}'
	[cpp]='int main() {return 0;}'
	[markdown]='# Hello'
	[vim]='echo "hi"'
)

FILES=()
for ft in "${!SNIPPET[@]}"; do
	f="$TMPDIR/test.$ft"
	echo "${SNIPPET[$ft]}" >"$f"
	FILES+=("$f")
done

# -----------------------------------------------------------------------------
# 2.  One Neovim instance, open all buffers, then quit
#     (running :checkhealth at the end for good measure)
# -----------------------------------------------------------------------------
CMD_OPEN=""
for f in "${FILES[@]}"; do
	CMD_OPEN+=" | edit ${f}"
done
CMD_OPEN="${CMD_OPEN# | }" # drop leading separator
CMD="${CMD_OPEN} | checkhealth | qa"

set +e
OUT="$("$NVIM" --headless \
	--cmd "set rtp^=$ROOT packpath^=$ROOT" \
	-u "$ROOT/init.lua" \
	+"$CMD" 2>&1)"
STATUS=$?
set -e

# -----------------------------------------------------------------------------
# 3.  Fail-fast diagnostics
# -----------------------------------------------------------------------------
if ((STATUS != 0)); then
	echo "$OUT"
	echo "❌ Neovim exited with status $STATUS"
	exit $STATUS
fi

if grep -E "E[0-9]{4}:" <<<"$OUT" >/dev/null; then
	echo "$OUT"
	echo "❌ Neovim reported errors"
	exit 1
fi

echo "TEST OK"
