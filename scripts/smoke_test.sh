#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NVIM="$ROOT/.tools/bin/nvim"

[ -x "$NVIM" ] || { echo "❌ no nvim – run make offline first" >&2; exit 1; }

export NVIM_OFFLINE_BOOT=1
"$NVIM" --headless +'quit'
echo "SMOKE OK"

