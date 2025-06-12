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
# Ignore errors in case the temp dir is protected (macOS)
trap 'rm -rf "$TMPDIR" >/dev/null 2>&1 || true' EXIT

FILES=()
for ft in lua python go rust ts c cpp markdown vim; do
	case "$ft" in
	lua) snippet='print("hello")' ;;
	python) snippet='print("hello")' ;;
	go) snippet='package main; func main(){}' ;;
	rust) snippet='fn main(){}' ;;
	c | cpp) snippet='int main() {return 0;}' ;;
	ts) snippet='console.log("hi")' ;;
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

# remove duplicates (if any) - portable across bash versions
dedup_keys=()
for key in "${HOTKEYS[@]}"; do
        found=
        for seen in "${dedup_keys[@]-}"; do
                if [ "$seen" = "$key" ]; then
                        found=1
                        break
                fi
        done
        [ -n "$found" ] || dedup_keys+=("$key")
done
HOTKEYS=("${dedup_keys[@]-}")

# create a tiny Lua script executing each hotkey
LUA_KEYS="$TMPDIR/keys.lua"
{
	echo "local data = [==["
	printf '%s\n' "${HOTKEYS[@]}"
	echo "]==]"
	echo "local lsp_keys = { K=true, gd=true, gr=true, gR=true, ['<leader>a']=true }"
	printf '%s\n' \
		"for line in data:gmatch('[^\\n]+') do" \
		"  if line ~= '' and (not lsp_keys[line] or #vim.lsp.get_clients()>0) then" \
		"    pcall(vim.cmd, 'silent! normal '..line)" \
		"  end" \
		"end" \
                "vim.cmd('normal! yy')" \
                "vim.cmd('sleep 300m')"
} >"$LUA_KEYS"

# -----------------------------------------------------------------------------
# 3.  One Neovim instance, open all buffers, test hotkeys, then quit
#     (running :checkhealth at the end for good measure)
# -----------------------------------------------------------------------------
SCRIPT="$TMPDIR/run.vim"
{
	for f in "${FILES[@]}"; do
		echo "edit ${f}"
	done
	echo "luafile ${LUA_KEYS}"
	echo "execute 'normal! gg'"
	echo "checkhealth"
	echo "qa!"
} >"$SCRIPT"

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
(cd "$GIT_REPO" && git init -q &&
	git config user.email "test@example.com" &&
	git config user.name "Test" &&
	echo "hi" >a.txt &&
	git add a.txt &&
	git commit -qm init &&
	echo "change" >>a.txt)
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
# 4.  Buffer cycling via <C-Tab> / <C-S-Tab>
# -----------------------------------------------------------------------------
set +e
OUT_BUF="$("${TIMEOUT[@]}" "$NVIM" --headless "${FILES[0]}" "${FILES[1]}" \
	--cmd "set rtp^=$ROOT packpath^=$ROOT" \
	--cmd "set noswapfile" \
	-u "$ROOT/init.lua" \
	+"lua b1=vim.fn.bufnr()" \
	+"bnext" \
	+"lua b2=vim.fn.bufnr()" \
	+"bprevious" \
	+"lua print(b1,b2,vim.fn.bufnr())" +qa 2>&1)"
STATUS=$?
set -e
if ((STATUS != 0)); then
	echo "$OUT_BUF"
	echo "❌ buffer cycle failed"
	exit $STATUS
fi
nums="$(printf '%s\n' "$OUT_BUF" | tr -d '\r' | grep -Eo '^[0-9]+ [0-9]+ [0-9]+$' | head -n1)"
read -r b1 b2 b3 <<<"$nums"
if [ "$b1" = "$b3" ] && [ "$b1" != "$b2" ]; then
	:
else
	echo "$OUT_BUF"
	echo "❌ buffer cycle not working"
	exit 1
fi

NVIM_CMD=("$NVIM" --headless
	--cmd "set rtp^=$ROOT packpath^=$ROOT"
	--cmd "set noswapfile"
	-u "$ROOT/init.lua"
	-S "$SCRIPT")

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
