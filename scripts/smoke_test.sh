#!/usr/bin/env bash
# Minimal “does Neovim exit?” check – no plugins, always offline.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM="$ROOT/.tools/bin/nvim"

if [[ ! -x "$NVIM" ]]; then
	echo "❌ Neovim binary not found – run 'make offline' first" >&2
	exit 1
fi

export NVIM_OFFLINE_BOOT=1 # skip Lazy on startup
"$NVIM" --headless +'q'    # just start & quit
echo "SMOKE OK"
