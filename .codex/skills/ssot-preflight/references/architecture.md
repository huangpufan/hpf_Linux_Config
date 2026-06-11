# Architecture 主干参考

本文件是 `architecture/` 主干、递归拆分、必需图、覆盖深度的语义所有者。Bootstrap、主动审计、重大重构、架构域拆分/合并时按需阅读。

## 目录

- [1. 目标](#1-目标)
- [2. Views + Domains 推荐结构](#2-views--domains-推荐结构)
- [3. 固定问题集](#3-固定问题集)
- [4. 架构域有效性测试](#4-架构域有效性测试)
- [5. 拆分决策流程](#5-拆分决策流程)
- [6. decomposition_basis 模板](#6-decomposition_basis-模板)
- [7. 覆盖深度](#7-覆盖深度)
- [8. 轻量模式](#8-轻量模式)
- [9. 反模式表](#9-反模式表)
- [10. 仓库形态示例](#10-仓库形态示例)
- [11. 源资料吸收规则](#11-源资料吸收规则)
- [12. 旧结构性目录迁移](#12-旧结构性目录迁移)
- [13. Doctor 验真检查](#13-doctor-验真检查)

## 1. 目标

`architecture/` 必须让新 Agent 快速理解系统如何运转，而不是把源码目录翻译成文档目录。它的核心产物是：

- 全系统架构地图
- Reader Map / 快速理解地图：入口层告诉读者从哪里开始读，不承载独立长期事实
- Readable Authority / 可读权威正文：正文层用短叙述、claim、evidence、why、风险和约束解释事实为什么成立
- 设计意图、运行哲学、优先级、非目标和成功标准
- 跨域 architecture views
- 可递归的 architecture domains
- 每层的拆分依据和停止理由
- 权威 Mermaid 架构视图和运行流图
- 当前实现、目标设计、差距
- 影响后续改动取舍的设计约束、拒绝方案和必须保留的行为
- 影响 Current / Target / Gap 的架构演进与迁移线
- 覆盖深度、验证方式和证据指针

`architecture/README.md` 是入口，不是完整审计报告。它的目标是让 Agent 在 1 分钟内建立系统目标、主路径、核心不变量和下一步阅读路径。长流程、完整状态表、资源/锁/失败恢复细节应下沉到 `views/` 或 `domains/`。

## 2. Views + Domains 推荐结构

新 bootstrap 和用户明确要求的重大架构重组，优先使用以下结构：

```text
architecture/
  README.md
  views/
    README.md
    operating-model.md
    critical-journeys.md
    current-target-gap.md
  domains/
    README.md
    <domain>/
      README.md
```

职责分配：

| 位置 | 权威位置 |
|---|---|
| `architecture/README.md` | 架构入口：设计简报、架构一眼看懂 / Reader Map、系统原则 / 运行模型 摘要、主要用户/运行旅程、核心不变量、视角索引、Domain 索引、Current / Target / Gap 摘要、coverage 指针 |
| `architecture/views/operating-model.md` | 系统定位、产品/系统目标、运行哲学、当前优先级、非目标、主要 actor、用户/运行主路径、成功标准和非功能约束的设计含义 |
| `architecture/views/critical-journeys.md` | 关键端到端流程、业务闭环、阶段生命周期、验收/恢复信号、跨域运行流 overview diagrams |
| `architecture/views/current-target-gap.md` | 全局 current / target / gap、迁移姿态、部分落地设计意图、阻塞裁决和相关 decisions 指针 |
| `architecture/domains/<domain>/README.md` | 域级设计意图、设计约束、取舍/拒绝方案、状态/资源所有权、跨边界契约、不变量、失败恢复、验证证据、域内 diagrams |

兼容规则：

- 既有 `architecture/<domain>/README.md` direct child-domain 结构仍然有效；不要为了协议升级机械迁移。
- 小型 CLI/库可继续使用 single-level `architecture/README.md`，但必须满足 domain-level required sections 和 停止审查。
- 不新增顶层 `SSOT/design/`。设计文档是 源资料，长期设计事实吸收到 `architecture/views/`、`architecture/domains/`、`decisions/` 等权威位置。
- `docs/`、根 README、ADR、runbook 仍是源资料或 薄文档，不承载独立长期事实。

### 2.1 Legacy 模式下的设计意图最小补偿（v2.12 新增）

走 legacy direct child-domain 路线（没有 `architecture/views/`）时，root `architecture/README.md` `[MUST]` 承担 operating-model view 的最小职责，避免设计意图无归宿：

| Legacy 模式 root 必备节 | 等价于 views/ 中的 | 最小内容要求 |
|---|---|---|
| `设计简报` | `operating-model.md` 的使命/优化/非目标/成功标准 | 1-3 段自然语言；不允许只写表格 |
| `核心不变量` | `operating-model.md` 中的设计力量摘要 + 各 domain 不变量入口 | 表格形式，每行链接 domain README 的「不变量与约束」节 |
| `Current / Target / Gap 摘要` | `current-target-gap.md` 的全局矩阵 | 表格形式，跨 domain 的演进姿态，详细 gap 链接到 `tech-debt/` 或 domain CTG |

`关键旅程 (critical-journeys)` 在 legacy 模式下 `[SHOULD]` 由 root「主要用户 / 运行旅程」表承担；当跨域旅程超过 4 条或包含失败/恢复信号时，`[SHOULD]` 升级建立 `views/critical-journeys.md`。

判断信号：当 domain 数量 ≥ 4，或同一旅程跨 ≥ 3 个 domain 时，legacy 模式已达到读者认知极限，`[SHOULD]` 考虑迁到 `views/ + domains/`。但迁移是用户裁决项，不是自动触发。

理由：legacy 模式过去只继承了 domain 的技术骨架，忽略了 operating-model 视角对系统"为什么这样设计"的承载。明确补偿要求后，新 Agent 在 legacy 仓库也能从 root README 建立完整心智模型，不需要去考古 PRD/ADR。

## 3. 固定问题集

### 3.0 Reader Map 与 Readable Authority

`architecture/` 的目标是建立可扫描、可验证、可维护的系统心智模型。Reader Map、Readable Authority、claim-to-evidence、脚本/工具目录和 diagram candidate 治理都是 SSOT 原生能力：

- **Reader Map / 快速理解地图**：入口层导航，用 views、domains、journeys、runtime flows 和 source-material routing 组织读者路径。它只回答“读哪里、为什么、证据方向是什么”，不能承载独立长期事实。主题必须来自 architecture decomposition、读者问题和仓库证据，并经过 `decomposition_basis`、`why separate` 和 independence signal 校准。
- **Readable Authority / 可读权威正文**：正文层权威解释。正文可以承载长期事实，但关键 claim 必须有 owner、evidence、why/risk/constraint；复杂关系要有局部 Mermaid 图；证据不足时写 `gap` / `unknown` / `not_applicable`，不写空泛总结。
- **Claim-to-evidence**：关键断言不只写结论，还要给出代码、配置、schema、测试、运行证据或源资料指针；这是 SSOT 原生写作标准，不依赖外部资料格式。
- **Script / tool inventory routing**：脚本和工具清单不堆进 architecture root；先按 build/test/dev/release/deployment 路由到工程操作区。只有脚本本身承载模型生成管线、session 分析、发布一致性、状态迁移、运行时 contract 生成等架构行为时，才进入相关 view/domain。
- **Diagram candidate governance**：外部生成图、截图、IDE 依赖图和自动 dependency graph 只能作为候选；权威图必须是可维护 Mermaid fenced block，且分离 current / target / stale。

### 3.1 Root 入口要求

`architecture/README.md` 必须包含：

- `设计简报`
- `架构一眼看懂` / `Reader Map`
- `系统原则 / 运行模型`
- `主要用户 / 运行旅程`
- `核心不变量`
- `视角索引`
- `Domain 索引`
- `Current / Target / Gap 摘要`
- `架构视角 / 图`
- `关键断言与证据`
- `decomposition_basis`
- `证据与覆盖`

Root entry 可以摘要并链接 `views/` / `domains/`，但不能只是纯链接页；必须给出足够的系统心智模型。长表格、完整 flow、状态/资源/失败细节不应堆在 root。

`设计简报` 必须用 1-3 段自然语言说明系统使命、主要受众、优化优先级、当前阶段优先事项、非目标、成功标准和 未来 Agent 必须保持的内容。它不能被纯表格替代。

`架构一眼看懂` / `Reader Map` 负责把系统分成可扫描的知识入口，通常链接到 operating model、critical journeys、current-target-gap、domains 和工程操作区域。每行必须包含主题、读者问题、一句话答案、权威位置、关键证据、主要风险/约束。主题必须由正式 decomposition、domain validity 和证据校准；不能照搬外部主题树。它不承载独立事实；长期事实必须在 linked owner 中维护。

`关键断言与证据` 负责用一张短表列出 root 层最重要的 claim、证据指针、why/risk/constraint 和权威 owner。它不是完整审计表；完整细节下沉到 views/domains/engineering areas。

### 3.2 Views 索引要求

`architecture/views/README.md` 必须包含：

- `视角索引`
- `跨域 Reader Map` / `快速理解地图`
- `视角规则`
- `源资料路由`
- `开放视角缺口`

Views index 只管理跨域视角的入口和吸收路由，不承载具体 domain 的状态/资源/契约细节。

### 3.3 单个 View 要求

每个 architecture view 文件必须包含：

- `范围`
- `为什么这个视角存在`
- `叙述 / 模型`（Readable Authority，不能只有表格）
- `设计意图 / 约束`（名称可按 view 语义调整，但必须表达设计意图和约束）
- `相关 Domains`
- `Current / Target / Gap`
- `证据`

View 主要回答跨域问题，不拥有具体状态资源或契约的最终细节；这些细节链接到 domain 权威位置。

View 不能是纯表格。若源资料中有 PRD、当前阶段目标、产品承诺、非目标、验收标准或设计原则，必须吸收到 `operating-model.md`、`critical-journeys.md` 或 `current-target-gap.md`，而不是只在 `STATUS.md` 标记已读。

### 3.4 Domain 要求

每个 domain README（包括 `architecture/domains/<domain>/README.md` 和兼容的 legacy direct child-domain README）必须包含 core required 和 conditional required。条件项不适用时也必须出现，并写 `not_applicable` 与原因。

核心必需项：

- `边界`
- `设计意图`
- `设计约束`
- `取舍 / 被拒绝的简化`
- `未来 Agent 必须保持的内容`
- `decomposition_basis`
- `设计单元`
- `Domain 一眼看懂` / `Reader Map`
- `架构视角 / 图`
- `运行流`
- `状态、数据与资源`
- `跨边界契约`
- `不变量与约束`
- `失败与恢复`
- `验证`
- `关键断言与证据`
- `Current / Target / Gap`

条件性必需项：

- `配置 / 可变性模型`
- `生命周期 / 并发 / 调度模型`
- `演进 / 迁移台账`

`演进 / 迁移台账` 只在 git history、ADR、docs、源资料 或当前代码显示重大迁移、旧 surface 删除、兼容路径、deprecated concept 或禁止复活概念时记录；否则写 `not_applicable`。它不是顶层 `history/` 或项目流水账，只保留影响 Current / Target / Gap 的旧形态、替代形态、兼容状态、禁止复活概念和证据。

Performance/capacity、扩展点、兼容性策略只有在它们是系统设计事实、用户承诺或风险来源时才进入 architecture。

Domain 的 `设计意图` 必须解释为什么该域是一个设计边界。`设计约束` 必须说明约束的原因和违反后果。`取舍 / 被拒绝的简化` 必须保留会诱使未来 Agent 回退的捷径及其边界。`未来 Agent 必须保持的内容` 用于记录最短的维护者警示，不复制 domain 细节。Domain 正文应采用 Readable Authority：每个重要小节先给一句到一段的结论性叙述，再用表格索引 evidence、owner、why/risk/constraint；不能只堆表格。

### 3.5 架构视角 / 图 协议

Architecture diagrams 是 architecture README 内的一等事实，不是独立导出物：

- Mermaid fenced blocks 是 canonical diagram。PNG/SVG/PDF 导出只作为派生产物，不能成为维护源。
- 外部生成图、截图、IDE 依赖图和自动 dependency graph 只能作为 diagram candidate 或侦察线索；进入 SSOT 前必须重写为可维护的 Mermaid fenced block，并按 `current` / `target` / `stale` 区分状态与证据。
- Diagram 必须写在对应 `architecture/README.md`、`architecture/views/*.md`、`architecture/domains/<domain>/README.md` 或兼容的 legacy direct child-domain README 中，不另设平行 权威区域。
- 每个 diagram 必须有 metadata：`Diagram ID`、`Status`、`Covers`、`证据`。
- `Status` 使用 `current` / `target` / `stale`。`stale` diagram 不支撑 `covered`。
- Current 与 Target diagram 必须分开；不能在一张图里混合已实现事实和目标设计。
- Current diagram 需要代码、配置、schema、测试或实际运行证据；Target diagram 需要 decision、ADR、issue 或 conversation 等设计意图证据。

Root、view 和 domain 的 diagram 要求：

| Diagram 类型 | 何时 required | 说明 |
|---|---|---|
| Boundary / context view | Root entry 和每个 domain required | 显示系统/架构域边界、外部 actor/system、重要信任或配置边缘 |
| Decomposition / domain view | 存在 domains 或 legacy child domains 时 required | 显示 domains、ownership/dependency 边、递归边界；也称 decomposition/domain diagram |
| Runtime flow diagram | 每个 `运行流` row 都 required | 表格行必须链接 current `Diagram ID` |
| 状态/resource diagram | 存在重要共享/持久状态、缓存、索引、资源 lifecycle 时 required | 显示 owner、reader/derived user、持久化或生命周期；也称 state/resource diagram，并从匹配表格行链接 Diagram ID |
| 生命周期/concurrency diagram | 存在进程、线程、worker、async job、锁、队列、调度、初始化/关闭顺序时 required | 显示顺序、并发边界、锁或调度关系；也称 lifecycle/concurrency diagram，并从匹配表格行链接 Diagram ID |
| 失败/recovery diagram | 存在独立失败检测、重试、降级、回滚、终止或恢复路径时 required | 显示 failure branch 和恢复语义；也称 failure/recovery diagram，并从匹配表格行链接 Diagram ID |
| Trust/config diagram | 存在信任边界、权限、secret、feature flag、环境/平台差异时 required | 显示安全/配置影响路径；也称 trust/config diagram，并从匹配表格行链接 Diagram ID |

复杂 flow 必须分层表达：先写 overview diagram，再按阶段、状态转换、锁、回滚、持久化、跨边界契约或失败语义补 subflow diagrams。大型内核式函数即使不跨源码模块，只要承载独立阶段、状态转换、锁、回滚、持久化、契约或失败语义，也属于 architecture flow，必须建模。

Flow 纳入 `运行流` 的标准：跨 architecture 边界、改变共享或持久状态、拥有资源生命周期、暴露用户/运维/API 行为、涉及锁/事务/重试/回滚、影响安全/信任边界，或算法密集且高风险。Routine helper call 不自动成为 flow。

## 4. 架构域有效性测试

每个 architecture domain 必须说明 `why separate`，并至少证明一个独立性来源：

| 独立性来源 | 有效信号 |
|---|---|
| 独立状态或资源所有者 | 该域拥有写入权、生命周期、缓存、持久化、句柄、连接池或资源回收策略 |
| 独立失败边界或恢复模型 | 该域有独立降级、重试、回滚、终止、隔离或告警策略 |
| 独立契约族 | 该域维护 API、CLI、SDK、协议、事件、文件格式或 schema 的兼容性语义 |
| 独立不变量、约束或信任边界 | 该域有专属权限、隔离、数据一致性、安全或资源约束 |
| 独立 lifecycle / concurrency / scheduling 模型 | 该域有独立进程、线程、worker、队列、锁、初始化/关闭顺序或调度策略 |
| 独立 current / target / gap | 该域的目标演进、迁移状态或技术债与 sibling 明显不同 |
| 独立验证方式 | 该域需要专属测试、诊断命令、trace、metric、fixture 或人工验证路径 |

仅因源码目录、包名、类名、团队名存在而创建的 domain 无效。目录、团队或包可以作为证据线索，但不能单独成为拆分理由。

## 5. 拆分决策流程

每次创建或重组 architecture domain 前，按顺序执行：

1. 描述当前层级要解释的系统边界。
2. 列出 2-4 个候选拆分轴。
3. 对每个候选轴评估：能否解释运行流、状态所有权、失败模式、契约边界、变更风险。
4. 选择一个主轴，必要时允许一个辅轴。
5. 对每个候选 domain 执行架构域有效性测试。
6. 在 root `architecture/README.md`、`domains/README.md` 或对应 domain README 写入 `decomposition_basis`：chosen axis、rejected axes、recursion rule、覆盖深度；抽样或分段覆盖时再写 覆盖范围 / 抽样策略。
7. 写入或更新 必需 Mermaid 图，确保 `运行流` 每行链接 current flow `Diagram ID`。
8. 对继续递归或停止递归的判断请求独立 reviewer challenge。
   - `no-more-required-changes`：记录 reviewer、结果和挑战摘要后接受当前递归深度。
   - `needs-fix`：按 剩余修改项 调整拆分/合并/README 内容后复审。
9. 只有当 domain 自身仍有多套不变量、状态所有者、失败模型、契约族、lifecycle 模型或演进 gap 时，才继续递归；停止拆分必须有停止审查通过。

### 5.1 候选轴评估表

| 候选轴 | 优先选择信号 | 谨慎使用信号 |
|---|---|---|
| 运行时边界 | 多进程、多服务、worker、plugin、内核子系统、独立 failure domain | 只是部署目录不同，但共享同一状态和失败模型 |
| 业务/能力边界 | bounded context 清晰，用户能力和数据所有权一致 | 业务名很多但底层运行流高度一致 |
| 技术子系统 | compiler/query/storage/rendering/scheduler 等技术边界稳定 | 子系统只是代码目录名，职责不清 |
| 数据/状态生命周期 | 写入、缓存、索引、复制、恢复等状态语义主导复杂度 | 数据只是普通 CRUD，状态模型不复杂 |
| 关键运行流 | 请求链路、事务链路、任务执行链路决定大部分风险；符合 flow inclusion rule | 流程只是若干 routine helper calls，没有独立架构语义 |
| 外部契约边界 | 协议、SDK、CLI、文件格式是兼容性核心 | 契约可由 schema 自动读出，缺少额外设计语义 |
| 变更边界 | 经常一起变、一起测、一起发布、同团队 owning | 团队/目录边界和系统行为边界不一致 |

### 5.2 递归拆分判定表

| 信号 | 判定 | 说明 |
|---|---|---|
| 单个 README 需要混合多套状态所有者 | MUST 继续拆分 | 状态写入权和资源生命周期是强架构边界 |
| 存在多套失败模型、恢复路径或 trust boundary | MUST 继续拆分 | 否则失败恢复会被写成含混清单 |
| 存在多套跨边界契约族 | MUST 继续拆分 | 各契约族需要不同 权威来源 和兼容性语义 |
| 存在独立 lifecycle/concurrency/scheduling 模型 | MUST 继续拆分 | 进程、worker、队列、锁、调度器通常需要独立不变量 |
| `current/target/gap` 分裂严重 | MUST 继续拆分 | 演进路线不同会让单页状态不可维护 |
| 同层 domain 超过 9 个 | SHOULD 增加中间层或重选主轴 | 过平的层级通常表示主轴不稳 |
| 同层 domain 少于 3 个 | SHOULD 重新检查是否需要拆分 | 两个域也可成立，但必须有清楚独立性 |
| Domain 只能因目录名成立 | MUST NOT 创建 | 未通过架构域有效性测试 |

### 5.3 停止判定表

| 信号 | 判定 | 说明 |
|---|---|---|
| 继续拆只能得到文件/API/schema/env 清单 | MUST 停止 | architecture 记录语义和边界，不复制 权威来源 |
| 更细信息可从代码、schema、测试或生成工具直接读取 | MUST 停止 | 用指针和语义层即可 |
| Domain 内状态、失败模型、契约和验证方式一致 | SHOULD 停止 | 一个 README 能表达完整固定问题集 |
| Domain README 能完整回答 core + conditional required | SHOULD 停止 | 不为层级感而制造子目录 |
| 小型 CLI/库无多个 public API、adapter、持久状态、插件、兼容承诺或独立失败边界 | SHOULD 使用轻量模式 | `decomposition_basis` 写 `single-level` 和停止理由 |
| 内部调用只是 routine helper calls | SHOULD 停止 | 只有具备独立阶段、状态转换、锁、回滚、持久化、契约或失败语义时才进入 运行流 并画图 |

停止判定表只能产生候选结论。任何 `MUST 停止`、`SHOULD 停止`、`single-level` 或“停止拆分”写入 architecture README 前，都必须由独立 reviewer 检查当前层级及其候选拆分轴，并返回 `no-more-required-changes`。

## 6. decomposition_basis 模板

```markdown
## decomposition_basis

- **选择的拆分轴**: `single-level` / <运行时边界 / 技术子系统 / 数据生命周期 / ...>
- **Why this axis**: <为什么它最能解释系统行为和演进风险>
- **被拒绝的拆分轴**:
  - <轴 A>: <为什么不用>
  - <轴 B>: <为什么不用>
- **Recursion rule**: <何时继续拆，何时停止>
- **覆盖深度**: `deep` / `sampled` / `inferred` / `unknown`
- **Coverage scope**: <已覆盖的代码/配置/schema/test 范围>
- **Evidence summary**: <关键证据指针>
- **图清单**: <required current/target diagram IDs and evidence status>
- **如果是 single-level**: <为什么没有 domains，什么信号会触发后续递归>
- **停止审查**: <reviewer + result (`no-more-required-changes` / `needs-fix`) + reviewed scope>
- **Reviewer 挑战**: <最强的继续拆分/替代拆分质疑，以及 剩余修改项（如有）>
```

## 7. 覆盖深度

| 覆盖深度 | 含义 | 可标 covered 的条件 |
|---|---|---|
| `deep` | 关键代码、配置、schema、测试和运行入口已直接审查 | 证据指针完整，required sections 和 必需图 已回答，且独立停止审查 返回 `no-more-required-changes` |
| `sampled` | 按风险抽样审查，未穷尽全部范围 | 抽样策略、样本范围、未覆盖范围均记录；未覆盖范围标 `gap`/`unknown`；抽样范围内 必需图 已回答，且独立停止审查 返回 `no-more-required-changes` |
| `inferred` | 主要来自目录、命名、源资料（README、docs、ADR 等）或局部代码推断 | 不能单独支撑 `covered`；需补充 直接证据，或将剩余范围标 `gap`/`unknown` |
| `unknown` | 证据不足，无法判断 | 不能标 `covered`；必须进入 gap/unknown |

L/XL 仓库可分段收敛，但必须在 manifest 或 `STATUS.md` 记录分段边界、已覆盖 domains、剩余 gap。抽样优先级为：高变更、高依赖、高状态复杂度、高失败影响、用户近期工作相关区域。

## 8. 轻量模式

小型 CLI/库允许只有 `architecture/README.md`。使用轻量模式时：

- `decomposition_basis` 的 chosen axis 写 `single-level`。
- `If single-level` 必须说明停止理由。
- `single-level` 必须有独立 reviewer 的 `no-more-required-changes`；否则只能标为待确认的 gap/unknown，不能支撑 `covered`。
- `配置 / 可变性模型`、`生命周期 / 并发 / 调度模型` 和 `演进 / 迁移台账` 可写 `not_applicable`，但不能留空或写 TODO。
- 仍必须提供 current boundary/context diagram；每个 Runtime Flow 仍必须链接 current Mermaid flow diagram。
- 出现多个 public API surface、runtime adapter、持久状态、插件机制、兼容性承诺或独立失败边界时，应退出轻量模式并递归拆分。

## 9. 反模式表

| 反模式 | 为什么危险 | Doctor 结果 |
|---|---|---|
| 源码目录一比一镜像为 architecture domains | 目录结构不是架构边界，无法解释状态/失败/契约 | 阻断相关区域 `covered` |
| 一文件一文档、一类一文档 | 粒度过细，读者无法找到 权威层级 | 阻断相关区域 `covered` |
| architecture root、view 或 domain 主要由表格组成，缺少设计意图/约束/取舍叙述 | Agent 只能得到目录和证据，无法理解为什么这样设计或未来应保留什么 | 阻断相关区域 `covered` |
| 同层混用运行时、业务、源码、团队轴但无取舍说明 | 拆分逻辑不稳定，后续 Agent 无法递归 | 阻断相关区域 `covered` |
| domain 没有 `why separate` 或 independence signal | 无法证明架构域有效 | 阻断相关区域 `covered` |
| 把 target、ADR 或计划写成 current | 混淆已实现事实和设计意图 | 阻断相关区域 `covered`，必要时进入裁决队列 |
| Current/Target diagram 混在一张图里 | 读者无法判断哪些是已实现事实 | 阻断相关区域 `covered` |
| `运行流` 行没有 current Mermaid flow diagram | 流程文字和图无法互相验真 | 阻断相关区域 `covered` |
| diagram 缺少 metadata、证据或与表格断开 | 图不可审计，容易过时 | 阻断相关区域 `covered` |
| 复制 API/schema/env 全字段 | 与 权威来源 重复维护，容易过时 | 阻断相关区域 `covered` |
| 把重大迁移/旧 surface 删除/deprecated concept 写成 loose notes 或顶层 history | 架构 current/target/gap 与禁止复活概念脱节 | 阻断相关区域 `covered`，需写入 演进 / 迁移台账 |
| README/docs/ADR 与 architecture 平行维护长期事实 |权威位置分裂，后续 Agent 无法判断哪个为准 | 阻断相关区域 `covered`，需吸收到权威位置或改为薄文档|
| 覆盖深度 与证据不一致 | `covered` 声明不可信 | 阻断相关区域 `covered` |

## 10. 仓库形态示例

下表为不同仓库类型提供拆分轴和域划分的参考起点。Agent 应根据侦察结果选择最接近的形态，再结合代码证据调整——同一类型的不同仓库可能因规模、演进阶段或设计取舍而采用完全不同的主轴。

| 仓库类型 | 常见主轴 | 顶层域示例 |
|---|---|---|
| 小型 CLI / 脚本工具 | single-level 或外部契约边界 | command surface, config, execution path |
| 编译器 / 语言工具链 | 技术子系统（pipeline 阶段） | lexer/parser, semantic analysis, IR/optimizer, codegen, runtime/stdlib, diagnostics |
| 数据库内核 | 技术子系统 + 数据/状态生命周期 | query（parser → planner → executor）, storage engine, transaction/MVCC, WAL/recovery, replication, catalog/metadata |
| 消息中间件 / 事件系统 | 数据流拓扑 + 持久化生命周期 | broker/routing, topic/partition management, producer protocol, consumer protocol, storage/retention, cluster coordination |
| 搜索 / 索引引擎 | 数据生命周期（写入 → 索引 → 查询） | ingestion/indexing, query engine, ranking/scoring, schema/mapping, cluster/shard management, storage |
| 前端 SPA | 用户运行时 + 状态/数据流 | app shell/routing, state management, data fetching/cache, UI component system, rendering/layout, persistence/offline |
| 移动端应用 | 平台适配层 + 业务能力 | platform abstraction（iOS/Android/跨平台）, navigation, business modules, networking/sync, local storage, push/lifecycle |
| 桌面应用（Electron / 跨平台） | host 适配 + IPC 边界 | main process/host, renderer/UI, IPC protocol, plugin/extension system, file system/storage, update/packaging |
| 后端单体服务 | 运行流 + 数据所有权 | API edge（protocol/auth/validation）, application core（business rules）, persistence（schema/migration/query）, async jobs/workers, external integrations |
| 微服务 / 多服务仓库 | 业务能力边界 + 运行时隔离 | 按 bounded context 拆分的各服务域, shared contracts/libraries, API gateway/BFF, infrastructure scaffolding, observability |
| 数据管道 / ETL / 流处理 | 数据血缘 + 处理阶段 | ingestion/source connectors, transformation/enrichment, orchestration/scheduling, storage/sink, data quality/lineage, schema registry |
| ML 平台 / 模型服务 | 训练-服务分离 + 实验管理 | data preparation/feature store, training/experiment, model registry/versioning, serving/inference, monitoring/drift detection, pipeline orchestration |
| SDK / 客户端库 | 契约边界 + runtime adapter | public API surface, core runtime/engine, platform adapters, protocol/serialization, compatibility/versioning, packaging/distribution |
| Agent / AI 编排系统 | control loop + execution runtime | planning/reasoning, tool/action execution, memory/context, model integration, control plane/orchestration, safety/guardrails |
| 游戏引擎 / 实时系统 | 主循环阶段 + 子系统 | core loop/scheduler, rendering/graphics, physics/simulation, input/interaction, audio, asset management, networking/multiplayer |
| Infra/IaC / 平台工程 | 部署边界 + 资源生命周期 | environments/topology, compute provisioning, networking/service mesh, secrets/identity, observability/alerting, release/rollback pipeline |
| Monorepo 平台（多产品） | 产品/包边界 + 共享基础设施 | 各产品域（按业务边界）, shared packages/core, build system/toolchain, CI/CD pipeline, developer experience/tooling |

示例不是模板。真实拆分必须由侦察结果、代码证据和 `decomposition_basis` 支撑。

## 11. 源资料吸收规则

设计文档、PRD、历史架构说明、根 README、`docs/`、ADR、runbook 和用户显式提供资料都是 源资料。它们可以作为探索入口和证据来源，但长期架构事实必须进入 architecture views/domains、decisions 或相关卫星区域。

Reader Map、claim-to-evidence、脚本/工具分类和 diagram candidate 治理属于 SSOT 原生协议和模板能力；具体事实仍必须按源资料规则验证并路由。不能新增平行自动生成知识面，不能把外部自动主题树当成 authority。

源资料分类、薄文档规则、冲突裁定和 architecture source routing 表以 [`source-material.md`](source-material.md) 为语义所有者。本文件只保留 architecture 侧约束：不新增顶层 `SSOT/design/` 来承接设计文档；否则权威位置会分裂。

## 12. Doctor 验真检查

Doctor 的完整检查清单、architecture 硬阻断和输出标签由 [`doctor.md`](../../ssot-doctor/references/doctor.md) 维护。本文件只定义 architecture 应满足的结构、拆分、Reader Map、Readable Authority、diagram、coverage 和迁移规则；Doctor 按这些规则验真。

命中 architecture 硬阻断、`[READER-MAP]`、`[READABILITY]` 或 `[DIAGRAM]` stale 项时，相关区域不能标 `covered`。这只阻断 SSOT 覆盖状态，不阻断日常代码开发。
