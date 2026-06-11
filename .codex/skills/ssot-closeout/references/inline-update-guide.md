# 内联更新执行参考

本文件服务于内联更新：当 Agent 决定更新 SSOT 时，按需阅读本文件获取执行细则。

**阅读时机**：不在 session 开始时阅读。当 `$ssot-preflight` 或 `$ssot-closeout` 识别到需要更新 SSOT，准备执行写入时，阅读本文件。

**与其他参考文件的关系**：

| 文件 | 服务场景 | 阅读时机 |
|---|---|---|
| 本文件 | 内联更新（日常开发中即时写入） | Agent 决定更新 SSOT 时 |
| `commit-audit.md` | 主动追赶（commit 级 batch 审查） | 用户发起追赶时 |
| `conversation-audit.md` | Session 自检 + 主动追赶 | session 结束时 / 用户发起追赶时 |

---

## 目录

- [1. 内联更新流程](#1-内联更新流程)
- [2. 写入纪律](#2-写入纪律)
- [3. 不写什么](#3-不写什么)

## 1. 内联更新流程

1. 重新读取目标 SSOT 文件和 `SSOT/STATUS.md`。
2. 按 [`update-routing.md`](update-routing.md) 判断影响面、区域映射和是否需要级联检查。
3. 若本次涉及 README/docs/ADR/runbook/PRD/用户显式提供资料，按 [`source-material.md`](../../ssot-preflight/references/source-material.md) 做源资料分类、吸收、薄文档检查和冲突裁定。
4. 按下方写入纪律更新唯一 权威位置；不要在多个区域重复维护同一事实。
5. 更新 `STATUS.md` 的区域状态、开放缺口、开放裁决项、源资料吸收矩阵和停止审查记录。

内联更新用于日常开发中的即时写入；commit-audit 和 conversation-audit 使用相同 owner 规则，但有不同的批量输入和水位推进流程。

---

## 2. 写入纪律

### 2.1 文档语言锁

更新任何 SSOT Markdown 前，先读取 `SSOT/STATUS.md` 的 `documentation_language` 和 `documentation_language_evidence`：

- 字段已存在：本次新增或修改的 SSOT 正文、标题、表格标签和模板结构必须使用锁定语言。
- 字段缺失：只从根 README、`docs/`、ADR、runbook、子系统 README 和用户显式提供的外部资料探测自然语言；忽略代码块、命令、路径、API 名、枚举值、代码标识符和直接引用文本。
- 语言混杂、证据不足或没有可检测文档：先询问用户选择 SSOT 文档语言，不得用当前对话语言兜底。
- 后续源资料语言变化不自动切换 `documentation_language`；确需切换时写入 开放裁决项，并在 停止审查闸门记录语言变更审查。

代码标识符、路径、命令、API 名、枚举值和直接引用保持原文。

### 2.2 来源标记

内联更新写入 SSOT 的内容应标记来源，便于后续审计和验真：

| 来源 | 含义 | 标记方式 |
|---|---|---|
| 代码变更直接推导 | commit 本身就是证据 | 无需额外标记（默认） |
| 对话中的确定性结论 | 对话产生的长期 SSOT 知识 | 行内标注 `（来源：conversation，<日期或 session 标识>）` |
| 源资料吸收 | README/docs/ADR/runbook 或用户显式提供资料中的长期知识 | 记录原路径/URL/会话标识和分类（`absorb` / `link-only` / `stale/conflict` / `obsolete`） |
| Agent 推断（无直接代码证据） | 口头约定、调试推断、隐性耦合 | 使用 confidence frontmatter（见 [`knowledge-integrity.md`](../../ssot-preflight/references/knowledge-integrity.md) 状态机和写入标注表） |

### 2.3 交叉验证

当对话中的结论涉及代码实现时，Agent 应交叉验证代码是否匹配：

- 验证通过 → 来源可同时标记 `conversation` + `code-analysis`，提升置信度
- 对话结论与代码不一致：
  - 若结论描述当前已实现事实 → 以代码/配置/schema/test 为准，修正薄文档或在 SSOT 源资料吸收 标记 `stale/conflict` 并写明裁定后的 权威位置
  - 若结论描述设计意图、约束或未落地决策 → 不自动判定代码正确；更新 architecture views/domains 的 current/target/gap，必要时在相关决策中标记 `implementation_state: diverged` 或 `partial`，并写入 `STATUS.md` 的 `开放裁决项`

源资料与代码或 SSOT 冲突时，按 [`source-material.md`](../../ssot-preflight/references/source-material.md) 的冲突裁定规则处理。不要直接把 docs 内容覆盖进 SSOT，也不要只标 `stale/conflict` 后跳过。

### 2.4 写入前的 re-read

更新任何 SSOT 文件前，先读取该文件的当前内容，确保：

- 不覆盖他人的更新（尤其是 STATUS.md）
- 不违背 `STATUS.md` 的 `documentation_language`
- 不重复已有内容
- 新内容与已有内容保持一致
- 不与已有 active 条目矛盾或否定翻转：旧结论被新结论反转时，执行冲突 / 否定扫描——保留双方证据或登记 开放裁决项，不静默覆盖

### 2.5 STATUS.md 同步

完成区域内容更新后，同步更新 STATUS.md：

- 推进 `tracked_commit` 到当前 HEAD（如果本次变更已 commit）前，必须有独立 reviewer 对该范围返回 `no-more-required-changes`
- 推进 `tracked_skill_version` 到当前 `ssot-preflight` 的 `metadata.protocol_version` 前，必须先完成 协议升级审查，并由独立 reviewer 返回 `no-more-required-changes`
- 更新受影响区域的状态（如 `gap` → `covered`、`covered` → `stale`）；其中 `covered` 是 停止结论，必须先记录 停止审查
- 更新 源资料吸收矩阵：本次读取或变更的源资料必须记录分类、权威位置、吸收状态、冲突/裁决项和 最后检查
- 更新 open gaps 列表
- 新增或更新运行中发现的裁决项；提醒用户一次，但默认不阻断当前任务

更新 STATUS.md 前必须 re-read 最新版本。若本次补齐或变更 `documentation_language`，同步更新 `documentation_language_evidence`；语言变更必须已有裁决/审查证据。

如果本次内联检查结论是 `no-op` / `无需更新`，也必须请求独立 reviewer 复核受影响范围。Reviewer 返回 `needs-fix` 时，按 剩余修改项 修复后再更新 STATUS.md；只有 `no-more-required-changes` 才能记录 no-op 或推进水位。

### 2.6 裁决项登记

需要裁决但不必立即打断当前任务的情况，写入 `STATUS.md` 的 `开放裁决项`：

| 场景 | 动作 |
|---|---|
| 当前实现与 `architecture/` 或 `decisions/` 冲突 | 更新 architecture current/target/gap，标记相关决策 `implementation_state: diverged` 或记录约束冲突，新增/更新裁决项 |
| 两个设计意图互相冲突 | 保留双方链接，新增/更新裁决项 |
| 事实来源无法合并且会影响后续实现 | 标记相关区域 `conflict`，新增/更新裁决项 |

新增项使用 `ADJ-YYYYMMDD-NN`，状态默认为 `pending`。运行中提醒一次：

```text
发现需裁决项 ADJ-YYYYMMDD-NN：<问题>。本次不阻断当前任务，已记录到 STATUS.md。
```

若用户选择延期，状态写为 `deferred` 并记录 `revisit_condition`；未指定时使用“下次会话重新裁决”。

### 2.7 源资料吸收

README/docs/ADR/runbook/PRD 或用户显式提供资料发生变化时，按 [`source-material.md`](../../ssot-preflight/references/source-material.md) 分类并处理。更新完成后同步 `STATUS.md` 源资料吸收矩阵，记录分类、权威位置、吸收状态、冲突/裁决项和最后检查。

---

### 2.8 晋升与降级检查

内联更新时遇到带 `confidence` 标注的 SSOT 内容，若手头恰好有相关证据（因为正在做代码任务），顺手晋升或降级：

- 当前代码变更证实了某个 `candidate` 声明 → 晋升为 `source-backed`，更新 evidence 指针。
- 当前代码变更推翻了某个声明 → 降级或删除，记录降级原因。
- 触碰的文件/函数与某个 `hypothesis` 的 evidence 指针重合 → 检查 hypothesis 是否仍有效。

晋升和降级不是额外任务——它是内联更新中"重新读取目标文件"步骤的自然延伸。完整规则见 [`knowledge-integrity.md`](../../ssot-preflight/references/knowledge-integrity.md)。

---

## 3. 不写什么

以下情况不需要更新 SSOT：

- 纯格式/注释/typo 修正（除非修改了架构域、入口文件或 权威来源 路径指针）
- 单文件内的实现细节变更（不影响架构边界、状态所有权、API 契约、外部行为、资源生命周期、锁/事务/重试/回滚、失败语义或 high-risk algorithm flow）
- 探索性讨论和被否决的方案（除非否决本身构成一个 decision）
- 中间推测和临时假设
- 纯操作性指令（"帮我改一下这个文件"）
- 代码/脚本可直接推导的信息（如完整的依赖树、路由列表——用指针替代）
