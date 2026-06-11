# 知识完整性协议

本文件是 SSOT 知识 confidence 状态机、写入时标注、晋升/降级规则和 blocking 逻辑的语义所有者。写入推断性或对话来源的长期知识、内联更新遇到带 confidence 标注的内容、Doctor 检查 confidence tag、或 Stop review 评估覆盖范围时按需阅读。

## 目录

- [1. Confidence 状态机](#1-confidence-状态机)
- [2. 写入时标注](#2-写入时标注)
- [3. 晋升与降级](#3-晋升与降级)
- [4. Blocking 规则](#4-blocking-规则)
- [5. Frontmatter 格式](#5-frontmatter-格式)
- [6. 向后兼容](#6-向后兼容)

## 1. Confidence 状态机

SSOT 中每条长期知识都有一个隐式或显式的 confidence 状态。状态决定该知识可以写入哪些权威位置，以及是否阻断覆盖声明。

```text
hypothesis ──► candidate ──► source-backed ──► verified
                                                 │
                                          （隐式，无标注）
```

| 状态 | 含义 | 可写入的权威位置 |
|---|---|---|
| `hypothesis` | Agent 推测，无直接证据 | gotchas（标记来源）、STATUS.md 开放缺口 |
| `candidate` | 有初步证据（代码注释、commit 消息、docs、对话确认），但未经代码级交叉验证 | 涌现/历史区域（gotchas、bugs、tech-debt、decisions）+ architecture 的 gap/unknown 注释 |
| `source-backed` | 有代码/配置/schema/test 直接证据 | 所有权威位置 |
| `verified` | 经独立 reviewer 或后续 session 确认 | 所有权威位置；这是默认状态，不需要 confidence 标注 |

状态只能按序晋升，但可以跳过中间状态（例如 Agent 推测后立即找到代码证据，直接标 `source-backed`）。降级可以从任何状态到任何更低状态或直接删除。

---

## 2. 写入时标注

Agent 写入长期知识到 SSOT 时，根据知识来源确定默认 confidence：

| 知识来源 | 默认 confidence | 说明 |
|---|---|---|
| 代码/配置/schema/test 直接推导 | 不需要标注（等价于 `verified`） | 代码本身就是证据 |
| 对话中用户确认的结论 | `candidate` | 对话确认提供了初步证据，但需要代码级交叉验证 |
| Agent 代码分析推断 | `candidate` | 有分析依据，但推断可能有误 |
| Agent 推测，无直接证据 | `hypothesis` | 口头约定、猜测、隐性耦合判断 |

写入规则：

- 默认 confidence 可以按实际证据向上调整。例如对话中用户确认的结论，如果 Agent 同时用代码验证了，可以直接标 `source-backed` 而非 `candidate`。
- 标注 `source-backed` 时必须同时提供 `evidence` 字段（见 §5）；否则应使用 `candidate`。
- 默认 confidence 不可向下调整来规避写入位置限制。
- `hypothesis` 不得写入 architecture views/domains 的权威正文。可以作为 gap 注释或 STATUS.md 开放缺口存在，以标记"此处需要验证"。

---

## 3. 晋升与降级

### 3.1 晋升时机

晋升嵌入在 SSOT 已有的协议触点中，不需要专门的"晋升活动"。

| 已有协议触点 | 晋升方向 | 触发条件 |
|---|---|---|
| 内联更新 | candidate → source-backed | Agent 修改代码时，发现触碰了某个 candidate 声明相关的代码，且代码证实了该声明 |
| Commit 审查 | candidate → source-backed | 审查 diff 时发现新 commit 证实了某个 candidate 声明 |
| 对话自检 | hypothesis → candidate | Agent 回顾本 session，发现某个 hypothesis 在对话中获得了用户确认或初步证据 |
| Stop review | source-backed → verified | 独立 reviewer 审查覆盖范围时确认 source-backed 声明的证据有效，去除 confidence 标注 |

Agent 遇到带 confidence 标注的内容时，不必主动寻找证据来晋升——但如果手头恰好有相关证据（因为正在做代码任务），应顺手更新标注。晋升是已有工作的副产物，不是额外任务。

### 3.2 降级时机

| 降级触发 | 典型时机 | 动作 |
|---|---|---|
| 代码变更推翻了声明 | Commit 审查、内联更新 | 降级（source-backed → candidate 或更低）或删除，记录降级原因 |
| 指针断裂（文件/函数已不存在） | Doctor L1 确定性检查 | 降级或删除，记录原因 |
| 新证据与声明冲突 | 内联更新、commit 审查 | 降级或进入开放裁决项 |
| 用户明确否定 | 对话 | 删除或标记 resolved/obsolete |

降级必须记录原因，格式不强制——可以在 frontmatter 增加 `demoted_reason`，也可以在正文中行内标注。

### 3.3 角色分配

| 状态转换 | 角色 |
|---|---|
| hypothesis → candidate | 工作 Agent（updater） |
| candidate → source-backed | 工作 Agent（updater） |
| source-backed → verified（去标注） | 独立 reviewer（stop review）或不同 session 的 Agent 确认 |
| 任何降级 | 工作 Agent，发现证据失效时立即执行 |

verified 是隐式状态（无 confidence 标注），晋升到 verified 等价于删除 confidence frontmatter。这与现有的"所有 SSOT 内容默认可信"原则一致——只有需要特别标记不确定性时才添加 confidence。

---

## 4. Blocking 规则

`hypothesis` 和 `candidate` 阻断所在范围的 `covered` 状态，等价于 `gap`/`unknown`。

具体规则：

- 某个区域或 architecture domain 内存在 `confidence: hypothesis` 或 `confidence: candidate` 的内容时，该范围不能标为 `covered`。
- 这意味着要达到 `converged`，必须处理所有 hypothesis/candidate——要么找到证据晋升为 source-backed 或 verified，要么降级为 unknown 并进入开放缺口，要么删除。
- `source-backed` 不阻断 `covered`。它表示"有证据但尚未经独立确认"，与 `covered` 的含义（"内容与代码一致且有停止审查"）兼容。
- 若团队不追求 `converged`（脚本/原型项目），hypothesis/candidate 可以一直存在，不影响日常开发。

---

## 5. Frontmatter 格式

扩展现有 `SKILL.md` §3.4 的 confidence frontmatter：

```yaml
---
confidence: hypothesis | candidate | source-backed
source: conversation | code-analysis | code-comment | git-history | documented
discovered_at: 2026-05-27
evidence: "src/auth/handler.ts#retryWithBackoff（重试逻辑）"
---
```

字段说明：

| 字段 | 必需 | 说明 |
|---|---|---|
| `confidence` | 是（若非 verified） | 状态机中的当前状态 |
| `source` | 是 | 知识来源类型 |
| `discovered_at` | 是 | 发现日期 |
| `evidence` | `source-backed` 时必需；`hypothesis`/`candidate` 时推荐 | 证据指针（见 §5.1 锚定规则） |

### 5.1 证据指针锚定（v2.13）

`evidence` 指向代码时，`[SHOULD]` 锚到 **符号名** 而非行号，格式 `path#symbol`（如 `src/auth/handler.ts#retryWithBackoff`）：

- 行号（`path:line`）随代码移动静默失真；符号名抗移动，且能被 [`assets/scripts/ssot-lint.sh`](../../ssot-doctor/assets/scripts/ssot-lint.sh) grep 复核存在性（失效输出 `[STALE]`）。
- 文件级事实可只写 `path`；指向具体实现时优先 `path#symbol`。
- `[MAY]` 仅对核心不变量（架构级、安全级）追加 content-hash 或 commit SHA 锁定版本；不要对每条 evidence 都算 hash，否则代码无意义改动会触发噪声告警。

`verified` 状态不需要 frontmatter——没有 confidence 标注的内容即为 verified。

---

## 6. 向后兼容

旧的 `confidence: inferred` + `needs_verification: true` 格式视为 `candidate` 的等价表达：

| 旧格式 | 等价新状态 | 迁移方式 |
|---|---|---|
| `confidence: inferred` + `needs_verification: true` | `candidate` | 不要求机械迁移；Agent 遇到时按新协议处理即可 |
| `confidence: inferred`（无 needs_verification） | `candidate` | 同上 |
| 无 confidence 标注 | `verified` | 无需处理 |

协议升级审查（v2.11）不要求遍历所有 SSOT 文件机械替换旧标注。Agent 在日常维护中遇到旧格式时按等价关系处理。

同理，v2.13 引入的 `path#symbol` 证据锚定不要求机械迁移既有 `path:line` 指针；Agent 在内联更新或 Doctor 复核中触碰到失效的行号指针时，顺手改为符号锚即可。
