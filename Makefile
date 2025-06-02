.PHONY: smoke offline

smoke: ## lightweight head-less check
	@./scripts/smoke_test.sh

offline: ## bootstrap unless OFFLINE=1
	@if [ "$${OFFLINE:-0}" -eq 1 ]; then \
	echo "(offline mode – skipping bootstrap)"; \
	else \
	./scripts/bootstrap.sh; \
	fi

