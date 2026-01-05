#!/bin/bash
# ============================================================
# 运行 Docker 测试
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="hpf-nix-test"
IMAGE_TAG="latest"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo "========================================"
echo "  Nix 安装测试"
echo "========================================"
echo ""

# 检查镜像是否存在
if ! docker image inspect "$IMAGE_NAME:$IMAGE_TAG" &> /dev/null; then
    log_error "镜像 $IMAGE_NAME:$IMAGE_TAG 不存在"
    log_info "请先运行 ./build.sh 构建镜像"
    exit 1
fi

# 解析参数
MODE="test"
while [[ $# -gt 0 ]]; do
    case $1 in
        --interactive|-i)
            MODE="interactive"
            shift
            ;;
        --shell|-s)
            MODE="shell"
            shift
            ;;
        --help|-h)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --interactive, -i  交互式运行测试"
            echo "  --shell, -s        进入容器 shell"
            echo "  --help, -h         显示帮助"
            exit 0
            ;;
        *)
            log_error "未知选项: $1"
            exit 1
            ;;
    esac
done

case $MODE in
    test)
        log_info "运行自动化测试..."
        docker run --rm "$IMAGE_NAME:$IMAGE_TAG" ./nix-config/test-installation.sh
        ;;
    interactive)
        log_info "交互式运行测试..."
        docker run -it --rm "$IMAGE_NAME:$IMAGE_TAG" ./nix-config/test-installation.sh
        ;;
    shell)
        log_info "进入容器 shell..."
        docker run -it --rm "$IMAGE_NAME:$IMAGE_TAG" bash
        ;;
esac

log_success "测试完成！"
