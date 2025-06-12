#!/usr/bin/env python3
"""Private, fail-fast, offline-friendly bootstrap."""

from __future__ import annotations
import os, shutil, subprocess, sys, tarfile, zipfile, platform
from pathlib import Path

# ───────────────────────────────────────── paths ──────────────────────────
ROOT  = Path(__file__).resolve().parent
TOOLS = ROOT / ".tools"
BIN   = TOOLS / "bin"
NVIM  = BIN / "nvim"

TOOLS.mkdir(parents=True, exist_ok=True)
BIN.mkdir(exist_ok=True)

# ──────────────────────────── Neovim (same as before) ─────────────────────
NVIM_VERSION = os.environ.get("NVIM_VERSION", "v0.11.2")
ASSET_MAP = {
    ("Linux",  "x86_64"):  "nvim-linux-x86_64.tar.gz",
    ("Linux",  "aarch64"): "nvim-linux-arm64.tar.gz",
    ("Darwin", "x86_64"):  "nvim-macos-x86_64.tar.gz",
    ("Darwin", "arm64"):   "nvim-macos-arm64.tar.gz",
    ("Windows_NT", "x86_64"): "nvim-win64.zip",
}
sysname = os.environ.get("OS") or platform.system()
machine = platform.machine()
machine = "x86_64" if machine.lower() in ("amd64", "x86_64") else machine
asset = ASSET_MAP.get((sysname, machine))
if not asset:
    say(f"Unsupported platform: {sysname} {machine} – skipping Neovim download")
    sys.exit(0)

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

# ────────────────────────────── Luacheck ─────────────────────────────────
LUACHECK_VERSION = "v1.2.0"
LUACHECK_ASSETS = {
    ("Linux",  "x86_64"):  "luacheck",
    ("Linux",  "aarch64"): "luacheck",
    ("Darwin", "x86_64"):  "luacheck",
    ("Darwin", "arm64"):   "luacheck",
    ("Windows_NT", "x86_64"): "luacheck.exe",
}

# ───────────────────────────────── utilities ──────────────────────────────
def say(msg: str) -> None:
    print(f"\033[1;34m[bootstrap]\033[0m {msg}", flush=True)

def fetch(url: str, out: Path) -> None:
    if os.name == "nt":
        subprocess.check_call([
            "powershell",
            "-Command",
            f"curl -L -o \"{out}\" {url}",
        ])
    else:
        subprocess.check_call(["curl", "-Lf", "--retry", "3", "-o", out, url])

def link_into_bin(binary: Path, name: str) -> None:
    target = BIN / name
    if target.exists() or target.is_symlink():
        target.unlink()
    target.symlink_to(binary)
    binary.chmod(0o755)

def untar_or_unzip(archive: Path, dest: Path) -> None:
    suf = archive.suffixes[-2:]
    if suf == [".tar", ".xz"] or suf == [".tar", ".gz"]:
        mode = "r:xz" if suf[-1] == ".xz" else "r:gz"
        with tarfile.open(archive, mode) as tf:
            tf.extractall(dest, filter="data")
    else:
        with zipfile.ZipFile(archive) as zf:
            zf.extractall(dest)

# ───────────────────────── download & extract Neovim ──────────────────────
# Redownload if either the version stamp or the nvim binary is missing
if not STAMP.exists() or not NVIM.exists():
    archive = TOOLS / asset
    say(f"Fetching Neovim {NVIM_VERSION} …")
    fetch(NVIM_URL, archive)

    say("Extracting …")
    shutil.rmtree(TOOLS / "nvim-extracted", ignore_errors=True)
    (TOOLS / "nvim-extracted").mkdir()
    untar_or_unzip(archive, TOOLS / "nvim-extracted")

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
stylua_asset = STYLUA_ASSETS.get((sysname, machine))
stylua_stamp = TOOLS / f".stylua.{STYLUA_VERSION}.ok"
if stylua_asset and not stylua_stamp.exists():
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
elif not stylua_asset:
    say("Skipping Stylua – unsupported platform")

# ──────────────────────────── grab ShellCheck ─────────────────────────────
shell_asset = SHELLCHECK_ASSETS.get((sysname, machine))
shell_stamp = TOOLS / f".shellcheck.{SHELLCHECK_VERSION}.ok"
if shell_asset and not shell_stamp.exists():
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
elif not shell_asset:
    say("Skipping ShellCheck – unsupported platform")

# ───────────────────────────── grab shfmt ─────────────────────────────────
shfmt_asset = SHFMT_ASSETS.get((sysname, machine))
shfmt_stamp = TOOLS / f".shfmt.{SHFMT_VERSION}.ok"
if shfmt_asset and not shfmt_stamp.exists():
    url = f"https://github.com/mvdan/sh/releases/download/{SHFMT_VERSION}/{shfmt_asset}"
    bin_path = TOOLS / shfmt_asset
    say(f"Fetching shfmt {SHFMT_VERSION} …")
    fetch(url, bin_path)
    link_into_bin(bin_path, "shfmt")
    shfmt_stamp.touch()
elif not shfmt_asset:
    say("Skipping shfmt – unsupported platform")

# ───────────────────────────── grab Luacheck ─────────────────────────────
luacheck_asset = LUACHECK_ASSETS.get((sysname, machine))
luacheck_stamp = TOOLS / f".luacheck.{LUACHECK_VERSION}.ok"
if luacheck_asset and not luacheck_stamp.exists():
    url = f"https://github.com/lunarmodules/luacheck/releases/download/{LUACHECK_VERSION}/{luacheck_asset}"
    bin_path = TOOLS / luacheck_asset
    say(f"Fetching Luacheck {LUACHECK_VERSION} …")
    fetch(url, bin_path)
    link_into_bin(bin_path, "luacheck")
    luacheck_stamp.touch()
elif not luacheck_asset:
    say("Skipping Luacheck – unsupported platform")

say("✅ bootstrap complete")

