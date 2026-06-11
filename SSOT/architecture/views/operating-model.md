# 运行模型

## 范围

- **负责**：仓库使命、主要 actor、运行哲学、当前优先级、非目标、成功标准和跨域设计约束。
- **不负责**：具体脚本实现细节、单工具安装逻辑或 Neovim 子配置细节。
- **主要源资料**：`README-CN.md`、`AGENTS.md`、`docs/agent-install-playbook.md`

## 为什么这个视角存在

这个仓库的核心不是“收集很多 shell 脚本”，而是把安装环境这件事变成 agent 可以可靠执行的系统。README 和 AGENTS 都在反复强调同一件事：先探测、再执行、最后验证，而且所有安装类任务默认先回到 `agent-runner.py` 和 `agent-tools.json`。

因此，运行模型关注的是约束而不是功能列表。未来任何变更，只要削弱了固定路径、单一 catalog、统一 check 语义或 GitHub 认证默认路径，就会让整个仓库重新退回“脚本很多但难以稳定自动化”的状态。

## 叙述 / 模型

工作流从用户或 agent 的安装意图进入，先判断要执行的是单工具还是 preset，再通过 runner 将意图翻译成对具体脚本的调用。runner 负责路径校验、sudo 预检、日志输出和 `check_cmd` 验收；脚本只负责各自的安装动作。系统信任 `agent-tools.json` 作为工具目录真相，而不是信任某个 README 列表或目录猜测。

## 设计简报

- **使命 / 承诺**：为 Linux / WSL2 开发环境初始化提供可重复、可验证的仓库级配置系统。
- **主要受众 / 操作者**：仓库所有者、在同机执行维护的 agent。
- **主要 actor / caller**：用户、agent、runner、工具脚本、目标 OS 环境。
- **优化优先级**：确定性入口、安装后可验证、固定路径、模块化脚本、默认 `gh + HTTPS`。
- **非目标**：不追求成为完全通用的跨发行版安装框架；不把 OpenHarmony 或个人化脚本纳入默认 bootstrap。
- **当前阶段优先级**：守住 runner-first 与 catalog-first 约束，并覆盖 Ubuntu 20.04/22.04/24.04。
- **成功标准**：agent 能根据 playbook 找到正确入口；执行后可通过 `check_cmd` 判断状态。

## 设计原则

| 原则 | 为什么重要 | 由什么保持 | 证据 / 来源 |
|---|---|---|---|
| runner 优先 | 统一入口才能保证自动化和日志/验收一致性。 | `AGENTS.md`、playbook、`agent-runner.py` | verified |
| catalog 单一真相 | `tool id`、脚本路径、sudo/ssh 前置和 `check_cmd` 必须在一处维护。 | `agent-tools.json` | verified |
| 先探测后执行 | 安装行为依赖系统版本、sudo 权限、认证状态和前置工具。 | playbook | documented |
| GitHub 默认 HTTPS | 避免把 SSH 切换当成隐式副作用，减少初始化歧义。 | README、AGENTS、setup docs | verified |

## 设计约束

| 约束 | 范围 | 违反后果 | 权威执行点 / 证据 |
|---|---|---|---|
| 仓库应位于 `~/hpf_Linux_Config` | runner / direct scripts | runner 拒绝执行或脚本前提失效 | `README-CN.md`、playbook、runner |
| Ubuntu 24.04 换源必须走 `ubuntu.sources` | source-change 工具 | 会写错系统文件并破坏换源 | AGENTS、playbook、`ubuntu-source-change.sh` 文档 |
| 安装结果由 `check_cmd` 判定 | 全部 tool/preset | 会把“脚本跑完”误当成“环境可用” | `agent-tools.json`、playbook |

## 主要路径

| 路径 | 用户 / 运行意图 | 成功信号 | 权威旅程 / domain |
|---|---|---|---|
| 机器 bootstrap | 在新机器上建立最小/完整开发环境 | runner 成功执行且 `check` 通过 | [critical-journeys.md](./critical-journeys.md) |
| 单工具安装 | 只补装一个工具或配置项 | 对应 tool 的 `check_cmd` 通过 | [installation-runtime domain](../domains/installation-runtime/README.md) |
| 状态检查 | 盘点当前机器就绪状态 | `check all` 或单项 `check` 结果清晰 | [critical-journeys.md](./critical-journeys.md) |

## 相关 Domains

| Domain | 为什么它执行此运行模型 | 约束 / 旅程链接 |
|---|---|---|
| installation-runtime | 所有安装编排、catalog、脚本分层与平台差异都在这里落地。 | runner / catalog / `check_cmd` |

## 被拒绝的优化 / 非目标

| 非目标或被拒绝的优化 | 为什么拒绝 | 替代做法 | 证据 / 决策 |
|---|---|---|---|
| 让 agent 直接在 `install-script/` 下自由挑脚本执行 | 看似更快，但会绕过统一入口和状态判断。 | 先用 runner，只有明确需要时才直调脚本。 | AGENTS、playbook |
| 默认自动切 SSH | 对熟悉 GitHub 的人很方便，但会引入额外认证副作用。 | 默认 `github-auth`，明确要求时再 `github-ssh`。 | README、setup docs |

## 当前 / 目标 / 差距

| 区域 | 当前运行模型 | 目标意图 | Gap / 裁决 | 证据 |
|---|---|---|---|---|
| 安装入口 | runner-first 已在文档和目录上统一 | 持续保持单一入口 | 需要未来改动不回退 | [current-target-gap.md](./current-target-gap.md) |
| 发布治理 | 尚未出现强 release 约束 | 若以后版本化，需要单独建规则 | 当前记为 gap | [current-target-gap.md](./current-target-gap.md) |

## 证据

| 断言 | 源资料 / 代码 / 运行证据 | 置信度 | 后续动作 |
|---|---|---|---|
| “安装环境”任务默认先回到 playbook → runner → catalog | `AGENTS.md`、`docs/agent-install-playbook.md`、`README-CN.md` | verified | 无 |
| 仓库定位是 Linux/WSL2 开发机配置仓库 | 双语 README | verified | 无 |
