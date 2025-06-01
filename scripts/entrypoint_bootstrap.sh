#!/usr/bin/env bash
# Pre-flight hook: executed by CI infra **while network is still on**.
# Purpose: download nvim appimage, clone lazy.nvim, sync plugins, install mason bins.
# If your CI platform offers a "pre-task" hook, call this script there before the network is sandboxed.

set -euo pipefail

# Pin lazy.nvim to a reproducible commit
LZ_REPO="https://github.com/folke/lazy.nvim.git"
LZ_COMMIT="3ad9f5e3e9db1e7e07d448f2d8e2d574b4bb1c05"

cache_dir=".tools"
nvim_dir="$cache_dir/nvim"
lazy_dir="$cache_dir/lazy"
mason_dir="$cache_dir/mason"
bin_dir="$cache_dir/bin"
NVIM_APPIMAGE="$nvim_dir/nvim.appimage"
NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.10.0/nvim.appimage"

if [[ "${OFFLINE:-0}" == "1" ]]; then
    if [[ ! -d "$lazy_dir/.git" ]]; then
        echo "[bootstrap] Lazy cache missing — run bootstrap with network first"
        exit 1
    fi
    echo "[bootstrap] offline mode – skipping bootstrap"
    exit 0
fi

mkdir -p "$nvim_dir" "$lazy_dir" "$mason_dir" "$bin_dir"
export PATH="$bin_dir:$PATH"
NVIM="$bin_dir/nvim"

verify_appimage() {
    local sha_url="${NVIM_URL}.sha256sum"
    if curl -fsSL --retry 3 -o "$NVIM_APPIMAGE.sha256" "$sha_url"; then
        (cd "$(dirname "$NVIM_APPIMAGE")" && sha256sum --check --strict "$(basename "$NVIM_APPIMAGE").sha256")
    else
        echo "[bootstrap] sha256 file unavailable – computing local hash"
        if command -v sha256sum >/dev/null; then
            sha256sum "$NVIM_APPIMAGE" || echo "[bootstrap] WARNING: integrity not verified"
        else
            echo "[bootstrap] sha256sum missing – skipping hash check"
        fi
    fi
}

headless() {
    "$NVIM" --headless -u NONE \
        +"set rtp^=$lazy_dir" \
        +"lua require('lazy').setup({})" \
        +"lua $1" +qa
}

download_nvim() {
    if [[ -x "$NVIM_APPIMAGE" ]]; then
        echo "[bootstrap] nvim appimage cached – skipping download"
        return
    fi
    echo "[bootstrap] downloading nvim appimage..."
    curl -L --retry 3 -o "$NVIM_APPIMAGE" "$NVIM_URL"
    verify_appimage
    chmod +x "$NVIM_APPIMAGE"
    ln -sf "$(pwd)/$NVIM_APPIMAGE" "$bin_dir/nvim"
}

clone_lazy() {
    if [[ ! -d "$lazy_dir/.git" ]]; then
        if [[ "${OFFLINE:-0}" == "1" ]]; then
            echo "[bootstrap] Lazy cache missing — run with network first"
            exit 1
        fi
        echo "[bootstrap] cloning lazy.nvim@${LZ_COMMIT:0:7}..."
        git clone --depth 1 "$LZ_REPO" "$lazy_dir"
    fi
    git -C "$lazy_dir" fetch --depth 1 origin "$LZ_COMMIT"
    git -C "$lazy_dir" reset --hard "$LZ_COMMIT"
    if [[ "$(git -C "$lazy_dir" rev-parse --verify HEAD)" != "$LZ_COMMIT" ]]; then
        echo "[bootstrap] ERROR: failed to checkout Lazy commit $LZ_COMMIT" >&2
        exit 1
    fi

    if [[ "${UPDATE:-0}" == "1" ]]; then
        echo "[bootstrap] updating lazy.nvim to latest main..."
        git -C "$lazy_dir" fetch --depth 1 origin main
        NEW_COMMIT=$(git -C "$lazy_dir" rev-parse FETCH_HEAD)
        git -C "$lazy_dir" reset --hard "$NEW_COMMIT"
        sed -i "s/^LZ_COMMIT=.*/LZ_COMMIT=\"$NEW_COMMIT\"/" "$0"
    fi
}

sync_plugins() {
    echo "[bootstrap] syncing plugins..."
    update_flag=${UPDATE:+true}
    headless "require('lazy').sync{update=${update_flag:-false}}"
    # ensure new plugins are on runtimepath before mason loads
    headless "vim.cmd('quit')"
}

install_mason() {
    if [[ ! -d "$mason_dir/bin" || "${UPDATE:-0}" == "1" ]]; then
        export MASON_SKIP_UPDATE_CHECK=1 MASON_DATA_PATH="$mason_dir"
        headless "require('mason').setup(); require('mason-lspconfig').setup{}"
        [[ "${UPDATE:-0}" == "1" ]] && echo "[bootstrap] Mason upgraded"
    else
        echo "[bootstrap] Mason cached – skipping"
    fi
}


download_nvim
clone_lazy
sync_plugins
install_mason
if [[ "${UPDATE:-0}" == "1" ]]; then
    echo "[bootstrap] updated"
else
    echo "[bootstrap] done"
fi
