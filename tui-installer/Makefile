.PHONY: help install install-dev run test lint format clean build

# Default target
help:
	@echo "TUI Installer - 可用命令"
	@echo ""
	@echo "  make install      安装依赖"
	@echo "  make install-dev  安装开发依赖"
	@echo "  make run          运行安装器"
	@echo "  make test         运行测试"
	@echo "  make lint         代码检查"
	@echo "  make format       代码格式化"
	@echo "  make clean        清理缓存文件"
	@echo "  make build        构建分发包"
	@echo ""

# Install dependencies
install:
	pip install -e .

# Install with development dependencies
install-dev:
	pip install -e ".[dev]"

# Run the installer
run:
	python -m tui_installer

# Run tests
test:
	pytest -v

# Run tests with coverage
test-cov:
	pytest --cov=tui_installer --cov-report=term-missing

# Lint code
lint:
	ruff check tui_installer tests
	mypy tui_installer

# Format code
format:
	ruff format tui_installer tests
	ruff check --fix tui_installer tests

# Clean cache and build files
clean:
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	rm -rf .ruff_cache/
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete

# Build distribution package
build: clean
	python -m build

# Interactive keyboard test
test-keys:
	python scripts/test_keys.py

