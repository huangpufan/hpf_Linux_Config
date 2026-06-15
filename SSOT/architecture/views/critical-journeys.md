# 关键旅程

## 范围

- **负责**：主要安装/检查旅程、闭环、验收信号、恢复信号。
- **不负责**：单脚本内部实现与每个工具的安装细节。
- **主要源资料**：`README-CN.md`、`docs/agent-install-playbook.md`、`install-script/agent-tools.json`

## 为什么这个视角存在

对这个仓库来说，真正决定是否“有用”的不是脚本数量，而是用户或 agent 是否能从明确意图出发，最终得到一个可验证的结果。安装失败、认证没完成、路径不对、系统版本不匹配，都会直接打断主路径。

因此，这里的关键旅程必须同时描述 happy path 和失败后的恢复点，尤其是 `check_cmd` 如何作为最终信号闭环。

## 叙述 / 模型

典型旅程从一个明确意图开始：列目录、执行 preset、安装单工具、检查状态。agent 先用 runner 解析意图，再由 runner 调脚本并回写日志。旅程成功的标准不是“脚本退出 0”，而是对应的 `check_cmd` 通过，或者至少能明确区分“脚本失败”和“验收失败”。

## 设计意图 / 约束

| 意图或约束 | 适用旅程 | 为什么重要 | 证据 / 来源 |
|---|---|---|---|
| 先探测环境，再决定执行项 | 全部安装旅程 | 环境前提不对时直接执行会放大破坏面 | playbook |
| `check_cmd` 是最终验收信号 | 安装、check、preset | 避免误判“已安装” | `agent-tools.json`、playbook |
| GitHub 认证边界清晰 | bootstrap / all-tools / github-auth | 单工具 `github-auth` 默认 HTTPS；个人 bootstrap 在 `hpf` 账户默认 SSH，非 `hpf` 账户需确认 | README、setup docs |

## 旅程总览

- **主要旅程**：bootstrap 新机器、执行 preset minimal/dev-full、单工具 install/check。
- **次要旅程**：只查看 catalog、只配置 Git 身份、只切换 GitHub SSH。
- **关键失败旅程**：仓库路径不对、非 `hpf` 账户未确认个人 bootstrap、`sudo -v` 失败、`gh auth` 未完成、`check_cmd` 失败。
- **明确不在范围内的旅程**：服务部署、远程环境编排、OpenHarmony 默认初始化。

## 旅程图

### `JOURNEY-INSTALL-CURRENT`

- **状态**: `current`
- **覆盖内容**: 安装/检查主闭环。
- **证据**: playbook、runner CLI、catalog

```mermaid
sequenceDiagram
  participant Actor as 用户/Agent
  participant Runner as agent-runner.py
  participant Catalog as agent-tools.json
  participant Script as install script
  participant Host as Linux/WSL2
  Actor->>Runner: list/check/install/preset
  Runner->>Catalog: 解析 tool id / check_cmd / 前置条件
  Runner->>Script: 执行目标脚本
  Script->>Host: 修改环境/安装工具
  Runner->>Host: 执行 check_cmd
  Host-->>Runner: 验收结果
  Runner-->>Actor: 成功 / 执行失败 / 验收失败
```

## 主要旅程

| 旅程 | 用户/运行意图 | 被触发的设计约束 | 验收信号 | Domains |
|---|---|---|---|---|
| bootstrap → minimal | 新机器先建基础工作环境 | 固定路径、sudo 前置、GitHub 认证、`check_cmd` | `preset minimal` 或 bootstrap 相关 `check_cmd` 通过 | installation-runtime |
| 单工具 install | 只补装一个工具 | tool id 必须来自 catalog | 对应 tool 的 `check_cmd` 通过 | installation-runtime |
| 全量盘点 check all | 诊断当前机器状态 | catalog 单一真相 | `check all` 输出每项状态 | installation-runtime |

## 失败 / 恢复旅程

| 失败旅程 | 检测信号 | 预期恢复 / 降级 | 必须可观测的内容 | Domains / tests |
|---|---|---|---|---|
| 仓库路径错误 | runner 入口拒绝执行 | 移动/clone 到 `~/hpf_Linux_Config` 后重试 | 明确报错，而不是静默执行错误路径 | installation-runtime |
| 需要 sudo 的任务无法通过 `sudo -v` | runner 在执行前失败 | 先解决 sudo 权限，再重试 | 失败与未执行要区分 | installation-runtime |
| 非 `hpf` 账户未确认个人 bootstrap | runner 或 `bootstrap.sh` 前置检查失败 | agent 先问用户是否允许生成/上传 SSH key，并确认 Git 邮箱；获准后带确认变量执行 | 失败发生在 sudo/SSH 副作用前 | installation-runtime |
| `gh auth` 未完成或 git protocol 不匹配 | `check_cmd` 失败 | 单工具认证先跑 `github-auth`；个人 bootstrap 相关失败按 SSH 路径修复，必要时再 `github-ssh` | 验证命令必须体现认证状态 | installation-runtime |
| 脚本退出 0 但环境仍未就绪 | runner 返回验收失败 | 回到具体 `check_cmd` 与脚本风险项排查 | 明确是“执行成功但验收失败” | testing |

## 验收标准

| 标准 | 适用对象 | 所需证据 | 频率 / 触发条件 |
|---|---|---|---|
| 执行入口正确 | install/check/preset | 通过 runner 调用 | 每次安装任务 |
| 最终状态可验证 | 全部工具/预设 | 对应 `check_cmd` | 每次修改脚本或 catalog 后 |
| 高风险认证路径清晰 | GitHub 相关 setup | `gh auth status`、git protocol | 涉及 GitHub setup 时 |

## 相关 Domains

| Domain | 负责的旅程阶段 | 负责的状态 / 契约 / 恢复 |
|---|---|---|
| installation-runtime | catalog 解析、脚本执行、验收、日志 | tool id/check/sudo/path/version constraints |

## 当前 / 目标 / 差距

| 旅程 | 当前行为 | 目标旅程 | Gap / 下一步验证 | 证据 |
|---|---|---|---|---|
| 安装闭环 | 入口和验收语义已明确 | 长期保持可复现 | 需要未来改动持续验证 `check_cmd` | runner + playbook |
| 发布旅程 | 基本不存在 | 若以后版本化再补齐 | 当前无需扩张 | README / release gap |

## 证据

| 断言 | 源资料 / 代码 / 运行证据 | 置信度 | 后续动作 |
|---|---|---|---|
| runner 能区分脚本失败与验收失败 | playbook 对返回码的说明 | documented | 若修改 runner，需重新验证 |
| preset 与单工具都以 catalog 为入口 | `agent-runner.py list`、`agent-tools.json` | verified | 无 |
