# 架构视角

<!-- 模板实例化说明：写入渲染后的 SSOT 文件前，必须把标题、表格标签、占位符和辅助说明翻译为 Phase 0 或 STATUS.md 锁定的 documentation_language。代码标识符、路径、命令、API 名、枚举值和直接引用保持原文。 -->

> 跨域架构视角。Views 从 源资料吸收系统目标、运行哲学、关键旅程和全局 current/target/gap，并把具体所有权、契约、状态和恢复细节路由到 domains。
>
> Views 是 SSOT 的设计意图层，必须包含叙述性的设计思考，不能只有表格。

## 视角索引

| 视角 | 路径 | 权威职责 | 源资料输入 | 证据 / 状态 |
|---|---|---|---|---|
| 运行模型 | [operating-model.md](./operating-model.md) | 使命、目标、原则、优先级、非目标、actors、主要用户/运行路径 | PRD、设计文档、root README、高层架构文档 | |
| 关键旅程 | [critical-journeys.md](./critical-journeys.md) | 端到端旅程、业务闭环、阶段生命周期、验收和恢复信号 | PRD flows、设计 walkthrough、runbook、源码轨迹 | |
| Current / Target / Gap | [current-target-gap.md](./current-target-gap.md) | 已实现状态与目标设计、迁移立场、全局 gaps、裁决指针 | ADR、设计文档、roadmap、源资料、代码证据 | |

## 跨域快速理解地图 / Reader Map

> Views 的入口地图只做路由，不承载独立长期事实。具体设计意图、旅程和 gap 必须进入对应 view 正文；状态/资源/契约/恢复细节继续下钻到 domains。

| 读者问题 | 一句话答案 | 权威视角 | 后续下钻 | 关键证据 / 风险 |
|---|---|---|---|---|
| 系统为什么这样设计，优先优化什么？ | | [operating-model.md](./operating-model.md) | domains / decisions | |
| 哪些端到端路径决定系统是否可用？ | | [critical-journeys.md](./critical-journeys.md) | domains / tests | |
| 当前实现、目标设计和迁移 gap 分别是什么？ | | [current-target-gap.md](./current-target-gap.md) | domains / decisions / tech-debt | |

## 视角规则

- View 不能只有表格。必须有 `为什么这个视角存在` / 叙述章节解释设计意图。
- Views 回答跨域问题；domains 负责详细状态/资源、契约、不变量、失败恢复和验证。
- 当总览 Mermaid 图能澄清全系统旅程时，view 可以包含这些图。
- View 必须链接到负责具体状态/资源/契约/失败细节的 domains。
- Views 必须分离 当前事实 与 目标设计。Current claim 需要代码/配置/schema/test/runtime 证据；target claim 需要 decision、ADR、issue 或 conversation 证据。
- 当 PRD/设计资料包含当前优先级、非目标和成功标准时，operating-model 必须吸收。
- Critical-journeys 必须吸收用户/操作者验收与恢复信号，而不是只列 happy-path flow 名称。
- Current-target-gap 必须解释迁移立场和部分落地的意图，而不是只列 gap 行。
- Reader Map、主题候选和 evidence links 必须来自架构分解、读者问题和仓库证据；每个 view 必须补上设计意图、why、约束、风险和权威 owner；不要把外部主题树当成 view 结构本身。

## 源资料路由

| 源资料内容 | 目标视角 | Domain / 卫星区域后续 |
|---|---|---|
| 系统定位、目标、当前优先级、非目标、运行哲学、主要 actor、成功标准 | [operating-model.md](./operating-model.md) | 链接执行这些原则的 domains |
| 用户/运行主路径、业务闭环、阶段生命周期、验收/恢复信号 | [critical-journeys.md](./critical-journeys.md) | 链接负责各阶段/状态/资源的 domains |
| Current/target/gap、迁移目标、设计缺口、部分落地的意图 | [current-target-gap.md](./current-target-gap.md) | 链接 decisions、domains、开放裁决项 |
| 外部生成图、截图、dependency graph 或自动摘要中的候选线索 | 仅在交叉验证后按语义拆入 operating-model / critical-journeys / current-target-gap | 脚本清单默认来自仓库脚本、manifest、CI 和配置；架构行为再链接 domains |

## 开放视角缺口

| 视角 | Gap / unknown | 所需证据 | 阻塞级别 |
|---|---|---|---|
| | | | blocking / non-blocking |
