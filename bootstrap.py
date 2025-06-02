#!/usr/bin/env python3
"""Private, fail-fast, offline-friendly bootstrap (minimal – no Mason/LSP)."""
from __future__ import annotations
import os, shutil, subprocess, sys, tarfile
from pathlib import Path

ROOT   = Path(__file__).resolve().parent
TOOLS  = ROOT / ".tools"
BIN    = TOOLS / "bin"
NVIM   = BIN / "nvim"

NVIM_VERSION = "v0.11.2"
ASSET_MAP = {
    ("Linux",  "x86_64"):  "nvim-linux-x86_64.tar.gz",
    ("Linux",  "aarch64"): "nvim-linux-arm64.tar.gz",
    ("Darwin", "x86_64"):  "nvim-macos-x86_64.tar.gz",
    ("Darwin", "arm64"):   "nvim-macos-arm64.tar.gz",
}
asset = ASSET_MAP.get((os.uname().sysname, os.uname().machine))
if not asset:
    sys.exit(f"[bootstrap] Unsupported platform: {os.uname().sysname} {os.uname().machine}")
NVIM_URL = f"https://github.com/neovim/neovim/releases/download/{NVIM_VERSION}/{asset}"
STAMP    = TOOLS / f".nvim.{NVIM_VERSION}.{asset}.ok"

say = lambda m: print(f"\033[1;34m[bootstrap]\033[0m {m}", flush=True)

TOOLS.mkdir(parents=True, exist_ok=True)
BIN.mkdir(parents=True, exist_ok=True)

##############################################################################
# 1. Download & extract Neovim once
##############################################################################
if not STAMP.exists():
    archive = TOOLS / asset
    say(f"Fetching Neovim {NVIM_VERSION} …")
    subprocess.check_call(["curl", "-Lf", "--retry", "3", "-o", archive, NVIM_URL])

    say("Extracting …")
    shutil.rmtree(TOOLS / "nvim-extracted", ignore_errors=True)
    (TOOLS / "nvim-extracted").mkdir()
    with tarfile.open(archive) as tf:
        tf.extractall(TOOLS / "nvim-extracted")

    found = next((p for p in (TOOLS / "nvim-extracted").rglob("bin/nvim")), None)
    if not found:
        sys.exit("[bootstrap] nvim binary not found inside archive")

    # ------------------------------------------------------------------
    # NEW – (force-)create symlink every time (cross-platform safe)
    # ------------------------------------------------------------------
    if NVIM.exists() or NVIM.is_symlink():
        NVIM.unlink()
    NVIM.symlink_to(found)

    STAMP.touch()

##############################################################################
# Helper: run headless Neovim with our runtime path
##############################################################################
def run_nvim(*extra_args: str) -> None:
    xdg = ROOT / ".cache" / "xdg"
    env = os.environ | {
        "XDG_DATA_HOME":   str(xdg / "data"),
        "XDG_CONFIG_HOME": str(xdg / "config"),
        "XDG_STATE_HOME":  str(xdg / "state"),
        "XDG_CACHE_HOME":  str(xdg / "cache"),
    }
    subprocess.check_call(
        [str(NVIM), "--headless",
         "--cmd", f"set rtp^={ROOT} packpath^={ROOT}",
         "-u", str(ROOT / "init.lua"), *extra_args],
        env=env,
    )

##############################################################################
# 2. Sync Lazy plugins (none configured – still exercises bootstrap)
##############################################################################
say("Syncing Lazy plugins …")
run_nvim("+lua require('lazy').sync{wait=true}", "+qa")

say("✅ bootstrap complete")

