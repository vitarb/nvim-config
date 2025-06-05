### AGENTS.md

**Quick guide for using this repo inside the CI container (or locally).**

---

#### 1.  Bootstrap once

```bash
make offline   # downloads Neovim + tools, caches them in ./.tools
Running make offline multiple times is safe; it simply skips work if the
tool-chain is already present.

2. Day-to-day commands
make smoke   # head-less “does it run?” check → prints “SMOKE OK”
make test    # full head-less config test     → prints “TEST OK”
make lint    # Stylua + ShellCheck            → prints “LINT OK”
make format  # Fix formatting (run it if lint gives formatting errors)
They run quickly and fail fast on any error.

3. Optional helpers
make clean        # wipe ./.tools + ./.cache (forces a fresh bootstrap next time)
make docker-image # build the dev image locally (Ubuntu 22.04 with build deps)
4. CI reference
.github/workflows/test.yml does exactly this:

make offline
make smoke
make test
make lint

If any step fails, the PR is blocked.

5. Adding new dependencies
If you introduce a plugin, linter, or external tool:

Add it to lua/plugins.lua (or extend bootstrap.py if it must be pre-downloaded).

Run the four commands above locally— they must all succeed.

Update README.md (and this file) so others know how to use the new feature.

Happy hacking — reproducible and CI-verified!

### Extending the configuration

When you add or remove hot-keys, also update the test matrix.
Hot-key list lives in README; tests parse it automatically, so remember to update both together.

### Hotkeys added in this repo

* `'gh` – Stage Git hunk
* `'gl` – Reset Git hunk
* `'gp` – Preview Git hunk
* `<C-Tab>` – Next buffer
* `<C-S-Tab>` – Previous buffer

Whenever you add, remove, or change a shortcut in *Common hotkeys* of `README.md`, add or update the matching test in `scripts/test.sh` so CI still passes.
