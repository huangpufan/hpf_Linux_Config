# 侦察报告

<!-- 模板实例化说明：写入渲染后的 SSOT 文件前，必须把标题、表格标签、占位符和辅助说明翻译为 Phase 0 或 STATUS.md 锁定的 documentation_language。代码标识符、路径、命令、API 名、枚举值和直接引用保持原文。 -->

> Bootstrap 临时文件。由 Phase 0 侦察阶段产出，供后续阶段参考。Bootstrap 完成且停止审查通过后随 `.bootstrap/` 一起清理。

## 文档语言探测

| 字段 | 值 |
|---|---|
| 探测结果 | `<documentation_language>` / `unknown` / `mixed` |
| 探测来源 | README / docs / ADR / runbook / 子系统 README / 用户显式提供资料 |
| 证据摘要 | |
| 已忽略内容 | code blocks / commands / paths / API names / enum values / identifiers / direct quotes |
| 是否需要询问用户 | yes / no |
| 用户选择或裁决 | |
| 写入 STATUS 字段 | `documentation_language`, `documentation_language_evidence` |

> 语言混杂、证据不足或没有可检测文档时，必须先询问用户选择 SSOT 文档语言；不要用当前对话语言兜底。

## 规模

| 指标 | 值 |
|---|---|
| 规模等级 | `S` / `M` / `L` / `XL` |
| 估算代码行数 | |
| 源文件数量 | |
| 顶层目录数量 | |
| 最大目录深度 | |

## 仓库拓扑

| 字段 | 值 |
|---|---|
| 拓扑类型 | 单体应用 / monorepo-workspaces / monorepo-services / 库/工具 / 内核或基础设施 |
| 工作空间配置 | 文件路径，或不适用 |
| 独立部署单元数 | |
| 入口点 | 文件路径列表 |

## Architecture 拆分候选

| 候选轴 | 适用证据 | 可形成的 domain / 独立性信号 | 优点 | 风险/不足 |
|---|---|---|---|---|
| | | | | |

| 字段 | 值 |
|---|---|
| 推荐主轴 | |
| 推荐理由 | |
| 拒绝的替代轴 | |
| 递归/停止规则 | |
| 覆盖深度预判 | `deep` / `sampled` / `inferred` / `unknown` |
| 抽样/未覆盖计划 | |
| Views / Domains 结构判断 | views+domains / single-level / legacy direct child-domain |
| 预建 architecture views | operating-model, critical-journeys, current-target-gap |
| 预建 architecture domains | why separate + independence signal |
| 必需图预判 | boundary/context, decomposition/domain, runtime flow, state/resource, lifecycle/concurrency, failure/recovery, trust/config |
| 停止/递归审查挑战 | reviewer + result (`no-more-required-changes` / `needs-fix`) + 剩余修改项 |

> 推荐主轴、预建 views/domains、`single-level` 或停止拆分判断都是后续 architecture 结构的 stop/recursion claim。写入正式 architecture README 前，必须由独立 reviewer 挑战这些判断。

## 设计意图候选

| 设计维度 | 发现 | 来源 | 建议权威位置 | 置信度 / 缺口 |
|---|---|---|---|---|
| 使命 / 承诺 | | | `architecture/views/operating-model.md` | verified / documented / inferred / unknown |
| 当前优先级 | | | `architecture/views/operating-model.md` | |
| 非目标 | | | `architecture/views/operating-model.md` | |
| 成功标准 / 验收信号 | | | `architecture/views/operating-model.md` / `architecture/views/critical-journeys.md` | |
| 主旅程 / 闭环 | | | `architecture/views/critical-journeys.md` | |
| 全局 target / 迁移立场 | | | `architecture/views/current-target-gap.md` | |
| 拒绝方案 / 不要复活 | | | `architecture/views/current-target-gap.md` / `decisions/` | |

> 设计意图候选不是最终结论。Phase 2 必须交叉验证并吸收到 views/domains/decisions；证据不足时写 gap/unknown，不能编造。

## Architecture Diagram 候选

| Diagram ID 草案 | 状态 | 覆盖内容 | 触发条件 | 证据候选 |
|---|---|---|---|---|
| | current / target / stale | | boundary / domains / runtime flow / state / lifecycle / failure / trust-config | |

## 可读性候选 / 证据表达候选

| 字段 | 值 |
|---|---|
| 来源 | repo evidence / source material / external generated candidate / other |
| Reader Map 候选 / 主题域 | |
| 脚本/工具清单候选 | Filename / Purpose / Category / evidence |
| Diagram candidates | Diagram candidate + suggested Mermaid destination |
| Claim-to-evidence 候选 | claim shape + evidence link + reusable SSOT table target |
| 建议吸收路由 | architecture view/domain / development / testing / release / deployment / link-only |
| 吸收状态 | pending / absorbed / link-only / stale/conflict |
| 未验证风险 | |

> 条件性小节。只有侦察发现能提升可扫描性或证据表达的候选时才填写；否则写 `not_applicable` 和原因。候选可以来自仓库证据、普通源资料或用户显式提供的外部生成资料，但不能作为事实权威。不要新增平行自动生成知识面，不要镜像全文；可吸收 Reader Map、claim-to-evidence、脚本/工具目录和 diagram candidate 治理，并补上 SSOT 的 why、风险、约束、owner、current/target/gap。脚本清单默认来自仓库脚本、manifest、CI 和配置，并路由到 development/testing/release/deployment；只有承载架构行为时才进入 architecture。所有主题、图和 claim 吸收前必须用代码、配置、schema、测试或运行行为交叉验证。

## 技术栈

| 类别 | 值 |
|---|---|
| 主要语言 | |
| 框架 | |
| 构建系统 | |
| 包管理器 | |
| 运行时 | |

## 源资料盘点

| 源资料 | 路径/来源 | 分类 | 信息量 | 与代码一致性 | 权威位置 | 可服务的区域 |
|---|---|---|---|---|---|---|
| | | absorb / link-only / stale/conflict / obsolete | 高 / 中 / 低 / 空 | 一致 / 部分过时 / 严重过时 / 未验证 | SSOT/... | architecture, identity, ... |

> 源资料包括 README、docs、ADR/runbook、PRD、设计文档、子系统 README，以及用户显式提供的外部资料。只吸收长期知识，不全文镜像。`stale/conflict` 必须继续路由到 当前事实 裁定、Current / Target / Gap 或 开放裁决项，不能只标记后跳过。

## 推荐策略

> 基于以上发现，对后续 bootstrap 阶段的建议。Agent 应在此记录对区域填充顺序、architecture 拆分、深度分配和会话规划的判断。

- **区域顺序调整**：（如果默认 Tier 序需要调整，说明原因）
- **需要特别关注的 architecture views/domains**：
- **可快速完成的区域**：
- **预计需要的会话数**：
- **其他发现/注意事项**：
