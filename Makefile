.PHONY: smoke setup-offline
smoke: ## lightweight test usable after network cutoff
	@./scripts/smoke_test.sh
setup-offline: ## placeholder – will run entrypoint_bootstrap in later tasks
	@echo "(setup-offline not implemented yet)"
