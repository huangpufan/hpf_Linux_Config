# Tools - 独立工具安装脚本

每个工具保留独立安装脚本，runner 只是统一调度层。
当前仓库默认固定在 `~/hpf_Linux_Config`。

如果你是 agent，且任务是“安装环境”，不要把这个目录当第一阅读入口。
先读仓库根目录 `AGENTS.md`，再读 `docs/agent-install-playbook.md`，然后回到这里找单工具脚本。

## 目录结构

```text
tools/
├── apt/      # APT 包安装
├── snap/     # Snap 包安装
├── cargo/    # Cargo / Rust 工具
├── npm/      # NPM 工具
├── pip/      # Pip 工具
└── curl/     # 通过 curl 安装
```

## 使用方式

### 直接调用脚本

```bash
bash install-script/tools/npm/fkill.sh
bash install-script/tools/curl/lazygit.sh
bash install-script/tools/cargo/eza.sh
```

### 通过 runner 调用

```bash
# 查看全部目录项
python3 install-script/agent-runner.py list

# 先准备 GitHub CLI 与认证
python3 install-script/agent-runner.py install gh
python3 install-script/agent-runner.py install github-auth

# 检查单个工具
python3 install-script/agent-runner.py check git

# 先 dry-run，再执行
python3 install-script/agent-runner.py install git --dry-run
python3 install-script/agent-runner.py install git

# 执行预设
python3 install-script/agent-runner.py preset minimal
```

完整 agent 工作流见 [docs/agent-install-playbook.md](../../docs/agent-install-playbook.md)。

## 脚本规范

1. **幂等性**：重复运行不会出错，已安装则跳过。
2. **独立性**：不要依赖其他工具脚本的隐式副作用。
3. **标准输出**：优先复用 `install-script/lib/common.sh` 中的日志函数。
4. **可验证性**：新增脚本时必须提供对应的 `check_cmd`。

### 脚本模板

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../lib/common.sh
. "$REPO_ROOT/lib/common.sh"

TOOL_NAME="tool-name"
TOOL_CMD="tool-cmd"

is_installed() {
    command -v "$TOOL_CMD" >/dev/null 2>&1
}

do_install() {
    # 安装逻辑
}

main() {
    if is_installed; then
        log_info "$TOOL_NAME is already installed"
        return 0
    fi

    log_info "Installing $TOOL_NAME..."
    do_install
    log_info "$TOOL_NAME installed successfully"
}

main "$@"
```

## 添加新工具

1. 在对应子目录下创建脚本，例如 `tools/npm/new-tool.sh`。
2. 遵循上述脚本模板。
3. 更新 `install-script/agent-tools.json`，补齐 `id`、`name`、`description`、`script`、`requires_sudo`、`requires_ssh`、`check_cmd`、`timeout`。
4. 如需加入预设，再更新 `install-script/presets/*.sh`。
