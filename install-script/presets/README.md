# Presets - 预设安装组合

预设的工具安装组合，方便一键安装常用工具集。

如果你是 agent，在“安装环境”任务里应把这个目录视为组合入口，而不是第一阅读入口。
先读仓库根目录 `AGENTS.md` 和 `docs/agent-install-playbook.md`，再决定是否执行某个 preset。

## 可用预设

| 预设 | 说明 |
|------|------|
| `minimal.sh` | 最小工具集：基础命令行工具 |
| `dev-cli.sh` | 命令行开发环境：现代 CLI 工具 |
| `dev-full.sh` | 完整开发环境：包含编译器和调试工具 |
| `all-tools.sh` | 全量预设链：执行 `bootstrap + dev-full`，不包含 Neovim、OpenHarmony 或个人专项脚本 |

## 使用方式

推荐通过 runner：

```bash
python3 install-script/agent-runner.py preset minimal --dry-run
python3 install-script/agent-runner.py preset minimal
python3 install-script/agent-runner.py preset dev-full
```

preset 的验收由 `install-script/presets/check-preset.py` 汇总对应成员工具的
`check_cmd`。只抽查少数命令不足以代表 preset 就绪。

直接脚本：

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
