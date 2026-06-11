# 对话级审查参考

本文件服务于 `$ssot-audit` 的两个流程：

- **Session 自检**：每个 session 结束时，Agent 用本文件的映射表回顾当前对话，确认内联更新无遗漏。
- **主动追赶（Session 审查部分）**：用户发起追赶时，Agent 用本文件的完整流程审查旧 transcript。

对话审查与 commit 审查（`references/commit-audit.md`）是平行的协议：commit 审查从 `git diff` 中提取区域级变更，对话审查从 transcript 中提取长期 SSOT 知识。两者共享 `$ssot-closeout` 的写入纪律和区域映射逻辑。

---

## 目录

- [使用场景](#使用场景)
- [完整执行流程（主动追赶时使用）](#完整执行流程主动追赶时使用)
- [Transcript 定位](#transcript-定位)
- [Transcript 阅读策略](#transcript-阅读策略)
- [Transcript-to-区域映射](#transcript-to-区域映射)
- [来源标记](#来源标记)
- [规模自适应（主动追赶时适用）](#规模自适应主动追赶时适用)
- [与 commit 审查的协同](#与-commit-审查的协同)
- [与 Session 自检的关系](#与-session-自检的关系)

## 使用场景

| 场景 | 输入 | 使用本文件的哪部分 |
|---|---|---|
| Session 自检 | 当前 session 的对话内容 | Transcript-to-区域映射表 + 关注信号 |
| 主动追赶 | 旧 transcript 文件 | 完整执行流程 |

---

## 完整执行流程（主动追赶时使用）

```text
1. 定位原始 transcript（见下方"Transcript 定位"）
2. 读取 STATUS.md 的 tracked_session、documentation_language 和 documentation_language_evidence
3. 筛选 tracked_session 之后的新 transcript
4. 阅读 transcript，识别长期 SSOT 知识（见下方"Transcript-to-区域映射"）
5. 按 `$ssot-closeout` 写入路由更新受影响区域
   → 新增/修改的 SSOT 正文、标题、表格标签使用 documentation_language
   → 来源标记为 conversation（附 session 标识或时间戳）
   → 用户显式提供的外部资料按 [`source-material.md`](../../ssot-preflight/references/source-material.md) 分类，保留来源指针，并同步 `STATUS.md` 源资料吸收
   → 涉及代码的结论，交叉验证代码是否匹配
6. 请求独立 reviewer 审查本次 transcript 范围、写入结果和任何 `no-op` / `无需更新` 结论
   → `no-more-required-changes`：继续
   → `needs-fix`：按 剩余修改项 补写后重复审查
7. 更新 STATUS.md：
   - 推进 tracked_session 到最新已审查的 session
   - 更新受影响区域的状态
   - 记录停止审查闸门证据
```

> **Session 自检不走此流程**——Session 自检直接审查当前对话内容，不需要定位 transcript 文件或推进 tracked_session。但自检结论为 `no-op` / `无需更新` 时仍需独立 reviewer 检查当前 session 范围。

---

## Transcript 定位

不同 harness 的 transcript 位置和格式不同。Agent 应按以下优先级寻找：

| Harness | 典型位置 | 格式 | 备注 |
|---|---|---|---|
| Cursor | 项目级 `agent-transcripts/*.jsonl` 或 IDE 管理的 transcript 目录 | JSONL（每行一条消息） | 包含 role、content、tool_use 等字段 |
| Claude Code | Claude 管理的 JSONL transcript | JSONL | 通过 hook stdin 或会话目录访问 |
| Codex | 会话日志目录 | 各有不同 | — |
| 其他 | 各有约定 | — | Agent 应根据 harness 文档确定 |

**定位失败时**：如果 Agent 无法找到 transcript 文件（harness 不留记录、权限不足、路径未知），在 STATUS.md 备注中记录原因，不阻塞其他工作。对话审查是"有素材就做，没素材就跳"——不像 commit 审查那样总能 `git log`。

**当前会话的特殊情况**：Agent 在当前对话中可以直接审查本次会话的内容，无需定位 transcript 文件。这是对话审查最常见的场景——任务结束时回顾本次对话是否产生了值得沉淀的长期 SSOT 知识。

---

## Transcript 阅读策略

### 提取目标

从 transcript 中识别**长期 SSOT 知识**——即属于 architecture 主干或卫星区域范畴、且对后续 Agent 有长期价值的信息。

只提取**确定性结论**，不提取：

- 探索性讨论（"我们试试 X 方案？""先看看 Y 行不行"）
- 被否决的方案（除非否决本身构成一个 decision）
- 中间推测和临时假设
- 纯操作性指令（"帮我改一下这个文件"）

### 过滤噪声

Transcript 中大部分内容是操作性的（文件读写、工具调用、中间输出）。以下内容通常不含长期 SSOT 知识，可快速跳过：

- 纯文件读取操作及其输出
- 重复的工具调用和中间状态
- 代码生成的中间过程（除非过程中讨论了 why）
- 格式化、排版等非语义操作

### 关注信号

以下对话模式往往包含长期 SSOT 知识：

- 用户或 Agent 明确说"我们决定..."、"选 X 因为..."
- 调试过程中发现的根因分析
- "注意这里不能..."、"这个坑是..."
- "这是临时方案，之后要..."
- "当前优先..."、"这不是当前目标..."、"成功标准是..."
- 对约束的确认或澄清
- 对设计思路、设计意图、非目标、拒绝方案或不要复活旧方案的确认
- 新术语的定义或已有术语含义的修正
- 对系统边界、设计单元、运行流、状态所有权的讨论
- 部署、配置、安全相关的策略讨论
- 对架构图、流程图、Current/Target 设计图、生命周期/失败恢复/信任边界图的讨论
- 用户显式提供外部资料、规范、设计说明或历史文档，并要求作为项目背景使用

---

## Transcript-to-区域映射

Transcript-to-区域映射以 [`update-routing.md`](../../ssot-closeout/references/update-routing.md) 的“对话信号到区域映射”为语义所有者。对话审查只负责从 transcript 中提取长期 SSOT 知识，并把提取结果输入该映射。

用户显式提供外部资料、规范、PRD、设计说明或历史文档时，按 [`source-material.md`](../../ssot-preflight/references/source-material.md) 执行源资料分类、吸收、薄文档检查和冲突裁定。

---

## 来源标记

对话审查写入 SSOT 的内容应标记来源为 `conversation`。如果用户显式提供外部资料，还应记录资料标识（路径、URL、文件名或会话位置）、源资料分类和 `STATUS.md` 源资料吸收状态；分类语义以 [`source-material.md`](../../ssot-preflight/references/source-material.md) 为准。标记方式不强制，可以是：

- 行内标注：`（来源：conversation，2026-05-24 会话）`
- 条目元数据中的来源字段
- 脚注引用

当对话中的结论涉及代码实现时，Agent 应交叉验证代码是否匹配。如果验证通过，来源可同时标记 `conversation` + `code-analysis`，提升置信度。如果对话结论与代码不一致，按 `$ssot-preflight` 的“已实现事实 vs 设计意图”规则和 [`source-material.md`](../../ssot-preflight/references/source-material.md) 的冲突裁定规则区分权威：描述已实现事实时以代码/配置/schema/test 为准；描述设计意图、约束或未落地决策时，不自动判定代码正确，需更新 architecture views/domains 的 current/target/gap，必要时标记 `implementation_state: diverged` 或记录约束冲突，并写入 `STATUS.md` 的 开放裁决项。`stale/conflict` 不能只标记后跳过。

写入前必须遵守 文档语言锁：若 `STATUS.md` 缺失 `documentation_language`，只从根 README、`docs/`、ADR、runbook、子系统 README 和用户显式提供的外部资料探测；语言混杂、证据不足或没有可检测文档时先询问用户。不要用当前对话语言作为兜底。直接引用、代码标识符、路径、命令、API 名和枚举值保持原文。

---

## 规模自适应（主动追赶时适用）

| 情况 | 策略 |
|---|---|
| 少量（1–3 个）未审查 session | 逐个阅读 transcript，提取长期 SSOT 知识 |
| 大量未审查 session | 优先处理最近的 session；旧 session 可降低优先级或跳过——对话知识的时效性通常不如 commit 变更 |

**时效性判断**：对话中的知识可能已被后续 commit 体现或推翻。Agent 应将对话结论与当前代码状态交叉验证，避免写入已过时的信息。

---

## 与 commit 审查的协同

在主动追赶中，对话审查和 commit 审查可独立执行，也可协同：

- **独立执行**：各自通过独立停止审查 后推进自己的水位（`tracked_commit` / `tracked_session`）
- **协同执行**：全面审计时同时追赶两个事件源的积压
- **交叉验证**：对话中讨论的变更通常已通过 commit 落地——两个事件源可以互相印证

典型分工：`decisions/` 中的决策记录更适合从对话中提取（因为 why 在对话里），而 architecture 中的 current 事实更适合从 commit 中提取（因为 what 在代码里）。

---

## 与 Session 自检的关系

Session 自检是本文件映射表的轻量应用——只看当前 session、只检查遗漏、不推进 tracked_session。主动追赶才使用完整流程。

如果 Agent 在内联更新中已经充分写入了本次对话产生的长期 SSOT 知识，Session 自检可以提出 `no-op`，但该 停止结论 必须由独立 reviewer 返回 `no-more-required-changes` 后才成立。Reviewer 发现遗漏时返回 `needs-fix`，Agent 补写后复审。

### Confidence 扫描

Session 自检时，Agent 还应回顾本 session 中写入或修改的带 `confidence` 标注的 SSOT 内容：

- 标注是否合理？（来源为对话确认的结论是否正确标为 `candidate`？Agent 推测是否正确标为 `hypothesis`？）
- 本 session 中是否获得了新证据可以晋升已有的 hypothesis/candidate？
- 是否有 session 中确认的结论被遗漏了标注？

这不是额外的审查流程，而是 Session 自检回顾遗漏时的附加检查维度。详见 [`knowledge-integrity.md`](../../ssot-preflight/references/knowledge-integrity.md)。

### 近场触发探查（v2.14 新增）

Session 自检时，Agent 还应顺带做一次**近场触发探查**——回顾本次会话自身，判断 SSOT 是否真被触发与用上：

- 本次是实质性代码任务吗？感知阶段读了 `SSOT/` 吗，还是跳过感知直接改代码？
- 读取面对不对？SSOT 内容真的影响了产出，还是读了等于没读？

这是只读、零成本的自观察，**不改任何文件**。若发现触发不充分（该读没读 / 读偏 / 没用上），按 [`consumption-audit.md`](../../ssot-doctor/references/consumption-audit.md) 的核心规则处理：默认只记录并产出触发改进建议，用户授权后才优化触发侧（项目适配器 / `SSOT/README.md` 导航 / skill 本体）。需要更大样本佐证或定位系统性断点时，再升级到远场 transcript 分析。

注意区分职责：本文件（对话审查）从 transcript 提取知识**写入** SSOT；近场触发探查与消费审查评估 SSOT **被用得怎样**，方向相反，语义所有者是 [`consumption-audit.md`](../../ssot-doctor/references/consumption-audit.md)。
