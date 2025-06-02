.PHONY: smoke setup-offline
smoke: ## lightweight test usable after network cutoff
	@./scripts/smoke_test.sh

offline:  ## run bootstrap unless OFFLINE=1
	@if [ "$${OFFLINE:-0}" -eq 1 ]; then \
		echo "(offline mode – skipping bootstrap)"; \
	else \
		./scripts/bootstrap.sh; \
	fi

