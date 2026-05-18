# Agent Install Playbook

本仓库不再提供旧的交互式终端安装入口。面向 agent 的标准入口是：

- 固定仓库路径：`~/hpf_Linux_Config`
- 安装脚本目录：`install-script/`
- 工具清单：`install-script/agent-tools.json`
- 确定性执行器：`install-script/agent-runner.py`

## 目标

让 agent 在安装 Linux 开发环境时保持三点：

1. 先探测，再决定，不靠猜。
2. 安装路径可复现，统一通过 runner 调度。
3. 安装后必须用 `check_cmd` 读回验证，并明确汇报失败项。

## 标准工作流

### 1. 先探测环境

至少确认：

- 仓库是否位于 `~/hpf_Linux_Config`
- 当前系统与发行版，例如 `uname -a`、`cat /etc/os-release`
- 是否在 WSL / Linux
- 当前用户是否能执行 `sudo`
- 用户要的是单工具还是预设组合
- Git 身份（name / email）是否已知
- 是否需要 GitHub 认证；默认走 `gh + HTTPS`，只有明确要求时才切换 SSH
- 是否存在会影响脚本的前置条件，比如 Node、Cargo、Snap

如果意图不明确，先问用户；如果只是执行路径不明确，不要自行发明流程，直接使用 runner。

### 2. 列出可执行项

```bash
python3 install-script/agent-runner.py list
```

这个输出就是 agent 可执行目录。不要再依赖已删除的 TUI 配置或本地 state。

### 3. 安装前做 check

单工具：

```bash
python3 install-script/agent-runner.py check git
```

全量盘点：

```bash
python3 install-script/agent-runner.py check all
```

`check_cmd` 是唯一状态来源。不要维护“已安装列表”或本地缓存状态。

### 4. 新机器建议顺序

```bash
python3 install-script/agent-runner.py install gh
HPF_GIT_NAME="Your Name" HPF_GIT_EMAIL="you@example.com" \
python3 install-script/agent-runner.py install git-identity
python3 install-script/agent-runner.py install github-auth
python3 install-script/agent-runner.py preset minimal
```

如用户明确要 SSH：

```bash
python3 install-script/agent-runner.py install github-ssh
```

### 5. 先 dry-run，再执行

单工具：

```bash
python3 install-script/agent-runner.py install git --dry-run
python3 install-script/agent-runner.py install git
```

预设：

```bash
python3 install-script/agent-runner.py preset minimal --dry-run
python3 install-script/agent-runner.py preset minimal
```

支持的 preset 名称：

- `minimal`
- `dev-cli`
- `dev-full`
- `all-tools`

## Runner 约定

- `install` / `preset` 会先校验 tool id、脚本路径。
- runner 会先校验仓库是否位于 `~/hpf_Linux_Config`。
- `requires_sudo: true` 时，runner 会先执行 `sudo -v`。
- 执行环境会注入 `DEBIAN_FRONTEND=noninteractive`。
- 脚本 stdout/stderr 会实时输出到终端，并写入
  `~/.local/share/hpf-linux-config/logs/<id>_<timestamp>.log`
- 脚本退出非 0：runner 原样返回该退出码。
- 脚本退出 0 但 `check_cmd` 验证失败：runner 返回 `2`。

这意味着 agent 可以明确区分：

- 执行失败
- 执行成功但验收失败

## 汇报格式建议

安装后至少汇报：

- 执行了哪个 tool / preset
- `check_cmd` 是否通过
- 哪些步骤失败
- 日志路径
- 是否还有需要用户确认的后续步骤

示例：

```text
已在 ~/hpf_Linux_Config 下执行 github-auth 和 preset minimal。
gh 已完成 GitHub HTTPS 认证。
git/gh/tmux/htop/bat/fzf/zoxide 脚本已运行。
最终验证通过。
日志：~/.local/share/hpf-linux-config/logs/preset-minimal_20260518T120000.log
```
