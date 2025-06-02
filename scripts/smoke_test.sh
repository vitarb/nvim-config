#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM="$ROOT/.tools/bin/nvim"

if [[ ! -x $NVIM ]]; then
  echo "❌ smoke_test: $NVIM not found (did you run make offline?)" >&2
  exit 1
fi

export NVIM_OFFLINE_BOOT=1   # skip plugin bootstrap
"$NVIM" --headless +'quit'
echo "SMOKE OK"

