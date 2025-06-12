#───────────────────────────────────────────────────────────────────────────────
#  Neovim mini-config – make targets
#───────────────────────────────────────────────────────────────────────────────
.PHONY: offline smoke test lint luacheck clean docker-image

#-------------------------------------------------------------
# build or update the tool-chain in .tools/  (downloads once)
#-------------------------------------------------------------
offline:           ## bootstrap Neovim + plugins (skipped with OFFLINE=1)
ifeq ($(OFFLINE),1)
	@echo "(offline mode – skipping bootstrap)"
else
	@python3 bootstrap.py
endif

#-------------------------------------------------------------
# ultra-fast “does it start at all?” check (depends on offline)
#-------------------------------------------------------------
smoke: offline     ## head-less start; prints “SMOKE OK” on success
	@./scripts/smoke_test.sh

#-------------------------------------------------------------
# full self-test (always offline; fails on any error message)
#-------------------------------------------------------------
test: offline      ## ensure Neovim starts cleanly
ifeq ($(DOCKER),1)
	$(call run_in_docker,make test DOCKER=0)
else
	@./scripts/test.sh
endif

#-------------------------------------------------------------
# lint Lua & shell scripts
#-------------------------------------------------------------
lint: offline luacheck ## run Stylua, Luacheck & ShellCheck
ifeq ($(DOCKER),1)
	$(call run_in_docker,make lint DOCKER=0)
else
	@.tools/bin/stylua --check init.lua lua
	@.tools/bin/luacheck init.lua lua
	@if [ -d scripts ] && ls scripts/*.sh >/dev/null 2>&1; then \
	  .tools/bin/shellcheck scripts/*.sh; \
	fi
	@echo "LINT OK"
endif

luacheck: offline ## run Lua static analysis
ifeq ($(DOCKER),1)
        $(call run_in_docker,make luacheck DOCKER=0)
else
	        @.tools/bin/luacheck init.lua lua
endif

#-------------------------------------------------------------
# format helper – beautify sources in-place
#-------------------------------------------------------------
format: offline   ## stylua + shfmt rewrite
ifeq ($(DOCKER),1)
	$(call run_in_docker,make format DOCKER=0)
else
	@.tools/bin/stylua init.lua lua
	@if command -v .tools/bin/shfmt >/dev/null 2>&1; then \
	  .tools/bin/shfmt -w scripts 2>/dev/null || true; \
	else \
	  echo "(shfmt not present – skipped shell formatting)"; \
	fi
endif

#-------------------------------------------------------------
# clean everything produced by bootstrap (tools + caches)
#-------------------------------------------------------------
clean:             ## remove downloaded Neovim & caches
	rm -rf .tools .cache

#-------------------------------------------------------------
# Docker helpers
#-------------------------------------------------------------
IMAGE      ?= nvim-config-dev
DOCKERFILE ?= Dockerfile

docker-image:      ## build image with all build deps (ubuntu:22.04)
	docker build -t $(IMAGE) -f $(DOCKERFILE) .

run_in_docker = docker run --rm \
	-e OFFLINE="$(OFFLINE)" -e NVIM_OFFLINE_BOOT="$(NVIM_OFFLINE_BOOT)" \
	-v $(CURDIR):/workspace -w /workspace $(IMAGE) /bin/sh -c '$1'

# let `make <target> DOCKER=1` transparently run inside the container
# (targets above use $(call run_in_docker,...) when DOCKER=1)

