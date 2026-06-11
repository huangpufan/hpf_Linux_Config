# 当前 / 目标 / 差距

## 范围

- **负责**：全局 current/target/gap、迁移立场和设计缺口。
- **不负责**：具体脚本逻辑与单个工具实现细节。
- **主要源资料**：README、AGENTS、playbook、当前仓库结构

## 为什么这个视角存在

这个仓库已经从“脚本集合”向“agent 可消费的安装系统”迈进了一大步，但还没有演化成一个强 release / ADR / 变更治理齐备的工程产品。Current/Target/Gap 的作用，就是把已经落地的约束和仍然薄弱的长期治理分开，不让后续维护者误以为一切都已经完整制度化。

## 叙述 / 模型

当前实现的主轴已经明确：runner-first、catalog-first、固定路径、check-first 验收。目标不是再搞一套新的入口，而是持续守住这些约束，同时在真正需要的时候补齐 release、decision 和更细粒度 architecture domain。现阶段不应该为了“文档看起来完整”而强行拆出更多层级。

## 设计意图 / 约束

| 意图或约束 | 当前关系 | 为什么重要 | 证据 / 决策 |
|---|---|---|---|
| 安装入口统一 | implemented | 这是整个 agent-first 模型的根基 | README、AGENTS、playbook |
| 发布治理轻量化 | implemented | 仓库主要交付本地配置，不是版本化服务 | 当前目录与文档事实 |
| 支线能力按需成域 | pending | 防止过度文档化 | 当前架构拆分判断 |

## 迁移立场

- **当前基线**：安装入口与工具目录统一，agent 使用路径明确。
- **目标设计**：继续保持单一安装入口与可验证 catalog；在出现更多独立状态边界前不做过度拆分。
- **最高优先级 gaps**：release 规则稀薄、独立决策条目少、`nvim/` 研究与配置仍属支线。
- **当前阶段非目标**：把仓库做成多 domain 大型系统；为不存在的部署/发布流程补过多样板。
- **风险容忍 / 回滚立场**：宁可保留 gap，也不编造未证实的治理事实。

## 当前 / 目标 / 差距 矩阵

| 区域 | 当前事实 | 目标意图 | Gap / 阻塞项 | 权威 owner | 证据 |
|---|---|---|---|---|---|
| 安装入口 | `agent-runner.py` + `agent-tools.json` 已是主入口 | 长期保持 runner-first | 未来变更若绕过 runner 会破坏约束 | domain | verified |
| 架构拆分 | 1 个核心 domain 已足够表达主干 | 只在出现独立状态/契约边界时再细分 | `nvim/` 是否独立成域尚无必要 | architecture | inferred |
| 发布流程 | 无正式 release 流水线证据 | 需要时再显式补齐 | 当前只能记录现状 | release | verified |
| 决策沉淀 | 多数长期约束仍在 README/AGENTS | 后续高影响变更应转入 decisions | 当前条目不足 | decisions | verified |

## 部分落地的设计意图

| 意图 | 落地状态 | 缺失部分 | 决策 / 来源 | 所需裁决 |
|---|---|---|---|---|
| 全部安装任务走统一流程 | implemented | 无 | README、AGENTS、playbook | 无 |
| 更系统化的发布/决策治理 | pending | 规则、脚本、版本策略 | 当前仓库无直接证据 | 暂不需要 |

## 被拒绝的替代方案 / 不要复活

| 旧形态或被拒绝方案 | 为什么拒绝 | 替代方向 | 执行位置 |
|---|---|---|---|
| 先翻历史脚本再决定怎么装 | 会让 agent 行为漂移且难验证 | 先读 playbook 与 catalog | development / gotchas |
| 把 direct scripts 当默认入口 | 失去统一校验和日志 | runner-first | operating-model / domain |

## 开放设计问题

| 问题 | 为什么重要 | 何时需要 | 当前默认 | 链接 |
|---|---|---|---|---|
| `nvim/` 是否未来要成独立 domain | 影响架构粒度与阅读入口 | 当 Neovim 配置继续独立演进时 | 先保持支线，不独立成域 | tech-debt |
| 是否需要正式 release 规则 | 影响版本与对外交付 | 仓库开始稳定打 tag/发布时 | 当前视为 not_applicable/gap | release |

## 相关 Domains

| Domain | Current / target 职责 | Gap 链接 |
|---|---|---|
| installation-runtime | 当前和目标都负责维持统一入口与验收 | 无阻塞 gap |

## 证据

| 断言 | 源资料 / 代码 / 运行证据 | 置信度 | 后续动作 |
|---|---|---|---|
| 当前最可靠的长期主轴是 runner/catalog 体系 | README、AGENTS、playbook、catalog | verified | 后续改动应优先守住这条主轴 |
| release/decision 区域仍薄 | 仓库当前没有对应重型证据 | verified | 日后需要时再增长 |
