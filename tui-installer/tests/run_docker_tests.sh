#!/bin/bash
# TUI Installer Docker 测试脚本
# 使用 Ubuntu 容器运行全面测试

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
TUI Installer Docker 测试脚本

用法: $0 [选项] [测试类型]

测试类型:
  all         运行所有测试 (默认)
  unit        仅运行单元测试
  integration 仅运行集成测试
  coverage    运行测试并生成覆盖率报告
  lint        运行代码检查
  shell       启动交互式 shell 进行调试

选项:
  -h, --help     显示此帮助信息
  -b, --build    强制重新构建 Docker 镜像
  -v, --verbose  显示详细输出
  -k PATTERN     只运行匹配模式的测试

示例:
  $0                    # 运行所有测试
  $0 unit               # 只运行单元测试
  $0 coverage           # 生成覆盖率报告
  $0 -b all             # 重新构建镜像并运行所有测试
  $0 -k "test_execute"  # 只运行包含 test_execute 的测试
EOF
}

# 解析参数
FORCE_BUILD=false
VERBOSE=false
TEST_PATTERN=""
TEST_TYPE="all"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--build)
            FORCE_BUILD=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -k)
            TEST_PATTERN="$2"
            shift 2
            ;;
        all|unit|integration|coverage|lint|shell)
            TEST_TYPE="$1"
            shift
            ;;
        *)
            error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

# 检查 Docker 是否可用
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker 未安装或不在 PATH 中"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        error "Docker 守护进程未运行"
        exit 1
    fi
    
    info "Docker 环境检查通过"
}

# 构建测试镜像
build_image() {
    local image_name="tui-installer-test"
    
    # 检查镜像是否存在
    if ! $FORCE_BUILD && docker image inspect "$image_name" &> /dev/null; then
        info "使用已有镜像: $image_name"
        return 0
    fi
    
    info "构建测试镜像..."
    
    cd "$PROJECT_DIR"
    docker build -t "$image_name" -f tests/Dockerfile .
    
    success "镜像构建完成: $image_name"
}

# 创建测试结果目录
setup_results_dir() {
    local results_dir="$SCRIPT_DIR/test-results"
    mkdir -p "$results_dir"
    echo "$results_dir"
}

# 运行所有测试
run_all_tests() {
    info "运行所有测试..."
    
    local results_dir=$(setup_results_dir)
    local extra_args=""
    
    if [ -n "$TEST_PATTERN" ]; then
        extra_args="-k $TEST_PATTERN"
    fi
    
    if $VERBOSE; then
        extra_args="$extra_args -v --tb=long"
    else
        extra_args="$extra_args --tb=short"
    fi
    
    docker run --rm \
        -v "$PROJECT_DIR:/workspace/tui-installer:ro" \
        -v "$results_dir:/workspace/test-results" \
        -e PYTHONPATH=/workspace/tui-installer \
        tui-installer-test \
        pytest $extra_args \
        --junitxml=/workspace/test-results/junit.xml \
        -o junit_family=xunit2
    
    success "所有测试完成！结果保存在: $results_dir"
}

# 运行单元测试
run_unit_tests() {
    info "运行单元测试..."
    
    local extra_args=""
    if [ -n "$TEST_PATTERN" ]; then
        extra_args="-k $TEST_PATTERN"
    fi
    
    docker run --rm \
        -v "$PROJECT_DIR:/workspace/tui-installer:ro" \
        -e PYTHONPATH=/workspace/tui-installer \
        tui-installer-test \
        pytest -v --tb=short $extra_args \
        tests/test_models.py \
        tests/test_config.py \
        tests/test_executor.py \
        tests/test_system.py \
        tests/test_input.py
    
    success "单元测试完成！"
}

# 运行集成测试
run_integration_tests() {
    info "运行集成测试..."
    
    local extra_args=""
    if [ -n "$TEST_PATTERN" ]; then
        extra_args="-k $TEST_PATTERN"
    fi
    
    docker run --rm \
        -v "$PROJECT_DIR:/workspace/tui-installer:ro" \
        -e PYTHONPATH=/workspace/tui-installer \
        tui-installer-test \
        pytest -v --tb=short $extra_args \
        tests/test_integration.py \
        tests/test_app.py
    
    success "集成测试完成！"
}

# 运行覆盖率测试
run_coverage_tests() {
    info "运行覆盖率测试..."
    
    local results_dir=$(setup_results_dir)
    
    # 使用可写的挂载方式，先复制到容器内部
    docker run --rm \
        -v "$PROJECT_DIR:/workspace/tui-installer-src:ro" \
        -v "$results_dir:/workspace/test-results" \
        -e PYTHONPATH=/workspace/tui-installer \
        tui-installer-test \
        sh -c "cp -r /workspace/tui-installer-src /tmp/tui-installer && \
               cd /tmp/tui-installer && \
               pip install -e . --quiet && \
               pytest -v \
               --cov=tui_installer \
               --cov-report=term-missing \
               --cov-report=html:/workspace/test-results/coverage \
               --cov-report=xml:/workspace/test-results/coverage.xml"
    
    success "覆盖率测试完成！"
    info "HTML 报告: $results_dir/coverage/index.html"
    info "XML 报告: $results_dir/coverage.xml"
}

# 运行代码检查
run_lint() {
    info "运行代码检查..."
    
    # 使用临时目录避免只读问题
    docker run --rm \
        -v "$PROJECT_DIR:/workspace/tui-installer-src:ro" \
        -e PYTHONPATH=/tmp/tui-installer \
        tui-installer-test \
        sh -c "cp -r /workspace/tui-installer-src /tmp/tui-installer && \
               cd /tmp/tui-installer && \
               pip install -e . --quiet && \
               ruff check tui_installer tests && echo '✓ Ruff 检查通过' && \
               mypy tui_installer && echo '✓ MyPy 检查通过'"
    
    success "代码检查完成！"
}

# 启动交互式 shell
run_shell() {
    info "启动交互式 shell..."
    warn "提示: 输入 'exit' 退出"
    
    docker run --rm -it \
        -v "$PROJECT_DIR:/workspace/tui-installer" \
        -e PYTHONPATH=/workspace/tui-installer \
        -e TERM=xterm-256color \
        tui-installer-test \
        /bin/bash
}

# 主函数
main() {
    echo ""
    echo "========================================"
    echo "  TUI Installer Docker 测试"
    echo "========================================"
    echo ""
    
    check_docker
    build_image
    
    echo ""
    
    case $TEST_TYPE in
        all)
            run_all_tests
            ;;
        unit)
            run_unit_tests
            ;;
        integration)
            run_integration_tests
            ;;
        coverage)
            run_coverage_tests
            ;;
        lint)
            run_lint
            ;;
        shell)
            run_shell
            ;;
    esac
    
    echo ""
    success "测试运行完成！"
}

main

