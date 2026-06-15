# 开发工作流

> 这个仓库的“开发”主要指扩展或维护安装系统，而不是启动服务。关键是沿着 runner → catalog → scripts 这条路径工作，并把验证留给 `check_cmd`。

## 开发一眼看懂 / Reader Map

| 读者问题 | 一句话答案 | 权威位置 | Evidence | 风险 / 前置条件 |
|---|---|---|---|---|
| 如何进入安装主流程？ | 先用 runner，看 `list/check/install/preset`。 | [本地运行](#本地运行) | AGENTS、playbook | 仓库路径必须正确。 |
| 常用脚本和目录怎么找？ | 先看 catalog，再下钻具体子目录。 | [脚本 / 工具目录](#脚本--工具目录) | `agent-tools.json` | 不要从历史脚本海里猜。 |
| 新增能力时要遵守哪些模式？ | 增加脚本后必须更新 catalog，并保留验证路径。 | [模式语言](#模式语言) | tools README | 验证缺失会导致不可维护。 |

## 本地运行

这个仓库没有统一“启动服务”命令。最常见的本地工作流，是列出目录、执行某个 tool/preset、或者检查当前机器状态。开发时也应沿着这套入口验证自己的改动，而不是只手动跑 shell 脚本。

| 场景 | 命令 | 目的 | Required setup | Evidence | Known risk |
|---|---|---|---|---|---|
| 查看可执行目录 | `python3 install-script/agent-runner.py list` | 获取 tool/preset 真相 | 仓库位于 `~/hpf_Linux_Config` | playbook | 路径不对会直接失败 |
| 检查单个工具 | `python3 install-script/agent-runner.py check <tool>` | 回读当前机器状态 | 目标工具在 catalog 中 | playbook | `check_cmd` 可能依赖外部认证 |
| 执行单工具安装 | `python3 install-script/agent-runner.py install <tool>` | 跑具体安装脚本 | 可能需要 sudo / 环境变量 | playbook、catalog | 不能跳过 dry-run 思维 |
| 执行预设 | `python3 install-script/agent-runner.py preset minimal` | 安装一组工具 | 可能需要 GitHub 认证、sudo；非 `hpf` 账户执行 `bootstrap` / `all-tools` 前需确认 | README、preset docs | preset 失败要回到单项排查 |

## 脚本 / 工具目录

| Filename | Purpose | Category | When to use | Evidence | Risk or prerequisite | Architecture link if any |
|---|---|---|---|---|---|---|
| `install-script/agent-runner.py` | 统一入口与执行器 | other | 任何安装/检查任务 | AGENTS、playbook | 路径固定 | architecture |
| `install-script/agent-tools.json` | 工具目录与 `check_cmd` 真相 | diagnostics | 新增/修改工具定义时 | AGENTS | 双写会漂移 | architecture |
| `install-script/presets/*.sh` | 组合安装 | other | 跑 bundle 时 | preset docs | 仍应通过 runner 进入 | installation-runtime |
| `install-script/presets/check-preset.py` | preset 成员验收汇总 | diagnostics | 修改 preset 成员或 `check_cmd` 后 | catalog、preset scripts | 成员清单与安装步骤必须同步 | testing |
| `install-script/setup/*.sh` | 账号/系统配置 | other | 认证、换源、registry、Git 身份 | setup docs | 常涉及外部状态 | installation-runtime |
| `install-script/tools/*/*.sh` | 单工具安装 | other | 补装某个工具 | tools README | 前置条件各异 | installation-runtime |
| `install-script/nvim/nvim-verify.sh` | Neovim 专项验证 | diagnostics | 修改 Neovim 安装或配置后 | playbook | 依赖 headless 启动 | tech-debt |

## 模式语言

| 模式 | 什么时候使用 | 为什么重要 | Evidence | Risk |
|---|---|---|---|---|
| runner-first | 安装、检查、preset 任务 | 保证统一执行与验收语义 | AGENTS、playbook | 直接调脚本会绕过协议 |
| catalog-first | 新增/修改工具项 | 保持 `tool id`/`check_cmd` 唯一真相 | AGENTS | 忘记更新 catalog 会造成隐性坏账 |
| 先 dry-run / 先 check 的心智 | 运行高风险安装前 | 降低误操作和排障成本 | playbook | 跳过会放大问题定位难度 |

## 端到端骨架流程

| 功能类型 | 需要触碰的权威位置 | 代表性示例 | 验证方式 | 风险 |
|---|---|---|---|---|
| 新增工具 | `agent-tools.json` + 对应脚本 + preset（如需要） | 新增一个 cargo/npm/apt 工具 | `list` + `check <tool>` | 忘记补 `check_cmd` |
| 调整安装流程 | runner / preset / setup 脚本 | 修改 GitHub 认证或 bootstrap 顺序 | 跑对应 `preset` 和 `check` | 容易破坏单工具 HTTPS、个人 bootstrap SSH 或非 `hpf` 账户确认流 |
| 调整 preset 成员 | preset 脚本 + `presets/check-preset.py` + catalog | 给 `dev-cli` 增删一个工具 | helper 成员覆盖检查 + 对应 preset check | 安装步骤和验收清单漂移 |
| Neovim 配置改动 | `nvim/` 与相关安装/验证脚本 | 插件或 provider 调整 | `check nvim` / `nvim-verify.sh` | 环境依赖多 |

## 开放缺口

| Gap / unknown | 所需证据 | 阻塞级别 |
|---|---|---|
| 缺少统一 CI/自动测试入口 | 若未来引入 CI 配置再吸收 | non-blocking |
