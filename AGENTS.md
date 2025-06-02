### AGENTS.md

**How to work on this repo once the network is gone**

---

#### 0.  What already happened **before** you start

*GitHub Actions* (or a human) has already run **`make offline`** while the
machine still had Internet.
That step downloaded Neovim and the plugin manager into `./.tools/`.

> After this bootstrap the network is cut off.
> You **cannot** run `make offline` again – it will hang.

---

#### 1.  The two commands you *can* run

From now on **always prefix your commands with `OFFLINE=1`** so the Makefile
skips the network-hungry target.

```bash
# 1) prove the Neovim binary itself works (plugins disabled)
OFFLINE=1 make smoke     # → prints “SMOKE OK”

# 2) verify the real config & plugins load cleanly
OFFLINE=1 make test      # → prints “TEST OK”
```

That’s the whole workflow for an agent:
`OFFLINE=1 make smoke → OFFLINE=1 make test → hack away`.

---

#### 2.  Make targets available to you

| Target             | Purpose during an **offline** run                                                                                                          |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `smoke`            | Head-less Neovim, plugins disabled.<br>Fails fast on any error.                                                                            |
| `test`             | Head-less Neovim with full config & plugins.<br>Fails fast on any error.                                                                   |
| `clean` *(rarely)* | Delete `.tools/` & `.cache/` – **only** if you need a fresh bootstrap (you’ll then need someone with network to run `make offline` again). |

Do **not**:

* run `make offline` – it needs the Internet;
* set `DOCKER=1` – the agent is already running inside a container.

---

#### 3.  Extending the configuration

Adding anything that tries to download code (plugins, linters, etc.) will
break offline runs.

If you must add such a dependency:

1. Vendor it into the repo **or**
2. Teach `bootstrap.py` (executed during the online phase) to fetch it.

Then verify locally:

```bash
make clean            # blow away old tool-chain
make offline          # *with* Internet – once
OFFLINE=1 make test   # should print “TEST OK”
```

Commit only when that passes.

---

#### 4.  CI reference

`.github/workflows/test.yml` replicates the same sequence:

1. `make offline`   *(networked, once)*
2. `OFFLINE=1 make smoke`
3. `OFFLINE=1 make test`

Any mistake that requires Internet after step 1 will fail the build.

---

#### 5.  Keep docs in sync

Whenever you add new plugins, commands, flags or change parameters, update the
`README.md` accordingly. Document new usage, options and any additional
prerequisites so others can reproduce the environment offline. If you create or
move files, adjust the file tree section of the README so it reflects the
current layout.

---

Happy hacking — 100 % reproducible, 100 % offline!

