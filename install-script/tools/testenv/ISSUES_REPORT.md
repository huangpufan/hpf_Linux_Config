# install-script 测试问题报告

**测试日期**: 2025-12-03  
**测试环境**: Ubuntu 22.04 Docker 容器

## 测试结果总结

| 脚本 | 状态 | 问题 |
|------|------|------|
| latestgccg++-install.sh | ✅ 通过 | - |
| git-install.sh (FZF) | ⚠️ 部分通过 | 安装成功但 PATH 未生效 |
| clang13-install.sh | ✅ 通过 | 使用了过时的 apt-key |
| cargo-install.sh | ❌ 失败 | 硬编码路径问题 |
| nvim-install.sh | ⚠️ 部分测试 | 未定义变量 `ubuntu_version` |
| tmux 配置 | ✅ 通过 | - |
| pip-install.sh | ✅ 通过 | - |
| npm-install.sh | ✅ 通过 | - |

---

## 详细问题分析

### 1. ❌ cargo-install.sh - 硬编码路径

**问题**: 脚本中硬编码了仓库路径
```bash
TARGET_LINK="$HOME/hpf_Linux_Config/install-script/basic/cargo-config"
```

**错误信息**:
```
Target for symlink does not exist: /root/hpf_Linux_Config/install-script/basic/cargo-config
```

**建议修复**:
```bash
# 使用相对路径或自动检测
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_LINK="$SCRIPT_DIR/cargo-config"
```

---

### 2. ⚠️ nvim-install.sh - 未定义变量

**问题**: 使用了未定义的 `ubuntu_version` 变量
```bash
if [[ $ubuntu_version == "22.04" ]] ; then
  sudo apt -y install efm-langserver lua5.4
fi
```

**建议修复**:
```bash
# 在脚本开头定义
ubuntu_version=$(lsb_release -rs 2>/dev/null || echo "")
# 或者使用 lib/common.sh 中的函数
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
ubuntu_version=$(ubuntu_version_id)
```

---

### 3. ⚠️ clang13-install.sh - 过时的 apt-key

**问题**: 使用了已弃用的 `apt-key add` 命令
```bash
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
```

**警告**: Ubuntu 22.04+ 中 `apt-key` 已弃用

**建议修复**:
```bash
# 使用新的 GPG 密钥方式
wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] http://apt.llvm.org/$(lsb_release -cs)/ llvm-toolchain-$(lsb_release -cs)-13 main" | sudo tee /etc/apt/sources.list.d/llvm-13.list
```

---

### 4. ⚠️ git-install.sh (FZF) - PATH 问题

**问题**: FZF 安装成功，但 `~/.local/bin` 或 `~/.fzf/bin` 未加入当前 shell 的 PATH

**建议**: 脚本末尾添加提示或自动 source
```bash
echo "请运行 'source ~/.bashrc' 或重新打开终端以使用 fzf"
```

---

### 5. ⚠️ apt-snap-install.sh - Snap 依赖

**问题**: 脚本依赖 snap，但在 Docker 容器或某些环境中 snap 不可用
```bash
sudo snap install btop dust procs bandwhich lnav
sudo snap install zellij --classic
sudo snap install emacs --classic
```

**建议修复**:
```bash
# 检测 snap 是否可用
if command -v snap >/dev/null 2>&1 && systemctl is-active snapd >/dev/null 2>&1; then
    sudo snap install btop dust procs bandwhich lnav
    # ...
else
    echo "[WARN] snap 不可用，跳过 snap 包安装"
fi
```

---

### 6. ⚠️ 多个脚本 - 缺少 shebang 或错误处理

**缺少 shebang 的脚本**:
- `basic/git-install.sh`
- `basic/clang13-install.sh`
- `basic/latestgccg++-install.sh`

**建议**: 所有脚本添加标准头部
```bash
#!/usr/bin/env bash
set -Eeuo pipefail
```

---

## 推荐的通用改进

### 1. 使用 lib/common.sh

已有公共库，建议在所有脚本中使用：
```bash
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
set -Eeuo pipefail
```

### 2. 环境检测模板

```bash
# 检测是否在容器中
is_container() {
    [ -f /.dockerenv ] || grep -q 'docker\|lxc\|containerd' /proc/1/cgroup 2>/dev/null
}

# 检测 WSL
is_wsl() {
    grep -qi 'microsoft' /proc/version 2>/dev/null
}

# 检测 snap 可用性
has_snap() {
    command -v snap >/dev/null 2>&1 && systemctl is-active snapd >/dev/null 2>&1
}
```

### 3. 路径处理模板

```bash
# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 获取仓库根目录
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
```

---

## 测试命令

```bash
# 运行静态检查
bash tools/testenv/test_scripts.sh

# 运行实际安装测试
bash tools/testenv/test_install.sh ubuntu:22.04

# 在交互式环境中调试
bash tools/testenv/run.sh jammy
```

