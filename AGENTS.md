This repo is a **fully-portable Neovim toolkit**.  
Once you run `make offline` everything (Neovim, Lazy plugins, Mason tools) is cached
under `.tools/` and the project works without the Internet.

---

## 1 · Bootstrap (needs the Internet once)

```bash
make offline          # downloads nvim + plugins + Mason packages
````

*If CI already restored the `.tools` cache, set `OFFLINE=1` and the step is
skipped.*

---

## 2 · Smoke test (works offline)

```bash
make smoke            # prints “SMOKE OK” on success
```

Runs Neovim head-less with plugins disabled (`NVIM_OFFLINE_BOOT=1`) just to
prove the binary is runnable.

---

## 3 · Daily usage

* **Launch** with the private binary: `./.tools/bin/nvim`
  (or add `.tools/bin` to your `PATH`).
* All interactive goodies (Lazy, Mason, DAP, etc.) are ready.

---

## Make targets

| Target    | What it does                               |
| --------- | ------------------------------------------ |
| `offline` | Full bootstrap (skipped when `OFFLINE=1`). |
| `smoke`   | Minimal head-less check (no plugin load).  |

---

## Environment variables

| Var                 | Meaning                                                    |
| ------------------- | ---------------------------------------------------------- |
| `OFFLINE=1`         | Don’t run bootstrap (cache already warm).                  |
| `NVIM_OFFLINE_BOOT` | Tell `init.lua` to bypass Lazy at startup (used by smoke). |

---

## **When you add or change tools**

1. **Plugin / config** goes in `lua/plugins/…` as usual.
2. **Mason registry names** of every new tool **must be added in *two places*:**

   * the `want` list inside `scripts/bootstrap.sh`, **and**
   * the identical `want` list inside the Lua snippet embedded in the
     `make test` target (found in the Makefile).

> **Why?**
> Our CI workflow (`.github/workflows/offline.yml`) runs `make offline`
> to pre-fetch all tools, then re-runs `make smoke` with `OFFLINE=1`.
> If a tool is not listed in `bootstrap.sh`, the offline phase will break.

---

## CI check

`offline-bootstrap` GitHub Actions workflow:

* restores the `.tools/` cache;
* runs `make offline` (online phase);
* runs `make smoke` with `OFFLINE=1` (offline phase).

A PR that forgets to update `bootstrap.sh` will fail here.

## Makefile

**Makefile tip:** each command under a target **must start with a TAB**,  
not spaces. If you indent with spaces `make` treats the line as a new
target and the recipe won’t run.

---
That’s all – **`make offline` → `make smoke` → hack away!**


