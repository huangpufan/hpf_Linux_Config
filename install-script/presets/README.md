# Presets - 预设安装组合

预设的工具安装组合，方便一键安装常用工具集。

## 可用预设

| 预设 | 说明 |
|------|------|
| `minimal.sh` | 最小工具集：基础命令行工具 |
| `dev-cli.sh` | 命令行开发环境：现代 CLI 工具 |
| `dev-full.sh` | 完整开发环境：包含编译器和调试工具 |
| `all-tools.sh` | 所有工具：安装全部可用工具 |

## 使用方式

```bash
# 安装最小工具集
bash install-script/presets/minimal.sh

# 安装完整开发环境
bash install-script/presets/dev-full.sh
```

## 自定义预设

你可以参考现有预设创建自己的组合：

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/../tools"

# 安装你需要的工具
bash "$TOOLS_DIR/apt/bat.sh"
bash "$TOOLS_DIR/curl/fzf.sh"
bash "$TOOLS_DIR/cargo/eza.sh"
# ...
```

