#!/bin/bash
# ============================================================
# Nix 安装脚本 (含中国镜像源配置)
# 支持: Ubuntu, Debian, Fedora, CentOS, Arch, 等
# 已通过 Docker 端到端验证
# ============================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查是否以 root 运行
check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        log_error "请不要以 root 用户运行此脚本"
        log_info "Nix 支持单用户模式安装，无需 root 权限"
        exit 1
    fi
}

# 检查必要的依赖
check_dependencies() {
    log_info "检查依赖..."

    local missing_deps=()

    for cmd in curl xz; do
        if ! command -v $cmd &> /dev/null; then
            missing_deps+=($cmd)
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_warn "缺少依赖: ${missing_deps[*]}"
        log_info "尝试安装依赖..."

        # 检测包管理器并安装
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y curl xz-utils
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y curl xz
        elif command -v yum &> /dev/null; then
            sudo yum install -y curl xz
        elif command -v pacman &> /dev/null; then
            sudo pacman -Sy --noconfirm curl xz
        else
            log_error "无法自动安装依赖，请手动安装: ${missing_deps[*]}"
            exit 1
        fi
    fi

    log_success "依赖检查完成"
}

# 安装 Nix (单用户模式)
install_nix() {
    log_info "开始安装 Nix (单用户模式)..."

    if [ -d "$HOME/.nix-profile" ]; then
        log_warn "检测到已安装 Nix，跳过安装"
        return 0
    fi

    # 使用官方安装脚本 (单用户模式，无需 root)
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

    log_success "Nix 安装完成"
}

# 配置中国镜像源 (已通过 Docker 验证)
configure_china_mirror() {
    log_info "配置中国镜像源 (清华 TUNA)..."

    # 创建 Nix 配置目录
    mkdir -p ~/.config/nix

    # 写入配置文件 (与 Docker 测试验证一致)
    cat > ~/.config/nix/nix.conf << 'EOF'
# Nix 配置文件 (已通过 Docker 端到端验证)
# 启用 Flakes 和 nix-command
experimental-features = nix-command flakes

# 中国镜像源配置 (清华大学 TUNA)
substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=

# 备用镜像源 (中科大 USTC)
# substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/

# 上海交大镜像 (备选)
# substituters = https://mirror.sjtu.edu.cn/nix-channels/store https://cache.nixos.org/

# 下载超时设置
connect-timeout = 15
download-attempts = 3

# 最大并行下载数
max-jobs = auto
cores = 0

# 保留构建依赖 (用于开发)
keep-outputs = true
keep-derivations = true
EOF

    log_success "镜像源配置完成 (使用清华 TUNA 源)"
}

# 安装常用工具 (使用 nix profile，已通过 Docker 验证)
install_packages() {
    log_info "安装常用工具 (使用 nix profile)..."

    # 加载 Nix 环境
    if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi

    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # 定义工具分组
    declare -A package_groups
    package_groups["核心工具"]="nixpkgs#eza nixpkgs#bat nixpkgs#fzf nixpkgs#zoxide nixpkgs#ripgrep"
    package_groups["更多工具"]="nixpkgs#fd nixpkgs#htop nixpkgs#btop nixpkgs#lazygit nixpkgs#delta"
    package_groups["文件管理"]="nixpkgs#ranger nixpkgs#broot nixpkgs#dust nixpkgs#ncdu"
    package_groups["终端工具"]="nixpkgs#tmux nixpkgs#neovim nixpkgs#jq nixpkgs#tldr"
    package_groups["其他工具"]="nixpkgs#sd nixpkgs#procs nixpkgs#git nixpkgs#neofetch"

    # 按分组安装
    for group in "核心工具" "更多工具" "文件管理" "终端工具" "其他工具"; do
        log_info "安装 $group..."
        if nix profile install ${package_groups[$group]}; then
            log_success "$group 安装完成"
        else
            log_warn "$group 部分包可能安装失败，继续..."
        fi
    done

    log_success "工具安装完成"
}

# 验证安装
verify_installation() {
    log_info "验证安装..."

    # 加载 Nix 环境
    if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi

    echo ""
    echo "=========================================="
    echo "Nix 版本:"
    nix --version

    echo ""
    echo "已安装的工具:"
    echo "----------------------------------------"

    local tools=(
        "eza:ls替代"
        "bat:cat替代"
        "fzf:模糊搜索"
        "zoxide:目录跳转"
        "lazygit:Git UI"
        "btop:系统监控"
        "nvim:编辑器"
        "rg:ripgrep搜索"
        "fd:find替代"
        "tmux:终端复用"
    )

    local passed=0
    local total=${#tools[@]}

    for tool_info in "${tools[@]}"; do
        local tool="${tool_info%%:*}"
        local desc="${tool_info##*:}"
        if command -v "$tool" &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} $tool ($desc)"
            passed=$((passed + 1))
        else
            echo -e "  ${RED}✗${NC} $tool ($desc) - 未安装"
        fi
    done

    echo "=========================================="
    echo -e "验证结果: ${GREEN}$passed${NC}/${BLUE}$total${NC} 工具可用"
    echo ""
}

# 显示使用说明
show_usage() {
    echo ""
    echo "=========================================="
    echo "安装完成！使用说明:"
    echo "=========================================="
    echo ""
    echo "1. 重新加载 shell 环境:"
    echo "   source ~/.nix-profile/etc/profile.d/nix.sh"
    echo ""
    echo "2. 或者重新打开终端"
    echo ""
    echo "3. 安装新包:"
    echo "   nix profile install nixpkgs#<package-name>"
    echo ""
    echo "4. 搜索可用包:"
    echo "   nix search nixpkgs <package-name>"
    echo ""
    echo "5. 临时使用某个包:"
    echo "   nix shell nixpkgs#<package-name>"
    echo ""
    echo "6. 更新所有包:"
    echo "   nix profile upgrade '.*'"
    echo ""
    echo "7. 列出已安装的包:"
    echo "   nix profile list"
    echo ""
    echo "=========================================="
}

# 主函数
main() {
    echo ""
    echo "=========================================="
    echo "  Nix 安装脚本 (已通过 Docker 端到端验证)"
    echo "  含中国镜像源配置 (清华 TUNA)"
    echo "=========================================="
    echo ""

    # 解析参数
    local skip_packages=false
    local only_nix=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-packages)
                skip_packages=true
                shift
                ;;
            --only-nix)
                only_nix=true
                shift
                ;;
            --help|-h)
                echo "用法: $0 [选项]"
                echo ""
                echo "选项:"
                echo "  --skip-packages    跳过工具包安装"
                echo "  --only-nix         只安装 Nix 和配置镜像源"
                echo "  --help, -h         显示帮助信息"
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                exit 1
                ;;
        esac
    done

    # 执行安装步骤
    check_not_root
    check_dependencies
    install_nix
    configure_china_mirror

    if [ "$only_nix" = true ]; then
        log_success "Nix 安装完成 (仅安装 Nix)"
        show_usage
        exit 0
    fi

    if [ "$skip_packages" = false ]; then
        install_packages
    fi

    verify_installation
    show_usage

    log_success "所有安装完成！"
}

# 运行主函数
main "$@"
