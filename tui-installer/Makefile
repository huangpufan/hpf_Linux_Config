.PHONY: help run test lint format clean build venv

# Paths
VENV := .venv
PYTHON := $(VENV)/bin/python
UV := uv

# Default target
help:
	@echo "TUI Installer - 可用命令"
	@echo ""
	@echo "  make run          运行安装器 (自动配置环境)"
	@echo "  make test         运行测试"
	@echo "  make lint         代码检查"
	@echo "  make format       代码格式化"
	@echo "  make clean        清理缓存文件"
	@echo "  make build        构建分发包"
	@echo ""

# Create venv and install dependencies (automatic, no user action needed)
$(VENV)/.installed: pyproject.toml
	@if ! command -v $(UV) >/dev/null 2>&1; then \
		echo "错误: 需要安装 uv (https://docs.astral.sh/uv/)"; \
		exit 1; \
	fi
	@echo "正在配置虚拟环境..."
	@$(UV) venv $(VENV) --quiet
	@$(UV) pip install -e . --quiet
	@touch $(VENV)/.installed
	@echo "环境配置完成"

# Run the installer (fully automatic: venv + deps + sudo + run)
run: $(VENV)/.installed
	@sudo -v && $(PYTHON) -m tui_installer

# Run tests
test: $(VENV)/.installed
	@$(UV) pip install -e ".[dev]" --quiet
	@$(PYTHON) -m pytest -v

# Run tests with coverage
test-cov: $(VENV)/.installed
	@$(UV) pip install -e ".[dev]" --quiet
	@$(PYTHON) -m pytest --cov=tui_installer --cov-report=term-missing

# Lint code
lint: $(VENV)/.installed
	@$(UV) pip install -e ".[dev]" --quiet
	@$(PYTHON) -m ruff check tui_installer tests
	@$(PYTHON) -m mypy tui_installer

# Format code
format: $(VENV)/.installed
	@$(UV) pip install -e ".[dev]" --quiet
	@$(PYTHON) -m ruff format tui_installer tests
	@$(PYTHON) -m ruff check --fix tui_installer tests

# Clean cache and build files
clean:
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	rm -rf .ruff_cache/
	rm -rf $(VENV)/
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete

# Build distribution package
build: $(VENV)/.installed clean
	@$(PYTHON) -m build

# Interactive keyboard test
test-keys: $(VENV)/.installed
	@$(PYTHON) scripts/test_keys.py
