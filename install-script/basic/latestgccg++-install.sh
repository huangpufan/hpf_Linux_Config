#!/usr/bin/env bash
# basic/latestgccg++-install.sh - GCC 安装脚本
# - Ubuntu 24.04: 系统自带 GCC 13（build-essential），无需额外安装
# - Ubuntu 22.04/20.04: 安装 GCC 11（较新可用的版本）
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

install_gcc11() {
    log_info "Installing GCC 11..."

    # 非 24.04 才需要添加 PPA
    . /etc/os-release
    if [ "${VERSION_ID:-}" != "24.04" ]; then
        DEBIAN_FRONTEND=noninteractive sudo apt install -y software-properties-common
        sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
        sudo apt update
    fi

    DEBIAN_FRONTEND=noninteractive sudo apt install -y gcc-11 g++-11
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60 --slave g++ /usr/bin/g++ g++-11

    log_info "GCC 11 安装完成"
    gcc --version | head -1
}

install_gcc13() {
    log_info "Ubuntu 24.04: installing GCC 13 (distro default)..."

    DEBIAN_FRONTEND=noninteractive sudo apt install -y gcc-13 g++-13
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 60 --slave g++ /usr/bin/g++ g++-13

    log_info "GCC 13 安装完成"
    gcc --version | head -1
}

main() {
    . /etc/os-release

    local version="${VERSION_ID:-}"

    case "$version" in
        "24.04")
            # 检查是否已经有可用的 gcc（build-essential 自带 gcc-13）
            if command -v gcc >/dev/null 2>&1; then
                local current
                current=$(gcc --version | grep '^gcc' | sed 's/^.* //g' || echo "")
                if echo "$current" | grep -qE '^1[3-9]\.'; then
                    log_info "GCC $current is already installed (distro default), skipping"
                    exit 0
                fi
            fi
            install_gcc13
            ;;
        "22.04"|"20.04")
            if command -v gcc >/dev/null 2>&1; then
                local current
                current=$(gcc --version | grep '^gcc' | sed 's/^.* //g' || echo "")
                if echo "$current" | grep -qE '^11\.'; then
                    log_info "GCC $current is already installed, skipping"
                    exit 0
                fi
            fi
            install_gcc11
            ;;
        *)
            log_err "Unsupported Ubuntu version: ${version:-unknown}"
            exit 1
            ;;
    esac
}

main "$@"
