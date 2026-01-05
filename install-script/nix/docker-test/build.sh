#!/bin/bash
# ============================================================
# Docker 测试环境构建脚本
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_DIR="$(dirname "$SCRIPT_DIR")"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

IMAGE_NAME="hpf-nix-test"
IMAGE_TAG="latest"

echo ""
echo "========================================"
echo "  Nix Docker 测试环境构建"
echo "========================================"
echo ""

# 检查 Docker 是否可用
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装或不可用"
    exit 1
fi

# 复制必要的文件到 docker-test 目录
log_info "复制配置文件..."
cp "$NIX_DIR/install-nix.sh" "$SCRIPT_DIR/"
cp "$NIX_DIR/home.nix" "$SCRIPT_DIR/"
cp "$NIX_DIR/flake.nix" "$SCRIPT_DIR/"

# 设置执行权限
chmod +x "$SCRIPT_DIR"/*.sh

# 构建 Docker 镜像
log_info "开始构建 Docker 镜像 (这可能需要 10-20 分钟)..."
log_info "镜像名称: $IMAGE_NAME:$IMAGE_TAG"
echo ""

cd "$SCRIPT_DIR"

# 构建镜像
docker build \
    --progress=plain \
    -t "$IMAGE_NAME:$IMAGE_TAG" \
    .

log_success "Docker 镜像构建完成！"
echo ""
echo "========================================"
echo "  使用方法"
echo "========================================"
echo ""
echo "1. 运行测试:"
echo "   ./run-test.sh"
echo ""
echo "2. 进入容器交互:"
echo "   docker run -it --rm $IMAGE_NAME:$IMAGE_TAG bash"
echo ""
echo "3. 运行验证测试:"
echo "   docker run -it --rm $IMAGE_NAME:$IMAGE_TAG ./nix-config/test-installation.sh"
echo ""
echo "========================================"
