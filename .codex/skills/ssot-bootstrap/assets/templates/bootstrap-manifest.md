# Bootstrap 总纲

<!-- 模板实例化说明：写入渲染后的 SSOT 文件前，必须把标题、表格标签、占位符和辅助说明翻译为 Phase 0 或 STATUS.md 锁定的 documentation_language。代码标识符、路径、命令、API 名、枚举值和直接引用保持原文。 -->

> 临时文件。Bootstrap 完成（收敛检查和停止审查均通过）后随 `.bootstrap/` 一起删除。
>
> **写入规则**：仅由协调者（父 Agent）更新。工作者（子 Agent）不直接编辑此文件。

## 仓库概况

| 字段 | 值 |
|---|---|
| 规模等级 | `S` / `M` / `L` / `XL` |
| 侦察报告 | [recon.md](./recon.md) |
| 文档语言锁 | `<documentation_language>` |
| 语言证据 | `<documentation_language_evidence>` |
| 累计会话数 | 1 |

## Phase 进度

| Phase | 状态 | 关联会话 | 停止审查者 | 停止结果 | 剩余修改项 | 备注 |
|---|---|---|---|---|---|---|
| 0 侦察 | pending | | | | | |
| 1 骨架 | pending | | | | | |
| 2 填充 | pending | | | | | |
| 3 收敛 | pending | | | | | |
| 4 清理 | pending | | | | | |

> 状态值域：`done` / `active` / `pending`
>
> `done` 是 停止结论。只有独立 reviewer 返回 `no-more-required-changes` 后才能写；`needs-fix` 时在 剩余修改项 列列出必须修改项并保持 `active` / `pending`。

## 区域状态

| 区域 | 状态 | 分配 | 已覆盖范围 | 剩余范围 | 置信度 | 停止审查者 | 停止结果 | 剩余修改项 |
|---|---|---|---|---|---|---|---|---|
| architecture | pending | | | | | | | |
| identity | pending | | | | | | | |
| glossary | pending | | | | | | | |
| development | pending | | | | | | | |
| testing | pending | | | | | | | |
| deployment | pending | | | | | | | |
| release | pending | | | | | | | |
| decisions | pending | | | | | | | |
| gotchas | pending | | | | | | | |
| bugs | pending | | | | | | | |
| tech-debt | pending | | | | | | | |

> 状态值域：`pending`（未开始）/ `active`（已分配，进行中）/ `done`（已填充，且停止审查通过）/ `blocked`（阻塞，备注说明原因）
>
> 分配：填写负责该区域的 session 编号（如 `session-003`）。并行时同一 README 或条目文件只能分配给一个 session。
>
> 置信度值域：`high`（来自代码/配置——实际执行的事实）/ `medium`（来自文档/注释——可能过时）/ `low`（推断——无直接证据）
>
> 区域按 Tier 依赖序排列：Tier 1（identity, glossary, architecture root/views）→ Tier 2（architecture domains）→ Tier 3（development, testing, deployment, release）→ Tier 4（decisions, gotchas, bugs, tech-debt）

## Architecture 拆分状态

| 字段 | 值 |
|---|---|
| 候选拆分轴 | |
| 选定主轴 | |
| 拒绝的轴与原因 | |
| 递归/停止规则 | |
| 覆盖深度 | `deep` / `sampled` / `inferred` / `unknown` |
| 覆盖范围 / 抽样策略 | |
| 必需图清单 | boundary/context, decomposition/domain, runtime flow, state/resource, lifecycle/concurrency, failure/recovery, trust/config |
| Views | operating-model, critical-journeys, current-target-gap |
| 设计意图覆盖 | mission/priorities/non-goals/success standards/journeys/current-target-gap |
| Domain 有效性规则 | why separate + independence signal |
| 已创建 domains | |
| 待探索 domains | |
| 未覆盖 gap | |
| 递归/停止审查 | reviewer + `no-more-required-changes` / `needs-fix` + 剩余修改项 |

## Architecture Diagram 状态

| Diagram ID | 架构路径 | 状态 | 覆盖内容 | 证据 | 链接的表格行 | Gap / 下一步动作 |
|---|---|---|---|---|---|---|
| | SSOT/architecture/.../README.md | current / target / stale | | | 运行流 / 子 Domains / 契约 / 状态 / 生命周期 / 失败 / trust-config | |

## 源资料吸收状态

| 源资料 | 路径/来源 | 分类 | 权威位置 | 状态 | 冲突/裁决项 |
|---|---|---|---|---|---|
| | | absorb / link-only / stale/conflict / obsolete | SSOT/... | pending / absorbed / linked / conflict-recorded / obsolete | |

> README/docs/ADR/runbook/PRD 和用户显式提供资料是输入信源；长期知识应吸收到 权威位置，README/docs 只能作为薄文档或派生产物。`stale/conflict` 不能只标记后跳过，必须裁定当前事实、写入 Current / Target / Gap 或登记裁决项。

## 收敛检查

> Phase 3 期间由协调者记录。大规模仓库可按 Tier、architecture view 或 architecture domain 分段收敛。

| 分段 | 审查会话 | Reviewer | 结果 | 剩余修改项 | 需修正项 |
|---|---|---|---|---|---|
| Tier 1 | | | pending | | |
| Tier 2 | | | pending | | |
| Tier 3 | | | pending | | |
| Tier 4 | | | pending | | |

> 结果值域：`pending` / `passed` / `needs-fix`
>
> `passed` 只能在独立 reviewer 返回 `no-more-required-changes` 后填写；`needs-fix` 必须触发修复后复审。

## Tier 4 发现汇总

> 由协调者从各 session log 的 Tier 4 发现中汇总。集中整理后写入对应区域，并标记"已录入"。

| 发现 | 类型 | 来源标记 | 来源位置 | 来源会话 | 已录入 |
|---|---|---|---|---|---|
| | gotcha / bug / decision / architecture-constraint / debt | documented / code-comment / code-analysis / git-history | 文件路径或描述 | session-NNN | yes / no |
