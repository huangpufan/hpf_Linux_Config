#!/bin/bash
# Docker 容器入口点脚本

# 加载 Nix 环境
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# 执行传入的命令
exec "$@"
