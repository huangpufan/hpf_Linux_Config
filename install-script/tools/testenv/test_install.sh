#!/usr/bin/env bash
# 在 Docker 容器中实际执行安装脚本测试
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

IMAGE="${1:-ubuntu:22.04}"
TIMEOUT="${2:-300}"  # 默认5分钟超时

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[PASS]${NC} $*"; }
fail()    { echo -e "${RED}[FAIL]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }

# 检查 Docker
if ! command -v docker >/dev/null 2>&1; then
    fail "Docker 未安装"
    exit 1
fi

echo "========================================"
echo "  install-script 实际安装测试"
echo "========================================"
echo "镜像: $IMAGE"
echo "超时: ${TIMEOUT}s"
echo ""

# 创建测试结果目录
RESULTS_DIR="$REPO_ROOT/tools/testenv/test-results"
mkdir -p "$RESULTS_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RESULT_FILE="$RESULTS_DIR/install-test-$TIMESTAMP.log"

# 生成容器内测试脚本
generate_test_script() {
    cat << 'INNER_SCRIPT'
#!/bin/bash
set -Euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0
SKIPPED=0

log_pass() { echo -e "${GREEN}[PASS]${NC} $*"; ((PASSED++)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $*"; ((FAILED++)); }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $*"; ((SKIPPED++)); }
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }

# 测试单个脚本
test_script() {
    local script="$1"
    local name="$2"
    local timeout="${3:-120}"
    
    echo ""
    echo "========================================"
    log_info "测试: $name"
    echo "脚本: $script"
    echo "----------------------------------------"
    
    if [ ! -f "$script" ]; then
        log_fail "$name - 脚本不存在"
        return 1
    fi
    
    # 执行脚本
    local start_time=$(date +%s)
    local output
    local exit_code=0
    
    cd "$(dirname "$script")"
    output=$(timeout "$timeout" bash "$(basename "$script")" 2>&1) || exit_code=$?
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [ $exit_code -eq 0 ]; then
        log_pass "$name (${duration}s)"
    elif [ $exit_code -eq 124 ]; then
        log_fail "$name - 超时 (>${timeout}s)"
        echo "$output" | tail -20
    else
        log_fail "$name - 退出码: $exit_code"
        echo "$output" | tail -30
    fi
    
    return $exit_code
}

# 准备环境
log_info "准备测试环境..."
export DEBIAN_FRONTEND=noninteractive
export HOME=/root

# 安装基础依赖
apt update -y
apt install -y sudo git make curl wget ca-certificates xz-utils software-properties-common

# 创建必要目录
mkdir -p ~/.local/bin ~/.config

# 设置 PATH
export PATH="$HOME/.local/bin:$PATH"

# 复制工作目录
cp -a /mnt/ws/. /root/ws/
cd /root/ws

echo ""
echo "========================================"
echo "  开始测试安装脚本"
echo "========================================"

# ========================================
# 测试 1: basic/latestgccg++-install.sh
# ========================================
test_script "/root/ws/basic/latestgccg++-install.sh" "GCC 11 安装" 180 || true

# 验证安装
if command -v gcc >/dev/null 2>&1; then
    gcc_ver=$(gcc --version | head -1)
    log_info "GCC 版本: $gcc_ver"
fi

# ========================================
# 测试 2: basic/git-install.sh (FZF)
# ========================================
test_script "/root/ws/basic/git-install.sh" "FZF 安装" 60 || true

# 验证
if command -v fzf >/dev/null 2>&1; then
    log_info "FZF 已安装: $(fzf --version)"
fi

# ========================================
# 测试 3: basic/clang13-install.sh
# ========================================
test_script "/root/ws/basic/clang13-install.sh" "Clang 13 安装" 180 || true

# 验证
if command -v clang-13 >/dev/null 2>&1 || command -v clang >/dev/null 2>&1; then
    log_info "Clang 已安装"
fi

# ========================================
# 测试 4: basic/cargo-install.sh
# ========================================
test_script "/root/ws/basic/cargo-install.sh" "Cargo + Rust 工具安装" 300 || true

# 验证
if command -v cargo >/dev/null 2>&1; then
    log_info "Cargo 已安装: $(cargo --version)"
fi

# ========================================
# 测试 5: nvim/nvim-install.sh (部分测试)
# ========================================
# nvim 安装脚本有些依赖，我们测试核心部分
log_info "测试 Neovim 下载安装..."
cd /root/ws/nvim

# 安装 nvim 依赖
apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl || true

# 只测试 nvim 二进制下载部分
NEOVIM_VERSION="0.10.4"
URL="https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz"
WORKDIR="$(mktemp -d)"
pushd "$WORKDIR" >/dev/null
if curl -fL -o nvim.tar.gz "$URL" && tar -xzf nvim.tar.gz; then
    DEST_DIR="$HOME/.local/nvim-${NEOVIM_VERSION}"
    rm -rf "$DEST_DIR"
    mkdir -p "$DEST_DIR"
    cp -a nvim-linux-x86_64/. "$DEST_DIR/"
    mkdir -p "$HOME/.local/bin"
    ln -sfn "$DEST_DIR/bin/nvim" "$HOME/.local/bin/nvim"
    popd >/dev/null
    rm -rf "$WORKDIR"
    log_pass "Neovim $NEOVIM_VERSION 下载安装"
    "$HOME/.local/bin/nvim" --version | head -1
else
    popd >/dev/null
    log_fail "Neovim 下载安装失败"
fi

# ========================================
# 测试 6: basic/tmux 配置
# ========================================
cd /root/ws/basic/tmux
log_info "测试 tmux 配置安装..."
apt install -y tmux || true

if [ -f "tmux.conf" ]; then
    rm -f ~/.tmux.conf
    cp tmux.conf ~/.tmux.conf
    log_pass "Tmux 配置安装"
else
    log_fail "Tmux 配置文件不存在"
fi

# ========================================
# 测试 7: basic/pip-install.sh
# ========================================
cd /root/ws/basic
if [ -f "pip-install.sh" ]; then
    test_script "/root/ws/basic/pip-install.sh" "Pip 包安装" 120 || true
fi

# ========================================
# 测试 8: basic/npm-install.sh
# ========================================
if [ -f "npm-install.sh" ]; then
    # 先安装 npm
    apt install -y npm nodejs || true
    test_script "/root/ws/basic/npm-install.sh" "NPM 包安装" 120 || true
fi

# ========================================
# 测试总结
# ========================================
echo ""
echo "========================================"
echo "  测试总结"
echo "========================================"
echo -e "  通过: ${GREEN}$PASSED${NC}"
echo -e "  失败: ${RED}$FAILED${NC}"
echo -e "  跳过: ${YELLOW}$SKIPPED${NC}"
echo "========================================"

# 列出已安装的工具
echo ""
log_info "已安装工具验证:"
echo "----------------------------------------"
command -v gcc && gcc --version | head -1 || echo "gcc: 未安装"
command -v g++ && g++ --version | head -1 || echo "g++: 未安装"
command -v clang && clang --version | head -1 || echo "clang: 未安装"
command -v fzf && echo "fzf: $(fzf --version)" || echo "fzf: 未安装"
command -v cargo && cargo --version || echo "cargo: 未安装"
command -v nvim && nvim --version | head -1 || echo "nvim: 未安装"
command -v tmux && tmux -V || echo "tmux: 未安装"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
exit 0
INNER_SCRIPT
}

# 运行 Docker 测试
info "启动 Docker 容器..."

docker run --rm \
    -v "$REPO_ROOT:/mnt/ws:ro" \
    -e DEBIAN_FRONTEND=noninteractive \
    "$IMAGE" \
    bash -c "$(generate_test_script)" 2>&1 | tee "$RESULT_FILE"

EXIT_CODE=${PIPESTATUS[0]}

echo ""
info "测试日志保存到: $RESULT_FILE"

if [ $EXIT_CODE -eq 0 ]; then
    success "所有测试通过！"
else
    fail "存在失败的测试"
fi

exit $EXIT_CODE

