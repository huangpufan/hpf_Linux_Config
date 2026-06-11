# Doctor 验真

Doctor 验真检查已有 SSOT 内容是否仍然可信。它不追赶新 commit/session；追赶新变更分别由 [`commit-audit.md`](../../ssot-audit/references/commit-audit.md) 和 [`conversation-audit.md`](../../ssot-audit/references/conversation-audit.md) 负责。

使用场景：

- 主动追赶的默认附带步骤。
- CI pipeline 或手动执行 `ssot doctor`。
- 准备声明 Doctor `passed` / `no-op` / `无需更新`。
- 需要验证 `covered`、`converged` 或 tracked 水位声明是否有证据支撑。

Doctor 的 `passed`、`no-op` 或 `无需更新` 结论都是 停止结论，必须经过独立 reviewer。

---

## 目录

- [1. 执行方式](#1-执行方式)
- [2. 检查清单](#2-检查清单)
- [3. Architecture 硬阻断](#3-architecture-硬阻断)
- [4. 输出标签](#4-输出标签)
- [5. Pass / No-op 审查](#5-pass--no-op-审查)
- [6. 与其他流程的边界](#6-与其他流程的边界)

## 1. 执行方式

```text
1. 读取 SSOT/STATUS.md：
   - tracked_commit
   - tracked_session
   - tracked_skill_version
   - documentation_language
   - documentation_language_evidence
   - coverage states
   - 开放裁决项 / 开放缺口 / 停止审查闸门

2. 按本文件检查清单扫描已有 SSOT 内容。
   - 先完成 L1 确定性检查。
   - L1 全 pass 后进入 L2 语义检查。

3. 输出 stale 列表和建议修复动作。

4. Agent 可直接修复，也可报告给用户决策。

5. 若准备声明 Doctor passed/no-op/无需更新，必须请求独立 reviewer 审查 Doctor 范围。
   - no-more-required-changes：可在 STATUS.md 停止审查闸门记录 Doctor 通过。
   - needs-fix：按 剩余修改项 修复后重新跑 Doctor 和 reviewer。
```

独立运行场景下，Doctor 只跑验真检查，不执行 commit/session 审查。主动追赶场景下，Doctor 通常在 commit/session 审查后运行，用于验证已有 SSOT 与当前状态的可信度。

---

## 2. 检查清单

检查清单分为两层。L1 确定性检查可由 Agent 快速执行（结果为 pass/fail），不需要独立 reviewer 判断单项结果。L2 语义检查需要 Agent 判断和独立 reviewer。Doctor 执行时先完成 L1，L1 全 pass 后再进入 L2。

### 2.1 L1 确定性检查

L1 检查的判断依据是结构性的：字段是否存在、路径是否有效、值域是否合法。结果是确定性的 pass/fail。

**v2.12 新增 / v2.13 扩展 / v2.15 划界 / v2.17 边界澄清**：可使用 [`assets/scripts/ssot-lint.sh`](../assets/scripts/ssot-lint.sh) `[MAY]` 自动化以下 L1 检查项：#1 (DOC-LANGUAGE 字段存在性)、#2 (source_path 内部链接存在性，限 SSOT 内引用)、#6 中 `confidence: hypothesis` 出现在 `architecture/` 正文（v2.13，FAIL）、#7 中 SSOT-generated 薄适配器 ≤50 行体积和可选 source hash（v2.13，WARN；v2.17 起仅作用于带 generated marker 的文件）、STATUS 必需字段完整性、tracked_commit 与 HEAD 关系（含 converged 矛盾检测）、bug/tech-debt frontmatter、备注列冗余检测。脚本退出码 2 表示 FAIL，可作为 CI 硬阻断或 Doctor 前置 gate；剩余 L1 项的语义部分（#3 命令存在性、#4 gotchas 引用语义、#5 decisions 索引、#6 中 `candidate` 写入位置与值域合法性、#7 适配器摘要边界、#CR 核心参考文档盘点）仍需 Agent 判断。无 marker 的手写或 mixed 启动文件不因缺 marker 报 `[ADAPTER]`；若缺 SSOT 路由，走 `[CONSUMPTION]`，事实正确性走 `[CORE-REF]`。`[CORE-REF]` 的事实正确性不进入脚本，因为命令、工作流、架构约束和测试策略的时效性需要语义核对。

**v2.15 说明**：Reader Map、Readable Authority 和通用 diagram candidate 治理属于 L2 语义检查，不由 `ssot-lint.sh` 机械判断。脚本只检查确定性结构；正文是否能建立心智模型、入口是否承载独立事实、外部图是否被误当权威图，仍由 Doctor reviewer 判断。

| # | 检查项 | 判断依据 | 修复动作 |
|---|---|---|---|
| 0 | `SKILL-PROTOCOL` | `tracked_skill_version` 是否存在且可解析？当前 `ssot-preflight` 的 `metadata.protocol_version` 是否大于 `tracked_skill_version`？ | 进入 协议升级审查 |
| 1 | `DOC-LANGUAGE` | `documentation_language` 和 `documentation_language_evidence` 是否存在？ | 补语言锁；证据混杂/不足/无文档时询问用户 |
| 2 | source_path 存在性 | SSOT 中引用的文件路径是否仍然存在？ | 路径已变则更新指针；文件已删则标记 stale 或改为历史证据 |
| 3 | 命令存在性 | SSOT 中提到的命令是否仍在 package manifest、Makefile 或等价源文件中？ | 命令已变则更新 SSOT |
| 4 | gotchas 引用完整性 | gotchas 条目引用的文件、架构域或决策是否已删除、重命名或失效？ | 引用失效则标记 resolved、obsolete 或更新引用 |
| 5 | decisions 索引一致性 | 是否有 superseded 的决策但索引未更新？ | 补齐索引标记 |
| 6 | `CONFIDENCE` tag 合法性 | confidence 值域是否为 `hypothesis`/`candidate`/`source-backed`？旧 `inferred` 视为兼容。hypothesis 是否出现在 architecture views/domains 权威正文中？ | 修正非法值；将 architecture 中的 hypothesis 迁移到 gotchas 或 STATUS.md 开放缺口 |
| 7 | `ADAPTER` 一致性 | AGENTS.md/CLAUDE.md 等启动参考文件若带 SSOT-generated marker，是否超过 50 行？若含 SSOT 源 hash 行，源文件是否存在且 hash 是否匹配？ | 更新或重新生成 SSOT-generated 薄适配器；无 marker 的手写文件不按 `[ADAPTER]` 报错，按 `[CORE-REF]` / `[CONSUMPTION]` 分类 |
| CR | `CORE-REF` 盘点（v2.15） | 仓库根或常见 rules 位置存在 `AGENTS.md`、`CLAUDE.md`、`.cursor/rules/*`、`.windsurf/rules/*`、`GEMINI.md` 或等价启动参考文件时，`STATUS.md` 是否有 核心参考文档审查 表并逐项入表？ | 缺表或漏项时补表；不存在且项目无对应 harness 要求时记录 `not_applicable` |
| C | `CONSUMPTION` 链路（v2.13） | 启动参考文件是否含 SSOT 读取指令并指向有效 SSOT 路径或 `$ssot-*` 入口？`SSOT/README.md` 导航入口是否存在？（这是 L1 静态链路；真实对话里 SSOT 到底被触发/用上没的 L4 行为层探针见 [`consumption-audit.md`](consumption-audit.md)） | 启动参考文件补 SSOT 路由；补 `SSOT/README.md` 导航；静态链路项可由 ssot-lint 检查 9 自动化；`thin-adapterize` 只是条件性建议；L4 行为层归因与触发侧优化走消费审查 |

### 2.2 L2 语义检查

L2 检查需要 Agent 阅读代码/配置/schema/test 并判断语义一致性。结果需要 Agent 判断和独立 reviewer。

| # | 检查项 | 判断依据 | 修复动作 |
|---|---|---|---|
| 8 | confidence 条目验证 | `confidence: hypothesis` 或 `candidate` 的条目是否现在有代码证据可晋升或否定？多个待检条目时按 `discovered_at` 从旧到新排序优先检查。 | 有证据则晋升；否定则降级、删除或标记 obsolete |
| 9 | `DOC-LANGUAGE` 语义 | SSOT Markdown 正文、标题、表格标签是否偏离锁定语言？是否有未裁决的语言切换？ | 语言切换进入开放裁决项和停止审查闸门 |
| 10 | decisions 实现状态一致性 | 是否有 `implementation_state: diverged` 但 STATUS.md 无对应裁决项？是否有 pending/partial/implemented 与当前代码不符？ | 更新 implementation_state，并新增/更新裁决项 |
| 11 | 裁决队列有效性 | pending/deferred/resolved/superseded 是否符合当前事实？deferred 是否已到 revisit 条件？ | 更新队列状态；到期 deferred 在入口阻断 |
| 12 | architecture 递归结构有效性 | `architecture/README.md` 是否能建立快速心智模型并包含 设计简报？views 是否吸收 operating model / critical journeys / current-target-gap 且包含设计意图叙述？每个 domain README 是否有 设计意图、设计约束、取舍 / 被拒绝的简化、未来 Agent 必须保持的内容、decomposition_basis、core required、conditional required、current/target/gap、覆盖深度、覆盖范围 / 抽样策略、证据、验证方式和 必需 Mermaid 图？domain 是否通过架构域有效性测试？是否存在源码镜像式拆分或表格化文档？ | 补齐 root/views/domains，或在兼容 legacy direct child-domain 中补齐 |
| 13 | 覆盖声明有效性 | 标记 `covered` 的区域是否确实有 evidence 和停止审查支撑？architecture 的 覆盖深度 是否与实际证据和 必需图 一致？未覆盖范围是否显式标为 gap/unknown？范围内是否存在 `confidence: hypothesis` 或 `candidate` 阻断 `covered`？ | 无证据、无停止审查、coverage 不实或存在阻断性 confidence 则降级为 `gap` 或 `unknown` |
| 14 | architecture diagram 协议 | 必需图 是否缺失、stale、无证据、Current/Target 混用，或没有从 运行流 / 子 Domains / contracts / state / lifecycle / failure / trust/config 表格链接？ | 补图、拆分 current/target、补 evidence，或降级为 `gap` |
| 14A | Reader Map / 快速理解地图 | `SSOT/README.md`、`architecture/README.md`、`architecture/views/README.md` 和 domain README 的 Reader Map 是否存在、能快速路由读者、只链接权威位置？是否过时、断链、指向非权威位置，或在入口地图中维护独立长期事实？ | 补入口地图、修正权威链接、把独立事实迁回 owner，或标 `gap` |
| 14B | Readable Authority / 可读权威正文 | Root/view/domain 正文是否只有表格/清单？关键 claim 是否有一句话结论、owner、evidence、why/risk/constraint？证据不足处是否写 `gap` / `unknown` / `not_applicable` 而非空泛总结？ | 补短叙述、claim/evidence/why/risk/constraint，或降级覆盖状态 |
| 14C | 外部生成候选治理 | 外部生成图、截图、依赖图或自动摘要是否只作为普通候选处理？是否验证事实后路由到权威位置？是否误新增平行权威面、镜像全文、照搬外部主题树，或只更新源资料矩阵后结束？ | 按 source-material 路由吸收；删除平行权威面；未验证内容保留 pending/link-only/stale/conflict |
| 15 | architecture evolution ledger | git history、ADR、docs、源资料 或代码是否显示重大迁移、旧 surface 删除、兼容路径、deprecated concept 或禁止复活概念？ | 在 architecture 的 演进 / 迁移台账 记录旧形态、替代形态、兼容状态、禁止复活概念和证据；无此类演进则写 `not_applicable` |
| 16 | `BUG-GRANULARITY` | `critical` / `major` / `recurred` bug 是否按 failure mode 拆分？重复 fix/revert/hotfix 是否被粗暴合并成主题？ | 拆分到触发条件、症状、根因、修复模式、预防测试、关联 gotcha / architecture / decision 都可定位的条目 |
| 17 | 源资料吸收状态 | README/docs/ADR/runbook/PRD/核心参考文档 中的长期知识是否已归入 权威位置？`STATUS.md` 是否有 源资料吸收矩阵？是否存在只标记未处理的 stale/conflict？ | 吸收到 SSOT、裁定当前事实、写入 Current / Target / Gap 或新增裁决项 |
| 18 | 薄文档有效性 | README/docs 是否只作为摘要、链接、公开说明或派生产物？是否承载独立长期事实？ | 改为 薄文档，指向权威位置 |
| 19 | 适配器内容一致性 | 适配器中的核心不变量摘要是否与 SSOT architecture 当前内容一致？适配器中是否包含不在 SSOT 中的独立事实？ | 更新适配器内容或报告独立事实需迁移到 SSOT |
| 20 | `CORE-REF` 事实正确性（v2.15） | 核心参考文档中的命令、目录地图、工作流状态、架构约束、模型/配置规则、测试策略、Agent 操作前置条件是否与代码、manifests、Makefile/CI、SSOT 权威位置和当前 skill 协议一致？ | 输出具体建议：`update-doc`、`thin-adapterize`、`absorb-to-SSOT`、`record-conflict` 或 `no-op`；不能静默吸收漂移 |

---

## 3. Architecture 硬阻断

Doctor 命中以下任一项时，相关 architecture 区域或顶层 architecture 不能标 `covered`。这只阻断 SSOT 覆盖状态，不阻断日常代码开发。

- 缺少 `architecture/README.md`，或该文件既不能建立快速心智模型也不能路由到 权威 views/domains。
- 新 bootstrap 或重组后的 architecture root 缺少 设计简报、系统原则 / 运行模型、主要旅程、核心不变量、视角索引、Domain 索引、Current / Target / Gap 摘要、`decomposition_basis`、coverage 或 overview diagrams。
- Root、view 或 domain 主要由表格组成，缺少自然语言设计意图、约束和取舍叙述。
- Root、views 或 domains 缺少 Reader Map / 快速理解地图，或 Reader Map 承载独立长期事实、指向非权威位置、无法建立阅读路径。
- Root、view 或 domain 正文缺少 Readable Authority：关键 claim 没有 owner、evidence、why/risk/constraint，或复杂关系缺少局部 Mermaid 图。
- Domain README 缺少 设计意图、设计约束、取舍 / 被拒绝的简化、未来 Agent 必须保持的内容、`decomposition_basis`、core required、conditional required、`current/target/gap`、覆盖深度、evidence、Verification 或 必需 Mermaid 图。
- 有 PRD/设计文档/历史架构说明中的系统目标、当前优先级、非目标、成功标准、运行哲学、主路径、critical journeys 或 current-target-gap，但未吸收到 `architecture/views/` 或兼容 root view 区域。
- 条件项不适用时未写 `not_applicable` 和原因。
- 抽样或分段覆盖时缺少 覆盖范围 / 抽样策略。
- domain 没有 `why separate`，或无法证明独立状态/资源/契约/失败/不变量/lifecycle/演进 gap/验证方式。
- 同层 domains 明显镜像源码目录，且没有行为轴解释。
- 同层混用运行时、业务、源码、团队等多种轴，但没有取舍说明。
- 把目标设计、ADR、计划文档写成 当前事实，且没有代码/配置/schema/test 证据。
- Mermaid 图 缺失、stale、无 evidence、Current/Target 混用，或与 运行流 / 子 Domains / contracts / state / lifecycle / failure / trust/config 表格断开。
- 外部生成图、截图、IDE 依赖图或自动 dependency graph 被直接当作权威图，而未重写为 Mermaid fenced block、补 metadata 和 evidence。
- 有重大迁移、旧 surface 删除、兼容路径、deprecated concept 或禁止复活概念的证据，但缺少 演进 / 迁移台账；或无相关证据时未写 `not_applicable`。
- architecture 复刻 API/schema/env 全量字段，而不是记录 权威来源 + 语义。
- `covered` 状态没有 evidence 或 停止审查，或 覆盖深度 与实际证据 / 必需图 不一致。
- README/docs/ADR/PRD/核心参考文档 中的长期事实没有被吸收到 权威位置，`STATUS.md` 缺少 源资料吸收 记录，或薄文档与 SSOT 事实分裂。
- 范围内存在 `confidence: hypothesis` 或 `confidence: candidate` 的内容（参见 [`knowledge-integrity.md`](../../ssot-preflight/references/knowledge-integrity.md) §4 Blocking 规则）。

---

## 4. 输出标签

Doctor 输出一份 stale 列表。使用标签让后续修复和 review 能定位问题类型。

```text
[STALE]  gotchas/auth-mobile.md — source_path src/auth/legacy.ts 已不存在
[CONFIDENCE] gotchas/db-pool-limit.md — confidence: hypothesis 出现在 architecture domain 权威正文
[CONFIDENCE] bugs/race-condition.md — confidence: candidate 超过 60 天未晋升
[MISMATCH] development/README.md — 提到 npm test，实际为 pnpm test:unit
[INDEX] decisions/README.md — 0005 标记为 superseded 但索引仍显示 accepted
[ADJUDICATION] decisions/0007-cache.md — implementation_state: diverged，但 STATUS.md 无对应 ADJ 项
[DIAGRAM] architecture/query/README.md — Runtime Flow `plan query` 未链接 current Mermaid Diagram ID
[ARCH-ROOT] architecture/README.md — root 缺少 主要旅程 / 视角索引 / Domain 索引，不能建立 1 分钟心智模型
[ARCH-VIEWS] architecture/views/critical-journeys.md — PRD 中的端到端流程未吸收到 view
[ARCH-DOMAINS] architecture/domains/sdk/README.md — domain 缺少 why separate 或状态/契约证据
[DESIGN-INTENT] architecture/views/operating-model.md — PRD 当前优先级和非目标未吸收，或 view 只有表格没有设计叙述
[READER-MAP] architecture/README.md — Reader Map 缺失、指向非权威位置，或在入口地图维护独立事实
[READABILITY] architecture/domains/runtime/README.md — 正文只有表格，关键 claim 缺少一句话结论、owner、why/risk/constraint 或 evidence
[EVOLUTION] architecture/api/README.md — 删除 legacy API surface 的 commit 未记录到 演进 / 迁移台账
[BUG-GRANULARITY] bugs/auth.md — recurred 登录失败只按主题记录，缺少 failure-mode 级根因和预防测试
[SOURCE] docs/runtime.md — 长期架构约束未吸收到 architecture/ 对应 权威位置
[THIN-DOCS] README.md — 独立维护 当前事实，需改为摘要 + SSOT 链接
[ADAPTER] AGENTS.md — SSOT-generated 薄适配器超过 50 行，内容应精简为路由 + 核心不变量
[ADAPTER] CLAUDE.md — SSOT-generated 薄适配器 source hash 漂移，可能需要重新生成
[CORE-REF] AGENTS.md — 测试命令与 pyproject/Makefile 不一致，建议 update-doc：改为 `uv run python -m pytest ...`
[CORE-REF] CLAUDE.md — 含独立架构约束且 SSOT 无对应权威位置，建议 absorb-to-SSOT；若项目希望 SSOT 托管启动入口，再建议 thin-adapterize
[SKILL-PROTOCOL] STATUS.md — tracked_skill_version 缺失或落后于当前 ssot-preflight metadata.protocol_version
[DOC-LANGUAGE] STATUS.md — documentation_language 缺失、证据不足、SSOT 文本偏离锁定语言，或语言切换未进入裁决/审查
[CONSUMPTION] AGENTS.md — 启动参考文件未指向 SSOT/ 或 `$ssot-*`，Agent 可能不会读取 SSOT
```

标签语义：

- `[STALE]`：引用、路径、事实或状态过时。
- `[CONFIDENCE]`：confidence tag 非法值、与写入位置不一致、或 hypothesis/candidate 阻断 covered。
- `[MISMATCH]`：SSOT 与代码/配置/schema/test 当前事实不一致。
- `[INDEX]`：索引状态与条目状态不一致。
- `[ADJUDICATION]`：需要裁决但队列缺失或状态错误。
- `[DIAGRAM]`：architecture diagram 协议不满足，包括 required Mermaid 图缺失、状态/evidence 不足、current/target 混用，或外部图被直接当作权威图。
- `[ARCH-ROOT]`：architecture root 入口不能建立快速心智模型，或把所有细节堆在 root。
- `[ARCH-VIEWS]`：系统目标、当前优先级、非目标、成功标准、运行哲学、critical journeys 或 current-target-gap 仍停留在 源资料，未进入 views。
- `[ARCH-DOMAINS]`：状态/资源/契约/失败/验证细节未进入 domain 权威位置，或 domain 缺少有效性证据。
- `[DESIGN-INTENT]`：root/view/domain 缺少设计意图、优先级、非目标、成功标准、约束或取舍叙述，或主要由表格组成。
- `[READER-MAP]`：入口地图缺失、过时、指向非权威位置，或在入口中承载独立长期事实。
- `[READABILITY]`：正文只有表格/清单，缺少一句话结论、owner、why/risk/constraint 或 evidence。
- `[EVOLUTION]`：架构演进/迁移/禁止复活概念缺失。
- `[BUG-GRANULARITY]`：高影响 bug 记录粒度过粗。
- `[SOURCE]`：源资料中的长期事实未吸收。
- `[THIN-DOCS]`：README/docs 承载独立长期事实。
- `[ADAPTER]`：SSOT-generated 薄适配器文件形态问题：内容超出体积纪律、source hash 漂移，或适配器摘要越界。手写 / mixed 启动文件不因缺 generated marker 报此标签。
- `[CORE-REF]`：核心参考文档事实问题：启动/规则文件里的命令、目录地图、工作流、架构约束、模型/配置规则或测试策略未与代码/SSOT/协议对齐，或缺少 `STATUS.md` 核心参考文档审查记录。
- `[SKILL-PROTOCOL]`：协议水位缺失或落后。
- `[DOC-LANGUAGE]`：语言锁缺失、证据不足、文本偏离或语言切换未裁决。
- `[CONSUMPTION]`：SSOT 消费链路断裂——启动参考文件未指向 `SSOT/` 或 `$ssot-*`、SSOT 路径不可达，或缺少 `SSOT/README.md` 导航入口。

---

## 5. Pass / No-op 审查

如果 Doctor 未发现问题，不得直接写 `passed`。必须请求独立 reviewer 复核 Doctor 检查范围。

Reviewer 应读取：

- `STATUS.md` 和 停止审查闸门。
- Doctor 输出。
- 被抽查的 SSOT 区域、尤其是 `covered` 区域。
- 相关代码/配置/schema/test、源资料 或 diff/transcript 证据。
- `tracked_skill_version` 对应的 protocol upgrade notes。

Reviewer 返回：

- `no-more-required-changes`：可在 `STATUS.md` 停止审查闸门记录 Doctor 通过或 no-op。
- `needs-fix`：必须列 剩余修改项；修复后重新跑 Doctor 和 reviewer。

没有独立 review 时，Doctor 结果只能作为检查输出，不能支撑 `passed`、`no-op`、`covered`、`converged` 或 tracked 水位推进。

---

## 6. 与其他流程的边界

- **Commit 审查**：追赶 `tracked_commit..HEAD` 的代码变更；详见 [`commit-audit.md`](../../ssot-audit/references/commit-audit.md)。
- **Session 审查**：追赶 `tracked_session` 之后的旧 transcript；详见 [`conversation-audit.md`](../../ssot-audit/references/conversation-audit.md)。
- **协议升级审查**：追赶 `tracked_skill_version` 到当前 `ssot-preflight` 的 `metadata.protocol_version`；详见 [`protocol-upgrades.md`](../../ssot-audit/references/protocol-upgrades.md)。
- **知识完整性协议**：confidence 状态机的完整规则；详见 [`knowledge-integrity.md`](../../ssot-preflight/references/knowledge-integrity.md)。
- **薄适配器协议**：适配器内容规范和生成规则；详见 [`adapter-strategy.md`](adapter-strategy.md)。
- **消费审查**：评估 SSOT 在真实对话中的触发 / 使用有效性（L4 行为层探针），反向优化触发侧；详见 [`consumption-audit.md`](consumption-audit.md)。Doctor 验内容可信，消费审查验触发有效，二者正交。
- **Doctor**：验证已有 SSOT 内容可信度，不主动解释新 diff 或新 transcript。

主动追赶可以按任意顺序组合这些流程，但每个停止结论和 tracked 水位推进都必须有明确范围的独立停止审查。
