# 消费审查参考（触发侧 L4 行为探针）

本文件是 SSOT **触发 / 消费侧有效性** 的语义所有者，兑现 `ssot-preflight/SKILL.md` 与 [`doctor.md`](doctor.md) CONSUMPTION 检查项承诺、但此前从未定义的 **L4 行为层探针**：评估 SSOT 在真实对话中是否被触发、读对、用上，并据此优化触发侧——即“让 SSOT 更可能被 Agent 用起来”的那一侧。

定位与 Doctor 平行、与三个事件源审查正交：

- **Doctor** 验 SSOT **内容** 是否仍可信；**消费审查** 验 SSOT **触发 / 使用** 是否有效。
- 它不追赶 `tracked_commit` / `tracked_session` / `tracked_skill_version`，也不向 SSOT 写入新长期知识。

---

## 目录

- [1. 角色与边界](#1-角色与边界)
- [2. 核心规则：默认出建议、授权才改](#2-核心规则默认出建议授权才改)
- [3. L4 探针：双层](#3-l4-探针双层)
- [4. 信号提取与触发健康度](#4-信号提取与触发健康度)
- [5. 失败归因到优化对象](#5-失败归因到优化对象)
- [6. 优化协议：建议报告与授权执行](#6-优化协议建议报告与授权执行)
- [7. 落点：嵌入 Session 自检](#7-落点嵌入-session-自检)
- [8. 与其他流程的边界](#8-与其他流程的边界)

## 1. 角色与边界

**做什么**：

- 探查 SSOT 在真实对话中的触发与消费有效性。
- 定位“该触发却没触发 / 触发了没用上”的断裂环节。
- 产出**触发改进建议**，覆盖项目级触发侧（适配器、`SSOT/README.md` 导航）和 skill 级触发侧（`SKILL.md` 的 `description`、感知流程措辞、适配器模板）。

**不做什么**：

- `[MUST]` 不从对话提取长期知识写入 SSOT——那是 [`conversation-audit.md`](../../ssot-audit/references/conversation-audit.md) 的职责。
- `[MUST]` 不验证 SSOT 内容是否与代码一致——那是 [`doctor.md`](doctor.md) 的职责。
- 不推进任何 tracked 水位。

**与 CONSUMPTION 静态检查的关系**：[`ssot-lint.sh`](../assets/scripts/ssot-lint.sh) 检查 9 和 [`doctor.md`](doctor.md) 检查项 C 是 **L1 静态消费链路**（适配器有没有写 `SSOT/`、`SSOT/README.md` 在不在）；本文件是 **L4 行为层探针**（真实对话里到底用了没）。L1 是 L4 的前置必要条件：链路断了行为必然失效，链路通了行为未必有效。

## 2. 核心规则：默认出建议、授权才改

`[MUST]` 消费审查的所有优化动作遵循同一条规则，无论改动对象是项目级还是 skill 级：

```text
诊断 → 出建议 → 用户授权 → 改
```

- 诊断阶段**只读、只记录、不改任何文件**。
- 产出建议清单后**默认不执行**，等待用户逐条或整体授权。
- 用户授权等价于人工停止审查 reviewer：把人放进环路，规避“updater 用有偏样本自证后擅改全局触发契约”的风险（呼应 `ssot-preflight/SKILL.md` §1.3 独立停止审查闸门）。

理由：触发侧配置（尤其 `description` 和感知流程）是**触发契约**，一次有偏样本的误判若直接落地，会污染所有后续对话的触发行为，且难以回滚。默认出建议把“判断”和“生效”解耦，错误不会直接落地。

## 3. L4 探针：双层

探针分近场和远场两层，成本与样本质量不同，配合使用。

### 3.1 近场探针（self-observation）

`[SHOULD]` 嵌入 Session 自检，几乎零成本。Agent 回顾**当前会话自身**：

- 这是实质性代码任务吗？（只读问答 / 闲聊 / 纯机械变更不计入，对齐 `ssot-preflight/SKILL.md` §2.2 跳过条件）
- 感知阶段我读了 `SSOT/` 吗？还是直接读源码 / 改代码跳过了感知？
- 我读的面对不对？（任务需要的 domain / 契约有没有读到，还是读偏、读不够、或全量读浪费 context）
- SSOT 内容真的影响了我的决策 / 产出吗？还是读了等于没读？

近场探针的优势：Agent 对自己刚刚的行为有第一手判断，比事后解析 transcript 更准、更便宜。

### 3.2 远场探针（transcript 分析）

`[MAY]` 按需或用户点名时执行，做统计佐证、定位系统性断点。

- **数据源与定位**：复用 [`conversation-audit.md`](../../ssot-audit/references/conversation-audit.md) 的 Transcript 定位表（Cursor 为 `agent-transcripts/<uuid>/<uuid>.jsonl`，含 `subagents/`）。定位失败时降级记录、不阻塞，同 conversation-audit 现有纪律。
- **无状态**：远场每次实时扫最近 N 个 transcript 的触发信号，不维护持久计数器，不新增 STATUS 字段。

**样本偏差铁律** `[MUST]`：

- 当前正在做 SSOT 维护 / 审计的会话**不能**当触发健康样本——Agent 此时本就在读写 SSOT，统计会被严重高估。
- 最有价值的样本是过去**非 SSOT 任务**的普通编码对话：那才是“SSOT 本应被用上”的真实考场。
- 子代理（`subagents/`）transcript 的触发行为受父代理指令支配，不独立计入触发健康度。

## 4. 信号提取与触发健康度

信号分两层，对齐协议 L1 / L4 分层。

### 4.1 L1 机械信号（可从 transcript 结构提取）

从 transcript 的 `tool_use.name` 与 `input.path` 即可机械判断：

- 是否实质性代码任务（有无对源码的读 / 写工具调用）。
- 有无读取 `SSOT/` 路径（`Read` / `Glob` 的 path 命中 `SSOT/`）。
- 是否在未读 SSOT 的情况下直接改代码（跳过感知的强信号）。

### 4.2 L4 语义信号（需 Agent 判断）

- 触发后 SSOT 内容是否真正影响产出（决策中引用了 SSOT 结论 vs 读完无视）。
- 读取面是否匹配任务（读对 / 读偏 / 读不够 / 全量浪费）。

### 4.3 触发健康度

基于一组样本（非单次）给出分级：

- `healthy`：实质性任务中 SSOT 稳定被触发且用上。
- `partial`：触发不稳定，或触发了但常读偏 / 没用上。
- `broken`：实质性任务普遍跳过 SSOT。

`[MUST]` 健康度结论基于多样本统计，不得用单次会话下结论；样本不足时记 `unknown` 并说明原因。

## 5. 失败归因到优化对象

探针发现“该触发却没触发 / 没用上”时，定位断点并映射到改动对象与层级：

| 断裂环节 | 现象 | 改动对象 | 层级 |
|---|---|---|---|
| skill 未加载 | harness 没把 SSOT Skill bundle / `ssot-preflight` 纳入本任务 | `SKILL.md` 的 `description` 与任务信号不匹配 | skill 级 |
| 加载了但没读 SSOT | 触发了 skill 却跳过感知 | `SKILL.md` §2 感知流程门槛 / 措辞 | skill 级 |
| 无适配器 / 适配器没路由 | 项目缺 AGENTS.md 等，或其中没写 `SSOT/` | `AGENTS.md` / `CLAUDE.md` / `.cursor/rules`（见 [`adapter-strategy.md`](adapter-strategy.md)） | 项目级 |
| 导航找不到对的面 | 读了 SSOT 但没找到任务相关 domain | `SSOT/README.md` 导航 | 项目级 |
| 读对了面却没用上 | 内容读到却无视 | 多半是**内容质量**问题，转 Doctor / audit，不在触发侧改 | 不适用 |

这是指南而非穷举；Agent 按实际证据归因，一个现象可能命中多个环节。

## 6. 优化协议：建议报告与授权执行

### 6.1 建议报告结构

每条触发改进建议包含：

- **现象**：evidence——transcript `<uuid>` + 具体行为，或当前会话的近场观察。
- **归因**：命中 §5 的哪个断裂环节。
- **改动对象 + 层级**：项目级 or skill 级。
- **具体改法**：建议的最小改动。
- **风险与可逆性**：尤其 skill 级要标注影响面。
- **状态**：默认 `建议`；授权后转 `已采纳`。

### 6.2 授权与执行

`[MUST]` 默认不改任何文件。用户授权后：

- **项目级**（适配器 / `SSOT/README.md`）：按 [`adapter-strategy.md`](adapter-strategy.md) 和现有写入纪律改。
- **skill 级**：见 §6.3 额外约束。

### 6.3 skill 本体改动的额外约束

`[MUST]` 改 `SKILL.md` 的 `description`、感知流程或适配器模板属高影响变更：

- 需独立停止审查（不可 updater 自证），对齐 `ssot-preflight/SKILL.md` §1.3。
- 若改变了字段、状态、gate、Doctor 行为或其他协议义务，必须 bump `metadata.protocol_version` 并补 [`protocol-upgrades.md`](../../ssot-audit/references/protocol-upgrades.md)。
- `[SHOULD]` 改动前提示用户：若当前操作的是**已安装 skill 副本**（非源仓库），改动不回流源仓库、`install.sh` 重装会丢失。本协议不引入“作者模式”自动分流——由用户在授权时知情承担。

## 7. 落点：嵌入 Session 自检

`[SHOULD]` 主触发点嵌入 [`conversation-audit.md`](../../ssot-audit/references/conversation-audit.md) 的 Session 自检：

- **常驻轻量**：每次 Session 自检顺带做 §3.1 近场探针，只读、记录，不触发重活。
- **按需升级**：当近场探针提示触发不充分，或用户点名“探查触发效果”时，才升级到 §3.2 远场全量消费审查并产出建议。

不引入新的强制独立命令，不在每次会话强制跑远场分析（对齐 `ssot-preflight/SKILL.md` §2.5 context 预算与“不强制每 session 跑 Doctor”的克制传统）。

## 8. 与其他流程的边界

- **vs conversation-audit**：[`conversation-audit.md`](../../ssot-audit/references/conversation-audit.md) 从 transcript 提取知识**写入** SSOT；本文件评估 SSOT **被用得怎样**，反向优化触发侧。两者共用 transcript 定位，方向相反。
- **vs Doctor**：[`doctor.md`](doctor.md) 验**内容**可信；本文件验**触发 / 使用**有效。“读对了面却没用上”若归因为内容问题，转交 Doctor。
- **vs CONSUMPTION 静态检查**：[`ssot-lint.sh`](../assets/scripts/ssot-lint.sh) 检查 9 是 L1 静态链路；本文件是 L4 行为探针。L1 通过是 L4 有效的前置必要条件。
