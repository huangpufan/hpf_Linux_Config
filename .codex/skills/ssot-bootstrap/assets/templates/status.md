# SSOT 状态

<!-- 模板实例化说明：写入渲染后的 SSOT 文件前，必须把标题、表格标签、占位符和辅助说明翻译为 Phase 0 或 STATUS.md 锁定的 documentation_language。代码标识符、路径、命令、API 名、枚举值和直接引用保持原文。 -->

## 事件源覆盖

| 字段 | 值 |
|---|---|
| tracked_commit | `<commit-sha>` |
| tracked_session | `<ISO-timestamp-or-session-id>` |
| tracked_skill_version | `<ssot-preflight-protocol-version>` |
| documentation_language | `<locked-natural-language-or-BCP47-tag>` |
| documentation_language_evidence | `<source-artifact-paths-or-user-decision-and-review-evidence>` |
| coverage_result | `bootstrap` / `catching_up` / `in_progress` / `converged` |
| last_stop_review | `<review-id-or-summary>` |

> `converged` 表示 commit、session、skill 协议 三个水位和 文档语言锁 都已覆盖并通过独立 review。最终推进 `tracked_commit` / `tracked_session` / `tracked_skill_version`、变更 `documentation_language` 以及声明 `converged` 是高影响停止结论，必须由独立 reviewer 返回 `no-more-required-changes` 后才有效。`covered`、Doctor 分段 `passed`、session/commit `no-op` / `无需更新`、`single-level` 和停止拆分属于中影响停止结论；优先独立复核，不可用时按 `self-reviewed` 降级路径记录。

## 区域状态

| 区域 | 状态 | 备注 |
|---|---|---|
| architecture | | |
| identity | | |
| glossary | | |
| development | | |
| testing | | |
| deployment | | |
| release | | |
| decisions | | |
| gotchas | | |
| bugs | | |
| tech-debt | | |

> 状态值域：`covered` / `gap` / `stale` / `unknown` / `not_applicable` / `conflict`
>
> `covered` 是中影响停止结论。标记前必须在下方 停止审查闸门记录 `no-more-required-changes`；优先独立 reviewer，不可用时 `reviewer` 写 `self-reviewed` 并在 `evidence` 说明自审范围、依据和跳过项。
>
> `architecture` 标 `covered` 前，确认 root 入口 可建立快速心智模型；Reader Map / 快速理解地图只做权威路由且不承载独立事实；views/domains 或兼容 legacy direct child-domain 的 required README 有 Readable Authority / 可读权威正文、evidence 和 必需 Mermaid 图；运行流 已链接 current flow Diagram ID；domain 有 `why separate` + independence signal；覆盖深度 与证据一致；未覆盖范围已列入 gap/unknown；停止拆分 / `single-level` 结论已被 reviewer 挑战通过。
>
> 备注列禁止维护可派生信息（条目计数、子目录条目状态、最近测试结果）。需要引用子目录时使用纯指针：`条目以 [`gotchas/README.md`](./gotchas/README.md) 为权威；当前覆盖 …`。详细规则见 `$ssot-preflight` 的 `references/status-protocol.md` §3.0。

## 源资料吸收

| 源资料 | 路径/来源 | 分类 | 权威位置 | 吸收状态 | 冲突/裁决项 | 最后检查 |
|---|---|---|---|---|---|---|
| | | absorb / link-only / stale/conflict / obsolete | SSOT/... | pending / absorbed / linked / conflict-recorded / obsolete | | |

> README、docs、ADR、PRD、设计文档、runbook、子系统 README、核心参考文档 和用户显式提供资料都是 源资料。分类为 `absorb` 的长期知识必须进入权威位置；`stale/conflict` 不能只标记后跳过，必须裁定当前事实、写入 Current / Target / Gap 或登记 开放裁决项。

## 核心参考文档审查

| 文档 | 路径 | 角色 | 状态 | 权威关系 | 检查范围 | 最后检查 | 证据 | 建议动作 | 冲突/裁决项 |
|---|---|---|---|---|---|---|---|---|---|
| AGENTS.md / CLAUDE.md / Cursor rules | | startup / agent-rules / reference / none | covered / stale / conflict / missing / not_applicable | thin-adapter / source-material / mixed | commands / directory-map / workflow / architecture / model-config / testing / routing | | | update-doc / thin-adapterize / absorb-to-SSOT / record-conflict / no-op | |

> `AGENTS.md`、`CLAUDE.md`、`.cursor/rules`、`.windsurf/rules`、`GEMINI.md` 等启动即读 / Agent rules 文件若包含仓库约束、命令、工作流、架构边界、模型/配置规则或测试策略，必须按 `[CORE-REF]` 与代码、manifests、CI、SSOT 和当前协议核对。`[ADAPTER]` 只检查 SSOT-generated 薄适配器文件形态；无 marker 的手写 / mixed 文件不因缺 marker 报 `[ADAPTER]`。`[CONSUMPTION]` 检查 SSOT 触发链路；事实错误必须给出具体修改建议，不要静默吸收。

## 停止审查闸门

| scope | stop_claim | reviewer | reviewed_at | result | evidence | remaining_changes |
|---|---|---|---|---|---|---|
| | converged / covered / no-op / 无需更新 / tracked_commit / tracked_session / tracked_skill_version / protocol-upgrade / documentation_language / doc-language-change | | | no-more-required-changes / needs-fix | | |

> 高影响停止结论 updater 不能自审。中影响范围可按 `$ssot-preflight` 的 `references/status-protocol.md` §7.1 使用 `reviewer: self-reviewed` 降级路径，并在 evidence 中写清已检查项与未检查项。`needs-fix` 时不得接受对应 停止结论；修复后必须再次审查，直到 result 为 `no-more-required-changes`。

## 开放裁决项

| id | status | created_at | source | scope | question | needed_by | resolution | revisit_condition | links |
|---|---|---|---|---|---|---|---|---|---|
| | | | | | | | | | |

> 状态值域：`pending`（新会话入口阻断）/ `deferred`（不阻断，直到 revisit_condition 命中）/ `resolved`（不阻断，保留历史）/ `superseded`（被新裁决替代）
>
> `deferred` 必须记录 `revisit_condition`；可使用日期、里程碑、相关 architecture view/domain 再次修改、某个 issue/PR 完成后等条件；未指定时默认为“下次会话重新裁决”。

## 开放缺口

| 区域 | 状态 | 缺口描述 | 阻塞程度 |
|---|---|---|---|
| | gap / unknown | | |

> Reader Map 过时、正文不可读、required diagram 缺失或外部图误作权威图时，记录到对应区域 / view / domain 的 gap，并阻断该范围 `covered`。
