# 源资料参考

本文件是源资料分类、吸收状态、薄文档规则、冲突裁定和 architecture source routing 的语义所有者。`STATUS.md` 只维护矩阵和水位字段；本文件维护如何判断和处理源资料。

## 目录

- [1. 源资料范围](#1-源资料范围)
- [2. 分类与处理规则](#2-分类与处理规则)
- [3. 薄文档规则](#3-薄文档规则)
- [4. 冲突裁定](#4-冲突裁定)
- [5. Architecture Source Routing](#5-architecture-source-routing)
- [6. 状态同步](#6-状态同步)

## 1. 源资料范围

源资料是 SSOT 之外的原始信源，包括：

- 根 README、`docs/`、ADR、PRD、设计文档、runbook、ARCHITECTURE.md、CONTRIBUTING.md、子系统/服务 README。
- `AGENTS.md`、`CLAUDE.md`、`.cursor/rules`、`.windsurf/rules`、`GEMINI.md` 等核心参考文档：Agent 启动即读、仓库级指令或 IDE/Agent rules 文件。
- 用户在当前会话中显式提供的外部资料、规范、设计说明、历史文档、URL、文件或上下文。
- 内联文档注释中成体系的设计说明。

源资料可以作为探索入口、证据来源、公开说明或派生产物，但长期知识必须吸收到 `SSOT/` 的唯一权威位置中维护。描述当前已实现事实时，源资料可信度低于代码、配置、schema、测试和实际运行行为；描述目标设计和历史意图时，源资料可能是重要证据，但仍要进入 architecture / decisions / 状态矩阵。

Reader Map、claim-to-evidence、脚本/工具目录和 diagram candidate 治理是 SSOT 原生表达能力，不依赖任何外部生成资料。外部生成图、截图、依赖图或自动摘要若由用户显式提供，只能作为普通外部资料中的候选线索；吸收前必须回到代码、配置、schema、测试或实际运行行为交叉验证。不能新增平行自动生成知识面，不能镜像全文，也不能把外部目录或主题结构照搬成 SSOT 权威结构；未验证内容保持 `pending`、`link-only` 或 `stale/conflict`。

源资料盘点可以复用 文档语言锁 的探测来源，但语言锁只根据 `SKILL.md` 文档语言锁允许的自然语言证据判断。源资料的自然语言变化只能触发语言锁审查线索，不得自动切换 `documentation_language`。

### 1.1 核心参考文档

核心参考文档不是普通薄入口的例外。若它们只包含 SSOT 路由、generated marker 和少量核心不变量摘要，按 SSOT-generated 薄适配器处理；若它们含有命令、目录地图、工作流状态、架构约束、模型/配置规则、测试策略、Agent 操作前置条件或其他长期事实，则同时是源资料，必须做事实审查。`thin-adapterize` 只是条件性建议：只有长期事实已迁入 SSOT、项目希望该文件改由 SSOT 托管、或用户明确要求时才提出；手写或 mixed 启动文件可以保留本地事实，但必须接受 `[CORE-REF]` 审查。

处理规则：

- 与代码/配置/schema/test、package manifests、Makefile、CI 配置、SSOT architecture/testing/development 和当前 skill 协议逐项比对。
- 若长期事实有效但不应留在启动文件中，吸收到 SSOT 权威位置，并在满足上述条件时建议 `thin-adapterize`。
- 若事实过时或错误，标记 `stale/conflict`，给出具体 `update-doc` 建议；不要只把正确事实吸收到 SSOT 后静默忽略启动文件漂移。
- 若事实表达目标设计但实现未落地，进入 Current / Target / Gap、decisions 或开放裁决项，并在核心参考文档审查表中标明 `record-conflict`。
- 若文件不存在且项目没有要求对应 harness，记 `not_applicable`；不要为了通过审查机械创建启动文件。

## 2. 分类与处理规则

对每份源资料分类：

| 分类 | 适用条件 | 处理动作 |
|---|---|---|
| `absorb` | 含有应长期保留的系统知识、设计意图、约束、流程、陷阱、决策或风险 | 提炼长期知识到对应 权威位置，保留来源指针和证据等级；不要全文镜像。 |
| `link-only` | 原文有价值，但不应复制维护，例如完整教程、外部规范、长篇背景资料或公开文档 | 在权威位置保留摘要 + 链接，不复制全文；必要时说明何时回读原文。 |
| `stale/conflict` | 与代码事实、当前运行行为或已有设计意图冲突，或同一资料内部过时 | 不能只标记后跳过；必须裁定当前事实、写入 Current / Target / Gap、更新 decisions 或登记开放裁决项。 |
| `obsolete` | 已失效，仅有历史价值，或被明确替代 | 不作为当前事实证据；必要时保留历史指针、替代资料和禁止复活说明。 |

吸收时遵守：

1. 只提炼长期知识，不复制源资料全文。
2. 若事实可从代码/配置/schema/test 直接推导，SSOT 写摘要 + 指针 + why/风险/约束。
3. 记录原路径、URL、文件名、会话位置或其他稳定来源标识。
4. 分类为 `stale/conflict` 的资料必须继续路由，不能停留在矩阵状态。
5. 分类为 `obsolete` 的资料不得支撑 `covered` 或当前事实；若旧形态可能诱导未来 Agent 回退，写入 architecture 演进 / 迁移台账、gotchas 或 decisions。

## 3. 薄文档规则

README、docs、ADR、PRD、公开说明、安装教程、链接页或摘要页可以存在，但若它们承载独立长期事实，应改为薄文档：

- 只保留面向人类或入口用途的摘要。
- 链接到 `SSOT/` 的权威位置，或声明内容由 SSOT 派生。
- 不与 SSOT 平行维护架构边界、运行流、状态所有权、契约、目标设计、约束、陷阱、RCA 或技术债。
- 若薄文档与当前实现冲突，以代码/配置/schema/test 裁定当前事实，并在源资料吸收矩阵标记冲突处理结果。
- 若薄文档与设计意图冲突，保留双方证据，更新 architecture Current / Target / Gap、decisions 或开放裁决项。

## 4. 冲突裁定

源资料与代码或 SSOT 冲突时按以下规则处理：

| 冲突类型 | 裁定方式 |
|---|---|
| 源资料描述当前实现，但代码/配置/schema/test/运行行为不一致 | 当前事实以代码/配置/schema/test/运行行为为准；在 SSOT 写明裁定后的事实和来源，把源资料标为 `stale/conflict`。 |
| 源资料描述目标设计、约束或未落地方案，但当前实现不同 | 不自动判定代码正确；在 architecture Current / Target / Gap 同时记录当前实现和目标意图，必要时把相关 decision 的 `implementation_state` 标为 `diverged` 或 `partial`。 |
| 两份源资料互相冲突 | 保留双方来源，优先使用代码事实裁定当前实现；设计意图冲突进入 decisions 或开放裁决项。 |
| 源资料语言变化 | 只作为语言锁审查线索；不得自动改写 `documentation_language`。 |
| 源资料要求恢复旧方案、旧 surface 或 deprecated concept | 检查 architecture 演进 / 迁移台账、decisions、gotchas；若旧方案已禁止复活，记录冲突并避免按源资料恢复。 |

无法归入上述层级的冲突，保留双方证据并进入裁决队列。

## 5. Architecture Source Routing

Architecture 相关源资料按内容路由到唯一权威位置：

| 源资料内容 | 权威位置 |
|---|---|
| 系统定位、产品/系统目标、当前优先级、非目标、运行哲学、主要 actor、用户/运行主路径、成功标准 | `architecture/views/operating-model.md` |
| 关键端到端流程、业务闭环、阶段生命周期、验收/恢复信号、跨域运行流 overview | `architecture/views/critical-journeys.md` |
| 全局 Current / Target / Gap、迁移路线、迁移意图、未落地目标、部分实现的设计意图 | `architecture/views/current-target-gap.md` |
| 组件、边界、状态、锁、资源生命周期、契约、失败恢复、验证证据、domain-specific diagrams | `architecture/domains/<domain>/README.md` 或兼容 legacy direct child-domain |
| 脚本/工具清单、build/test 命令、模型生成、session 分析、版本同步、import rewriting 等工程自动化 | 默认路由到 `development/`、`testing/`、`release/` 或 deployment 相关区域；只有当脚本承载模型生成管线、session 分析、发布一致性、状态迁移或其他架构行为时，才同步进入相关 architecture view/domain |
| 决策、拒绝方案、回滚选择、禁止复活、取舍原因 | `decisions/`，并同步 architecture 演进 / 迁移台账 指针 |
| 事故、RCA、复发风险、回归测试 | `bugs/`、`gotchas/`、`testing/`，并同步相关 domain |
| 性能/容量、扩展点、兼容性策略 | 只有当它们是系统设计事实、用户承诺或风险来源时进入 architecture；否则进入对应工程区域或不记录 |
| 纯公开说明、用户文档、安装教程 | 保持为薄文档或工程操作区域摘要；不作为长期设计事实源 |

View 不能是纯表格。若源资料中有 PRD、当前阶段目标、产品承诺、非目标、验收标准或设计原则，必须吸收到 `operating-model.md`、`critical-journeys.md` 或 `current-target-gap.md`，而不是只在 `STATUS.md` 标记已读。

## 6. 状态同步

`STATUS.md` 必须保留 源资料吸收矩阵。每次读取或变更仍有长期价值的源资料，都记录：

- 源资料标题或路径/来源。
- 分类：`absorb` / `link-only` / `stale/conflict` / `obsolete`。
- 权威位置。
- 吸收状态：`pending` / `absorbed` / `linked` / `conflict-recorded` / `obsolete`。
- 冲突/裁决项：`ADJ-...` 或 `none`。
- 最后检查日期或 commit/session 标识。

核心参考文档还必须同步维护 `STATUS.md` 的 核心参考文档审查 表。源资料吸收矩阵记录“长期事实吸收到哪里”，核心参考文档审查表记录“启动/参考文件本身是否仍正确，以及建议怎么改”；两者不能互相替代。

Bootstrap 期间 `SSOT/.bootstrap/manifest.md` 也记录吸收进度；bootstrap 清理前，长期仍有价值的源资料状态必须转录到 `STATUS.md`。
