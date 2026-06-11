# SSOT 状态

## 事件源覆盖

| 字段 | 值 |
|---|---|
| tracked_commit | `0d39135b3d036c66753ba39bb4510a21d6f67bb8` |
| tracked_session | `bootstrap-2026-06-03` |
| tracked_skill_version | `2.16` |
| documentation_language | `中文` |
| documentation_language_evidence | `README-CN.md`、`docs/agent-install-playbook.md`、`AGENTS.md` 为中文主叙述；`README.md` 与 `nvim/README.md` 提供英文镜像，因此锁定 SSOT 正文为中文。 |
| coverage_result | `bootstrap` |
| last_stop_review | `bootstrap 进行中；最终 converged / tracked_commit / tracked_session / tracked_skill_version 尚未推进。` |

## 区域状态

| 区域 | 状态 | 备注 |
|---|---|---|
| architecture | gap | 已建立 root、views 与 `installation-runtime` domain；其余子目录按当前仓库规模不再继续拆分。 |
| identity | covered | 仓库定位已由根 README 与 runner 入口吸收。 |
| glossary | covered | 仅保留仓库内高频专有术语。 |
| development | covered | 以 `install-script/agent-runner.py`、`agent-tools.json` 和 playbook 为权威。 |
| testing | covered | 当前仓库的验证主路径是 `agent-runner.py check ...` 与脚本自检。 |
| deployment | not_applicable | 当前仓库不交付常驻服务或部署单元，主要产物是本地安装脚本与配置仓库。 |
| release | gap | 缺少明确版本/发布自动化约束，仅记录现状。 |
| decisions | gap | 仅沉淀 bootstrap 决策与已证实的长期约束，后续开发再自然积累。 |
| gotchas | covered | 已记录高风险安装/认证/路径约束。 |
| bugs | not_applicable | 本次 bootstrap 未发现可稳定归档的历史 bug 记录。 |
| tech-debt | covered | 已记录可确认的债务/过渡点。 |

## 源资料吸收

| 源资料 | 路径/来源 | 分类 | 权威位置 | 吸收状态 | 冲突/裁决项 | 最后检查 |
|---|---|---|---|---|---|---|
| 根 README 中文版 | `README-CN.md` | absorb | `SSOT/identity/README.md`、`SSOT/architecture/views/operating-model.md`、`SSOT/development/README.md` | absorbed | none | 2026-06-03 |
| 根 README 英文版 | `README.md` | link-only | `SSOT/STATUS.md` | linked | none | 2026-06-03 |
| 安装 playbook | `docs/agent-install-playbook.md` | absorb | `SSOT/development/README.md`、`SSOT/testing/README.md`、`SSOT/gotchas/README.md` | absorbed | none | 2026-06-03 |
| 仓库级 agent 规则 | `AGENTS.md` | absorb | `SSOT/architecture/views/operating-model.md`、`SSOT/development/README.md`、`SSOT/gotchas/README.md` | absorbed | none | 2026-06-03 |
| 预设说明 | `install-script/presets/README.md` | absorb | `SSOT/architecture/domains/installation-runtime/README.md`、`SSOT/development/README.md` | absorbed | none | 2026-06-03 |
| setup 说明 | `install-script/setup/README.md` | absorb | `SSOT/architecture/domains/installation-runtime/README.md`、`SSOT/gotchas/README.md` | absorbed | none | 2026-06-03 |
| tools 说明 | `install-script/tools/README.md` | absorb | `SSOT/architecture/domains/installation-runtime/README.md`、`SSOT/development/README.md` | absorbed | none | 2026-06-03 |
| 工具目录清单 | `install-script/agent-tools.json` | absorb | `SSOT/architecture/domains/installation-runtime/README.md`、`SSOT/testing/README.md` | absorbed | none | 2026-06-03 |
| runner 入口 | `install-script/agent-runner.py` | absorb | `SSOT/architecture/domains/installation-runtime/README.md`、`SSOT/testing/README.md` | absorbed | none | 2026-06-03 |
| Neovim 现代化研究 | `docs/nvim-plugin-modernization-research-2026-05-25.md` | absorb | `SSOT/tech-debt/README.md` | absorbed | none | 2026-06-03 |

## 核心参考文档审查

| 文档 | 路径 | 角色 | 状态 | 权威关系 | 检查范围 | 最后检查 | 证据 | 建议动作 | 冲突/裁决项 |
|---|---|---|---|---|---|---|---|---|---|
| AGENTS.md | `AGENTS.md` | startup | covered | source-material | commands / directory-map / workflow / routing | 2026-06-03 | 与 `docs/agent-install-playbook.md`、`install-script/agent-runner.py`、`install-script/agent-tools.json` 一致 | no-op | none |

## 停止审查闸门

| scope | stop_claim | reviewer | reviewed_at | result | evidence | remaining_changes |
|---|---|---|---|---|---|---|
| documentation_language | `documentation_language` | `bootstrap-reviewer` | 2026-06-03 | `no-more-required-changes` | 对比 `README-CN.md`、`docs/agent-install-playbook.md`、`AGENTS.md` 的中文主体与 `README.md` 的镜像角色 | none |
| architecture/domain-installation-runtime | `covered` | `self-reviewed` | 2026-06-03 | `no-more-required-changes` | 已检查 domain 边界、runner/tool catalog/source docs 一致性；未做代码逐函数穷尽审查 | 仍需全局 reviewer 决定 bootstrap 收敛 |

## 开放裁决项

| id | status | created_at | source | scope | question | needed_by | resolution | revisit_condition | links |
|---|---|---|---|---|---|---|---|---|---|

## 开放缺口

| 区域 | 状态 | 缺口描述 | 阻塞程度 |
|---|---|---|---|
| architecture | gap | `install-script/` 之外的 `nvim/` 与个人配置子树只做了仓库级定位，未拆成独立 domain。 | 非阻塞 |
| release | gap | 仓库缺少正式 release/tag/changelog 流程证据，只能记录当前“配置仓库”现状。 | 非阻塞 |
| decisions | gap | 现有长期决策主要散落在 README 与 AGENTS 约束中，尚未形成独立 decisions 条目。 | 非阻塞 |
