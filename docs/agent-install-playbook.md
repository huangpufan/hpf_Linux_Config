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
- 是否需要 GitHub 认证；`github-auth` 单工具默认走 `gh + HTTPS`，本仓库个人新机路径 `bootstrap` / `all-tools` 默认会切到 SSH
- 当前账户是否是 `hpf`；如果是，`bootstrap` / `all-tools` 直接执行；如果不是，先问用户是否仍要执行个人 SSH bootstrap，并确认 Git 邮箱
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

默认先执行 bootstrap，再执行工具预设。这里的 `bootstrap` 是本仓库所有者的
个人新机路径：它会先创建目录与 bashrc 配置，安装 git/gh，生成 SSH key，
触发 `gh` 网页认证，补充常用 `gh` scope，上传 SSH public key，并把
GitHub git protocol 切到 `ssh`。这样后续 `nvm`、release 下载、仓库 clone
等 GitHub 访问会走个人默认的 SSH 路径。

agent 执行前先用 `id -un` / `$USER` / `$HOME` 判断当前账户。检测到 `hpf`
时直接执行；非 `hpf` 账户必须先问用户：

- 是否就是仓库所有者或是否允许在这台机器执行个人 bootstrap；
- 是否允许生成/上传 SSH key 并把 GitHub git protocol 切到 `ssh`；
- Git `user.email` 应该是什么。

非 `hpf` 账户获准后，执行时显式传入确认变量：

```bash
HPF_BOOTSTRAP_CONFIRM_PERSONAL=yes \
HPF_GIT_NAME="Your Name" HPF_GIT_EMAIL="you@example.com" \
python3 install-script/agent-runner.py preset bootstrap
```

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

`all-tools` 会先执行 `bootstrap`，再进入 `dev-full` 预设；它不是
OpenHarmony、Neovim 或个人专项脚本的全仓库穷尽安装。

### 4.1 把一台新机器配成“我的机器”：完整顺序

`all-tools` 之后，agent 配置和 dsh 插件各有一个独立的 tool，按下面的顺序（每一步都先 `--dry-run`，装完用 `check` 读回）：

```bash
python3 install-script/agent-runner.py preset bootstrap        # 1. GitHub SSH、git/gh、目录与 bashrc
python3 install-script/agent-runner.py install nvm             # 2. Node.js（agents 预设和 dsh-plugins 都依赖它）
python3 install-script/agent-runner.py preset agents           # 3. agent CLI 本体（不含登录与凭据）
python3 install-script/agent-runner.py install agent-config    # 4. agent 配置（私有 submodule，覆盖前备份）
python3 install-script/agent-runner.py install dsh-plugins     # 5. dsh 插件、profile、dsh-web 服务（私有仓库）
```

顺序的原因：

- 第 4、5 步取回的是**私有**仓库，走 SSH，所以依赖第 1 步生成并上传的 SSH key，以及账号对
  `huangpufan/agent-config`、`huangpufan/dsh-plugins` 的访问权限。第 4、5 步在连接 GitHub 前会先通过
  `https://api.github.com/meta` 登记 GitHub 的 SSH 主机密钥，避免无 tty 会话卡在
  “Are you sure you want to continue connecting?”；这一步不替代第 1 步的认证。
- 第 4 步 `agent-config` 会**覆盖本机已有的 agent 配置**（`~/.claude/settings.json`、`~/.codex/config.toml`、
  `~/.config/devin/config.json`、pi 的设置和扩展目录），覆盖前备份为 `<文件>.bak.<时间戳>`。已经有自己配置的机器上，
  先 `bash agent-config/install.sh --check` 看漂移，再让用户确认。含密钥的配置（pi `models.json`、`opencode.json`）永不覆盖。
- 第 5 步 `dsh-plugins` 默认放在 `~/project/dsh-plugins`（`DSH_PLUGINS_DIR` 可改）。目录已存在时只在已跟踪文件无改动时
  `git pull --ff-only`，否则原样保留；之后运行它自带的 `node scripts/agent-runner.mjs apply`。

`install dsh-plugins` 的退出码语义：

| apply 退出码 | 含义 | 本 tool 的表现 |
|---|---|---|
| `0` | 已收敛 | 成功 |
| `2` | 需要人处理（最常见：缺 API key；也可能是插件源码不在云端） | **按成功返回**，并打印 `needs you: see output above`；这不是安装失败 |
| `1` | 还有可做的事（体积很大的下载，或已改动的本机配置在等确认） | 失败，并提示 `DSH_PLUGINS_APPLY_ARGS` |
| `3` / 其它 | 某个修复步骤失败 | 原样透传 |

`DSH_PLUGINS_APPLY_ARGS=--include-heavy` 允许下载体积很大的插件资产（`dsh-legao` 约 2.2 GiB），
`DSH_PLUGINS_APPLY_ARGS=--overwrite-config` 允许覆盖本机已改动的配置（先备份）。两者都不默认开启，要先问用户。
`check dsh-plugins` 只读，等价于在那个仓库里运行 `node scripts/agent-runner.mjs check`，只有它退出 `0` 才算就绪。
如果取回的 dsh-plugins 里还没有 `scripts/agent-runner.mjs`，说明最新版本没有推送到 GitHub：tool 会直接报错并说明，
需要在开发那份 dsh-plugins 的机器上先提交并推送，不要手工拼凑。

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

支持的 preset 名称以 `python3 install-script/agent-runner.py list` 的“预设组合”一节为准（runner 里的 `PRESET_TOOL_IDS` 是它的来源），当前为：

- `bootstrap`
- `minimal`
- `dev-cli`
- `dev-full`
- `all-tools`
- `agents`

其中 `agents` 只安装 pi、codex、claude、opencode、gemini、cursor-agent、devin、kimi 的 CLI 本体，
不处理登录与凭据，也**不属于** `all-tools`。它需要 Node.js/npm（先装 `nvm`），验收同样走
`check_cmd`（`python3 install-script/agent-runner.py check preset-agents`）。

这些 agent 的**配置**不在 `agents` 预设里，而在私有 submodule `agent-config/`（配置正本，不含任何密钥；
含密钥的配置只有 `templates/*.example` 脱敏模板，真实 key 仍需用户自己填）。新 clone 里它是空目录：

```bash
git submodule update --init agent-config
# 先只看会改什么（不改任何文件）
bash agent-config/install.sh --check
```

`agent-config/install.sh`（不带 `--check`）会把配置部署到 `$HOME`：`~/.pi/agent/extensions` 用 symlink，
`~/.claude/settings.json`、`~/.codex/config.toml` 等用拷贝，**覆盖前先备份**为 `<文件>.bak.<时间戳>`。
在已经有自己 agent 配置的机器上，执行前先 `--check` 并让用户确认。

## 单工具补充：Neovim

`nvim` 不能只用 `command -v nvim` 判断是否安装完整。这个工具至少包含四层状态：

1. Neovim 二进制：每次安装先构建独立 release，验收成功后通过 `current`
   原子切换；`~/.local/bin/nvim` 是稳定 launcher。
2. 配置链接：`~/.config/nvim` 必须指向 `~/hpf_Linux_Config/nvim`。
3. 插件目录：`lazy.nvim`、Mason、parser、provider 和运行数据必须落到当前
   release 自己的 XDG 目录。
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
readlink ~/.local/share/hpf-linux-config/nvim/current
find "$(readlink -f ~/.local/share/hpf-linux-config/nvim/current)/xdg/data/nvim/lazy" -maxdepth 1 -mindepth 1 -type d | wc -l
nvim --headless '+checkhealth' '+w! /tmp/hpf-nvim-checkhealth.txt' '+qa'
```

release 布局如下：

- `~/.local/share/hpf-linux-config/nvim/releases/<release-id>/`：binary、插件、Mason、parser、provider、state/cache 与 manifest。
- `current` / `previous`：当前与上一份 release；切换只在 candidate 完整验收后发生。
- `persistent/`：sessions、bookmarks、undo、shada、grug-far history 和 blink frecency，跨 release 复用。

激活前如仍有用户 Neovim 进程使用当前 binary，安装会拒绝切换。首次迁移只复制现有数据，
不会删除旧环境；非 symlink 的 `~/.config/nvim` 会直接报错。

其中 `python3 install-script/agent-runner.py check nvim` 会调用
`install-script/nvim/nvim-verify.sh`，覆盖启动、`checkhealth`、插件加载、
插件命令入口、LSP attach、Git blame、LSP 签名提示、自定义与公共 snippets、
Treesitter parser 以及已知易脏插件缓存目录。

注意事项：

- Ubuntu 24.04 会因为 PEP 668 拦截普通 `pip3 install --user pynvim`。优先用
  `apt install python3-pynvim` 补 Python provider。
- Node provider 需要 `npm install -g neovim`；脚本会尽量安装，失败时应在汇报中说明。
- `checkhealth` 中 `lazy-rocks/hererocks` 的 `luarocks` 提示在当前配置没有插件依赖
  `luarocks` 时可以忽略；真正需要拦截的是 headless 启动报错、`lazy.nvim`
  缺失、插件同步失败。
- Neovim 配置说明位于 `nvim/README-CN.md` / `nvim/README.md`；如需启用 Copilot 等账号型插件，应在 Neovim 内人工完成对应授权，不属于自动安装验收项。

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
