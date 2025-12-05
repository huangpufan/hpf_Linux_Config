# Tools - 独立工具安装脚本

每个工具一个独立的安装脚本，便于单独安装和维护。

## 目录结构

```
tools/
├── apt/      # APT 包管理器安装的工具
├── snap/     # Snap 包安装的工具
├── cargo/    # Cargo (Rust) 安装的工具
├── npm/      # NPM (Node.js) 安装的工具
├── pip/      # Pip (Python) 安装的工具
└── curl/     # 通过 curl 脚本安装的工具
```

## 使用方式

### 单独安装某个工具

```bash
# 安装 fkill
bash install-script/tools/npm/fkill.sh

# 安装 lazygit
bash install-script/tools/curl/lazygit.sh

# 安装 eza
bash install-script/tools/cargo/eza.sh
```

### 通过 TUI 安装器选择安装

```bash
make run_tui_installer
# 或
python -m tui_installer
```

## 脚本规范

每个工具脚本应遵循以下规范：

1. **幂等性**：重复运行不会出错，已安装则跳过
2. **独立性**：不依赖其他工具脚本（依赖环境由 `_ensure.sh` 处理）
3. **标准输出**：使用 `lib/common.sh` 中的 log 函数

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

1. 在对应的子目录下创建脚本（如 `tools/npm/new-tool.sh`）
2. 遵循上述脚本模板
3. 更新 `tui-installer/tui_installer/data/tools_config.json` 添加配置

