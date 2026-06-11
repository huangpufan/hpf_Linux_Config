# Bootstrap 协议

当 Agent 首次面对一个没有 SSOT 的仓库时，使用本协议建立初始 SSOT。

## 目录

- [0. 适用场景与前置条件](#0-适用场景与前置条件)
- [1. Phase 0：侦察](#1-phase-0侦察)
- [2. Phase 1：骨架创建](#2-phase-1骨架创建)
- [3. Phase 2：增量填充](#3-phase-2增量填充)
- [4. Phase 3：收敛检查](#4-phase-3收敛检查)
- [5. Phase 4：清理](#5-phase-4清理)
- [6. 跨会话恢复与并行协调](#6-跨会话恢复与并行协调)
- [7. Bootstrap 反模式](#7-bootstrap-反模式)

## 0. 适用场景与前置条件

**触发条件**：仓库中不存在 `SSOT/` 目录。

**前提**：

- Agent 对仓库有读取权限
- Agent 可执行 shell 命令（用于规模估算和文件扫描）
- 仓库处于可构建/可运行状态（不要求，但如果是则有助于验证）

**核心约束**：Bootstrap 是一次性的知识提取过程，不是日常维护。完成后由 `$ssot-preflight` 的入口感知和 `$ssot-closeout` 的写入收尾接管。

---

## 1. Phase 0：侦察

### 目标

在创建任何 SSOT 正文前，先锁定项目文档语言，再建立对仓库的基本认知——规模、形态、技术栈、已有信息资产。侦察结果决定后续所有阶段的策略。

### 侦察维度

**文档语言锁**

先探测项目已有文档的自然语言，并把结果写入侦察报告，供 Phase 1 初始化 `STATUS.md` 的 `documentation_language` 和 `documentation_language_evidence`。

探测来源仅限根 README、`docs/`、ADR、runbook、子系统/服务 README，以及用户在当前会话中显式提供的外部资料。探测时忽略代码块、命令、路径、API 名、枚举值、代码标识符和直接引用文本。

判断规则：

- 若来源显示单一主导自然语言，锁定该语言，并记录证据来源。
- 若语言混杂、证据不足或没有可检测文档，必须先询问用户选择 SSOT 文档语言；不要用当前对话语言兜底。
- 锁定后，Bootstrap 生成的所有 SSOT Markdown 正文、标题、表格标签和模板结构都使用该语言；代码标识符、路径、命令、API 名、枚举值和直接引用保持原文。

**规模估算**

确定仓库的代码体量。不需要精确行数，需要量级正确。可用的信号包括源文件数量、目录深度、代码行数抽样等。

规模等级作为参考（Agent 应根据仓库实际特征综合判断，LOC 只是其中一个信号）：

| 等级 | 典型特征 | Bootstrap 含义 |
|---|---|---|
| S | < 1 万行，少量文件 | 全量阅读可行，单会话可完成 |
| M | 1 万–10 万行，清晰的目录结构 | 需选择性阅读，1–2 个会话 |
| L | 10 万–100 万行，多架构域/多服务 | 需分层探索，架构边界是关键，2–5 个会话 |
| XL | 100 万+ 行，大型 monorepo 或多团队仓库 | 必须分层抽样，优先理解边界而非穷尽，5+ 个会话 |

**仓库拓扑与架构拆分轴检测**

判断仓库的组织形态，并初步识别 `architecture/` 的候选拆分轴。这决定了后续架构主干是否按运行时边界、业务/能力边界、技术子系统、数据生命周期、关键运行流、外部契约边界或变更边界递归拆分。

| 拓扑 | 典型信号 | 对 bootstrap 的影响 |
|---|---|---|
| 单体应用 | 单一入口点，单一构建产物 | 常按关键运行流或技术子系统拆 architecture |
| monorepo-workspaces | 工作空间配置（pnpm-workspace.yaml, lerna.json, nx.json, turbo.json, Cargo.toml [workspace], Go workspace, Bazel BUILD 等） | 先判断 workspace 是否真是运行/变更边界，不能机械映射 |
| monorepo-services | 多个 Dockerfile 或独立部署单元，可能无工作空间配置 | 运行时边界通常是 architecture 顶层候选轴 |
| 库/工具 | 单一 package manifest，以 exports/CLI 为主 | 外部契约边界和兼容性语义通常是 architecture 核心 |
| 内核/编译器/数据库 | 子系统强、状态模型复杂、测试矩阵大 | 技术子系统 + 数据/状态生命周期通常是主轴 |

Agent 应检查工作空间配置文件、构建系统配置、部署配置、入口点、状态持久化位置、测试边界和已有架构文档来判断拓扑，而非仅依赖目录名。

**架构拆分候选**

侦察阶段必须产出 2-4 个 architecture 候选拆分轴，并推荐一个主轴。推荐理由必须说明该轴如何解释运行流、状态所有权、失败模式、契约边界和变更风险；对预建 domain 还要说明 `why separate` 和至少一个独立性信号。

新 bootstrap 默认评估 `views/ + domains/` 结构：

- 哪些目标、优先级、非目标、成功标准和设计意图进入 `views/operating-model.md`。
- 哪些旅程/验收信号进入 `views/critical-journeys.md`。
- 哪些 current-target-gap 和部分落地意图进入 `views/current-target-gap.md`。
- 哪些状态/契约/失败细节进入 `domains/<domain>/README.md`。

Bootstrap 可以从仓库证据和普通源资料中抽取可读性候选：Reader Map 主题、claim-to-evidence 断言、脚本/工具清单和 diagram candidates。推荐主轴必须由代码、配置、schema、测试、运行行为或设计意图资料交叉验证，不能照搬外部自动主题树，也不能新增平行自动生成知识面、schema 或新顶层区域。

Phase 2 输出时应吸收两类可读性能力：Reader Map / 快速理解地图用于 root/views/domain 入口导航；Readable Authority / 可读权威正文用于关键 claim 的 evidence、why、风险、约束、owner 和 current/target/gap 分离。Reader Map 必须由 architecture decomposition、读者问题和证据生成。还要初步盘点必需 Mermaid 图：boundary/context、domain decomposition（如有）、每个 Runtime Flow 的 current flow diagram，以及适用的 state/resource、lifecycle/concurrency、failure/recovery、trust/config diagrams。L/XL 仓库还应给出初步 覆盖深度 预判和抽样/未覆盖计划。详细规则见 [`references/architecture.md`](../../ssot-preflight/references/architecture.md)。

**Agent 指令文件盘点**

扫描仓库中已存在的 Agent harness 指令文件（AGENTS.md、CLAUDE.md、.cursor/rules、.windsurf/rules、GEMINI.md、.codex/ 等）。记录每个文件的位置、是否含 SSOT generated marker、是否承载独立长期事实、以及应进入 `STATUS.md` 核心参考文档审查 表的角色 / 权威关系。文件形态检查见 [`adapter-strategy.md`](../../ssot-doctor/references/adapter-strategy.md)；SSOT 触发链路见 [`consumption-audit.md`](../../ssot-doctor/references/consumption-audit.md)；事实正确性和源资料分类见 [`source-material.md`](../../ssot-preflight/references/source-material.md) 与 [`doctor.md`](../../ssot-doctor/references/doctor.md) 的 `[CORE-REF]`。

**技术栈识别**

从 package manifest（package.json, go.mod, Cargo.toml, pyproject.toml, pom.xml, build.gradle 等）和构建配置中识别主要语言、框架和构建系统。技术栈信息影响证据来源图中的具体文件路径。

**源资料 盘点与分类**

扫描仓库中已存在的 源资料。这些是 bootstrap 的"免费信息"——已有资料应被优先利用来建立假设，而不是从代码重新推导所有上下文。

典型扫描目标：根 README.md、ARCHITECTURE.md、CONTRIBUTING.md、docs/ 目录、外部 ADR 目录、runbook、各子系统/服务 README、内联文档注释的覆盖情况，以及用户在当前会话中显式提供的外部资料。源资料 盘点可以复用 文档语言锁 的探测来源，但语言锁只根据 `$ssot-preflight` 文档语言锁允许的自然语言证据判断。

对每份 源资料，评估其与代码的一致性和信息量，并按 [`source-material.md`](../../ssot-preflight/references/source-material.md) 分类为 `absorb`、`link-only`、`stale/conflict` 或 `obsolete`。Architecture 源资料的默认吸收路由、薄文档规则和冲突裁定也以该文件为语义所有者。

Repository scripts and utilities 默认先从仓库脚本目录、package manifest、CI、Makefile、配置和实际运行命令中识别，并路由到 `development/`、`testing/`、`release/` 或 deployment 相关区域；只有当脚本承载模型生成管线、session 分析、发布一致性、状态迁移或其他架构行为时，才同步进入相关 architecture view/domain。

`STATUS.md` 必须保留 源资料吸收矩阵；bootstrap 期间也同步记录到 `SSOT/.bootstrap/manifest.md`。

### 产出

侦察结果存储为 `SSOT/.bootstrap/recon.md`。这份报告必须包含 文档语言锁 探测结果、证据和是否已询问用户。这份报告是后续所有阶段的参考依据，直到 bootstrap 完成后随 `.bootstrap/` 一起清理。

模板见 [`assets/templates/recon-report.md`](../assets/templates/recon-report.md)。

---

## 2. Phase 1：骨架创建

### 目标

创建 SSOT 目录结构和状态追踪文件。骨架结构可由侦察结果指导。

### 产出物

1. `SSOT/` 目录
2. `SSOT/README.md`（主干 + 卫星区域索引；若侦察到高频/高风险研发任务簇，可加入 任务入口映射薄索引）— 模板见 [`assets/templates/ssot-readme.md`](../assets/templates/ssot-readme.md)
3. `SSOT/STATUS.md`（tracked_commit 设为当前 HEAD，tracked_skill_version 设为当前 `ssot-preflight` 的 `metadata.protocol_version`，documentation_language / documentation_language_evidence 设为 Phase 0 锁定结果，coverage_result 设为 `bootstrap`，所有区域状态设为 gap 或 unknown）— 模板见 [`assets/templates/status.md`](../assets/templates/status.md)
4. `SSOT/architecture/` 主干文件夹和卫星区域文件夹，每个放入 `README.md`；新 bootstrap 默认创建 `architecture/views/README.md`、`architecture/views/operating-model.md`、`architecture/views/critical-journeys.md`、`architecture/views/current-target-gap.md` 和 `architecture/domains/README.md`。root 模板见 [`assets/templates/architecture-readme.md`](../assets/templates/architecture-readme.md)，views index 模板见 [`assets/templates/architecture-views-readme.md`](../assets/templates/architecture-views-readme.md)，individual view 模板见 [`assets/templates/architecture-view-operating-model.md`](../assets/templates/architecture-view-operating-model.md)、[`assets/templates/architecture-view-critical-journeys.md`](../assets/templates/architecture-view-critical-journeys.md)、[`assets/templates/architecture-view-current-target-gap.md`](../assets/templates/architecture-view-current-target-gap.md)，domain README 模板见 [`assets/templates/architecture-domain-readme.md`](../assets/templates/architecture-domain-readme.md)。工程操作区域可使用 [`assets/templates/development-readme.md`](../assets/templates/development-readme.md)、[`assets/templates/testing-readme.md`](../assets/templates/testing-readme.md)、[`assets/templates/release-readme.md`](../assets/templates/release-readme.md)
5. `SSOT/.bootstrap/recon.md`（Phase 0 已产出）
6. `SSOT/.bootstrap/manifest.md`（协调层：全局状态 + 区域分配）— 模板见 [`assets/templates/bootstrap-manifest.md`](../assets/templates/bootstrap-manifest.md)
7. `SSOT/.bootstrap/sessions/`（日志层：每个探索单元一个文件）— 模板见 [`assets/templates/bootstrap-session.md`](../assets/templates/bootstrap-session.md)
8. 可选的薄适配器文件（AGENTS.md、CLAUDE.md 等）— 仅当侦察发现仓库已有或需要 Agent 指令文件时生成。模板见 [`assets/templates/adapter-agents-md.md`](../assets/templates/adapter-agents-md.md) 和 [`assets/templates/adapter-claude-md.md`](../assets/templates/adapter-claude-md.md)。生成前检查目标文件是否已存在且非 SSOT 生成（无 generated marker），有冲突时报告而非覆盖。详见 [`adapter-strategy.md`](../../ssot-doctor/references/adapter-strategy.md)

### 骨架适配

对于 L/XL 规模的仓库，骨架创建时可根据侦察结果预建 `architecture/domains/` 的第一层 domain（如 `query-engine/`, `storage-engine/`, `control-plane/`）和默认 views（`operating-model.md`, `critical-journeys.md`, `current-target-gap.md`），减少后续填充时的结构性工作。但不要在骨架阶段填充内容；只允许写按 `documentation_language` 翻译后的空 README 标题和 TODO 状态，具体内容属于 Phase 2。既有项目接力时可保留 legacy direct child-domain 结构。

---

## 3. Phase 2：增量填充

这是 bootstrap 的核心阶段。以下六个机制共同指导 Agent 的探索和填充行为。

### 3.1 探索原则

以下原则适用于所有规模的仓库：

**广度优先于深度**：先建立对整个仓库的粗粒度理解，再对重要区域下钻。不要在一个架构域里钻太深，而忽略仓库的其他部分。

**高探索效率文件优先**：按以下优先级选择探索起点（注意：这是探索效率排序，不是可信度排序——可信度见 §3.4）——

| 优先级 | 文件类型 | 原因 |
|---|---|---|
| 1 | 源资料（README, docs, ARCHITECTURE, ADR, runbook, 用户显式提供资料） | 前人的总结，信息密度最高，适合快速建立初始理解 |
| 2 | 配置/manifest（package.json, Dockerfile, CI 配置） | 机器可解析，既高效又可信 |
| 3 | 入口点（main, index, app, server） | 揭示设计单元间的顶层关系 |
| 4 | 接口定义（OpenAPI, protobuf, GraphQL schema, 类型定义） | 契约边界 |
| 5 | 实现代码 | 仅当以上来源不足以回答问题时 |

**源资料 是线索而非结论**：侦察阶段盘点的 源资料，应在对应区域填充时作为探索起点——先从资料建立假设，再用代码和配置验证。描述当前已实现事实时，源资料 可信度低于代码/配置/schema/test（见 §3.4）。但 `architecture/` 与 `decisions/` 承载设计意图，不能因当前代码未落地就直接覆盖或删除；不一致时按 [`source-material.md`](../../ssot-preflight/references/source-material.md) 记录实现状态并进入裁决队列。

**吸收而非镜像**：按 [`source-material.md`](../../ssot-preflight/references/source-material.md) 只提炼长期知识到 权威位置，并保留来源指针、证据等级和冲突状态。README/docs 可保留为 薄文档、公开说明或派生产物，但不能作为独立长期事实源与 `SSOT/` 分裂。无论源资料使用哪种语言，SSOT 输出语言都以 `STATUS.md` 的 `documentation_language` 为准；直接引用保持原文。

**标记 unknown，不猜测**：证据不足时写 unknown。推断必须标记来源（见 §3.6 证据溯源协议）。不要为了"填满"区域而编造内容。

**记录探索边界**：每次会话结束时，在 session log 中记录已探索了什么、还没探索什么。这是跨会话恢复与并行协调的关键信息。

### 3.2 填充依赖序

SSOT 分为主干和卫星区域。填充时应先建立 architecture 主干，再填充工程操作和涌现/历史区域。

```text
Tier 1（上下文 + 主干）—— 必须最先完成
  identity    仓库是什么
  glossary    仓库的专有词汇表
  architecture/README.md  设计简报、Reader Map / 快速理解地图、视角索引、Domain 索引、顶层 current/target/gap 摘要、required overview Mermaid 图
  architecture/views/operating-model.md  系统目标、运行哲学、当前优先级、非目标、主要 actor、用户/运行主路径、成功标准
  architecture/views/critical-journeys.md  关键端到端流程、业务闭环、阶段 lifecycle、验收/恢复信号
  architecture/views/current-target-gap.md  全局 Current / Target / Gap、迁移线、部分实现的设计意图

Tier 2（架构域）—— 依赖 architecture 顶层 decomposition_basis 和 views
  architecture/domains/<domain>/README.md（或兼容 legacy architecture/<domain>/README.md）
  设计意图、设计约束、取舍/拒绝方案、关键运行流、状态所有权、契约、约束、失败恢复、验真方式、必需 Mermaid 图

Tier 3（工程操作层）—— 依赖对 architecture 的理解
  development   怎么跑起来
  testing       测试策略
  deployment      部署与分发
  release         发布流程

Tier 4（涌现/历史层）—— 不主动"填充"，在探索 Tier 1–3 过程中自然积累
  decisions    重大决策
  gotchas      已知陷阱
  bugs         Bug 修复记录
  tech-debt    技术债务
```

**Tier 4 的特殊性**：decisions、gotchas、bugs、tech-debt 的信息本质上是"发现"的而非"提取"的。在 bootstrap 阶段，Agent 从未参与过项目开发，能发现的内容有限。协议要求：

- 在填充 Tier 1–3 的过程中，Agent 应同步留意 Tier 4 的素材（如发现阶段优先级/非目标/成功标准 → 记入 operating-model view，发现架构约束来源 → 记入相关 domain 的 设计约束 / 不变量 / 约束 或 operating-model view，发现旧方案废弃/迁移/不要复活 → 记入 architecture 的 演进 / 迁移台账 和 decisions，发现循环依赖 → 记为潜在 gotcha，发现 TODO/FIXME → 记为 tech-debt 候选，发现重复的 fix/revert/hotfix commit → 按 failure mode 记为潜在 bugs 条目）
- 这些发现记录在各自的 session log 的 Tier 4 发现区域
- 协调者从 session logs 汇总到 manifest.md 的 Tier 4 发现汇总中
- 当 Tier 1–3 填充到一定程度后，集中整理 Tier 4 发现，写入对应区域
- Tier 4 的 bootstrap 质量标准低于 Tier 1–3：骨架 + 已发现的条目即可，后续在实际开发过程中自然增长
- 若 git history 显示某些研发任务簇反复出现且高风险，可在 `SSOT/README.md` 增加 任务入口映射；它只链接 architecture/testing/bugs/gotchas/decisions 等权威位置，不能承载独立事实。

**跨 Tier 并行的场景**：如果 Agent 在建立 architecture 主干时，同时发现了足够的信息来填充某个工程操作区域（如从 Dockerfile 直接获得完整的 deployment 信息），可以顺手填充，不必严格等待。Tier 序是默认优先级，不是铁律。

### 3.3 证据来源图

每个区域的信息隐藏在不同位置。以下表格指导 Agent 在填充特定区域时应该去哪里找信息。

| 区域 | 首选来源 | 次选来源 | 代码搜索信号 |
|---|---|---|---|
| identity | 根 README, package manifest, 仓库描述 | CI badges, about page, 用户显式提供资料 | — |
| glossary | 根 README, ARCHITECTURE.md, 子系统/服务 README 中的术语解释 | 代码中的类/类型/常量命名, 注释中的术语定义, 用户显式提供资料 | 领域实体命名, 自定义类型名, 常量枚举名 |
| architecture | ARCHITECTURE/设计文档, PRD, 入口点, package/workspace manifest, 服务/运行时配置, schema, 路由/协议定义, 测试边界, 重大迁移/旧 surface 删除/deprecated concept 证据 | 代码结构, README, ADR, 运维 runbook, 用户显式提供资料 | `main`, `server`, `route`, `schema`, `state`, `retry`, `auth`, `metric`, `adapter`, `deprecated`, `legacy`, `migration` |
| development | Makefile, package.json scripts, Dockerfile, docker-compose | CONTRIBUTING.md, README "Getting Started" | — |
| testing | 测试目录, 测试配置 (jest/vitest/pytest/go test), CI 测试步骤 | 覆盖率配置, 测试 fixture | `test`, `spec`, `__tests__`, `_test.go` |
| deployment | Dockerfile, k8s/, terraform/, CI/CD 配置, docker-compose | 部署文档, release 脚本 | — |
| release | CHANGELOG, release 脚本, 版本文件, CI release 步骤 | tag 规则, publish 配置 | `version`, `release`, `changelog` |
| decisions | ARCHITECTURE.md, ADR 目录, 设计文档 | PR 描述, commit 消息中的 "why" | — |
| gotchas | 代码注释, bug 修复 commit, workaround 代码 | Issue tracker | `TODO`, `FIXME`, `HACK`, `WORKAROUND`, `XXX`, `NOTE` |
| bugs | bug 修复 commit, PR 描述中的 root cause 分析, Issue tracker；重复 fix/revert/hotfix 按 failure mode 聚类 | 代码注释中的修复说明, CHANGELOG | `fix`, `bugfix`, `hotfix`, `revert`, `Fixes #` |
| tech-debt | 代码注释, legacy 代码模式, deprecated 标记 | Issue tracker 中的 debt/refactor 标签 | `TODO`, `FIXME`, `deprecated`, `legacy`, `TECH_DEBT` |
| architecture（外部依赖/集成） | 代码中的 API client、SDK 调用、重试/超时配置、错误处理分支 | README 中的集成说明, 外部 API 文档链接, 已知限制记录, 用户显式提供资料 | `client`, `sdk`, `api`, `timeout`, `retry`, `rate_limit`, `workaround`, `vendor`, `external` |

这张表是指南而非清单——Agent 应根据仓库的技术栈和组织方式灵活调整。不同语言和框架的惯例不同。

当侦察发现脚本目录、package manifest、CI、Makefile 或配置中的工具入口时，Tier 3 区域应吸收其可扫描格式：development/testing/release/deployment README 中可使用 `Filename / Purpose / Category / When to use / Evidence / Risk or prerequisite` 这类结构化目录，并按语义把 build/test/codegen/session-analysis/version-sync/import-rewrite 等脚本路由到对应区域。字段是推荐结构，不是新 schema。脚本若维护架构不变量或生成运行时 contract，再从工程操作区链接回 architecture domain、view 或 decision。

### 3.4 证据可信度与探索效率

证据有两个独立的维度：**可信度**（冲突时信谁）和**探索效率**（先看什么能最快建立理解）。两者的排序恰好相反。

**可信度排序**（高 → 低）：

```text
Tier A：代码行为（运行结果、实际 import/export、真实调用链）
  → 已实现事实。描述当前落地行为时，以代码为准。
Tier B：配置文件（package.json, Dockerfile, CI config, schema）
  → 接近已实现事实。机器可解析，通常与代码同步，但可能存在未使用的配置。
Tier C：代码注释 / commit 消息
  → 开发者的即时意图记录，但可能过时或不准确。
Tier D：源资料（README, ADR, ARCHITECTURE.md, docs/, runbook, 用户显式提供资料）
  →源资料可能滞后；architecture 的 Current / Target / Gap 与 不变量 / 约束 以及 ADR 是设计意图权威，但不是已实现事实权威。
```

**探索效率排序**（高 → 低）：

源资料 > 配置文件 > 代码结构 > 代码内容 > Git 历史。资料虽然可信度低，但作为探索起点效率最高——先从资料建立初始理解，再用代码和配置验证与校正。

**核心原则**：源资料 是线索；代码/配置/schema/test 是已实现事实的裁判，`architecture/` 和 `decisions/` 是设计意图的裁判。Agent 应：

1. 从源资料出发快速建立假设（探索效率高）
2. 用代码和配置验证假设（可信度高）
3. 发现 源资料与已实现事实不一致时，以代码/配置/schema/test 为准，在 SSOT 中标注分歧（"资料声称 X，但代码实际为 Y"）
4. 发现已实现事实与设计意图不一致时，不自动改写设计意图；在决策中标记 `implementation_state: diverged` 或 `partial`，并写入 `STATUS.md` 的 `开放裁决项`

这与 `$ssot-preflight` 的“已实现事实 vs 设计意图”原则一致：先区分二者，再处理冲突。

### 3.5 深度校准指南

不同规模的仓库，`architecture/` 应产出不同粒度的内容。以下是典型校准（Agent 应根据仓库实际特征调整）：

| 区域 | S | M | L | XL |
|---|---|---|---|---|
| architecture | 单层 README，或轻量 `views/ + domains/`，必需 Mermaid 图 完整 | Root entry + views + 少量有效 domain + 必需 Mermaid 图 | Root entry + views + 两层 domains，关键流/状态/契约有 domain/subfile，并有 overview/subflow diagrams | 多层递归 domains，含抽样说明、覆盖深度、必需图 和剩余 gap |
| development/testing | 全部策略详述 | 全部策略 | 按架构域描述策略 | 按关键架构域 + 代表性示例 |
| deployment/release | 单路径说明 | 环境/发布差异 | 按部署单元或环境 | 按运行时边界/团队发布边界分段 |
| gotchas/bugs/tech-debt | 所有已知 | 所有已知 | 按架构域分组 | 按架构域 + 风险等级分组 |

**XL 仓库的抽样策略**：当仓库规模使得穷尽不可行时，Agent 应：

- 在 architecture root、views 或 domain README 中标明 覆盖深度：`deep`、`sampled`、`inferred`、`unknown`
- 优先深入分析高变更频率、高依赖被引用、状态所有权复杂、失败影响大、或用户近期工作相关的架构域
- 为抽样范围内每个 `运行流` row 建立 current Mermaid flow diagram；未覆盖 flow 或 conditional diagram 必须标 `gap`/`unknown`
- 在 session log 中记录抽样策略、已抽样的架构域列表和未覆盖 gap

### 3.6 证据溯源协议

SSOT 的所有内容都应可追溯到证据来源。Bootstrap 阶段尤其重要，因为 Agent 对仓库的理解完全来自代码和 源资料，没有团队成员的口头知识。

**Tier 1–3 区域**：内容通常来自配置文件、架构入口和代码结构，证据来源在大多数情况下是显而易见的（如"构建命令见 package.json"）。遵循 `$ssot-preflight` 的“摘要 + 指针 + 语义层”原则即可。

**Tier 4 区域**：信息来源更多样，且 Agent 可能通过代码分析推断出原始开发者未显式记录的信息。这些推断有价值但必须标记来源：

| 来源标记 | 含义 | 置信度 |
|---|---|---|
| `documented` | 来自 源资料（README, docs, ADR, runbook, 用户显式提供资料, 注释中的完整说明） | 高（但需验证时效性） |
| `code-comment` | 来自代码注释（TODO, FIXME, HACK, WORKAROUND 等） | 中（开发者自己标记的） |
| `code-analysis` | Agent 通过代码分析推断（如发现循环依赖、发现异常的错误处理模式） | 中低（需人工确认） |
| `git-history` | 来自 git 历史分析（如频繁 revert 的区域、大量 hotfix 的架构域） | 低（统计推断） |
| `conversation` | 来自 Agent 对话记录（附 session 标识或时间戳） | 中（对话中的结论，涉及代码时应交叉验证） |

标记格式不强制——可以是行内标注、脚注或条目元数据。关键是让下一个读 SSOT 的 Agent（或人类）能区分"确认的事实"和"推断的假设"。

---

## 4. Phase 3：收敛检查

### 目标

验证 SSOT 内容与代码状态一致、无遗漏、无过时信息。

### 流程

```text
1. 独立 reviewer（非填充者/协调者本人）读取 `SSOT/README.md`、`architecture/README.md`、`architecture/views/README.md`、`architecture/domains/README.md`（如存在）和所有顶层区域索引
2. 对照 tracked_commit 对应的代码状态、tracked_skill_version 对应的 skill 协议 规则，以及 `documentation_language` 对应的语言锁
3. 对照源资料分类和 `STATUS.md` 源资料吸收：`absorb` 是否已进入权威位置？`stale/conflict` 是否已裁定当前事实、进入 Current / Target / Gap 或进入裁决队列？README/docs 是否只作为 薄文档？SSOT 正文、标题、表格标签是否使用锁定语言？
4. 逐区域判断：内容是否准确、完整、无过时信息？
5. 对 architecture 递归检查：root 入口 是否能建立 1 分钟心智模型并包含 设计简报；views 是否吸收目标/优先级/非目标/成功标准/主路径/current-target-gap 且不是纯表格；每个 domain 是否有 设计意图、设计约束、取舍 / 被拒绝的简化、未来 Agent 必须保持的内容、decomposition_basis、core required、conditional required、current/target/gap、覆盖深度、覆盖范围 / 抽样策略、evidence、验证方式和 必需 Mermaid 图；domain 是否通过架构域有效性测试
6. 对所有 `done`、`passed`、`covered`、`single-level`、停止拆分和 `无需更新` 结论发起 challenge，并检查 manifest/session/architecture README 中是否记录停止审查evidence
7. 如果所有区域都无需更新 → reviewer 输出 `no-more-required-changes`，对应分段才可标 `passed`
8. 如果有区域需要更新 → reviewer 输出 `needs-fix` 和 剩余修改项；协调者修复后重复检查
```

### 大规模仓库的分段收敛

对于 L/XL 规模的仓库，一次性审查全部 architecture domains 和卫星区域可能超出单个 Agent 会话的能力。允许以下分段策略：

- 按 Tier 分段：先确认 architecture root/views 和上下文收敛，再确认 domains 和工程操作区域
- 按 architecture domain 分段：对于 XL 仓库，可按顶层架构域逐组检查相关区域
- 整体收敛 = 所有分段均有独立 reviewer 的 `no-more-required-changes`

分段收敛的进度记录在 manifest.md 的收敛检查区域中。

---

## 5. Phase 4：清理

Bootstrap 完成后（收敛检查通过，且独立 reviewer 对 Phase 4 清理返回 `no-more-required-changes`）：

1. **归档 recon.md 而非删除**（v2.12 新增）：
   - `[MUST]` 将 `SSOT/.bootstrap/recon.md` 移动到 `SSOT/decisions/0000-bootstrap-recon.md`
   - 在文件头添加 frontmatter：
     ```yaml
     ---
     id: DEC-0000
     type: bootstrap-archaeology
     status: archived
     archived_at: <ISO date>
     ---
     ```
   - 不需要重写正文；保留原始侦察证据（语言探测、规模、拓扑、架构拆分候选、源资料盘点、推荐策略）
   - 在 `SSOT/decisions/README.md` 索引中加入指针，标注为"考古条目，记录初次 bootstrap 的决策上下文"

2. 删除 `SSOT/.bootstrap/` 目录的过程性文件（manifest.md、sessions/）
   - manifest 和 session logs 是过程日志，价值随 bootstrap 完成而消失
   - 长期有效的停止审查摘要必须先转录到 `STATUS.md`（见步骤 3）

3. 更新 `SSOT/STATUS.md`：
   - `coverage_result` 从 `bootstrap` 改为 `converged`
   - 确认 `tracked_skill_version` 仍等于当前 `ssot-preflight` 的 `metadata.protocol_version`；若中途 bundle 协议升级，先执行 协议升级审查
   - 确认 `documentation_language` 和 `documentation_language_evidence` 已存在；若中途需要切换语言，先完成裁决和独立 review
   - 确认 源资料吸收矩阵 已包含 bootstrap 期间读取且仍有长期价值的资料，以及每份资料的权威位置/ 吸收状态 / 冲突裁决
   - 更新各区域状态
   - 清理 open gaps 中已解决的条目
   - 转录最终停止审查摘要，作为 `converged` 和 `tracked_commit` / `tracked_session` / `tracked_skill_version` 水位的证据

**理由（v2.12）**：recon.md 包含"为什么 architecture 被拆成这 N 个域"、"为什么某些源资料被标为 stale"等长期价值的决策证据。过去要求收敛后整体删除 `.bootstrap/` 导致这些考古信息永久丢失，后续维护者面临架构重组时缺乏上下文。manifest 和 session logs 仍然清理——它们是过程协调日志，长期价值低于决策记录。

---

## 6. 跨会话恢复与并行协调

对于 M/L/XL 规模的仓库，bootstrap 通常跨多个会话完成，且可由多个 Agent 并行推进。协调机制的核心是 `SSOT/.bootstrap/manifest.md`（全局状态）和 `SSOT/.bootstrap/sessions/`（探索日志）。

### 6.1 角色分工

Bootstrap 过程中存在三种角色：

**协调者（父 Agent）**：
- 持有全局视角，读写 `manifest.md`
- 根据 Tier 依赖序和当前进度分配工作范围
- 从 session logs 汇总信息，更新 manifest 状态
- 决定何时从 Phase 2 进入 Phase 3（收敛检查），但不能自证 `passed` / `done` / 清理

**工作者（子 Agent）**：
- 接受分配范围，只写入范围内的区域、architecture view 或 architecture domain 文件
- 写自己的 session log（`sessions/NNN-<scope>.md`）
- 不直接编辑 `manifest.md`
- 完成后向协调者汇报结果

**停止审查者（独立 reviewer）**：
- 不写入被审查范围，独立读取相关 SSOT、代码/配置/schema/test、源资料 和 session logs
- 挑战 `done`、`passed`、`covered`、`single-level`、停止拆分、`no-op` / `无需更新` 结论
- 返回 `no-more-required-changes` 或 `needs-fix`；`needs-fix` 必须列 剩余修改项

单 Agent 场景下，同一 Agent 可兼任协调者和工作者——先协调（读 manifest、决定范围），再执行（探索、填充、写 session log），最后回到协调（更新 manifest）。停止审查者必须是独立 agent/subagent；没有独立审查时不能写 `done` / `passed` / `converged` 或清理 `.bootstrap/`。

### 6.2 新 Agent 进入 bootstrap 的流程

```text
1. 检测到 SSOT/.bootstrap/ 存在 → 识别为 bootstrap 进行中
2. 读取 SSOT/.bootstrap/recon.md → 获取仓库全貌
3. 读取 SSOT/.bootstrap/manifest.md → 获取全局进度和区域分配
4. 如果是协调者角色：
   a. 扫描 sessions/ 中最近的 session logs 获取细节上下文
   b. 确定可分配的工作范围（状态为 pending 且依赖已满足的区域、architecture view 或 architecture domain）
   c. 分配范围并派发工作者
5. 如果是工作者角色：
   a. 根据分配范围，可选读取相关 session logs 获取上下文
   b. 探索并填充分配范围内的区域、architecture view 或 architecture domain 文件
   c. 写 session log
   d. 返回结果给协调者
```

### 6.3 并行协调规则

**范围分片**

并行的核心约束：**同一个 README 或条目文件同一时刻只能有一个 Agent 写入**。分片粒度按仓库规模调整：

| 规模 | 分片粒度 | 示例 |
|---|---|---|
| S/M | 按顶层区域或 views/domains | Agent A 负责 architecture root/views + identity，Agent B 负责 development/testing |
| L | 按 Tier 或 architecture domain | Agent A 负责 architecture root/views，Agent B 负责 domains/query-engine/ |
| XL | 按 architecture domain | Agent A 负责 architecture/domains/query-engine/，Agent B 负责 architecture/domains/storage-engine/ |

**Tier 依赖约束**

并行仍需尊重 Tier 依赖序：Tier 2 的工作者可能需要读取 Tier 1 的产出。协调者应确保：
- 同 Tier 内的区域可自由并行
- 下游 Tier 的工作在上游 Tier 至少达到 `done` 状态后再分配；这里的 `done` 必须已有独立停止审查 通过
- 例外：如果下游区域的信息来源不依赖上游产出（如从 Dockerfile 直接获得 deployment 信息），可以提前开始

**Session 编号**

Session 文件按创建顺序递增编号（`001`、`002`...）。并行 Agent 各自使用不同编号。协调者在分配时预分配编号，避免冲突。

### 6.4 manifest.md 的关键要求

manifest.md 必须包含足够的信息让新协调者无缝恢复：

- **区域级别的完成状态**：不止 pending/done，还有具体的已覆盖范围和剩余范围
- **architecture 拆分状态**：候选拆分轴、最终主轴、已创建 views/domains、domain 有效性证据、覆盖深度、覆盖范围 / 抽样策略、必需图清单、未覆盖 domain
- **分配状态**：哪些区域、architecture view 或 architecture domain 正在被哪个 session 处理（防止重复分配）
- **收敛检查进度**：哪些分段已通过、哪些需要修正
- **停止审查记录**：每个 `done`、`passed`、停止拆分、`single-level`、清理决定的 reviewer、result 和 剩余修改项
- **源资料吸收状态**：每份资料的分类、权威位置、吸收进度和冲突/裁决项
- **文档语言锁**：锁定语言、探测证据、是否曾询问用户，以及任何语言切换裁决
- **Tier 4 发现汇总**：从 session logs 中提取的涌现层素材

模板见 [`assets/templates/bootstrap-manifest.md`](../assets/templates/bootstrap-manifest.md)。

### 6.5 Session log 的关键要求

每个 session log 必须记录：

- **分配范围**：本次被分配的区域、architecture view 或 architecture domain
- **探索记录**：实际探索了哪些文件/目录（具体到文件级别）
- **源资料 处理**：读取了哪些资料、分类是什么、吸收到哪个 权威位置、是否有冲突
- **文档语言锁**：本 session 使用的锁定语言和证据来源；若发现语言证据变化，只记录为裁决候选，不自动切换
- **Architecture diagram 处理**：新增/更新了哪些 Diagram ID，哪些 必需图 仍是 gap/unknown
- **停止审查记录**：本 session 声明 `done`、`no-op`、`无需更新`、`single-level` 或停止拆分时，独立 reviewer 如何 challenge，结果是什么
- **产出文件**：写入了哪些 SSOT 区域、architecture view 或 architecture domain 文件
- **Tier 4 发现**：探索过程中积累的涌现层素材
- **阻塞与问题**：无法继续的点、需要协助的事项
- **下次建议**：对后续工作的方向建议

模板见 [`assets/templates/bootstrap-session.md`](../assets/templates/bootstrap-session.md)。

---

## 7. Bootstrap 反模式

避免以下行为：

- **不侦察就动手**：不了解仓库规模和拓扑就创建 SSOT 骨架，导致后续结构不匹配
- **不锁定语言就写正文**：语言证据混杂、不足或不存在时未询问用户，直接用当前对话语言创建 SSOT
- **试图阅读所有源代码**：对 M+ 仓库尝试全量阅读是不可行的，应按证据来源图中的优先级选择性阅读
- **乱序填充区域**：未建立 `architecture/README.md`、views 和拆分依据，就先大量填充 domains，导致后续结构不匹配
- **推断不标来源**：通过代码分析推断出 gotcha 或 decision，但不标记其为推断，让后续 Agent 误以为是确认的事实
- **镜像 源资料**：把 README、docs、PRD 或 ARCHITECTURE.md 的内容逐字搬入 SSOT，而非按 operating-model / critical-journeys / domains 等权威位置提炼长期知识 + 来源指针
- **只标 stale 后跳过**：发现 源资料与代码或设计意图冲突后，只在矩阵里标 `stale/conflict`，却没有裁定当前事实、写入 Current / Target / Gap 或登记裁决项
- **留下独立事实源**：README/docs 继续维护与 SSOT 平行的长期事实，而不是转成薄文档或由 SSOT 派生
- **漏画 必需图**：运行流 只写文字没有 current Mermaid Diagram ID，或 Current/Target 图混在一起
- **单会话硬撑**：对 L/XL 仓库试图在一个会话内完成全部 bootstrap，导致后期质量严重下降
- **均匀用力**：对所有架构域投入相同的探索深度，而非按重要性/变更频率/依赖被引用度分配
- **填充空壳文档**：为满足结构要求写"TODO: 待填充"式的内容——不如标记为 pending 并在 manifest.md 中记录
- **机械目录镜像**：把源码目录直接复制为 architecture domains，而没有 `decomposition_basis`、`why separate` 和 independence signal
- **忽略 Tier 4 素材**：在探索 Tier 1–3 时遇到陷阱/决策/债务线索但不记录，等到填充 Tier 4 时已经忘记
