#!/usr/bin/env bash
# Pre-flight hook: executed by CI infra **while network is still on**.
# Purpose: download nvim appimage, clone lazy.nvim, sync plugins, install mason bins.
# If your CI platform offers a "pre-task" hook, call this script there before the network is sandboxed.

set -euo pipefail

cache_dir=".tools"
nvim_dir="$cache_dir/nvim"
lazy_dir="$cache_dir/lazy"
mason_dir="$cache_dir/mason"
NVIM_APPIMAGE="$nvim_dir/nvim.appimage"
NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.10.0/nvim.appimage"
NVIM_SHA256="d0e61d7378b7b5ad2d98f5c2bdc45980c5c4f17ade9bd9d2b6dcefb1b1083d57"

if [[ "${OFFLINE:-0}" == "1" ]]; then
    echo "[bootstrap] offline flag detected – skipping downloads"
    exit 0
fi

mkdir -p "$nvim_dir" "$lazy_dir" "$mason_dir"

skip_due_to_no_network() {
    echo "[bootstrap] network unavailable – skipping bootstrap"
    exit 0
}

download_nvim() {
    if [[ -x "$NVIM_APPIMAGE" ]]; then
        echo "[bootstrap] nvim appimage cached – skipping download"
        return
    fi
    echo "[bootstrap] downloading nvim appimage..."
    if ! curl -L --retry 3 -o "$NVIM_APPIMAGE" "$NVIM_URL"; then
        skip_due_to_no_network
    fi
    echo "$NVIM_SHA256  $NVIM_APPIMAGE" | sha256sum -c -
    chmod +x "$NVIM_APPIMAGE"
    ln -sf "$(pwd)/$NVIM_APPIMAGE" /usr/local/bin/nvim
}

clone_lazy() {
    if [[ -d "$lazy_dir/.git" ]]; then
        echo "[bootstrap] lazy.nvim already cloned – skipping"
        return
    fi
    echo "[bootstrap] cloning lazy.nvim..."
    if ! git clone --depth 1 --branch stable https://github.com/folke/lazy.nvim.git "$lazy_dir"; then
        skip_due_to_no_network
    fi
}

sync_plugins() {
    echo "[bootstrap] syncing plugins..."
    NVIM_APPIMAGE="$NVIM_APPIMAGE" NVIM_APPNAME=nvim \
      nvim --headless -u NONE +"lua require('lazy.core.sync').sync()" +qa
}

install_mason() {
    echo "[bootstrap] installing Mason tools..."
    export MASON_SKIP_UPDATE_CHECK=1
    export MASON_DATA_PATH="$mason_dir"
    nvim --headless +"lua require('mason').setup(); require('mason-lspconfig').setup{}" +qa
}


download_nvim
clone_lazy
sync_plugins
install_mason

echo "[bootstrap] done"
