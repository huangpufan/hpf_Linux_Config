# 关键旅程

<!-- 模板实例化说明：写入渲染后的 SSOT 文件前，必须把标题、表格标签、占位符和辅助说明翻译为 Phase 0 或 STATUS.md 锁定的 documentation_language。代码标识符、路径、命令、API 名、枚举值和直接引用保持原文。 -->

> 跨域旅程视角。本文件解释应指导设计决策的端到端用户/运行路径。它必须包含叙述性的意图和验收信号，不能只有流程表。

## 范围

- **负责**：主要用户/操作者旅程、运行业务闭环、阶段生命周期、跨域总览图、验收和恢复信号。
- **不负责**：具体状态/资源细节或 domain 内契约；这些应链接到 domains。
- **主要 源资料**：

## 为什么这个视角存在

用 1-3 段说明哪些旅程决定系统是否有用。用户/操作者视角和系统视角不一致时，分别命名。

## 叙述 / 模型

在列出 flows 之前，用自然语言解释旅程模型。说明哪个旅程是设计锚点，以及未来变更应如何据此判断。

## 设计意图 / 约束

| 意图或约束 | 适用旅程 | 为什么重要 | 证据 / 来源 |
|---|---|---|---|
| | | | |

## 旅程总览

- **主要旅程**：
- **次要旅程**：
- **关键失败旅程**：
- **明确不在范围内的旅程**：

## 旅程图

> Mermaid 代码块是权威内容。此处使用总览图；domain-specific subflows 放入 domain README。

### 外部旅程图候选

> 外部生成图、截图、IDE 依赖图和自动 dependency graph 只作为候选。吸收时必须重写为 current 或 target Mermaid 旅程图，并链接负责各阶段的 domains。

| 候选图来源 | 建议权威 Diagram ID | 旅程 / 阶段 | 需验证内容 | 候选状态 |
|---|---|---|---|---|
| | | | | pending / converted / rejected / obsolete |

### `<JOURNEY-...-CURRENT>`

- **状态**: `current`
- **覆盖内容**:
- **证据**:

```mermaid
sequenceDiagram
  participant Actor
  participant System
  participant Domain
  Actor->>System: <intent>
  System->>Domain: <cross-domain step>
  Domain-->>System: <state/result>
  System-->>Actor: <visible outcome>
```

## 主要旅程

| 旅程 | 用户/运行意图 | 被触发的设计约束 | 验收信号 | Domains |
|---|---|---|---|---|
| | | | | |

## 失败 / 恢复旅程

| 失败旅程 | 检测信号 | 预期恢复 / 降级 | 必须可观测的内容 | Domains / tests |
|---|---|---|---|---|
| | | | | |

## 验收标准

| 标准 | 适用对象 | 所需证据 | 频率 / 触发条件 |
|---|---|---|---|
| | | | |

## 相关 Domains

| Domain | 负责的旅程阶段 | 负责的状态 / 契约 / 恢复 |
|---|---|---|
| | | |

## 当前 / 目标 / 差距

| 旅程 | 当前行为 | 目标旅程 | Gap / 下一步验证 | 证据 |
|---|---|---|---|---|
| | | | | |

## 证据

| 断言 | 源资料 / 代码 / 运行证据 | 置信度 | 后续动作 |
|---|---|---|---|
| | | verified / documented / inferred / unknown | |
