# 侦察报告

## 文档语言探测

| 字段 | 值 |
|---|---|
| 探测结果 | `中文` |
| 探测来源 | `README-CN.md`、`docs/agent-install-playbook.md`、`AGENTS.md` |
| 证据摘要 | 中文文档承担主叙述与操作约束；英文 README 主要是镜像与对照层。 |
| 已忽略内容 | code blocks / commands / paths / API names / enum values / identifiers / direct quotes |
| 是否需要询问用户 | no |
| 用户选择或裁决 | not_applicable |
| 写入 STATUS 字段 | `documentation_language`, `documentation_language_evidence` |

## 规模

| 指标 | 值 |
|---|---|
| 规模等级 | `M` |
| 估算代码行数 | 以 shell + Python 安装脚本为主，未做精确 LOC 统计 |
| 源文件数量 | `install-script/` 下百级文件量 |
| 顶层目录数量 | 9 |
| 最大目录深度 | 约 4 |

## 仓库拓扑

| 字段 | 值 |
|---|---|
| 拓扑类型 | 库/工具 |
| 工作空间配置 | not_applicable |
| 独立部署单元数 | 0 |
| 入口点 | `install-script/agent-runner.py`、`install-script/agent-tools.json`、`AGENTS.md`、`docs/agent-install-playbook.md` |

## Architecture 拆分候选

| 候选轴 | 适用证据 | 可形成的 domain / 独立性信号 | 优点 | 风险/不足 |
|---|---|---|---|---|
| 按安装运行边界拆 | README、AGENTS、playbook、runner、catalog | `installation-runtime`；有独立契约/状态/验收语义 | 能直接表达仓库主价值 | 需要克制，不再把每个目录都拆成域 |
| 按源码目录拆 | `install-script/basic/setup/tools` 目录结构 | basic/setup/tools 等 | 直观 | 只是实现分层，不是真正架构边界 |

| 字段 | 值 |
|---|---|
| 推荐主轴 | 安装运行边界 |
| 推荐理由 | 仓库主复杂度在 runner/catalog/脚本执行协议，而不是目录层次。 |
| 拒绝的替代轴 | 按源码目录机械拆分 |
| 递归/停止规则 | 暂停在单一核心 domain；只有当 `nvim/`、OpenHarmony 或 release 形成独立状态边界时再拆。 |
| 覆盖深度预判 | `deep` |
| 抽样/未覆盖计划 | 先覆盖安装主线；`nvim/` 与个人化子树保持仓库级定位。 |
| Views / Domains 结构判断 | views+domains |
| 预建 architecture views | operating-model, critical-journeys, current-target-gap |
| 预建 architecture domains | installation-runtime |
| 必需图预判 | boundary/context, decomposition/domain, runtime flow |
| 停止/递归审查挑战 | 待独立 reviewer 最终确认是否需要更细 domain |

## 设计意图候选

| 设计维度 | 发现 | 来源 | 建议权威位置 | 置信度 / 缺口 |
|---|---|---|---|---|
| 使命 / 承诺 | agent-first、deterministic 的 Linux/WSL2 开发环境配置仓库 | README、playbook | `architecture/views/operating-model.md` | verified |
| 当前优先级 | runner-first、catalog-first、check-first | AGENTS、playbook | `architecture/views/operating-model.md` | verified |
| 非目标 | 不把 OpenHarmony/个人配置纳入默认机器初始化 | README、AGENTS | `architecture/views/operating-model.md` | documented |
| 成功标准 / 验收信号 | install/check 结果必须由 `check_cmd` 验收 | playbook、catalog | `architecture/views/critical-journeys.md` | verified |
| 主旅程 / 闭环 | list/check/install/preset → script → check_cmd | runner、playbook | `architecture/views/critical-journeys.md` | verified |
| 全局 target / 迁移立场 | 保持单一入口和 catalog，不再回退到自由脚本流 | README、AGENTS | `architecture/views/current-target-gap.md` | inferred |

## 技术栈

| 类别 | 值 |
|---|---|
| 主要语言 | Shell、Python、Markdown |
| 框架 | 无重型应用框架 |
| 构建系统 | 脚本驱动 / make 辅助 |
| 包管理器 | apt、snap、cargo、npm、pip 等被安装目标 |
| 运行时 | Linux / WSL2 shell + Python 3 |

## 源资料盘点

| 源资料 | 路径/来源 | 分类 | 信息量 | 与代码一致性 | 权威位置 | 可服务的区域 |
|---|---|---|---|---|---|---|
| README-CN | `README-CN.md` | absorb | 高 | 一致 | identity / operating-model / development | architecture, identity, development |
| README | `README.md` | link-only | 中 | 一致 | STATUS language evidence | identity |
| playbook | `docs/agent-install-playbook.md` | absorb | 高 | 一致 | development / testing / gotchas | development, testing |
| AGENTS | `AGENTS.md` | absorb | 高 | 一致 | operating-model / gotchas | architecture, development |
| nvim modernization research | `docs/nvim-plugin-modernization-research-2026-05-25.md` | absorb | 中 | 未直接校验全部代码 | tech-debt | tech-debt |

## 推荐策略

- **区域顺序调整**：先完成 architecture 主干与 development/testing；deployment/release 轻量记录现状。
- **需要特别关注的 architecture views/domains**：installation-runtime。
- **可快速完成的区域**：identity、glossary、gotchas。
- **预计需要的会话数**：单次 bootstrap 可完成，但最终 stop review 仍需独立 reviewer。
- **其他发现/注意事项**：项目级 `.codex/skills/ssot-skill/` 已存在且未跟踪，应随 bootstrap 一并提交。
