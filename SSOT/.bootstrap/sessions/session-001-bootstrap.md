# Session 001: bootstrap whole repository

## 元数据

| 字段 | 值 |
|---|---|
| 时间 | 2026-06-03 15:xx |
| 分配范围 | 整仓 bootstrap：recon、骨架、主干填充 |
| 前置依赖 | `SSOT/.bootstrap/recon.md` |
| 文档语言锁 | `中文` |
| 语言证据 | `README-CN.md`、`docs/agent-install-playbook.md`、`AGENTS.md` |
| 产出文件 | `SSOT/` 主干与 `.bootstrap/*` |

## 探索记录

读取了仓库根目录、README 双语文档、`docs/agent-install-playbook.md`、`AGENTS.md`、`install-script/agent-runner.py` 的入口语义、`install-script/agent-tools.json` 的工具目录、`install-script/presets/README.md`、`install-script/setup/README.md`、`install-script/tools/README.md`，以及 `install-script/` 的第一层目录拓扑。

## 源资料处理

| 源资料 | 路径/来源 | 分类 | 权威位置 | 处理结果 |
|---|---|---|---|---|
| 中文 README | `README-CN.md` | absorb | architecture / identity / development | absorbed |
| 英文 README | `README.md` | link-only | STATUS language evidence | linked |
| playbook | `docs/agent-install-playbook.md` | absorb | development / testing / gotchas | absorbed |
| AGENTS | `AGENTS.md` | absorb | operating-model / gotchas | absorbed |
| nvim 研究文档 | `docs/nvim-plugin-modernization-research-2026-05-25.md` | absorb | tech-debt | absorbed |

## Architecture 拆分判断

| 字段 | 值 |
|---|---|
| 处理的 architecture 范围 | root / views / domains |
| 使用的拆分轴 | 安装运行边界 |
| 拒绝的替代轴 | 按源码目录机械拆分 |
| 继续递归/停止拆分的理由 | 现阶段只有 runner/catalog/脚本系统构成真正独立边界 |
| 覆盖深度 | `deep` |
| 覆盖范围 / 抽样策略 | 安装主线全覆盖，支线只做仓库级定位 |
| Views 吸收范围 | operating-model / critical-journeys / current-target-gap |
| 设计意图覆盖 | mission / priorities / non-goals / success standards / journeys / current-target-gap |
| 必需图清单 | boundary/context, decomposition/domain, runtime flow |
| Domain 有效性证据 | runner/catalog 构成独立契约与状态 owner |
| 未覆盖 gap | `nvim/` 与 release 仍未独立成域/规则 |
| 停止/递归审查挑战 | 待独立 reviewer 最终挑战 |

## Architecture Diagram 处理

| Diagram ID | 架构路径 | 状态 | 覆盖内容 | 证据 | 链接的表格行 | 处理结果 |
|---|---|---|---|---|---|---|
| `ARCH-CTX-CURRENT` | `SSOT/architecture/README.md` | current | 系统总边界 | README/docs | 图索引 | added |
| `ARCH-DOMAIN-CURRENT` | `SSOT/architecture/README.md` | current | root 到 domain 分解 | `install-script/` 结构 | 图索引 | added |
| `INSTALL-RUNTIME-FLOW-CHECK-CURRENT` | `SSOT/architecture/domains/installation-runtime/README.md` | current | 安装/验收主流 | playbook/catalog | 运行流 | added |

## 产出摘要

创建了 `SSOT/` 仓库级知识库，主干围绕安装运行边界组织；建立了 identity/glossary/development/testing/gotchas/tech-debt 等基础区域；对 deployment/release/bugs 采用轻量或 not_applicable 记录，避免编造无证据事实。

## Tier 4 发现

| 发现 | 类型 | 来源标记 | 来源位置 |
|---|---|---|---|
| Neovim 旧配置路线已 deprecated | debt | documented | `docs/nvim-plugin-modernization-research-2026-05-25.md` |
| Ubuntu 24.04 换源路径差异是高风险点 | gotcha | documented | `AGENTS.md`, `install-script/setup/README.md` |
| 默认 GitHub 认证应保持 HTTPS | architecture-constraint | documented | README / setup docs |

## 阻塞与问题

无硬阻塞。最终 bootstrap 收敛和 `.bootstrap/` 是否清理，仍需独立 reviewer 决定。

## 停止审查记录（Stop Review）

| scope | stop_claim | reviewer | result | 已审查证据 | 剩余修改项 |
|---|---|---|---|---|---|
| installation-runtime | single-level | self-reviewed | no-more-required-changes | runner/catalog/domain 内容已核对 | 仍需全局 reviewer 终审 |

## 下次建议

如果后续仓库开始出现稳定版本发布流程，优先扩充 `release/`。如果 `nvim/` 或 OpenHarmony 子树的状态边界继续增长，再重审是否拆 child domain。
