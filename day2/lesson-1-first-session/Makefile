.PHONY: start stop demo verify cleanup test

REPO_DIR := sample-repo
PYTHON   := .venv/bin/python
PIP      := .venv/bin/pip

start:
	@bash ./start.sh

stop:
	@bash ./stop.sh

test:
	cd $(REPO_DIR) && $(PIP) install -e ".[dev]" -q && $(PYTHON) -m pytest tests/unit/ -v --tb=short

demo:
	@echo "=== Context inspector ==="
	./dashboard/context_inspector.sh $(REPO_DIR)
	@echo ""
	@echo "=== Pytest ==="
	cd $(REPO_DIR) && $(PIP) install -e ".[dev]" -q && $(PYTHON) -m pytest tests/unit/ -v --tb=short
	@echo ""
	@echo "=== Metrics server + demo traffic ==="
	bash ./start.sh
	sleep 1
	bash $(REPO_DIR)/scripts/demo_metrics.sh
	@echo "Open http://127.0.0.1:$${METRICS_PORT:-8765}/ — counters should be non-zero."

verify:
	cd $(REPO_DIR) && bash scripts/verify_session.sh
	@exit_code=$$?; exit $$exit_code

cleanup:
	@echo "Cleaning generated files..."
	find $(REPO_DIR) -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find $(REPO_DIR) -name "*.pyc" -delete 2>/dev/null || true
	find $(REPO_DIR) -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find $(REPO_DIR) -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@echo "Cleanup complete."
