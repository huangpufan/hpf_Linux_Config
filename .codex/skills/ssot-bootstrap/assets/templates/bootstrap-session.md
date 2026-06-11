# Session NNN: <scope 描述>

<!-- 模板实例化说明：写入渲染后的 SSOT 文件前，必须把标题、表格标签、占位符和辅助说明翻译为 Phase 0 或 STATUS.md 锁定的 documentation_language。代码标识符、路径、命令、API 名、枚举值和直接引用保持原文。 -->

> Bootstrap 临时文件。每个独立探索单元（一个子 Agent 的一次运行）产出一个 session 文件；最终清理前必须有停止审查通过。
>
> **写入规则**：每个 Agent 只写自己的 session 文件，不编辑其他 session。

## 元数据

| 字段 | 值 |
|---|---|
| 时间 | YYYY-MM-DD HH:mm |
| 分配范围 | |
| 前置依赖 | recon.md |
| 文档语言锁 | `<documentation_language>` |
| 语言证据 | `<documentation_language_evidence>` |
| 产出文件 | |

## 探索记录

> 本次实际探索了什么（具体到目录/文件级别）。
> 记录探索路径和深度，让后续 Agent 知道哪些区域已被覆盖。

## 源资料处理

| 源资料 | 路径/来源 | 分类 | 权威位置 | 处理结果 |
|---|---|---|---|---|
| | | absorb / link-only / stale/conflict / obsolete | SSOT/... | |

## Architecture 拆分判断

> 如果本次范围涉及 architecture，记录候选拆分轴、最终选择、拒绝原因、覆盖深度、views 吸收范围和 domain 有效性判断。

| 字段 | 值 |
|---|---|
| 处理的 architecture 范围 | root / views / domains / legacy direct child-domain |
| 使用的拆分轴 | |
| 拒绝的替代轴 | |
| 继续递归/停止拆分的理由 | |
| 覆盖深度 | `deep` / `sampled` / `inferred` / `unknown` |
| 覆盖范围 / 抽样策略 | |
| Views 吸收范围 | operating-model / critical-journeys / current-target-gap |
| 设计意图覆盖 | mission / priorities / non-goals / success standards / journeys / current-target-gap |
| 必需图清单 | boundary/context, decomposition/domain, runtime flow, state/resource, lifecycle/concurrency, failure/recovery, trust/config |
| Domain 有效性证据 | why separate + independence signal |
| 未覆盖 gap | |
| 停止/递归审查挑战 | reviewer + result (`no-more-required-changes` / `needs-fix`) + 剩余修改项 |

> 如果本 session 判断 `single-level`、停止拆分、某区域 `done` 或 `无需更新`，必须记录停止审查如何挑战该结论。优先独立 reviewer；不可用时按 `self-reviewed` 降级路径记录范围、依据和跳过项。`needs-fix` 时不得把范围报为完成。

## Architecture Diagram 处理

| Diagram ID | 架构路径 | 状态 | 覆盖内容 | 证据 | 链接的表格行 | 处理结果 |
|---|---|---|---|---|---|---|
| | SSOT/architecture/.../README.md | current / target / stale | | | 运行流 / 子 Domains / 契约 / 状态 / 生命周期 / 失败 / trust-config | |

## 产出摘要

> 写入了哪些区域、architecture view 或 architecture domain 文件，核心内容概述。

## Tier 4 发现

> 探索过程中发现的 decisions/gotchas/bugs/tech-debt 素材，以及需要进入 architecture 约束与 gap 记录的线索。
> 协调者会从此处汇总到 manifest.md 的 Tier 4 发现汇总中。

| 发现 | 类型 | 来源标记 | 来源位置 |
|---|---|---|---|
| | gotcha / decision / bug / debt / architecture-constraint | documented / code-comment / code-analysis / git-history | 文件路径或描述 |

## 阻塞与问题

> 无法继续的点、证据不足的区域、需要其他 Agent 协助的事项。
> 协调者据此决定是否标记相关区域为 blocked。

## 停止审查记录（Stop Review）

| scope | stop_claim | reviewer | result | 已审查证据 | 剩余修改项 |
|---|---|---|---|---|---|
| | done / no-op / 无需更新 / single-level / 停止拆分 | | no-more-required-changes / needs-fix | | |

> 高影响 Bootstrap 结论（整体 `passed`、清理 `.bootstrap/`、最终水位推进）不能自审。这里记录的是本 session 相关停止结论的 reviewer challenge 或 `self-reviewed` 降级记录，降级时必须写清已检查项与未检查项；最终全局收敛仍以 manifest 和 STATUS.md 的记录为准。

## 下次建议

> 基于本次探索，对后续工作的建议（优先探索什么、哪些区域值得深入等）。
