# 架构说明

本仓库现在采用轻量的“文档入口 → runner → 工具目录 → 脚本 / 运行时配置”模型。
仓库内不再维护额外的状态事实目录，也不引入新的项目内事实层；当前事实权威回到 README、AGENTS、安装 playbook、runner、catalog 与代码本身。

## 事实来源与执行路径

```text
用户 / agent 任务
  │
  ├─ README.md / README-CN.md        # 人类快速入口
  ├─ AGENTS.md / CLAUDE.md           # agent 工作约束
  └─ docs/agent-install-playbook.md  # 安装任务阅读顺序与验收口径
      │
      ▼
install-script/agent-runner.py       # 唯一推荐执行入口
      │
      ▼
install-script/agent-tools.json      # 唯一 tool id / check_cmd catalog
      │
      ├─ presets/                    # bootstrap、minimal、dev-cli、dev-full、all-tools
      ├─ setup/                      # Git/GitHub、registry、系统/账号配置
      ├─ basic/                      # 基础环境引导与兼容脚本
      ├─ tools/                      # 单工具安装脚本
      ├─ nvim/                       # Neovim 安装与验证脚本
      └─ openharmony/                # OpenHarmony 专用环境，不属于默认初始化
```

安装状态不由仓库内状态文件记录，也不由历史 TUI / 旧治理文件推导；runner 只信任 `agent-tools.json` 中的 `check_cmd`。

## 目录职责

| 路径 | 职责 | 备注 |
|---|---|---|
| `README.md` / `README-CN.md` | 人类快速开始、项目结构、常用命令 | 只描述当前主线 |
| `AGENTS.md` / `CLAUDE.md` | agent 工作规则 | 安装任务必须先读 playbook，再走 runner |
| `docs/agent-install-playbook.md` | 安装与检查任务的操作手册 | 记录 Ubuntu 20.04/22.04/24.04、bootstrap 个人路径、Neovim 验收 |
| `install-script/agent-runner.py` | 标准执行器 | 提供 `list`、`check`、`install`、`preset`；固定仓库路径 `~/hpf_Linux_Config` |
| `install-script/agent-tools.json` | 工具目录 | 唯一 tool id、脚本路径、sudo 标记、`check_cmd` 来源 |
| `install-script/presets/` | 预设组合入口 | `all-tools` 是 `bootstrap + dev-full`，不是全仓库穷尽安装 |
| `install-script/setup/` | 系统与账号配置 | Git identity、GitHub auth、apt/npm/cargo registry 等 |
| `install-script/basic/` | 基础环境引导脚本 | 只保留仍被 catalog / presets 使用的脚本 |
| `install-script/tools/` | 单工具安装脚本 | 一个工具一个脚本，供 catalog 引用 |
| `install-script/openharmony/` | OpenHarmony 专用环境 | 不属于默认机器初始化 |
| `home/` | GNU Stow 运行时配置根目录 | 通过 `stow home -t $HOME` 部署到 `$HOME` |
| `nvim/` | Neovim 配置 | 通过 runner 安装并链接到 `~/.config/nvim`，不走 stow |

## Runner-first 安装模型

推荐命令始终从 runner 开始：

```bash
python3 install-script/agent-runner.py list
python3 install-script/agent-runner.py check all
python3 install-script/agent-runner.py preset minimal --dry-run
python3 install-script/agent-runner.py preset minimal
```

runner 的边界：

- 校验仓库位于 `~/hpf_Linux_Config`。
- 校验 tool id / preset 名称来自 `agent-tools.json`。
- 对 `requires_sudo: true` 的工具先执行 `sudo -v`。
- 执行脚本时注入非交互安装环境。
- 实时输出 stdout/stderr，并写入 `~/.local/share/hpf-linux-config/logs/`。
- 脚本退出成功后再执行对应 `check_cmd`；`check_cmd` 失败时返回验收失败。

因此 agent 不应自行维护“已安装列表”，也不应从旧聚合脚本或历史文档推断安装状态。

## Runtime 配置：`home/` + GNU Stow

`home/` 中的文件按 `$HOME` 目标路径组织：

```text
home/
├── .bash-aliases              # → ~/.bash-aliases
├── .bash-env                  # → ~/.bash-env
├── .bash-source               # → ~/.bash-source
├── .tmux.conf                 # → ~/.tmux.conf
├── .cargo/
│   └── config.toml            # → ~/.cargo/config.toml
├── .cgdb/
│   └── cgdbrc                 # → ~/.cgdb/cgdbrc
└── .config/
    └── herdr/
        └── config.toml        # → ~/.config/herdr/config.toml
```

部署与撤销：

```bash
cd ~/hpf_Linux_Config
stow home -t $HOME
stow -D home -t $HOME
```

`home/.cargo/config.toml` 保留 rsproxy sparse registry，作为本个人配置仓库面向国内网络的默认值。非国内网络或公司网络可以删除 `[source.crates-io] replace-with`，或使用本机级 local override 覆盖；这不是通用跨平台承诺。

## Neovim 配置

Neovim 配置保留在仓库根目录的 `nvim/`，标准安装路径是：

```bash
python3 install-script/agent-runner.py install nvim --dry-run
python3 install-script/agent-runner.py install nvim
python3 install-script/agent-runner.py check nvim
```

`nvim` tool 负责：

- 安装 Neovim 与 provider 依赖。
- 将固定版本 Neovim 放到 `~/.local/nvim-<version>/`。
- 创建 `~/.local/bin/nvim`。
- 将 `~/.config/nvim` 链接到 `~/hpf_Linux_Config/nvim`。
- 同步 lazy.nvim 插件并做 headless 启动验收。

`make link-nvim` 只适合作为已有安装上的 legacy/manual relink fallback；它不会安装 Neovim、provider 或插件。

## 个人路径与非默认范围

- `bootstrap` / `all-tools` 是仓库所有者的个人新机路径：默认会生成/上传 SSH key，并把 GitHub git protocol 切到 `ssh`。非 `hpf` 账户必须先确认并设置 `HPF_BOOTSTRAP_CONFIRM_PERSONAL=yes` 与 `HPF_GIT_EMAIL`。
- `all-tools` 是 `bootstrap + dev-full`，不包含 `nvim`、OpenHarmony 或个人专项脚本。
- `install-script/openharmony/` 仅在明确需要 OpenHarmony 环境时使用。
- 本仓库不再维护额外的状态事实目录，也不把旧治理 skill 作为默认全局入口。

## 变更规则

新增或修改安装能力时：

1. 先判断它属于 `presets/`、`setup/`、`basic/`、`tools/`、`nvim/` 还是 `openharmony/`。
2. 给单工具提供独立脚本。
3. 在 `install-script/agent-tools.json` 增加或更新 tool id、script、sudo 标记、`check_cmd` 和 timeout。
4. 用 runner 验证：`list`、单工具 `check`、必要时 `--dry-run`。
5. 更新 README / playbook 中对用户或 agent 可见的入口说明。
