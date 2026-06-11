# 更新路由参考

本文件是影响面分级、文件类型到区域映射、对话信号到区域映射、级联检查和决策推翻检查的语义所有者。内联更新、commit 审查和 conversation 审查都引用本文件，不各自维护映射副本。

## 目录

- [1. 影响面分级](#1-影响面分级)
- [2. 文件类型到区域映射](#2-文件类型到区域映射)
- [3. 对话信号到区域映射](#3-对话信号到区域映射)
- [4. 级联检查](#4-级联检查)
- [5. 决策推翻专项检查](#5-决策推翻专项检查)

## 1. 影响面分级

在执行更新前，先快速判断变更的影响面。影响面决定检查深度：

| 影响面 | 特征 | 检查深度 |
|---|---|---|
| trivial | 格式调整、注释修改、typo 修正、纯重构（不改行为） | 通常不需要更新 SSOT。例外：重命名了架构域、入口路径、Diagram ID 或 权威来源 指针 → 检查 architecture/。若本次要记录为 `no-op` / `无需更新`，仍需 停止审查。 |
| localized | 单文件或单一架构域内的实现变更 | 检查对应 architecture domain 或卫星区域。如修改了 API handler → 检查对应 domain 的跨边界契约和 flow diagram。 |
| cross-cutting | 跨架构域、跨层级、架构性变更 | 检查 architecture root/views/domains，并执行级联检查。 |

这是粗分级指南，不是精确分类。Agent 应基于变更的实际影响判断，不必机械对号入座。

## 2. 文件类型到区域映射

从代码或文件变更推导受影响的区域：

| 变更涉及的文件类型 | 可能受影响的区域 |
|---|---|
| 源代码（新增/删除/移动文件或目录） | architecture/（设计单元、边界、依赖关系、decomposition/domain diagram） |
| 源代码（修改导出/公共函数签名） | architecture/（跨边界契约、受影响的 flow/trust diagram） |
| 源代码（修改内部实现逻辑） | 通常无需更新 SSOT，除非涉及专项语义；若内部代码有独立阶段、状态转换、锁、回滚、持久化、契约或失败语义，则更新 运行流 和 Mermaid 图。若 `gotchas/` 索引中有条目的 `触发条件` 匹配当前变更路径，仍应检查该 gotcha 是否需要更新。若据此记录 `no-op` / `无需更新`，仍需停止审查。 |
| 源代码（错误处理/重试/熔断相关） | architecture/（失败恢复模型、failure/recovery diagram） |
| 源代码（认证/授权/权限相关） | architecture/（信任边界/不变量、trust diagram） |
| 源代码（日志/metric/trace 相关） | architecture/（可观测性/验真方式） |
| package manifest / lockfile | development/, architecture/（依赖/运行边界）, release/ |
| 测试文件 / 测试配置 | testing/ |
| CI/CD 配置 | deployment/, release/ |
| Dockerfile / k8s / Terraform / 基础设施代码 | deployment/, architecture/（运行时边界/配置模型） |
| schema / migration / protobuf / OpenAPI spec | architecture/（数据/状态所有权、契约、state/resource diagram） |
| 配置文件 / .env / feature flag | architecture/（配置模型、trust/config diagram）；部署差异同步 deployment/ |
| 监控/告警配置 | architecture/（可观测性/验真方式） |
| README / docs / ADR / runbook / PRD / 其他源资料 | 执行源资料吸收检查：分类为 `absorb`、`link-only`、`stale/conflict` 或 `obsolete`；把长期知识写入 权威位置；同步 `STATUS.md` 源资料吸收；必要时裁定冲突或新增裁决项。 |
| 外部生成图 / 截图 / dependency graph / 自动摘要 | 只作为普通源资料候选或 diagram candidate 处理；事实 claim 必须用代码/配置/schema/test/runtime 交叉验证。图进入权威位置前必须重写为可维护 Mermaid，并补 owner、evidence、current/target/stale。不能只更新源资料矩阵后结束。 |
| 删除旧 surface / 废弃兼容路径 / deprecated concept | architecture/（演进 / 迁移台账；同步 Current / Target / Gap 和 contracts/gotchas/decisions） |
| bug fix commit / hotfix / revert-fix loop | bugs/（critical / major / recurred 必须按 failure mode 粒度检查，不能只写宽泛主题） |

## 3. 对话信号到区域映射

从对话内容推导应写入的区域：

| 对话中出现的模式 | 可能影响的区域 |
|---|---|
| "我们决定用 X 而不是 Y，因为..." / 方案选型讨论 | decisions/ |
| "注意这里不能动，因为..." / "这个坑是..." | gotchas/ |
| "这个 bug 的根因是..." / 调试过程的根因分析 | bugs/ |
| "这个 bug 复发了" / 多次 hotfix/revert 同类问题 | bugs/（按 failure mode 聚类；同症状多根因拆分，同根因复发追加 recurrence timeline） |
| "这是临时方案，之后需要..." / "先这样，以后重构" | tech-debt/ |
| "当前优先 X" / "现阶段非目标 Y" / "成功标准是 Z" | architecture/views/operating-model.md，必要时 current-target-gap 或 decisions/ |
| "这个不能超过 X" / "必须满足 Y" / 约束确认 | architecture/views/operating-model.md 或相关 domain 的 设计约束 / Invariants；必要时 decisions/ |
| "这个设计思路是..." / "为什么这样做..." / "不要回到旧方案..." | architecture/views/current-target-gap.md、相关 domain 的 取舍 / 被拒绝的简化、decisions/ |
| 新术语定义 / 术语含义修正 | glossary/ |
| 系统边界、设计单元、依赖、运行流、状态所有权讨论 | architecture/（目标/主路径/设计意图进 views；状态/契约/失败/验证进 domains；含 必需 Mermaid 图） |
| 测试策略讨论 / 覆盖目标 | testing/ |
| 部署流程讨论 / 环境差异 | deployment/, architecture/（运行时边界/配置模型、trust/config diagram） |
| 安全模型讨论 / 权限设计 / secret 管理 | architecture/（信任边界、trust diagram） |
| 错误处理策略 / 重试/降级讨论 | architecture/（失败恢复模型、failure/recovery diagram） |
| 发布流程讨论 / 版本策略 | release/ |
| 数据模型讨论 / migration 策略 | architecture/（数据/状态所有权、state/resource diagram） |
| 旧方案废弃 / 架构迁移 / 兼容路径退出 / 不要复活某概念 | architecture/（演进 / 迁移台账；不写 loose notes 或顶层 history） |
| 日志策略 / 监控讨论 / 调试路径 | architecture/（可观测性/验真方式） |
| Current/Target 图、流程图、架构图讨论 | architecture/（架构视角 / 图；确保 current/target 分离并补证据） |
| 高频/高风险研发任务入口讨论 | `SSOT/README.md` 的 任务入口映射薄索引（只链接权威位置） |
| 用户显式提供外部资料、规范、PRD、设计说明或历史文档 | 作为源资料做吸收检查；目标/优先级/非目标/成功标准进 operating-model，旅程/验收进 critical-journeys，current-target-gap/迁移意图进 current-target-gap；同步 源资料吸收矩阵。 |

## 4. 级联检查

某些高影响变更会跨区域产生连锁影响。当命中以下场景时，除了更新直接对应的区域，还应检查关联区域集中的条目是否需要同步更新。

| 高影响变更 | 关联区域集 | 检查重点 |
|---|---|---|
| 决策推翻 | 旧决策 `影响范围` 字段中列出的 architecture views/domains 和卫星区域 | 旧决策影响的边界、契约、状态所有权、部署方式、恢复策略等是否过时 |
| 架构域重组（新增/删除/合并/拆分设计单元） | architecture/, gotchas/, tech-debt/ | decomposition_basis 是否变化；decomposition/domain diagram 是否同步；跨域契约是否受影响；相关 gotchas 是否失效 |
| 运行流变更（阶段/顺序/状态转换/资源生命周期调整） | architecture/, testing/ | 运行流 是否新增/删除/改名；flow overview/subflow 图 是否同步；测试 fixture 是否覆盖新路径 |
| 约束变更（新增/放松/废除约束） | architecture/, decisions/ | 是否需要新决策来响应约束变更；旧决策是否因约束放松而可以推翻；current/target diagrams 是否分离 |
| 配置结构变更（新增配置源/重组配置层次） | architecture/, deployment/ | 配置模型、trust/config diagram、部署流程、安全敏感配置是否受影响 |
| 数据模型迁移（schema 变更/存储方式迁移） | architecture/, testing/ | 数据/状态所有权、state/resource diagram、跨边界契约、测试 fixture 是否需要同步修改 |
| 架构迁移 / 删除旧 surface / 废弃兼容路径 | architecture/, gotchas/, decisions/, testing/ | 演进 / 迁移台账 是否记录旧形态、替代形态、兼容状态、禁止复活概念、证据 commit/decision；Current / Target / Gap 和测试是否同步 |
| 安全模型变更（认证/授权重构） | architecture/, gotchas/ | 信任边界、trust diagram、契约认证要求、安全配置、旧 gotchas 是否受影响 |
| 错误处理策略变更（重试/熔断/降级策略调整） | architecture/, deployment/ | 失败恢复模型、failure/recovery diagram、健康检查、监控告警阈值是否需要调整 |

级联流程：

```text
1. 识别当前变更是否命中上表中的某个场景
2. 是 → 遍历关联区域集，逐个检查：该区域中是否有条目引用了本次变更涉及的架构域/文件/概念？
3. 发现过时内容 → 同步更新
4. 未命中任何场景 → 跳过级联，直接更新直接对应的区域即可
```

级联是指南非强制全量扫描。根据变更的实际影响范围定向检查，不必每次遍历全部区域。

## 5. 决策推翻专项检查

当一个决策被推翻时，其影响范围内涉及的区域可能包含过时信息。Agent 应根据旧决策的 `影响范围` 字段检查：

| 旧决策影响了... | 需要检查... |
|---|---|
| 架构边界/设计单元 | architecture/ 对应 domain；必要时同步 视角索引 / Domain 索引、boundary/decomposition diagrams |
| 公共 API/协议/SDK | architecture/ 对应 domain 的跨边界契约；必要时同步 flow/trust diagrams |
| 部署方式/配置模型 | deployment/, architecture/；同步 trust/config diagrams |
| 错误处理策略 | architecture/ 对应 domain 的失败恢复模型；同步 failure/recovery diagrams |
| 安全模型 | architecture/ 对应 domain 的信任边界；同步 trust diagrams |
| gotchas 条目 | gotchas/（相关条目是否应标记为 resolved） |
| bugs 条目 | bugs/（相关条目是否因决策变更而需要标记为 recurred 或更新根因） |
| tech-debt 条目 | tech-debt/（相关条目是否应标记为 resolved/obsolete） |
| 架构约束 | architecture/（operating-model 或 domain 设计约束 / Invariants 是否因此变更或放松；current/target diagrams 是否仍分离） |
| 旧 surface / 兼容路径 / deprecated concept | architecture/（演进 / 迁移台账 是否记录旧形态、替代形态、兼容状态、禁止复活概念和证据 commit/decision） |
| Runtime Flow 或高风险内部流程 | architecture/（运行流 row、Diagram ID、overview/subflow Mermaid 图、evidence 是否同步） |

这是指南而非强制全量扫描。根据旧决策的影响范围定向检查，而非每次都审查全部区域。
