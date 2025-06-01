#!/usr/bin/env bash
set -euo pipefail
export NVIM_OFFLINE_BOOT=1
nvim --headless +"quit"
echo "SMOKE OK"
