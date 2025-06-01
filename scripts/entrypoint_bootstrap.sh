#!/usr/bin/env bash
# Pre-flight hook: executed by CI infra **while network is still on**.
# Purpose: download nvim appimage, clone lazy.nvim, sync plugins, install mason bins.
# In this first iteration we only echo a banner and exit 0.
set -euo pipefail
echo "[entrypoint_bootstrap] stub – nothing to do yet"
exit 0
