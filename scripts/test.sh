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

# plugins are loaded during tests

# -----------------------------------------------------------------------------
# 1.  Create tiny scratch files (lives in tmpfs, auto-deleted)
# -----------------------------------------------------------------------------
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

FILES=()
for ft in lua python go rust c cpp markdown vim; do
	case "$ft" in
	lua) snippet='print("hello")' ;;
	python) snippet='print("hello")' ;;
	go) snippet='package main; func main(){}' ;;
	rust) snippet='fn main(){}' ;;
	c | cpp) snippet='int main() {return 0;}' ;;
	markdown) snippet='# Hello' ;;
	vim) snippet='echo "hi"' ;;
	esac
	f="$TMPDIR/test.$ft"
	echo "$snippet" >"$f"
	FILES+=("$f")
done

# -----------------------------------------------------------------------------
# 2.  Hotkey list from README.md
# -----------------------------------------------------------------------------
HOTKEYS=()
while IFS= read -r line; do
	key=$(printf '%s\n' "$line" | sed -n "s/.*\`\([^\`]*\)\`.*/\1/p")
	if [ -n "$key" ]; then
		HOTKEYS+=("$key")
	fi
done < <(
	awk '/^### Common hotkeys/{flag=1; next}/^##/{flag=0} flag && /\*/' "$ROOT/README.md"
)

# -----------------------------------------------------------------------------
# 3.  One Neovim instance, open all buffers, test hotkeys, then quit
#     (running :checkhealth at the end for good measure)
# -----------------------------------------------------------------------------
CMD_OPEN=""
for f in "${FILES[@]}"; do
	CMD_OPEN+=" | edit ${f}"
done
CMD_OPEN="${CMD_OPEN# | }" # drop leading separator

CMD_KEYS=""
for k in "${HOTKEYS[@]}"; do
	CMD_KEYS+=" | silent! execute \"normal ${k}\""
done

CMD="${CMD_OPEN} | edit $ROOT/scripts/test.lua${CMD_KEYS} | execute 'normal! gg' | checkhealth | qa!"

# On macOS, `timeout` might not exist, so fall back to `gtimeout` (from coreutils)
# or a Perl alarm wrapper as a last resort.
if command -v timeout >/dev/null 2>&1; then
	TIMEOUT=(timeout 30s)
elif command -v gtimeout >/dev/null 2>&1; then
	TIMEOUT=(gtimeout 30s)
else
	TIMEOUT=(perl -e 'alarm shift; exec @ARGV' 30)
fi

# -----------------------------------------------------------------------------
# 3.  Gitsigns non-interactive API test
# -----------------------------------------------------------------------------
GIT_REPO="$TMPDIR/repo"
mkdir "$GIT_REPO"
(cd "$GIT_REPO" && git init -q && echo "hi" >a.txt && git add a.txt && git commit -qm init && echo "change" >>a.txt)
set +e
OUT_GIT="$("${TIMEOUT[@]}" "$NVIM" --headless \
	--cmd "set rtp^=$ROOT packpath^=$ROOT" \
	--cmd "set noswapfile" \
	-u "$ROOT/init.lua" \
	+"edit $GIT_REPO/a.txt" +"lua require('gitsigns').stage_hunk()" +q 2>&1)"
STATUS=$?
set -e
if ((STATUS != 0)); then
	echo "$OUT_GIT"
	echo "❌ gitsigns stage_hunk failed"
	exit $STATUS
fi

# -----------------------------------------------------------------------------
# 4.  Session save and restore
# -----------------------------------------------------------------------------
set +e
"${TIMEOUT[@]}" "$NVIM" --headless "${FILES[0]}" "${FILES[1]}" \
	--cmd "set rtp^=$ROOT packpath^=$ROOT" \
	--cmd "set noswapfile" \
	-u "$ROOT/init.lua" \
	+qa 2>&1
STATUS=$?
set -e
if ((STATUS != 0)); then
	echo "❌ session save failed"
	exit $STATUS
fi
set +e
OUT_SESSION="$("${TIMEOUT[@]}" "$NVIM" --headless \
	--cmd "set rtp^=$ROOT packpath^=$ROOT" \
	--cmd "set noswapfile" \
	-u "$ROOT/init.lua" \
	+"lua require('persistence').load({ last = true })" \
	+"lua print(vim.fn.argc())" +qa 2>&1)"
STATUS=$?
set -e
if ((STATUS != 0)); then
	echo "$OUT_SESSION"
	echo "❌ session restore failed"
	exit $STATUS
fi
if ! grep -qx '2' <<<"$OUT_SESSION"; then
	echo "$OUT_SESSION"
	echo "❌ session not restored"
	exit 1
fi

NVIM_CMD=("$NVIM" --headless
	--cmd "set rtp^=$ROOT packpath^=$ROOT"
	--cmd "set noswapfile"
	-u "$ROOT/init.lua"
	+"$CMD")

set +e
OUT="$("${TIMEOUT[@]}" "${NVIM_CMD[@]}" 2>&1)"
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
