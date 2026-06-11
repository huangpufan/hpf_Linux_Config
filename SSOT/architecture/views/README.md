# 架构视角

> 本仓库的跨域信息量不大，但仍然需要把“为什么这样组织安装系统”“关键安装闭环是什么”“当前实现与目标约束差在哪里”分离开写，避免所有结论都挤在一个 README 里。

## 视角索引

| 视角 | 路径 | 权威职责 | 源资料输入 | 证据 / 状态 |
|---|---|---|---|---|
| 运行模型 | [operating-model.md](./operating-model.md) | 使命、原则、优先级、非目标、actors、主要路径 | README、AGENTS、playbook | covered |
| 关键旅程 | [critical-journeys.md](./critical-journeys.md) | 端到端安装/检查旅程、验收和恢复信号 | runner、catalog、preset docs | covered |
| Current / Target / Gap | [current-target-gap.md](./current-target-gap.md) | 当前实现、目标约束、迁移缺口 | SSOT 区域状态与现有文档 | covered |

## 跨域快速理解地图 / Reader Map

| 读者问题 | 一句话答案 | 权威视角 | 后续下钻 | 关键证据 / 风险 |
|---|---|---|---|---|
| 为什么不允许 agent 直接在脚本海里自由探索？ | 因为安装系统已经被明确收束到 runner + catalog。 | [operating-model.md](./operating-model.md) | installation-runtime domain | 否则会绕开状态判定。 |
| 一次安装或检查任务的闭环是什么？ | `list/check/install/preset` 只是入口，最后必须落到 `check_cmd`。 | [critical-journeys.md](./critical-journeys.md) | development/testing | 不能把 exit code 0 当作唯一成功条件。 |
| 现阶段的长期缺口主要在哪里？ | release/decision 仍轻，`nvim/` 等支线还没形成独立 domain。 | [current-target-gap.md](./current-target-gap.md) | tech-debt / architecture root | 后续扩展时要重新审查拆分。 |
