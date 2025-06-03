#!/usr/bin/env python3
"""Private, fail-fast, offline-friendly bootstrap."""

from __future__ import annotations
import os, shutil, subprocess, sys, tarfile, zipfile
from pathlib import Path

# ───────────────────────────────────────── paths ──────────────────────────
ROOT  = Path(__file__).resolve().parent
TOOLS = ROOT / ".tools"
BIN   = TOOLS / "bin"
NVIM  = BIN / "nvim"

TOOLS.mkdir(parents=True, exist_ok=True)
BIN.mkdir(exist_ok=True)

# ──────────────────────────── Neovim (same as before) ─────────────────────
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

# ────────────────────────────── Stylua & ShellCheck ───────────────────────
STYLUA_VERSION = "v0.20.0"
STYLUA_ASSETS  = {
    ("Linux",  "x86_64"):  "stylua-linux-x86_64.zip",
    ("Linux",  "aarch64"): "stylua-linux-aarch64.zip",
    ("Darwin", "x86_64"):  "stylua-macos.zip",
    ("Darwin", "arm64"):   "stylua-macos.zip",
}

SHELLCHECK_VERSION = "v0.10.0"
SHELLCHECK_ASSETS  = {
    ("Linux",  "x86_64"):  "shellcheck-v0.10.0.linux.x86_64.tar.xz",
    ("Linux",  "aarch64"): "shellcheck-v0.10.0.linux.aarch64.tar.xz",
    ("Darwin", "x86_64"):  "shellcheck-v0.10.0.darwin.x86_64.tar.xz",
    ("Darwin", "arm64"):   "shellcheck-v0.10.0.darwin.aarch64.tar.xz",
}

# ────────────────────────────── NEW: shfmt ────────────────────────────────
SHFMT_VERSION = "v3.7.0"
SHFMT_ASSETS  = {
    ("Linux",  "x86_64"):  "shfmt_v3.7.0_linux_amd64",
    ("Linux",  "aarch64"): "shfmt_v3.7.0_linux_arm64",
    ("Darwin", "x86_64"):  "shfmt_v3.7.0_darwin_amd64",
    ("Darwin", "arm64"):   "shfmt_v3.7.0_darwin_arm64",
}

# ───────────────────────────────── utilities ──────────────────────────────
def say(msg: str) -> None:
    print(f"\033[1;34m[bootstrap]\033[0m {msg}", flush=True)

def fetch(url: str, out: Path) -> None:
    subprocess.check_call(["curl", "-Lf", "--retry", "3", "-o", out, url])

def link_into_bin(binary: Path, name: str) -> None:
    target = BIN / name
    if target.exists() or target.is_symlink():
        target.unlink()
    target.symlink_to(binary)
    binary.chmod(0o755)

def untar_or_unzip(archive: Path, dest: Path) -> None:
    if archive.suffixes[-2:] == [".tar", ".xz"]:
        with tarfile.open(archive, "r:xz") as tf:
            tf.extractall(dest)
    else:
        with zipfile.ZipFile(archive) as zf:
            zf.extractall(dest)

# ───────────────────────── download & extract Neovim ──────────────────────
if not STAMP.exists():
    archive = TOOLS / asset
    say(f"Fetching Neovim {NVIM_VERSION} …")
    fetch(NVIM_URL, archive)

    say("Extracting …")
    shutil.rmtree(TOOLS / "nvim-extracted", ignore_errors=True)
    (TOOLS / "nvim-extracted").mkdir()
    with tarfile.open(archive) as tf:
        tf.extractall(TOOLS / "nvim-extracted")

    found = next((p for p in (TOOLS / "nvim-extracted").rglob("bin/nvim")), None)
    if not found:
        sys.exit("[bootstrap] nvim binary not found inside archive")
    link_into_bin(found, "nvim")
    STAMP.touch()

# ───────────────────── run Neovim once to install Lazy ────────────────────
def run_nvim(*extra: str) -> None:
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
         "-u", str(ROOT / "init.lua"), *extra],
        env=env,
    )

say("Syncing Lazy plugins …")
run_nvim("+lua require('lazy').sync{wait=true}", "+qa")
# Compile treesitter grammars once while we still have network
run_nvim("+TSUpdateSync", "+qa")

# ───────────────────────────── grab Stylua ────────────────────────────────
stylua_asset = STYLUA_ASSETS[(os.uname().sysname, os.uname().machine)]
stylua_stamp = TOOLS / f".stylua.{STYLUA_VERSION}.ok"
if not stylua_stamp.exists():
    archive = TOOLS / stylua_asset
    say(f"Fetching Stylua {STYLUA_VERSION} …")
    fetch(f"https://github.com/JohnnyMorganz/StyLua/releases/download/{STYLUA_VERSION}/{stylua_asset}", archive)

    say("Extracting …")
    shutil.rmtree(TOOLS / "stylua-x", ignore_errors=True)
    (TOOLS / "stylua-x").mkdir()
    untar_or_unzip(archive, TOOLS / "stylua-x")
    bin_path = next((p for p in (TOOLS / "stylua-x").rglob("stylua")), None)
    if not bin_path:
        sys.exit("[bootstrap] stylua binary not found")
    link_into_bin(bin_path, "stylua")
    stylua_stamp.touch()

# ──────────────────────────── grab ShellCheck ─────────────────────────────
shell_asset = SHELLCHECK_ASSETS[(os.uname().sysname, os.uname().machine)]
shell_stamp = TOOLS / f".shellcheck.{SHELLCHECK_VERSION}.ok"
if not shell_stamp.exists():
    archive = TOOLS / shell_asset
    say(f"Fetching ShellCheck {SHELLCHECK_VERSION} …")
    fetch(f"https://github.com/koalaman/shellcheck/releases/download/{SHELLCHECK_VERSION}/{shell_asset}", archive)

    say("Extracting …")
    shutil.rmtree(TOOLS / "shellcheck-x", ignore_errors=True)
    (TOOLS / "shellcheck-x").mkdir()
    untar_or_unzip(archive, TOOLS / "shellcheck-x")
    bin_path = next((p for p in (TOOLS / "shellcheck-x").rglob("shellcheck")), None)
    if not bin_path:
        sys.exit("[bootstrap] shellcheck binary not found")
    link_into_bin(bin_path, "shellcheck")
    shell_stamp.touch()

# ───────────────────────────── grab shfmt ─────────────────────────────────
shfmt_asset = SHFMT_ASSETS[(os.uname().sysname, os.uname().machine)]
shfmt_stamp = TOOLS / f".shfmt.{SHFMT_VERSION}.ok"
if not shfmt_stamp.exists():
    url = f"https://github.com/mvdan/sh/releases/download/{SHFMT_VERSION}/{shfmt_asset}"
    bin_path = TOOLS / shfmt_asset
    say(f"Fetching shfmt {SHFMT_VERSION} …")
    fetch(url, bin_path)
    link_into_bin(bin_path, "shfmt")
    shfmt_stamp.touch()

say("✅ bootstrap complete")

