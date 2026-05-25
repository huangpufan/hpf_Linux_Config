# Agent Install Playbook

本仓库不再提供旧的交互式终端安装入口。面向 agent 的标准入口是：

- 固定仓库路径：`~/hpf_Linux_Config`
- 安装脚本目录：`install-script/`
- 工具清单：`install-script/agent-tools.json`
- 确定性执行器：`install-script/agent-runner.py`

## 支持版本

- Ubuntu 20.04
- Ubuntu 22.04
- Ubuntu 24.04

其中 `source-change` 在 Ubuntu 24.04 上会检查并改写
`/etc/apt/sources.list.d/ubuntu.sources`；在 20.04/22.04 上仍使用
`/etc/apt/sources.list`。

## 阅读顺序

如果 agent 的任务是“安装环境”或“检查安装状态”，建议按下面的顺序读：

1. 根目录 `AGENTS.md`
2. 本文档
3. `install-script/agent-tools.json`
4. 目标脚本所在子目录

目录分工：

- `install-script/presets/`：预设组合入口
- `install-script/setup/`：Git 身份、GitHub 认证、换源、registry 等系统配置
- `install-script/basic/`：基础环境引导与兼容性脚本
- `install-script/tools/`：单工具安装脚本
- `install-script/openharmony/`：OpenHarmony 专用环境
- `nvim/`：编辑器配置，不是默认机器安装入口

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

如果意图不明确，先问用户；如果只是执行路径不明确，不要自行发明流程，先回到 `AGENTS.md` / 本文档 / runner。

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

默认先执行 bootstrap，再执行工具预设。bootstrap 会先创建目录与 bashrc
配置，安装 git/gh，生成 SSH key，触发 `gh` 网页认证，补充常用 `gh`
scope，上传 SSH public key，并把 GitHub git protocol 切到 `ssh`。
这样后续 `nvm`、release 下载、仓库 clone 等 GitHub 访问不会默认走 HTTPS。

```bash
python3 install-script/agent-runner.py preset bootstrap
HPF_GIT_NAME="Your Name" HPF_GIT_EMAIL="you@example.com" \
python3 install-script/agent-runner.py install git-identity
python3 install-script/agent-runner.py preset minimal
```

如果要完整初始化，直接执行：

```bash
python3 install-script/agent-runner.py preset all-tools
```

`all-tools` 会先执行 `bootstrap`，再进入完整工具安装。

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

- `bootstrap`
- `minimal`
- `dev-cli`
- `dev-full`
- `all-tools`

## 单工具补充：Neovim

`nvim` 不能只用 `command -v nvim` 判断是否安装完整。这个工具至少包含四层状态：

1. Neovim 二进制：当前脚本固定安装到 `~/.local/nvim-<version>/`，并通过
   `~/.local/bin/nvim` 暴露命令。
2. 配置链接：`~/.config/nvim` 必须指向 `~/hpf_Linux_Config/nvim`。
3. 插件目录：`lazy.nvim` 和插件必须落到 `~/.local/share/nvim/lazy/`。
4. 启动验收：`nvim --headless '+qa'` 必须无错误退出。

标准安装方式仍然走 runner：

```bash
python3 install-script/agent-runner.py install nvim --dry-run
python3 install-script/agent-runner.py install nvim
python3 install-script/agent-runner.py check nvim
```

安装后如果要做更细的人工复核，使用：

```bash
install-script/nvim/nvim-verify.sh
which -a nvim
nvim --version
test -L ~/.config/nvim && readlink ~/.config/nvim
find ~/.local/share/nvim/lazy -maxdepth 1 -mindepth 1 -type d | wc -l
nvim --headless '+checkhealth' '+w! /tmp/hpf-nvim-checkhealth.txt' '+qa'
```

其中 `python3 install-script/agent-runner.py check nvim` 会调用
`install-script/nvim/nvim-verify.sh`，覆盖启动、`checkhealth`、插件加载、
插件命令入口、LSP attach、Treesitter parser 以及已知易脏插件缓存目录。

注意事项：

- Ubuntu 24.04 会因为 PEP 668 拦截普通 `pip3 install --user pynvim`。优先用
  `apt install python3-pynvim` 补 Python provider。
- Node provider 需要 `npm install -g neovim`；脚本会尽量安装，失败时应在汇报中说明。
- `checkhealth` 中 `lazy-rocks/hererocks` 的 `luarocks` 提示在当前配置没有插件依赖
  `luarocks` 时可以忽略；真正需要拦截的是 headless 启动报错、`lazy.nvim`
  缺失、插件同步失败。
- `install-script/nvim/readme.md` 中的 `CopilotAuto` 是后续人工认证/启用提示，不属于
  自动安装验收项；如果要启用 Copilot，需要用户在 Neovim 内完成对应账号授权。

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
