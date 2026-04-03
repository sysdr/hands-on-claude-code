.PHONY: start demo verify cleanup test

start:
	@bash ./start.sh

stop:
	@bash ./stop.sh

demo:
	@bash scripts/demo.sh

verify:
	@bash scripts/run_verify.sh

test: verify

cleanup:
	@rm -f src/project-fingerprint.json
	@rm -rf tests/__pycache__
	@echo "Workspace reset."
