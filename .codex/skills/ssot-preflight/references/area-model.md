# SSOT 区域模型

本文件是 `SSOT/` 顶层区域职责、卫星区域拆分、递归目录规则、任务入口映射 和不适用区域处理的语义所有者。判断“长期知识该写在哪里”或创建/审查 SSOT 骨架时按需阅读。

## 目录

- [1. 结构模型](#1-结构模型)
- [2. 区域职责](#2-区域职责)
- [3. 递归目录规则](#3-递归目录规则)
- [4. 任务入口映射](#4-任务入口映射)
- [5. 不适用区域](#5-不适用区域)

## 1. 结构模型

SSOT 根目录固定为仓库根下的 `SSOT/`，不使用 `docs/` 作为长期记忆面。

```text
SSOT/
  README.md          # 纯索引入口
  STATUS.md          # 维护状态
  architecture/      # 系统具体设计主干
    README.md        # 全系统架构入口
    views/           # 跨域架构视角
      README.md
      operating-model.md
      critical-journeys.md
      current-target-gap.md
    domains/         # 状态/契约/失败/验证的架构域
      README.md
  identity/          # 仓库定位
  glossary/          # 专有术语
  development/       # 本地开发与运行
  testing/           # 测试策略
  deployment/        # 部署与分发
  release/           # 发布流程
  decisions/         # ADR / 重大决策
  gotchas/           # 陷阱
  bugs/              # 修复认知
  tech-debt/         # 技术债务
```

核心模型：

- **主干**：`architecture/`。回答系统作为整体怎么运转、为什么这样拆、当前与目标差距在哪里。内部可分为 `views/` 和 `domains/` 两类 权威位置。
- **上下文区域**：`identity/`、`glossary/`。帮助 Agent 先理解仓库是什么、关键术语是什么意思。
- **工程操作区域**：`development/`、`testing/`、`deployment/`、`release/`。回答怎么跑、怎么测、怎么交付。
- **涌现/历史区域**：`decisions/`、`gotchas/`、`bugs/`、`tech-debt/`。记录 why、陷阱、修复认知和债务。

`architecture/` 的 Views + Domains 结构和递归协议由 [`architecture.md`](architecture.md) 维护。不要新增顶层 `SSOT/design/`；设计文档是 源资料，长期事实按内容进入 architecture views/domains、decisions、bugs、gotchas、testing 等权威位置。

---

## 2. 区域职责

### 2.1 architecture/

**职责**：系统具体设计主干。记录当前实现、目标设计和差距，解释系统边界、设计单元、运行流、架构视图/图、状态/数据/资源所有权、配置变化、生命周期/并发模型、跨边界契约、不变量、失败恢复和验真方式。

**内部 权威位置**：

- `architecture/README.md`：快速心智模型入口，承载 设计简报、Reader Map / 快速理解地图、系统原则 / 运行模型 摘要、主要旅程、核心不变量、视角索引、Domain 索引 和 Current / Target / Gap 摘要。
- `architecture/views/`：设计意图层和跨域视角，承载 operating model、critical journeys、current-target-gap、当前优先级、非目标、成功标准等设计文档吸收结果。
- `architecture/domains/`：具体架构域，承载域级设计意图、设计约束、取舍/拒绝方案、状态/资源所有权、契约、不变量、失败恢复、验证证据和域内 diagrams。
- 兼容 legacy direct child domains：既有 `architecture/<domain>/README.md` 仍可作为 domain 权威位置，不强制迁移。

**适用规则**：总是适用。新 bootstrap 和重大架构重组优先使用 `views/ + domains/`；小型 CLI/库可以只有单层 `architecture/README.md`；大型内核/monorepo 必须递归拆分为架构域。

**拆分信号**：见 [`architecture.md`](architecture.md)。本文件只声明 `architecture/` 在区域模型中的主干角色。

### 2.2 identity/

**职责**：仓库是什么。一句话定位、技术栈、主要能力、仓库类型。

**适用规则**：总是适用。

**内容要求**：必须让一个从未见过这个仓库的 Agent 在 30 秒内理解仓库本质。摘要事实并指向 manifest、README 或关键入口；不要复制项目说明全文。

**拆分信号**：通常不需要拆分，单文件即可。

### 2.3 glossary/

**职责**：仓库专有词汇表。记录业务领域术语、技术抽象命名、内部约定缩写，以及这些词在本仓库语境中的精确含义。

**适用规则**：总是适用。即使小项目也有自己的命名约定和领域术语。

**内容要求**：只记录本仓库特有的，或在本仓库中有特殊含义的术语。标准行业术语和框架概念若未被重新定义则不收录。每个术语包含名称、一句话定义、可选首次引入的架构域或使用上下文。可按领域分组。

**拆分信号**：术语超过 30 条或横跨多个不同业务领域时，按领域建子文件。

### 2.4 development/

**职责**：怎么把项目跑起来，以及怎么在这个项目里正确地写代码。本地环境搭建、构建命令、开发工作流、常用命令、编码约定和模式语言。

**适用规则**：总是适用。

**内容要求**：摘要常用命令并指向 `package.json`、`Makefile`、`Dockerfile` 等源文件。记录构建链中的非显而易见步骤和前置条件。若存在脚本/工具目录、package manifest、CI、Makefile 或配置中的工具入口，应维护 **脚本 / 工具目录**。推荐字段：`Filename` / `Purpose` / `Category` / `When to use` / `Evidence` / `Risk or prerequisite` / `Architecture link if any`。分类按项目语义选择，例如 build、dev-server、codegen、lint/format、import rewrite、session analysis、diagnostics；不要把这些分类当成新 schema，不复制脚本源码，只说明用途、约束和证据。

当项目存在超出 linter/formatter 覆盖范围的编码约定时，还应记录：

- **模式语言**：项目采用的关键编码范式和约定模式（如错误处理范式、依赖注入约定、日志调用规范），并指向代表性实现文件。只记录"新 Agent 写代码时会违反的"约定，不记录可从 linter 配置推导的规则。
- **端到端骨架流程**：添加典型功能类型（如新增 API、新增 Worker、新增 CLI 命令）时需要触碰的文件和步骤清单。用指针指向模板或已有示例，不写完整代码。
- **Agent 操作前置条件**：运行测试、构建或部署前必须满足的非显而易见前提（如先启动 docker compose、先 build 依赖包、不能跳过 pre-commit hook），以及违反时的静默失败表现。

**拆分信号**：monorepo 中各 workspace 有独立开发流程时，拆分为子文件。模式语言和骨架流程内容较多时，可拆为 `conventions.md` 子文件。

### 2.5 testing/

**职责**：怎么测试。测试策略、测试类型、运行命令、fixture、覆盖期望。

**适用规则**：有测试文件、测试脚本或测试配置时适用。无测试时声明现状并记录原因。

**内容要求**：摘要测试命令并指向测试配置文件。记录测试策略的 why，例如为什么这样划分测试层次。若测试命令来自脚本清单，应在测试策略中列 `Command / Purpose / Test level / Required setup / Evidence / Known risk`，并把构建、代码生成或服务启动前置条件链接回 `development/` 或 `deployment/`。无证据时写 `unknown` 或 `gap`，不要从脚本名猜测测试层级。

当 `bugs/` 中存在 `critical` / `major` / `recurred` 修复记录时，可选维护 **防御性测试来源** 小节：列出由 bug 回归驱动的关键测试（测试文件/用例 → `bugs/` 条目指针）。这让 Agent 在修改被保护代码时，能立即理解该测试的存在理由，避免误删或绕过。不要求穷尽，只记录"删掉这个测试会让历史 bug 复发"的关键条目。

**拆分信号**：unit/integration/e2e/performance 等测试类型各自有独立配置和策略时拆分。

### 2.6 deployment/

**职责**：怎么部署或分发。部署方式、环境、基础设施形态、CI/CD 流水线。

**适用规则**：有部署行为时适用。纯库/纯工具声明不适用或描述分发方式，例如 package publish。

**内容要求**：摘要并指向 `Dockerfile`、`k8s/`、`terraform/`、CI 配置等源文件。记录部署流程中的非显而易见步骤、环境差异、回滚策略。

**拆分信号**：多环境、多部署目标或多独立部署单元时拆分。

### 2.7 release/

**职责**：发布流程和版本策略。怎么发布、版本号规则、changelog 维护、release 流水线。

**适用规则**：有版本号、tags、changelog、release script、package publish 或 deploy release 时适用。

**内容要求**：摘要并指向 release 脚本、CI 配置或版本文件。记录版本策略的 why。若存在 version sync、changelog generation、publish、artifact signing 或 import rewriting 这类 release-adjacent 工具，应维护工具目录。推荐字段：`Filename` / `Purpose` / `Category` / `Release invariant` / `Evidence` / `Failure mode`。把会影响架构 current/target/gap 的一致性脚本同步链接到对应 architecture domain 或 decision。

**拆分信号**：多个可独立发布的产物时拆分。

### 2.8 decisions/

**职责**：重大决策与原因。为什么这样做而不是那样做、决策的上下文和后果。

**适用规则**：总是适用。初始可能为空，随仓库演进增长。

**内容要求**：`README.md` 作为决策索引，至少包含 `status` 和 `implementation_state`。每个重大决策一个独立文件，包含背景、决策、后果、影响范围，以及生命周期字段：

- `status`: `accepted` / `deprecated` / `superseded`
- `implementation_state`: `pending` / `partial` / `implemented` / `diverged` / `superseded`
- `superseded_by`：可选，指向推翻本决策的新决策编号
- `supersedes`：可选，指向被本决策推翻的旧决策编号

`implementation_state` 表示设计意图与当前实现的关系：

- `pending`：决策已接受，但尚未开始落地。
- `partial`：只落地了一部分，剩余范围明确。
- `implemented`：当前代码/配置/schema/test 与决策意图一致。
- `diverged`：当前实现与决策意图冲突；必须同步写入 `STATUS.md` 的 开放裁决项。
- `superseded`：决策已被新决策替代，不再作为当前设计意图。

只记录难以逆转或跨架构域影响的决策，不记录日常实现细节。被推翻的旧决策保留原位并标记，不物理归档，以保持历史上下文和链接完整。

**拆分信号**：天然多条目，每个决策一个文件，命名格式 `NNNN-<slug>.md`。

### 2.9 gotchas/

**职责**：已知陷阱、失败模式、不能动这里因为 X。记录代码无法表达的隐性知识。

**适用规则**：总是适用。初始可能为空，随踩坑经验增长。

**内容要求**：`README.md` 作为陷阱索引，至少包含 `status`。每个陷阱说明是什么、为什么危险、影响范围。规避方式 `[SHOULD]` 成对给出 “不要做什么 + 改做什么”，让条目可执行而非只记录失败故事——只描述失败现象却不给出替代做法的 gotcha 价值很低。可选增加：

- **触发条件**（推荐）：描述"当 Agent 做什么操作时应先检查此 gotcha"。格式为任务类型或文件/模块路径匹配。示例：`触发条件：修改 src/auth/ 下任何文件时`、`触发条件：添加新的数据库 migration 时`。触发条件让读取协议能精准路由——Agent 在执行匹配操作前主动下钻该 gotcha，而非依赖通用的"改代码就读 gotchas"规则。

状态：

- `active`：陷阱仍然存在。
- `resolved`：陷阱已因架构变更或修复不再成立，附失效原因和关联决策/变更。

已 resolved 的条目保留在文档中作为历史参考，但索引必须明确标记，避免 Agent 误判风险。

**拆分信号**：陷阱超过 10 条时，按架构域或主题分组。

### 2.10 bugs/

**职责**：Bug 修复记录。遭遇了什么问题、根因是什么、如何修复、学到了什么。

**适用规则**：总是适用。初始可能为空，随修复历史增长。

**内容要求**：`README.md` 作为修复记录索引，至少包含 `status` 和 `severity`。

- `critical` / `major`：独立文件，包含症状、根因分析、修复方案、影响范围、收获/模式、预防措施、关联区域、外部引用。
- `minor`：索引表中一行摘要即可，包含症状、根因和修复 commit/PR 引用。

Regression Granularity Rule：

- `critical`、`major`、`recurred` bug 不能只记录为宽泛主题，必须拆到 failure-mode 级条目。
- 单条记录必须能回答触发条件、症状、根因、修复模式、预防测试、关联 gotcha / architecture / decision。
- 同症状多根因要拆成多条；同根因多次复发可在同条内追加 recurrence timeline。
- `minor` 或 trivial bug 不强制完整复盘，除非复发、升级为 major，或暴露架构/测试缺口。

状态：

- `fixed`：已修复。
- `recurred`：曾认为已修复但复发，附复发原因和新修复记录链接。

修复揭示 gotcha、tech debt、decision 或 architecture 缺陷时，同步更新对应区域。SSOT 不替代 Issue Tracker；Issue Tracker 管理生命周期，`bugs/` 只记录修复完成后的长期认知。

**拆分信号**：条目超过 15 条时，按架构域或时间段分组。

### 2.11 tech-debt/

**职责**：技术债务登记。已知债务、临时方案、计划中的重构。

**适用规则**：总是适用。初始可能为空。

**内容要求**：`README.md` 作为债务索引，至少包含 `status`。每个债务项记录是什么、为什么欠下、影响范围、偿还计划、优先级。状态：

- `active`：债务仍然存在。
- `resolved`：债务已偿还，附解决方式和关联变更/决策。
- `obsolete`：债务因架构变更不再相关，附原因和关联决策。

已 resolved/obsolete 的条目保留在文档中作为历史参考，并在索引中明确标记。

**拆分信号**：天然多条目，每个重大债务一个文件。

---

## 3. 递归目录规则

每个文件夹必须有一个 `README.md` 作为索引。内容条目是独立 `.md` 文件。当条目需要进一步分组时，建子文件夹并递归应用同一规则。

示例：

```text
SSOT/architecture/
  README.md
  views/
    README.md
    operating-model.md
    critical-journeys.md
    current-target-gap.md
  domains/
    README.md
    query-engine/
      README.md
      parser.md
      planner.md
    storage-engine/
      README.md
      buffer-manager.md
      page-format.md
```

不要为了源码目录、包名、类名或团队名机械创建 SSOT 层级。拆分必须提升可读性、解释独立边界，或降低维护冲突。

---

## 4. 任务入口映射

不要新增强制顶层 `task-playbooks/` 或类似 权威区域。若 git history、commit 审查或长期会话显示某些研发任务簇高频或高风险，可以在 `SSOT/README.md` 增加薄入口图 `任务入口映射`。

适用信号包括：

- 反复修复同类失败。
- 经常触发跨域迁移。
- 发布、恢复、数据迁移或兼容性操作容易出错。
- 用户长期反复要求同一类高风险审查入口。

`任务入口映射` 只做入口索引。每行描述任务簇、触发信号、应该先读的权威位置和最后审查点。它不得维护独立长期事实，不得复制 playbook 正文；事实仍写回对应 权威位置。没有明确高频/高风险任务簇时，写 `not_applicable` 或不创建该小节。

---

## 5. 不适用区域

`architecture/`、`identity/`、`glossary/`、`decisions/`、`gotchas/`、`bugs/`、`tech-debt/` 总是适用。

工程操作区域（如 `deployment/`、`release/`）对某些仓库可能不适用，此时仍创建文件夹和 `README.md`，内容格式：

```markdown
# <区域名称>

本区域不适用于当前仓库。

**原因**：<具体原因>
```

这确保结构完整且无歧义，Agent 不会误以为某个区域“还没填写”。`not_applicable` 是合法状态，但必须说明原因；若用于停止结论或 `covered` 等价判断，仍需独立停止审查。

---
