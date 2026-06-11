# Skill 协议升级

本文件是 SSOT Skill bundle 协议版本升级的影响清单。每次 `ssot-preflight/SKILL.md` 顶部 YAML 中的 `metadata.protocol_version` bump 时，必须同步新增对应版本条目；否则该版本发布不完整。

协议升级审查只做影响审查：读取当前项目 `SSOT/STATUS.md` 的 `tracked_skill_version`，对照本文件中尚未应用的版本条目，判断哪些权威位置需要更新。不要机械把项目 SSOT 全量改写成最新模板。

## 目录

- [执行规则](#执行规则)
- [版本台账](#版本台账)
- [v2.17](#v217)
- [v2.16](#v216)
- [v2.15](#v215)
- [v2.14](#v214)
- [v2.13](#v213)
- [v2.12](#v212)
- [v2.11](#v211)
- [v2.10](#v210)
- [v2.9](#v29)
- [v2.8](#v28)
- [v2.7](#v27)
- [v2.6](#v26)

## 执行规则

1. 当前协议版本来自已加载/已安装的 `ssot-preflight/SKILL.md` 顶部 YAML 中的 `metadata.protocol_version`。
2. 项目已应用协议版本来自 `SSOT/STATUS.md` 的 `tracked_skill_version`。
3. 版本比较按 semantic version 的 numeric segment 比较；无法解析时保守执行 audit。
4. `tracked_skill_version` 缺失时按 `unknown/legacy` 处理，执行当前版本的 baseline audit。
5. 对每个未应用版本，按条目中的影响检查清单审查项目 SSOT。
6. 对无影响项明确记录 no-op；对有影响项只更新受影响权威位置。
7. 完成后必须有独立 reviewer 返回 `no-more-required-changes`，才能在 `STATUS.md` 停止审查闸门记录 `protocol-upgrade` / `tracked_skill_version` 并推进水位。

## 版本台账

### v2.17

**升级目标**：把单体 `ssot-skill` 拆成按流程触发的 SSOT Skill bundle。正式入口改为 `ssot-preflight`，负责任务开始前的 STATUS 感知、最小读取路由、协议水位比较和过程中写入触发清单；`ssot-bootstrap`、`ssot-closeout`、`ssot-audit`、`ssot-doctor` 分别承载初始化、变更批次收尾、主动追赶和健康/停止审查；`ssot-skill` 只保留轻量兼容 shim。协议版本唯一权威迁移到 `ssot-preflight/SKILL.md`。

**基线适用范围**：

- `tracked_skill_version` 小于 `2.17` 的项目。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 大于等于 `2.17`，且项目 SSOT 尚未按本条目完成审查。

**影响检查清单**：

| 检查项 | 影响区域 | 审查动作 | 完成标准 |
|---|---|---|---|
| Entry skill rename | 启动适配器、`SSOT/README.md` 任务入口、runtime prompt | 将“任务开始用 `ssot-skill`”更新为 `$ssot-preflight`；旧 `$ssot-skill` 只作为兼容 shim。 | 新任务入口能明确触发 `$ssot-preflight`；无新文档把 shim 当协议 owner。 |
| Lifecycle split routing | 启动适配器、mission prompt、bootstrap prompt、开发流程文档 | 增加 `$ssot-bootstrap`、`$ssot-closeout`、`$ssot-audit`、`$ssot-doctor` 的流程触发点。 | 每个 skill 都有明确触发时机；没有按内容域新增无触发点 skill。 |
| Protocol owner migration | `STATUS.md` 协议水位说明、Doctor/Audit 文本 | 将协议版本来源改为 `ssot-preflight/SKILL.md`。 | `tracked_skill_version` 语义指向 bundle 协议版本，而非旧 `ssot-skill/SKILL.md`。 |
| Open adjudication parser | runtime hooks / preflight 文本 | 规范 canonical heading 为 `## 开放裁决项`，兼容旧 `## 待裁决项`。 | pending 或到期 deferred 能被 preflight/runtime 正确识别。 |
| Install surface | 项目级 skill install | 安装全部 sibling skills，并保留 lightweight `ssot-skill` shim。 | `.codex/skills/` 下存在 5 个正式 skill + shim；source 与 install surface 对齐。 |
| Adapter / core-ref boundary | Doctor / lint / 启动参考文件审查 | 将 thin-adapter 明确为 SSOT-generated 或 SSOT 托管的可选入口形态；手写 / mixed 启动文件不因缺 generated marker 报 `[ADAPTER]`。 | `[ADAPTER]` 只覆盖生成型薄适配器形态；缺 SSOT 路由走 `[CONSUMPTION]`；命令、工作流、架构和测试事实走 `[CORE-REF]`。 |

**Doctor 标签**：

- `[SKILL-SPLIT]`：多 skill bundle 缺少正式入口、流程 skill、shim、版本 owner、或流程触发描述。
- `[SKILL-PROTOCOL]` 继续用于 `tracked_skill_version` 缺失或落后。

**不要求**：

- 不要求引入新的 SSOT 顶层区域、JSON/YAML 状态文件或产品级 Web/API truth。
- 不要求每个流程 skill 单独安装；v2.17 第一阶段按 bundle 一起安装。
- 不要求把所有历史文本机械改名；只修会影响触发、协议水位和运行时提示的权威位置。

### v2.16

**升级目标**：移除旧版外部生成仓库资料表面的所有命名入口、源资料分类和特殊路由。SSOT 保留可读性能力，但这些能力现在都是原生协议：Reader Map 从 architecture decomposition、读者问题和证据生成；claim-to-evidence 是写作标准；脚本/工具目录来自仓库脚本、manifest、CI 和配置；外部生成图、截图、依赖图和自动摘要只作为普通 diagram candidates 或用户显式提供的外部资料候选，不能成为权威结构。

**基线适用范围**：

- `tracked_skill_version` 缺失的 legacy 项目。
- `tracked_skill_version` 小于 `2.16` 的项目。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 大于等于 `2.16`，且项目 SSOT 尚未按本条目完成审查。

**影响检查清单**：

| 检查项 | 影响区域 | 审查动作 | 完成标准 |
|---|---|---|---|
| Legacy generated-knowledge surface cleanup | `SSOT/` 全树、适配器、STATUS 源资料矩阵 | 搜索旧版平行生成目录、旧名称入口、以外部自动主题树为来源的专用矩阵行或路由规则；删除平行权威面，把仍有价值的事实改按普通源资料重新验证并路由。 | 项目 SSOT 不再暴露旧名称或专用目录；没有把外部主题树当作 authority。 |
| Source material scope | `STATUS.md`, `source-material.md` 对应项目副本或本地约定 | 源资料范围只保留 README/docs/ADR/PRD/runbook/design docs/subsystem README/user-provided external material；外部自动摘要只能作为普通外部资料候选。 | 没有专门接受旧版自动知识面的源资料分类、状态或输入说明。 |
| Reader Map provenance | `SSOT/README.md`, `architecture/README.md`, views/domain README | 检查 Reader Map 是否由 decomposition_basis、读者问题、权威位置和证据生成，而不是借用外部主题树。 | Reader Map 只做路由，不承载独立事实；主题来自本仓库架构分解与证据。 |
| Evidence writing standard | architecture views/domains、development/testing/release/deployment | 检查关键 claim 是否按 native claim-to-evidence 写法维护 owner、evidence、why/risk/constraint。 | 关键 claim 有证据和权威 owner；未验证内容写 gap/unknown/not_applicable。 |
| Script/tool inventory provenance | `development/`, `testing/`, `release/`, deployment 相关区域 | 检查脚本/工具目录是否来自仓库 scripts、package manifest、CI、Makefile、配置或实际运行验证。 | 脚本清单不来自外部自动摘要的未验证复制；用途、前置条件和风险有证据。 |
| Generic diagram candidate governance | architecture root/views/domains | 检查外部生成图、截图、IDE 依赖图或自动 dependency graph 是否只作为候选，并重写为可维护 Mermaid 后才成为权威图。 | 外部图不直接支撑 covered；权威图有 Diagram ID、Status、Covers、evidence 和 owner。 |

**Doctor 标签**：

- `[LEGACY-SURFACE]`：仍存在旧版平行生成知识面、旧名称入口、专用源资料分类，或把外部主题树/自动摘要当作权威结构。
- 复用 `[READER-MAP]`、`[READABILITY]`、`[DIAGRAM]`：分别检查原生 Reader Map、可读权威正文和通用 diagram candidate 治理。

**不要求**：

- 不要求迁移脚本；协议升级审查足够。
- 不要求机械重写所有既有 SSOT 文件到最新模板。
- 不要求主动抓取任何外部生成资料。
- 不新增 SSOT 区域、STATUS 字段、schema 或生成器。

### v2.15

**升级目标**：补上「核心参考文档」审查切片，并建立 SSOT 可读性协议。`AGENTS.md`、`CLAUDE.md`、`.cursor/rules`、`.windsurf/rules`、`GEMINI.md` 等启动即读 / Agent rules 文件不能只按薄适配器结构检查；凡承载仓库约束、命令、目录地图、工作流、架构边界、模型/配置规则或测试策略，必须作为源资料和核心参考文档持续审查。新增 `STATUS.md` 的 核心参考文档审查 表；新增 Doctor `[CORE-REF]` L1/L2 检查。新增 Reader Map / 快速理解地图用于入口路由，新增 Readable Authority / 可读权威正文要求正文用短叙述、claim、evidence、why、风险和约束建立心智模型；claim-to-evidence 成为关键断言写作标准；脚本/工具目录进入工程操作区域；外部生成图、截图和依赖图只作为 diagram candidates。`[ADAPTER]` 继续只负责薄适配器文件形态，`[CONSUMPTION]` 继续负责 SSOT 触发链路。不新增 SSOT 顶层区域，不修改 `ssot-lint.sh` 的语义边界。

**基线适用范围**：

- `tracked_skill_version` 缺失的 legacy 项目。
- `tracked_skill_version` 小于 `2.15` 的项目。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 大于等于 `2.15`，且项目 SSOT 尚未按本条目完成审查。

**影响检查清单**：

| 检查项 | 影响区域 | 审查动作 | 完成标准 |
|---|---|---|---|
| 核心参考文档盘点 | `STATUS.md` | 查找 `AGENTS.md`、`CLAUDE.md`、`.cursor/rules/*`、`.windsurf/rules/*`、`GEMINI.md` 或等价启动参考文件；在 核心参考文档审查 表中逐项记录。 | 存在即入表；无文件且项目无 harness 要求时记 `not_applicable`。 |
| 源资料分类 | 源资料吸收矩阵 / 对应权威位置 | 对含长期事实的启动参考文件按 [`source-material.md`](../../ssot-preflight/references/source-material.md) 分类；长期事实吸收到 architecture/development/testing/decisions 等唯一权威位置。 | 有长期事实时完成 absorb / link / conflict 记录；纯薄适配器可 no-op。 |
| 事实正确性审查 | 核心参考文档本身 | 将文件中的命令、目录地图、工作流状态、架构约束、模型/配置规则、测试策略与代码、manifests、Makefile/CI、SSOT 和当前协议比对。 | 每项给出 `update-doc` / `thin-adapterize` / `absorb-to-SSOT` / `record-conflict` / `no-op`；不得静默吸收漂移。 |
| `[ADAPTER]` / `[CONSUMPTION]` / `[CORE-REF]` 分工 | Doctor / adapter strategy | 确认 `[ADAPTER]` 只覆盖 marker、行数、可选 source hash 和摘要边界；`[CONSUMPTION]` 覆盖 SSOT 触发链路；`[CORE-REF]` 覆盖事实正确性。 | Doctor 输出能区分文件形态、触发链路和事实问题。 |
| 脚本边界 | `ssot-lint.sh` 使用方式 | 不把命令/工作流/架构事实语义判断塞进确定性 lint。 | 现有脚本可继续跑；无脚本改动时记 no-op。 |
| Reader Map / 快速理解地图 | `SSOT/README.md`, `architecture/README.md`, `architecture/views/README.md`, domain README | 检查入口是否只链接权威位置，不承载独立长期事实；root 是否能一眼给出读者问题、权威位置、关键证据和风险。 | 入口能快速路由读者；过时、断链或写成第二事实源时修正或标 gap。 |
| Readable Authority / 可读权威正文 | architecture views/domains 和适用的工程操作区域 | 检查正文是否只有表格/清单；关键 claim 是否有 evidence、owner、why/risk/constraint；证据不足时是否写 `gap` / `unknown` / `not_applicable`。 | 正文先有短叙述，再有表格证据；不能为了填满模板编造。 |
| Claim-to-evidence writing | architecture views/domains 和适用的工程操作区域 | 检查关键 claim 是否有稳定 evidence links、owner、why/risk/constraint；证据不足时是否写 `gap` / `unknown` / `not_applicable`。 | 关键 claim 可追溯；不能只写结论或空泛总结。 |
| Diagram candidate governance | architecture root/views/domains | 检查外部生成图、截图或依赖图是否只作为 diagram candidate；权威图是否为 Mermaid fenced block，且有 metadata、evidence、状态和 current/target 分离。 | required diagram 缺失、外部图直接当权威图、无 evidence 或 current/target 混用时，相关范围不能标 `covered`。 |
| Engineering script inventory | `development/`, `testing/`, `release/`, deployment 相关区域 | 若源资料或代码显示脚本/工具清单，检查是否按工程区域吸收，必要时链接回 architecture owner。 | development/testing/release 使用新版清单字段；脚本清单不堆进 architecture root。 |
| Doctor 语义检查 | Doctor 输出, `STATUS.md` | 增加或等价执行 `[READER-MAP]`、`[READABILITY]`、扩展 `[DIAGRAM]` 检查。 | stale 项已修复、裁决或记录 no-op；通过后才允许推进 `tracked_skill_version`。 |

**Doctor 标签**：

- `[CORE-REF]`：核心参考文档缺少 STATUS 盘点，或其中的命令、目录地图、工作流状态、架构约束、模型/配置规则、测试策略与代码/SSOT/协议不一致。
- `[READER-MAP]`：入口地图缺失、过时、指向非权威位置，或在入口中承载独立长期事实。
- `[READABILITY]`：正文只有表格/清单，缺少一句话结论、why/risk/constraint、owner 或 evidence。
- `[DIAGRAM]`：继续覆盖 required Mermaid 图缺失、状态/evidence 不足、current/target 混用；新增外部生成图、截图或依赖图被直接当作权威图的场景。

**No-op 标准**：

- 项目没有核心参考文档，且没有某 harness 必需启动文件的项目约束；`STATUS.md` 记录 `not_applicable` 即可。
- 核心参考文档已是薄适配器，`[ADAPTER]` 文件形态合规、`[CONSUMPTION]` 静态链路合规，且不含独立长期事实；核心参考文档审查 表记录 `covered / thin-adapter / no-op`。
- 文件含长期事实，但本次审查已确认与代码、SSOT 和协议一致，且权威关系与建议动作记录清楚；可记 `covered`。

**不要求**：

- 不要求新增 `SSOT/core-reference/` 或其他顶层区域。
- 不要求机械替换用户手写的 `AGENTS.md` / `CLAUDE.md`；默认产出具体修改建议，只有用户授权或任务明确要求时才改启动文件本身。
- 不要求把 `[CORE-REF]` 语义检查自动化进 `ssot-lint.sh`。
- 不要求为没有对应 harness 的项目创建启动文件。
- 不要求为小型仓库编造复杂 Reader Map 或图；证据不足时写 `gap` / `unknown` / `not_applicable`。
- 不新增顶层平行知识区域、新 schema、新 STATUS 字段或生成器。
- 不要求主动抓取外部生成资料；只有用户显式提供资料时才按普通源资料处理。

### v2.14

**升级目标**：补上「触发 / 消费侧」行为反馈闭环——兑现协议自 v2.13 起承诺、却从未定义的 L4 行为层探针（[`ssot-lint.sh`](../../ssot-doctor/assets/scripts/ssot-lint.sh) 第 294 行注释、[`doctor.md`](../../ssot-doctor/references/doctor.md) CONSUMPTION 检查项的悬空引用）。新增 [`consumption-audit.md`](../../ssot-doctor/references/consumption-audit.md) 作为触发侧验真的语义所有者：从真实对话 transcript 探查 SSOT 是否被触发与用上，定位失败环节，产出触发改进建议。所有优化动作默认只出建议、用户授权后才改。不新增 SSOT 区域、不新增 STATUS 字段、不引入生成器或脚本化 LLM 调用。

**基线适用范围**：

- `tracked_skill_version` 缺失的 legacy 项目。
- `tracked_skill_version` 小于 `2.14` 的项目。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 为 `2.14`，且项目 SSOT 尚未按本条目完成审查。

**影响检查清单**：

| 检查项 | 影响区域 | 审查动作 | 完成标准 |
|---|---|---|---|
| 近场触发探查 | Session 自检流程 | 行为由 skill 协议驱动；项目 SSOT 文件本身无需修改。 | 确认 no-op；后续 Session 自检顺带近场探查。 |
| 远场消费审查 | 项目 transcript（按需） | 用户点名或近场信号不足时，按 [`consumption-audit.md`](../../ssot-doctor/references/consumption-audit.md) 扫历史 transcript 评估触发健康度。 | `[MAY]` 启用；未触发记 no-op。 |
| 触发侧优化建议 | 项目适配器 / `SSOT/README.md` 导航 / skill 本体 | 默认只产出建议；用户授权后才改对应文件。改 skill 本体需独立停止审查 + 视情况 bump 版本。 | 无授权时只记录建议、记 no-op；有授权时按归因层级改并记录停止审查。 |
| L4 引用闭环 | `doctor.md` / `ssot-lint.sh` 注释 | 行为由 skill 协议驱动；项目 SSOT 无需修改。 | 确认 no-op。 |

**Doctor 标签**：

- 复用既有 `[CONSUMPTION]`：L1 静态链路断裂仍由它标记；L4 行为层归因与触发侧优化走消费审查，不新增标签。

**不要求**：

- 不要求每次 Session 都跑远场 transcript 分析（近场探查零成本常驻，远场按需）。
- 不要求自动改写任何触发侧文件；默认只出建议。
- 不新增 SSOT 区域、STATUS 字段或必须创建的文件。
- 不要求为没有 transcript 可得的 harness 强行做远场探查；定位失败时降级记录。

### v2.13

**升级目标**：基于外部项目记忆系统研究，做工程化加固——把协议中本可机械判断的检查收敛进 `ssot-lint.sh`，并补足四类防腐能力：（1）写入前冲突 / 否定扫描；（2）证据指针符号锚（`path#symbol`）抗代码移动；（3）薄适配器源 hash 漂移检测；（4）SSOT 消费链路验证。所有变更不新增 SSOT 区域、不新增 STATUS 字段、不引入生成器或索引层。

**基线适用范围**：

- `tracked_skill_version` 缺失的 legacy 项目。
- `tracked_skill_version` 小于 `2.13` 的项目。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 为 `2.13`，且项目 SSOT 尚未按本条目完成审查。

**影响检查清单**：

| 检查项 | 影响区域 | 审查动作 | 完成标准 |
|---|---|---|---|
| 写入冲突 / 否定扫描 | SKILL.md §3.1 写入前置 | 行为由 skill 协议驱动；项目 SSOT 文件本身无需修改。 | 确认 no-op；后续写入按新前置执行。 |
| 证据指针符号锚 | 含 `evidence: path:line` 的 confidence frontmatter | 旧行号指针不要求机械迁移；遇到失效行号时改为 `path#symbol`。详见 [`knowledge-integrity.md`](../../ssot-preflight/references/knowledge-integrity.md) §5.1。 | 无失效指针时 no-op；有失效时顺手改符号锚。 |
| gotcha 可执行契约 | `gotchas/` | 检查 active gotcha 是否成对给出 “不要做 / 改做什么”。 | 高风险条目补全可执行规避；通用条目可不补。 |
| 适配器源 hash 行 | AGENTS.md / CLAUDE.md 等适配器 | 若项目使用薄适配器，可在 marker 增加 `SSOT-source: <path>@<hash>` 行启用漂移检测。详见 [`adapter-strategy.md`](../../ssot-doctor/references/adapter-strategy.md) §2-§3。 | `[MAY]` 启用；未启用记 no-op，不强制。 |
| 消费链路 | 适配器 + `SSOT/README.md` | 检查适配器是否含 SSOT 读取指令并路由到 SSOT、README 导航入口是否存在。 | 缺路由 / 入口时补齐；否则 no-op。 |
| ssot-lint 检查 6-9 | 项目 CI / Doctor 流程 | 可使用扩展后的 [`assets/scripts/ssot-lint.sh`](../../ssot-doctor/assets/scripts/ssot-lint.sh) 自动化新增 L1 检查。 | `[MAY]` 引入 CI / Doctor 前置；脚本从 skill 路径调用，无需复制。 |

**Doctor 标签**：

- `[CONSUMPTION]`：SSOT 消费链路断裂——适配器未路由到 SSOT、SSOT 路径不可达，或缺少 README 导航入口。

**不要求**：

- 不要求机械迁移既有 `path:line` 证据指针为符号锚。
- 不要求为所有 gotcha 补全可执行契约（高风险优先）。
- 不要求为薄适配器启用源 hash 行（`[MAY]`）。
- 不新增 SSOT 区域、STATUS 字段或必须创建的文件。

### v2.12

**升级目标**：基于 sisyphus SSOT 实例化效果反馈，做三项治理改进——（1）协议规则分层 MUST/SHOULD/MAY，降低 Agent 高负荷任务下的执行门槛；（2）独立停止审查闸门增加 `self-reviewed` 降级路径，中影响范围允许 updater 自审并明确记录；（3）STATUS.md 覆盖状态表禁止维护可派生信息（条目计数等），消除整类同步漂移。

**基线适用范围**：

- `tracked_skill_version` 缺失的 legacy 项目。
- `tracked_skill_version` 小于 `2.12` 的项目。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 为 `2.12`，且项目 SSOT 尚未按本条目完成审查。

**影响检查清单**：

| 检查项 | 影响区域 | 审查动作 | 完成标准 |
|---|---|---|---|
| 协议级别约定 | SKILL.md 引用方式 | Agent 读 SKILL.md 时识别 `[MUST]`/`[SHOULD]`/`[MAY]` 标记；项目 SSOT 文件本身不需要标注。 | 行为变更由 skill 协议驱动，无需修改项目 SSOT 文件；确认 no-op。 |
| self-reviewed 路径 | STATUS.md 停止审查闸门 | 检查现有停止审查表是否有应标 `self-reviewed` 但被遗漏的条目。 | 历史条目按 `reviewer` 字段实际记录的内容保留；新条目按 §1.3 区分使用。 |
| 备注列去冗余 | STATUS.md 覆盖状态表 | 检查 `区域 / 状态 / 备注` 表的备注列是否维护了可派生信息（条目计数、子目录条目状态、最近测试结果）。 | 含冗余信息时，改为指向子目录 README 的纯指针；备注只保留独有语义。详见 [`status-protocol.md`](../../ssot-preflight/references/status-protocol.md) §3.0。 |
| Legacy 模式设计意图最小补偿 | 走 legacy direct child-domain 路线的 `architecture/README.md` | 检查 root README 是否包含 `设计简报`、`核心不变量`、`Current / Target / Gap 摘要` 三节。 | 缺失任一节时，使用 `[MUST]` 标记补齐，至少给出最小叙述；不强制建立 `architecture/views/` 目录。详见 [`architecture.md`](../../ssot-preflight/references/architecture.md) §2.1。 |
| Bootstrap recon 归档 | Bootstrap Phase 4 清理流程 | 检查是否有未来 bootstrap 会执行的清理动作；已 bootstrap 完成的项目 recon.md 已被删除时，无需补救。 | 新 bootstrap 走改进后的归档路径（recon.md → `decisions/0000-bootstrap-recon.md`）。已完成项目记录 no-op。详见 [`bootstrap.md`](../../ssot-bootstrap/references/bootstrap.md) §5。 |
| ssot-lint 脚本可用性 | 项目 CI / Doctor 流程 | 检查项目是否可使用 `assets/scripts/ssot-lint.sh` 自动化 L1 检查。 | `[MAY]` 引入到 CI 或 Doctor 前置 gate；脚本本身无需复制到项目，可直接从 skill 路径调用。详见 [`doctor.md`](../../ssot-doctor/references/doctor.md) §2.1。 |

**不要求**：

- 不要求遍历所有历史停止审查条目补标 `self-reviewed`。
- 不要求新增任何 SSOT 文件或目录。
- 不引入新的必须创建的文件或区域。

### v2.11

**升级目标**：引入知识完整性协议（confidence 状态机）、分层验真协议（Doctor L1/L2）和薄适配器协议（AGENTS.md/CLAUDE.md 生成规范），形成知识创建→验证→生态适配的闭环治理。

**基线适用范围**：

- `tracked_skill_version` 缺失的 legacy 项目。
- `tracked_skill_version` 小于 `2.11` 的项目。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 为 `2.11`，且项目 SSOT 尚未按本条目完成审查。

**影响检查清单**：

| 检查项 | 影响区域 | 审查动作 | 完成标准 |
|---|---|---|---|
| 知识完整性协议 | 所有含 `confidence: inferred` 或 `needs_verification: true` 的 SSOT 文件 | 检查是否存在旧格式的 confidence 标注。旧 `inferred` 视为 `candidate` 的等价表达，不要求机械迁移。 | Agent 遇到旧格式时按等价关系处理；无旧格式时记录 no-op。 |
| confidence 写入位置合规 | architecture views/domains 权威正文 | 检查 architecture views/domains 中是否存在 `confidence: hypothesis` 的内容。 | hypothesis 内容迁移到 gotchas（标来源）或 STATUS.md 开放缺口；无此类内容时记录 no-op。 |
| confidence 阻断 covered | STATUS.md 覆盖状态表 | 检查标为 `covered` 的区域内是否存在 `confidence: hypothesis` 或 `candidate`。 | 存在则降级覆盖状态为 `gap`；不存在时记录 no-op。 |
| Doctor L1/L2 分层 | Doctor 检查流程 | 确认 Doctor 执行时按 L1→L2 顺序运行，并包含 `CONFIDENCE` 和 `ADAPTER` 检查项。 | 读取行为由 skill 协议驱动，无需修改项目 SSOT 文件；确认 no-op。 |
| 薄适配器审查 | AGENTS.md、CLAUDE.md、.cursor/rules 等 | 检查项目是否存在 Agent harness 指令文件。若存在且含独立长期事实，建议迁移到 SSOT 并替换为薄适配器。 | 有此类文件时记录迁移建议或 no-op（若文件已是薄适配器或不存在）。不要求强制替换用户手写的 Agent 指令文件。 |

**不要求**：

- 不要求机械遍历所有 SSOT 文件替换旧 confidence 格式。
- 不要求强制替换用户已有的 AGENTS.md/CLAUDE.md 为薄适配器。
- 不要求为没有 Agent 指令文件的项目创建适配器。
- 不引入新的必须创建的文件或区域。
- 不要求机械重写既有 SSOT 文件。

### v2.10

**升级目标**：丰富研发全流程 Agent 使用场景的记忆覆盖——让 Agent 不仅能理解架构和流程，还能正确地写出风格一致的代码、在操作前主动检查匹配的陷阱、理解测试存在的防御性理由，并在 bootstrap 时主动发现外部集成点的 quirks。本次变更不新增区域、不引入硬阻断，只细化现有区域的内容要求和路由规则。

**基线适用范围**：

- `tracked_skill_version` 缺失的 legacy 项目。
- `tracked_skill_version` 小于 `2.10` 的项目。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 为 `2.10`，且项目 SSOT 尚未按本条目完成审查。

**影响检查清单**：

| 检查项 | 影响区域 | 审查动作 | 完成标准 |
|---|---|---|---|
| development/ 开发约定 | `development/` | 检查项目是否存在超出 linter 覆盖的编码约定、端到端骨架流程或 Agent 操作前置条件。 | 有此类知识时记录模式语言、骨架流程和前置条件；无此类知识时记录 no-op。不要求编造不存在的约定。 |
| gotchas/ 触发条件 | `gotchas/` | 检查现有 `active` 状态的 gotcha 条目，是否可以为其补充 `触发条件` 字段以实现精准路由。 | 对高风险 gotcha 补充触发条件；对通用性陷阱可不补充。新增 gotcha 时推荐包含触发条件。 |
| testing/ 防御性测试来源 | `testing/` | 检查 `bugs/` 中是否存在 `critical` / `major` / `recurred` 条目，且对应的防御性测试可被识别。 | 有此类 bug 时在 testing/ 补充防御性测试来源小节；无此类 bug 时记录 no-op。 |
| bootstrap 外部依赖探索 | bootstrap 证据来源图（仅影响新 bootstrap） | 确认 bootstrap 证据来源图已包含外部依赖/集成行。 | 已包含；对既有项目 SSOT 无需修改。 |
| 读取路由更新 | `SSOT/README.md`（任务入口映射，如存在） | 确认 Agent 的读取流程是否已按新规则路由：新增功能时读 development/ 模式语言，gotcha 触发条件匹配时主动下钻。 | 读取行为由 skill 协议驱动，无需修改项目 SSOT 文件；确认 no-op。 |

**不要求**：

- 不要求为所有 gotcha 条目强制补充触发条件（字段是推荐而非必需）。
- 不要求为没有编码约定的项目编造 development/ 的模式语言内容。
- 不要求回溯性地为所有历史 bug 建立 testing/ 的防御性测试来源。
- 不引入新的 Doctor 硬阻断；本次新增字段均为可选/推荐。
- 不要求机械重写既有 SSOT 文件。

### v2.9

**升级目标**：把 architecture views 从可选的吸收槽升级为 SSOT 的设计意图层，避免 architecture 退化成表格化审计目录。新协议要求 root 设计简报、view 叙述、domain 设计意图、约束和取舍，并让 Doctor 阻断 表格化 architecture 覆盖。

**基线适用范围**：

- `tracked_skill_version` 缺失的 legacy 项目。
- `tracked_skill_version` 小于 `2.9` 的项目。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 为 `2.9`，且项目 SSOT 尚未按本条目完成审查。

**影响检查清单**：

| 检查项 | 影响区域 | 审查动作 | 完成标准 |
|---|---|---|---|
| Root 设计简报 | `architecture/README.md` | 检查 root 是否用自然语言说明使命、受众、优化优先级、当前优先级、非目标、成功标准和 未来 Agent 必须保持的内容。 | Root 不是纯表格或纯索引；能在 1 分钟内说明设计立场。 |
| 设计意图 views | `architecture/views/operating-model.md`, `critical-journeys.md`, `current-target-gap.md` | 对 PRD、设计文档、历史架构说明中的目标、优先级、非目标、验收标准、主路径和部分落地意图做吸收检查。 | 有相关源资料时，设计意图进入 views；无资料时记录 gap/unknown，不编造。 |
| Domain 设计意图区块 | `architecture/domains/` 或 legacy direct child domains | 检查每个 domain 是否说明 设计意图、设计约束、取舍 / 被拒绝的简化 和 未来 Agent 必须保持的内容。 | Domain 能解释为什么该边界存在、不能破坏什么、哪些捷径被拒绝。 |
| 表格化 architecture 防护 | architecture root/views/domains | 检查 architecture 是否主要由表格组成，缺少设计叙述。 | 表格只作为索引/证据账本；设计判断必须有自然语言叙述。 |
| 源资料吸收矩阵 | `STATUS.md` | 检查源资料吸收是否覆盖本次用于设计层审查的 PRD/docs/ADR/runbook/用户资料。 | 资料有分类、权威位置、吸收状态、冲突/裁决项。 |
| Doctor 检查 | Doctor 输出, `STATUS.md` | 增加或等价执行 `[DESIGN-INTENT]` 检查。 | stale 项已修复、裁决或记录 no-op；通过后才允许推进 `tracked_skill_version`。 |

**Doctor 标签**：

- `[DESIGN-INTENT]`：root/view/domain 缺少设计意图、优先级、非目标、成功标准、约束或取舍叙述，或主要由表格组成。

**不要求**：

- 不要求机械迁移已有 direct child-domain 项目到 `views/ + domains/`。
- 不要求新增顶层 `SSOT/design/`。
- 不要求为没有源资料或证据的项目编造设计目标；应记录 gap/unknown。
- 不要求把所有既有 SSOT 文件改写成最新模板，只更新受影响权威位置。

### v2.8

**升级目标**：把 architecture 从巨型 root README / 同质 direct child-domain 表格升级为 Views + Domains 协议；明确源资料的设计吸收路由，并把吸收状态长期记录到 `STATUS.md`。

**基线适用范围**：

- `tracked_skill_version` 缺失的 legacy 项目。
- `tracked_skill_version` 小于 `2.8` 的项目。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 为 `2.8`，且项目 SSOT 尚未按本条目完成审查。

**影响检查清单**：

| 检查项 | 影响区域 | 审查动作 | 完成标准 |
|---|---|---|---|
| 架构结构兼容性 | `architecture/README.md`, `architecture/views/`, `architecture/domains/`, legacy direct child domains | 判断项目是 single-level、legacy direct child-domain，还是 views/domains。 | 旧结构保持兼容；不机械迁移。新 bootstrap 或用户要求重组时采用 `views/ + domains/`。 |
| Root 架构入口 | `architecture/README.md` | 检查 root 是否能快速说明 系统原则 / 运行模型、主要旅程、核心不变量、视角索引、Domain 索引 和 Current / Target / Gap 摘要。 | Root 不是纯链接页，也不是完整审计报告；长 flow/state/failure 细节下沉到 views/domains。 |
| Views 权威位置 | `architecture/views/` | 对 PRD、设计文档、历史架构说明中的系统目标、运行哲学、用户/运行主路径、critical journeys、current-target-gap 做吸收检查。 | 有相关源资料时，目标/哲学/主路径进入 operating-model，端到端流程进入 critical-journeys，全局差距进入 current-target-gap；无资料时记录 gap/unknown。 |
| Domain 权威位置 | `architecture/domains/` 或 legacy direct child domains | 检查状态/资源所有权、锁、契约、失败恢复、验证证据是否在 domain README，而非堆在 root 或 docs。 | 每个 domain 有 `why separate` + independence signal；状态/契约/失败/验证细节有 evidence 和 diagrams。 |
| 源资料吸收矩阵 | `STATUS.md` | 检查是否存在源资料吸收表，并覆盖已读取或变化的 README/docs/ADR/runbook/PRD/用户资料。 | 每份资料有分类、权威位置、吸收状态、冲突/裁决项；`stale/conflict` 不能只标记后跳过。 |
| 禁止顶层 design 分裂 | `SSOT/` | 检查是否新增或依赖 `SSOT/design/` 等平行设计权威面。 | 不新增顶层 design；设计事实归入 architecture views/domains、decisions、bugs、gotchas、testing 等权威位置。 |
| Doctor 检查 | Doctor 输出, `STATUS.md` | 增加或等价执行 `[ARCH-ROOT]`、`[ARCH-VIEWS]`、`[ARCH-DOMAINS]`、`[SOURCE]` 检查。 | stale 项已修复、裁决或记录 no-op；通过后才允许推进 `tracked_skill_version`。 |

**Doctor 标签**：

- `[ARCH-ROOT]`：architecture root 不能建立快速心智模型，或把所有细节堆在 root。
- `[ARCH-VIEWS]`：系统目标、运行哲学、critical journeys 或 current-target-gap 仍停留在 源资料，未进入 views。
- `[ARCH-DOMAINS]`：状态/资源/契约/失败/验证细节未进入 domain 权威位置，或 domain 缺少有效性证据。
- `[SOURCE]`：源资料中的长期事实未吸收，或 `stale/conflict` 只标记未处理。

**不要求**：

- 不要求机械迁移已有 direct child-domain 项目到 `views/ + domains/`。
- 不要求新增顶层 `SSOT/design/`。
- 不要求为没有相关源资料的项目编造 view 内容；应记录 gap/unknown。

### v2.7

**升级目标**：把项目 文档语言锁 纳入 SSOT 协议状态，确保所有 SSOT Markdown 使用项目已有文档语言或用户明确选择的语言。

**基线适用范围**：

- `tracked_skill_version` 缺失的 legacy 项目。
- `tracked_skill_version` 小于 `2.7` 的项目。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 为 `2.7`，且项目 SSOT 尚未按本条目完成审查。

**影响检查清单**：

| 检查项 | 影响区域 | 审查动作 | 完成标准 |
|---|---|---|---|
| 文档语言字段 | `SSOT/STATUS.md` | 检查是否存在 `documentation_language` 和 `documentation_language_evidence`。 | 字段存在，并记录语言锁及证据；证据混杂、不足或没有可检测文档时，已询问用户并记录选择。 |
| 语言探测证据 | `SSOT/.bootstrap/recon.md`（若仍在 bootstrap）、`STATUS.md` | 只从根 README、`docs/`、ADR、runbook、子系统 README、用户显式提供资料判断；忽略代码块、命令、路径、API 名、枚举值、代码标识符和直接引用。 | `documentation_language_evidence` 能说明来源和判断；不得以当前对话语言兜底。 |
| 既有 SSOT 语言一致性 | 所有被本次升级触及的 SSOT Markdown | 检查正在修改的 SSOT 正文、标题、表格标签是否遵守锁定语言。 | 本次新增/修改内容使用锁定语言；代码标识符、路径、命令、API 名、枚举值和直接引用保持原文。 |
| 语言切换治理 | `STATUS.md` 开放裁决项 / 停止审查闸门 | 若 源资料语言已变化或 SSOT 已混用语言，判断是否需要语言切换裁决。 | 语言切换不自动发生；需要切换时已有裁决项和 `doc-language-change` / `documentation_language` review。 |
| Doctor 检查 | Doctor 输出, `STATUS.md` | 增加并运行或等价执行 `[DOC-LANGUAGE]` 检查。 | `[DOC-LANGUAGE]` stale 项已修复、裁决或记录 no-op；通过后才允许推进 `tracked_skill_version`。 |
| 模板实例化纪律 | 项目 SSOT 新增/修改文件 | 检查 Agent 是否按语言锁翻译模板结构，而非照搬模板原始语言。 | 不机械重写全部既有 SSOT；但从本次升级后，新改动必须遵守语言锁。 |

**Doctor 标签**：

- `[DOC-LANGUAGE]`：`documentation_language` 缺失、证据不足、SSOT 文本偏离锁定语言，或语言切换未进入裁决/审查。

**不要求**：

- 不要求机械重写全部既有 SSOT Markdown。
- 不要求在没有足够语言证据时猜测语言；必须询问用户。
- 不要求后续源资料语言变化时自动切换 SSOT 语言。

### v2.6

**升级目标**：把架构演进、bug 记录粒度、高频任务入口和 Doctor 验真要求显式纳入 SSOT 维护协议，并增加 skill 协议自觉知水位。

**基线适用范围**：

- `tracked_skill_version` 缺失的 legacy 项目。
- `tracked_skill_version` 小于 `2.6` 的项目。
- 当前 `ssot-preflight` 的 `metadata.protocol_version` 为 `2.6`，且项目 SSOT 尚未按本条目完成审查。

**影响检查清单**：

| 检查项 | 影响区域 | 审查动作 | 完成标准 |
|---|---|---|---|
| Bug failure-mode 粒度 | `bugs/`, `gotchas/`, `testing/`, 相关 `architecture/` domain | 查找 `critical` / `major` / `recurred` bug 是否只按宽泛主题记录；同症状多根因要拆分，同根因复发要追加 recurrence timeline。 | 高影响 bug 条目包含触发条件、症状、根因、修复模式、预防测试、关联 gotcha / architecture / decision；无此类 bug 时记录 no-op。 |
| 演进 / 迁移台账 | `architecture/README.md` 和相关 domain README | 检查 git history、ADR、docs/源资料或当前代码是否显示重大架构迁移、旧 surface 删除、兼容路径、deprecated concept 或“不要复活”的旧方案。 | 有证据时在对应 architecture 的 `演进 / 迁移台账` 记录旧形态、当前替代形态、兼容状态、禁止复活概念和证据；无证据时写 `not_applicable` 和原因。 |
| 任务入口映射薄索引 | `SSOT/README.md` | 检查 git history、commit 审查或长期会话是否显示高频/高风险研发任务簇。 | 只有存在任务簇时维护任务入口映射，且只链接权威位置；没有任务簇时写 `not_applicable`，不得写 playbook 正文或第二事实源。 |
| Doctor 检查 | `STATUS.md`, Doctor 输出, 相关权威位置 | 运行或等价执行 Doctor 中的 `BUG-GRANULARITY`、演进 / 迁移台账、薄文档/源资料、architecture diagram/coverage、`SKILL-PROTOCOL` 检查。 | Doctor stale 项已修复或记录为 no-op；`SKILL-PROTOCOL` 通过后才允许推进 `tracked_skill_version`。 |
| Skill 协议水位 | `SSOT/STATUS.md` | 增加 `tracked_skill_version` 字段，记录项目 SSOT 已应用到的协议版本。 | 独立 reviewer 对协议升级审查返回 `no-more-required-changes` 后，`tracked_skill_version` 更新为 `2.6`。 |

**Doctor 标签**：

- `[BUG-GRANULARITY]`：高影响 bug 记录过粗。
- `[EVOLUTION]`：架构迁移或 deprecated concept 未进入 演进 / 迁移台账。
- `[THIN-DOCS]` / `[SOURCE]`：长期事实停留在 README/docs/ADR/源资料。
- `[SKILL-PROTOCOL]`：`tracked_skill_version` 缺失或落后于当前 `ssot-preflight` 的 `metadata.protocol_version`。

**不要求**：

- 不要求把所有既有 SSOT 文件改写成最新模板。
- 不要求为无相关历史证据的项目编造 演进 / 迁移台账 条目。
- 不要求为没有高频/高风险任务簇的项目维护任务入口映射正文。
