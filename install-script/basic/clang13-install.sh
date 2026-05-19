#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "[ERROR] $0:$LINENO: $BASH_COMMAND" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

KEYRING_FILE="/usr/share/keyrings/llvm-archive-keyring.gpg"
LIST_FILE="/etc/apt/sources.list.d/llvm-13.list"

ensure_legacy_repo_prereqs() {
    local packages=()

    command -v wget >/dev/null 2>&1 || packages+=(wget)
    command -v gpg >/dev/null 2>&1 || packages+=(gpg)

    if [ "${#packages[@]}" -gt 0 ]; then
        sudo apt update
        sudo apt install -y "${packages[@]}"
    fi
}

ensure_legacy_repo() {
    local codename="$1"
    local deb_line="deb [signed-by=$KEYRING_FILE] http://apt.llvm.org/$codename/ llvm-toolchain-$codename-13 main"

    ensure_legacy_repo_prereqs

    if [ ! -f "$KEYRING_FILE" ]; then
        echo "添加 LLVM GPG 密钥..."
        wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo gpg --dearmor -o "$KEYRING_FILE"
    fi

    if ! grep -qsF "$deb_line" "$LIST_FILE" 2>/dev/null; then
        echo "添加 LLVM 仓库..."
        echo "$deb_line" | sudo tee "$LIST_FILE" >/dev/null
    fi
}

install_legacy_clang13() {
    local codename="$1"

    if command -v clang-13 >/dev/null 2>&1 && command -v lldb-13 >/dev/null 2>&1 && command -v lld-13 >/dev/null 2>&1; then
        echo "clang-13 toolchain is already installed."
        exit 0
    fi

    echo "检测到系统代号: $codename"
    ensure_legacy_repo "$codename"
    sudo apt update
    sudo apt install -y clang-13 lldb-13 lld-13
    sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-13 100
    sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-13 100
    sudo update-alternatives --install /usr/bin/cc cc /usr/bin/clang-13 100
    sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-13 100

    echo "clang-13 安装完成！"
}

install_noble_clang() {
    if command -v clang >/dev/null 2>&1 && command -v lldb >/dev/null 2>&1 && command -v lld >/dev/null 2>&1; then
        echo "Ubuntu 24.04 distro clang toolchain is already installed."
        exit 0
    fi

    echo "Ubuntu 24.04 使用发行版自带 clang/lldb/lld"
    sudo apt update
    sudo apt install -y clang lldb lld

    if command -v clang >/dev/null 2>&1; then
        sudo update-alternatives --install /usr/bin/cc cc "$(command -v clang)" 100
    fi
    if command -v clang++ >/dev/null 2>&1; then
        sudo update-alternatives --install /usr/bin/c++ c++ "$(command -v clang++)" 100
    fi

    echo "Ubuntu 24.04 clang 工具链安装完成！"
}

main() {
    local ubuntu_version
    local codename

    ubuntu_version="$(ubuntu_version_id)"
    codename="$(ubuntu_codename)"

    case "$ubuntu_version" in
        "20.04"|"22.04")
            install_legacy_clang13 "$codename"
            ;;
        "24.04")
            install_noble_clang
            ;;
        *)
            echo "[ERROR] Unsupported Ubuntu version: ${ubuntu_version:-unknown}"
            exit 1
            ;;
    esac
}

main "$@"
