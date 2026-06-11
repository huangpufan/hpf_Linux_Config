# STATUS.md 协议

本文件是 `SSOT/STATUS.md` 字段、覆盖状态、源资料吸收、核心参考文档审查、开放裁决项、开放缺口、停止审查闸门 和 Skill 协议水位 的语义所有者。创建或更新 `STATUS.md`、推进水位、声明停止结论、处理 源资料吸收、核心参考文档审查或处理裁决时按需阅读。

## 目录

- [1. 角色](#1-角色)
- [2. 顶层字段](#2-顶层字段)
- [3. 覆盖状态表](#3-覆盖状态表)
- [4. 源资料吸收](#4-源资料吸收)
- [4.1 核心参考文档审查](#41-核心参考文档审查)
- [5. 开放裁决项](#5-开放裁决项)
- [6. 开放缺口](#6-开放缺口)
- [7. 停止审查闸门](#7-停止审查闸门)
- [8. Skill 协议水位](#8-skill-协议水位)
- [9. 更新纪律](#9-更新纪律)

## 1. 角色

`SSOT/STATUS.md` 记录 SSOT 的维护状态，围绕三个事件源追踪覆盖情况：

- **commit**：`tracked_commit`
- **conversation**：`tracked_session`
- **skill 协议**：`tracked_skill_version`

它还记录项目级 文档语言锁：

- `documentation_language`
- `documentation_language_evidence`

`STATUS.md` 跟踪内容质量轴；Bootstrap 期间的 `SSOT/.bootstrap/manifest.md` 跟踪工作进度轴。两轴正交：manifest 标 `done` 不等于 STATUS 标 `covered`，两者各自都需要独立停止审查 支撑。Bootstrap 完成后 manifest 会被清理，`STATUS.md` 长期存续。

---

## 2. 顶层字段

| 字段 | 值域 | 语义 |
|---|---|---|
| `tracked_commit` | git commit SHA | SSOT 已审查到的最新 commit |
| `tracked_session` | ISO 时间戳或 session 标识 | SSOT 已审查到的最新对话记录 |
| `tracked_skill_version` | `ssot-preflight` 顶部 YAML 中的 `metadata.protocol_version` | 该项目 SSOT 已审查并应用到的 SSOT Skill bundle 协议版本 |
| `documentation_language` | 自然语言名或 BCP 47 tag | SSOT Markdown 正文、标题、表格标签的锁定语言 |
| `documentation_language_evidence` |源资料路径 / 用户裁决 / 审查记录 | 语言锁的探测证据、用户选择或变更审查依据 |
| `coverage_result` | `converged` / `in_progress` / `catching_up` / `bootstrap` | 整体收敛状态 |
| `last_stop_review` | reviewer/result/evidence reference | 最近一次支撑停止结论或水位推进的独立审查记录 |

### 2.1 coverage_result

| 状态 | 含义 |
|---|---|
| `converged` | SSOT 内容与 `tracked_commit` 的代码、`tracked_session` 的对话、`tracked_skill_version` 的协议规则和 `documentation_language` 的语言锁一致，且独立 reviewer 返回 `no-more-required-changes` |
| `in_progress` | 日常维护中，部分区域可能存在 gap 或 stale |
| `catching_up` | 正在分段追赶大量积压变更，`tracked_commit` 尚未到达 HEAD |
| `bootstrap` | 首次建立 SSOT，尚未完成初始填充 |

`converged` 是 停止结论。没有覆盖整体范围的 停止审查闸门记录时，不得写入。

---

## 3. 覆盖状态表

每行一个顶层 SSOT 区域；`architecture` 行必须说明全局架构主干是否可用，复杂仓库可在备注中列出未收敛的 architecture views/domains。

| 区域 | 状态 | 备注 |
|---|---|---|
| architecture | covered / gap / stale / unknown / conflict | 可选的简短说明 |
| identity | covered / gap / stale / unknown / not_applicable / conflict | 可选的简短说明 |
| ... | ... | ... |

### 3.0 备注列禁止冗余（v2.11）

备注列只能写不能从子目录派生的事实，例如：
- 该区域是否还有未覆盖范围（`covered with gaps in <domain>`）。
- 该区域内未收敛的设计或裁决指针。
- `architecture` 行的 views/domains 覆盖深度说明。

不允许在备注里维护可派生信息：
- 子目录条目计数（如 `14 个 active gotcha`、`6 个 ADR`）：以子目录 README 索引为唯一权威。
- 子目录中具体条目的状态（如 `DEBT-0011 active`）：以条目自身 frontmatter 或子目录 README 为权威。
- 最近一次测试通过结果：写入 停止审查闸门或验证账本，不堆在区域备注。

派生信息更新时只更新一处权威位置，禁止双写。STATUS 备注需要引用子目录时，使用纯指针：

```markdown
| gotchas | covered | 条目以 [`gotchas/README.md`](./gotchas/README.md) 为权威；当前覆盖 docs/runtime/SDK 三个主题分组。 |
```

理由：双写计数已被反复证明无法长期同步，updater 在高负荷任务中系统性遗忘；让子目录 README 成为唯一计数权威可消除整类漂移。

### 3.1 状态值域

| 状态 | 含义 |
|---|---|
| `covered` | 该区域的内容与 `tracked_commit` 的代码、`tracked_session` 的对话和 `tracked_skill_version` 的适用协议规则一致，范围内无 `confidence: hypothesis` 或 `confidence: candidate` 的内容，且该范围已有独立停止审查 通过 |
| `gap` | 该区域适用，但内容缺失或不完整 |
| `stale` | 该区域的内容落后于 `tracked_commit` 的代码、`tracked_session` 的对话或 `tracked_skill_version` 的协议规则 |
| `unknown` | 证据不足，无法判断 |
| `not_applicable` | 该工程操作区域对当前仓库不适用，已在 README 中声明原因 |
| `conflict` | 不同证据来源对该区域存在冲突，已记录双方说法但未裁决 |

`architecture` 标为 `covered` 还要求：root 入口能建立快速心智模型；Reader Map / 快速理解地图只做权威路由且不承载独立事实；views/domains 或兼容 legacy direct child-domain 的 required README 有 Readable Authority / 可读权威正文、evidence 和 必需 Mermaid 图；domain 通过架构域有效性测试；覆盖深度 与实际证据一致；未覆盖范围在 开放缺口 或对应 README 中显式标为 `gap`/`unknown`；architecture 停止审查覆盖递归停止、`single-level`、Reader Map、Readable Authority 和 必需图清单。

---

## 4. 源资料吸收

`源资料吸收` 是长期源资料处理矩阵。它记录每份 README、`docs/`、ADR、PRD、设计文档、runbook、子系统 README、核心参考文档、用户显式提供资料等被分类到哪里、是否已吸收、是否有冲突或裁决。分类、薄文档规则、冲突裁定和 architecture source routing 以 [`source-material.md`](source-material.md) 为语义所有者。

固定字段：

| 源资料 | 路径/来源 | 分类 | 权威位置 | 吸收状态 | 冲突/裁决项 | 最后检查 |
|---|---|---|---|---|---|---|
| `<title>` | path / URL / session marker | absorb / link-only / stale/conflict / obsolete | SSOT/... | pending / absorbed / linked / conflict-recorded / obsolete | ADJ-... / none | ISO 日期或 commit |

Bootstrap 期间 `SSOT/.bootstrap/manifest.md` 也记录吸收进度；bootstrap 清理前，长期仍有价值的源资料状态必须转录到 `STATUS.md`。

### 4.1 核心参考文档审查

`核心参考文档审查` 是启动即读 / Agent rules 文件的专项账本。它不新增 SSOT 顶层区域，只记录这些文件本身的角色、事实正确性和建议动作。源资料吸收矩阵回答“长期事实吸收到哪里”；本表回答“这个启动/参考文件现在是否可信，应该怎么改”。

固定字段：

| 文档 | 路径 | 角色 | 状态 | 权威关系 | 检查范围 | 最后检查 | 证据 | 建议动作 | 冲突/裁决项 |
|---|---|---|---|---|---|---|---|---|---|
| AGENTS.md / CLAUDE.md / Cursor rules | path | startup / agent-rules / reference / none | covered / stale / conflict / missing / not_applicable | thin-adapter / source-material / mixed | commands / directory-map / workflow / architecture / model-config / testing / routing | ISO 日期或 commit/session | code/config/test/SSOT/protocol pointers | update-doc / thin-adapterize / absorb-to-SSOT / record-conflict / no-op | ADJ-... / none |

规则：

- 仓库根或常见 agent rules 位置存在 `AGENTS.md`、`CLAUDE.md`、`.cursor/rules/*`、`.windsurf/rules/*`、`GEMINI.md` 或等价启动参考文件时，必须入表；没有此类文件且项目没有要求时，可写一行 `not_applicable`。
- `权威关系=thin-adapter` 表示文件由 SSOT 生成或托管，带 generated marker，只做 SSOT 读取指令和少量核心不变量摘要；`[ADAPTER]` 检查文件形态，`[CONSUMPTION]` 检查 SSOT 触发链路。
- `权威关系=source-material` 表示文件主要是手写源资料，含长期事实但不是 SSOT 权威位置；它接受 `[CORE-REF]`，不因缺 generated marker 接受 `[ADAPTER]`。
- `权威关系=mixed` 表示同一文件既有 SSOT 读取指令，又有命令、工作流、架构、测试或配置事实；必须接受 `[CONSUMPTION]` 和 `[CORE-REF]` 检查，仅当它带 generated marker、声明由 SSOT 托管时才接受 `[ADAPTER]`。
- `covered` 要求检查范围内的事实已与代码、manifests、Makefile/CI、SSOT 权威位置和当前 skill 协议比对，且建议动作是 `no-op` 或已完成。
- `stale` / `conflict` 必须给出具体 `建议动作` 和证据；不能只把事实吸收到 SSOT 后让启动文件继续误导后续 Agent。
- `missing` 只用于项目或 harness 明确需要该启动文件但文件不存在；普通项目没有某 harness 文件时用 `not_applicable`。
- `thin-adapterize` 只是条件性建议，不是所有启动文件的默认目标；手写或 mixed 文件可保留本地命令/工作流/约束，但这些事实必须持续接受 `[CORE-REF]`。

## 5. 开放裁决项

`开放裁决项` 是新会话入口裁决闸门。运行中发现需要人工裁决的问题时，先写入此队列；新会话开始后，若队列中存在 `pending` 或 revisit 条件已命中的 `deferred` 项，Agent 必须先处理裁决，不能执行代码、审计、规划或普通任务。

固定字段：

| id | status | created_at | source | scope | question | needed_by | resolution | revisit_condition | links |
|---|---|---|---|---|---|---|---|---|---|
| ADJ-YYYYMMDD-NN | pending / deferred / resolved / superseded | ISO 日期或时间 | 触发来源 | 影响范围 | 待裁决问题 | 何时必须裁决 | 裁决结果 | 延期重访条件 | 相关文件/决策/约束 |

### 5.1 裁决状态

| 状态 | 含义 |
|---|---|
| `pending` | 新会话入口阻断，必须先裁决 |
| `deferred` | 不阻断，直到 `revisit_condition` 命中 |
| `resolved` | 已裁决，不阻断，保留历史 |
| `superseded` | 被新的裁决项替代，不阻断，保留指针 |

`deferred` 本身是合法裁决，但必须有 `revisit_condition`。条件可以是日期、里程碑、相关架构域或实现区域再次修改、某个 issue/PR 完成后，或“下次会话重新裁决”。用户未指定时，默认写为“下次会话重新裁决”。

### 5.2 入口阻断提示

裁决闸门命中时，入口提示保持简短：

```text
发现以下待裁决项，必须先处理后才能继续当前任务：
- ADJ-YYYYMMDD-NN（scope）：question；needed_by；links
请逐项选择：接受 / 拒绝 / 替代方案 / 延期。
```

直到阻断项更新为 `resolved`、`superseded` 或未到期 `deferred`，不得继续当前普通任务。

---

## 6. 开放缺口

`开放缺口` 记录当前未解决的信息缺口。缺口可以是阻塞或非阻塞，但必须具体到区域、architecture view 或 architecture domain。

```markdown
## 开放缺口

| 区域 | 状态 | 缺口描述 | 阻塞程度 |
|---|---|---|---|
| architecture/query-engine | gap | planner 与 executor 的状态边界未确认 | 非阻塞 |
| architecture/auth-boundary | unknown | 认证模型未文档化 | 阻塞 |
```

规则：

- 不用 `unknown` 掩盖已有证据；有证据必须使用。
- `gap` 或 `unknown` 不一定阻断日常代码任务，但会阻断对应范围的 `covered`。
- 分段追赶或抽样覆盖时，未覆盖范围必须进入 开放缺口 或对应 README。
- Reader Map 过时、正文不可读、required diagram 缺失或外部图误作权威图时，按对应范围记录 `gap` / `unknown`，并阻断该范围 `covered`。

---

## 7. 停止审查闸门

每次准备将整体或区域声明为 `converged` / `covered` / `passed` / `done` / `no-op` / `无需更新`，准备接受 `single-level` 或停止拆分，准备变更 `documentation_language`，或准备最终推进 `tracked_commit` / `tracked_session` / `tracked_skill_version` 时，先创建审查记录。

固定字段：

| scope | stop_claim | reviewer | reviewed_at | result | evidence | remaining_changes |
|---|---|---|---|---|---|---|
| architecture | covered | reviewer-agent-id | ISO 时间 | no-more-required-changes / needs-fix | 读取范围、diff/transcript/SSOT 文件 | 若 needs-fix，列必须改的项 |
| protocol-upgrade | protocol-upgrade / tracked_skill_version | reviewer-agent-id | ISO 时间 | no-more-required-changes / needs-fix | 当前 protocol version、upgrade notes、受影响 SSOT 文件 | 若 needs-fix，列必须改的项 |
| doc-language | documentation_language / doc-language-change | reviewer-agent-id | ISO 时间 | no-more-required-changes / needs-fix | language evidence、用户裁决、受影响 SSOT 文件 | 若 needs-fix，列必须改的项 |

规则：

- `result` 只能是 `no-more-required-changes` 或 `needs-fix`。
- `needs-fix` 时不得接受对应 停止结论；修复后必须再次审查。
- 一次审查只能覆盖表中声明的 `scope`。
- 推进 `tracked_commit`、`tracked_session` 和 `tracked_skill_version` 必须分别或共同明确覆盖。
- Bootstrap manifest/session 中已有临时停止审查记录时，Phase 4 清理前必须把最终有效审查摘要转录到 `STATUS.md`。
- 没有停止审查时，水位只能保持在已审查且已复核的位置；`coverage_result` 不能写成 `converged`。

### 7.1 self-reviewed 降级（v2.12 新增）

SKILL.md §1.3 把停止结论分为 `[MUST]` 高影响、`[SHOULD]` 中影响和 `[MAY]` 局部范围三类。中影响范围允许 updater 自审，写入时按下表标注：

| 字段 | 自审场景的取值 |
|---|---|
| `reviewer` | `self-reviewed`（updater 自己的标识或单 Agent session 标识） |
| `result` | `no-more-required-changes` 或 `needs-fix`（自审同样必须给出明确返回值） |
| `evidence` | 必须包含：自审依据、逐项检查清单（哪些核心点已确认），明确列出"未检查"的项 |
| `remaining_changes` | `needs-fix` 时列出剩余项 |

self-reviewed 适用范围：区域 / view / domain `covered`、Doctor 分段 `passed`、session/commit `no-op`、`single-level`、停止拆分。

self-reviewed 不允许用于：`coverage_result: converged`、Bootstrap 整体 `passed`、清理 `SSOT/.bootstrap/`、最终推进 `tracked_commit`/`tracked_session`/`tracked_skill_version`、变更 `documentation_language`。

后续 audit/Doctor 发现 self-reviewed 范围有遗漏时，自动重置该范围为非停止状态，不需要额外裁决。

---

## 8. Skill 协议水位

当前 SSOT Skill bundle 协议版本来自已加载/已安装的 `ssot-preflight/SKILL.md` 顶部 YAML 中的 `metadata.protocol_version` 字段。项目 SSOT 的协议水位记录在 `STATUS.md` 的 `tracked_skill_version` 字段，表示该项目 SSOT 已经审查并应用到的协议版本。

版本比较按 semantic version 的 numeric segment 比较；无法解析时保守视为需要审查。

规则：

- 新建 SSOT 时，`tracked_skill_version` 初始化为当前 `ssot-preflight` 的 `metadata.protocol_version`。
- 旧项目首次缺失 `tracked_skill_version` 时，按 `unknown/legacy` 处理，必须执行一次当前版本的 baseline 协议升级审查。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 大于 `tracked_skill_version` 时，必须读取 [`protocol-upgrades.md`](../../ssot-audit/references/protocol-upgrades.md)，对所有未应用版本执行 协议升级审查。
- 协议升级审查只审查新版协议对项目 SSOT 的影响并更新受影响权威位置；不要机械把所有 SSOT 文档改写成最新模板。
- 协议升级审查完成前，整体 SSOT 不能声明 `coverage_result: converged`，也不能推进 `tracked_skill_version`。
- 只有审查更新完成，且独立 reviewer 对 `protocol-upgrade` / `tracked_skill_version` 范围返回 `no-more-required-changes` 后，才能把 `tracked_skill_version` 更新为当前 `ssot-preflight` 的 `metadata.protocol_version`。
- 每次 bump `ssot-preflight/SKILL.md` 的 `metadata.protocol_version` 时，必须同步更新 [`protocol-upgrades.md`](../../ssot-audit/references/protocol-upgrades.md)。缺失对应版本条目时，该 skill 发布不完整。

---

## 9. 更新纪律

更新 `STATUS.md` 前必须重新读取最新版本，不允许盲目覆盖。如果 `tracked_commit`、`tracked_session` 或 `tracked_skill_version` 已被他人推进，需要基于新基线重新审查。

更新任何 SSOT 文件前，必须读取 `documentation_language`。字段缺失时先补齐；语言证据混杂或不足时先问用户。后续源资料语言变化不能自动改写该字段；若确需切换语言，必须新增或更新 开放裁决项，并在 停止审查闸门记录语言变更的独立审查。

推进 tracked 水位到最终目标（HEAD / 最新 transcript / 当前 session / 当前 protocol version）前，必须先在 停止审查闸门记录独立 reviewer 的 `no-more-required-changes`。
