#!/bin/bash
# ============================================================
# Nix 安装验证测试脚本 (nix profile 版本)
# ============================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 计数器
PASSED=0
FAILED=0
TOTAL=0

# 测试函数
test_command() {
    local name="$1"
    local cmd="$2"
    local description="$3"

    TOTAL=$((TOTAL + 1))

    echo -n "测试 $name ($description)... "

    if eval "$cmd" &> /dev/null; then
        echo -e "${GREEN}通过${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}失败${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

test_tool_exists() {
    local tool="$1"
    local description="$2"

    TOTAL=$((TOTAL + 1))

    echo -n "检查 $tool ($description)... "

    if command -v "$tool" &> /dev/null; then
        local path=$(which "$tool")
        echo -e "${GREEN}存在${NC} - $path"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}不存在${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# ============================================================
# 开始测试
# ============================================================
echo ""
echo "========================================"
echo "  Nix 安装验证测试 (nix profile 版本)"
echo "========================================"
echo ""

# 加载 Nix 环境
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# ----------------------------------------------------------
echo -e "${BLUE}[1/5] 基础环境测试${NC}"
echo "----------------------------------------"
test_command "Nix 安装" "nix --version" "Nix 包管理器"
test_command "Flakes 支持" "nix flake --help" "Nix Flakes"
test_command "nix profile" "nix profile list" "包管理"
echo ""

# ----------------------------------------------------------
echo -e "${BLUE}[2/5] 核心工具测试${NC}"
echo "----------------------------------------"
test_tool_exists "eza" "ls 替代品"
test_tool_exists "bat" "cat 替代品"
test_tool_exists "fzf" "模糊搜索"
test_tool_exists "zoxide" "目录跳转"
test_tool_exists "rg" "ripgrep 搜索"
test_tool_exists "fd" "find 替代品"
test_tool_exists "sd" "sed 替代品"
test_tool_exists "broot" "目录树浏览"
echo ""

# ----------------------------------------------------------
echo -e "${BLUE}[3/5] 系统监控工具测试${NC}"
echo "----------------------------------------"
test_tool_exists "htop" "进程监视器"
test_tool_exists "btop" "系统监视器"
test_tool_exists "dust" "磁盘分析"
test_tool_exists "procs" "进程查看"
echo ""

# ----------------------------------------------------------
echo -e "${BLUE}[4/5] Git 和文件管理工具测试${NC}"
echo "----------------------------------------"
test_tool_exists "git" "版本控制"
test_tool_exists "lazygit" "Git UI"
test_tool_exists "delta" "Git diff"
test_tool_exists "ranger" "文件管理器"
test_tool_exists "ncdu" "磁盘分析"
echo ""

# ----------------------------------------------------------
echo -e "${BLUE}[5/5] 终端和开发工具测试${NC}"
echo "----------------------------------------"
test_tool_exists "tmux" "终端复用"
test_tool_exists "nvim" "Neovim 编辑器"
test_tool_exists "jq" "JSON 处理"
test_tool_exists "tldr" "命令手册"
test_tool_exists "neofetch" "系统信息"
echo ""

# ============================================================
# 功能测试
# ============================================================
echo -e "${BLUE}[额外] 功能验证${NC}"
echo "----------------------------------------"
test_command "eza 列出文件" "eza --version" "eza"
test_command "bat 显示文件" "echo 'test' | bat --plain" "bat"
test_command "fzf 版本" "fzf --version" "fzf"
test_command "ripgrep 版本" "rg --version" "ripgrep"
test_command "neovim 版本" "nvim --version" "neovim"
echo ""

# ============================================================
# 镜像源验证
# ============================================================
echo -e "${BLUE}[镜像源] 验证中国镜像配置${NC}"
echo "----------------------------------------"
if [ -f "$HOME/.config/nix/nix.conf" ]; then
    if grep -q "mirrors.tuna.tsinghua.edu.cn" "$HOME/.config/nix/nix.conf"; then
        echo -e "清华镜像源: ${GREEN}已配置${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "清华镜像源: ${RED}未配置${NC}"
        FAILED=$((FAILED + 1))
    fi
    TOTAL=$((TOTAL + 1))
else
    echo -e "nix.conf: ${RED}不存在${NC}"
    FAILED=$((FAILED + 1))
    TOTAL=$((TOTAL + 1))
fi
echo ""

# ============================================================
# 测试结果汇总
# ============================================================
echo "========================================"
echo "  测试结果汇总"
echo "========================================"
echo ""
echo -e "总测试数: ${BLUE}$TOTAL${NC}"
echo -e "通过: ${GREEN}$PASSED${NC}"
echo -e "失败: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  所有测试通过! Nix 环境配置成功!${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 0
else
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  有 $FAILED 个测试失败${NC}"
    echo -e "${YELLOW}========================================${NC}"
    exit 1
fi
