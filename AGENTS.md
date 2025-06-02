# AGENTS.md – quick guide for Codex

The repo is a **self‑contained, offline‑friendly Neovim setup**.  Once you run
`make offline` everything lives in `.tools/` – no further network needed.

---

## 1. Bootstrap (requires the Internet *once*)

```bash
make offline      # downloads nvim + plugins + Mason tools
```

*If you are in CI and a tool cache already exists, set `OFFLINE=1` to skip the
step.*

---

## 2. Smoke test (works offline)

```bash
make smoke        # prints “SMOKE OK” on success
```

This starts Neovim head‑less with plugins disabled just to prove the binary
runs.

---

## 3. Use the tool‑chain

* Launch with the private binary: `./.tools/bin/nvim`
  *(or add `.tools/bin` to your `PATH`).*
* All usual interactive features (Lazy, Mason, etc.) are ready.

---

## Make targets summary

| Target    | Purpose                                   |
| --------- | ----------------------------------------- |
| `offline` | Full bootstrap. Skipped when `OFFLINE=1`. |
| `smoke`   | Minimal head‑less check (no plugin load). |

---

## Environment variables

| Variable              | Effect                                                       |
| --------------------- | ------------------------------------------------------------ |
| `OFFLINE=1`           | Don’t run bootstrap (CI cache is warm).                      |
| `NVIM_OFFLINE_BOOT=1` | Tell `init.lua` to bypass Lazy at startup (used by `smoke`). |

---

That’s all an agent needs: **`make offline` → `make smoke` → hack away.**

