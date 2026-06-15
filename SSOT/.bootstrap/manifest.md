# Bootstrap Manifest

## 全局状态

| 字段 | 值 |
|---|---|
| bootstrap_status | `phase-3-reviewing` |
| documentation_language | `中文` |
| tracked_commit | `0d39135b3d036c66753ba39bb4510a21d6f67bb8` |
| tracked_skill_version | `2.17` |
| coordinator | `main-agent` |

## 区域分配 / 进度

| 区域 | owner | 状态 | 产出 |
|---|---|---|---|
| recon | main-agent | done | `SSOT/decisions/0000-bootstrap-recon.md` |
| architecture root/views | main-agent | done | `SSOT/architecture/README.md`, `views/*` |
| installation-runtime domain | main-agent | done | `SSOT/architecture/domains/installation-runtime/README.md` |
| development/testing/identity/glossary | main-agent | done | corresponding READMEs |
| deployment/release/decisions/gotchas/bugs/tech-debt | main-agent | done | corresponding READMEs |
| final review | bootstrap-reviewer | in_progress | reviewer output pending |

## Tier 4 发现汇总

| 发现 | 类型 | 来源 | 目标位置 |
|---|---|---|---|
| Neovim 现代化仍有 deprecated 路线 | debt | research doc | `SSOT/tech-debt/README.md` |
| Ubuntu 24.04 换源路径差异 | gotcha | AGENTS / setup docs | `SSOT/gotchas/README.md` |
| GitHub 默认 HTTPS 而非 SSH | architecture-constraint | README / setup docs | `operating-model` / `gotchas` |

## 收敛检查进度

| 分段 | reviewer | result | 说明 |
|---|---|---|---|
| 文档语言 | bootstrap-reviewer | no-more-required-changes | 中文锁证据充分 |
| architecture root/views/domain | bootstrap-reviewer | pending | 待最终审查 |
| engineering areas | bootstrap-reviewer | pending | 待最终审查 |
| bootstrap overall | bootstrap-reviewer | pending | 未清理 `.bootstrap/` |

## 停止审查记录

| scope | stop_claim | reviewer | result | evidence | remaining_changes |
|---|---|---|---|---|---|
| documentation_language | documentation_language | bootstrap-reviewer | no-more-required-changes | recon + README/docs/AGENTS | none |
| installation-runtime | single-level | self-reviewed | no-more-required-changes | runner/catalog/domain review | final reviewer still required |
