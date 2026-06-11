---
name: ssot-preflight
description: Repository SSOT preflight before substantive code, config, docs, review, debugging, refactoring, or planning work. Use to check SSOT/STATUS.md, open adjudications, documentation language, protocol version, minimal SSOT read routing, and in-task SSOT write triggers. Do not use for pure operations, trivial format-only edits, or non-repository chat.
metadata:
  protocol_version: "2.17"
  bundle: "SSOT Skill"
---

# SSOT Preflight

`ssot-preflight` is the mandatory entry point for the SSOT Skill bundle. It is intentionally small: it decides whether work may proceed, what minimal SSOT files to read, and what durable facts must be captured while working.

The bundle-level protocol version is owned here. Other SSOT skills must defer to `metadata.protocol_version` in this file.

## 1. Preflight Gate

Before substantive repository work:

1. Read `SSOT/STATUS.md`.
2. Check open adjudications. Canonical heading is `## 开放裁决项`; legacy `## 待裁决项` is accepted. A `pending` item, or a `deferred` item whose revisit condition has fired, blocks ordinary work until resolved or deferred again.
3. Check `documentation_language` and `documentation_language_evidence`. Any SSOT Markdown written during this task must use that language, except paths, commands, code identifiers, enum values, API names, and direct quotes.
4. Compare this file's `metadata.protocol_version` with `SSOT/STATUS.md` `tracked_skill_version`.
   - If the project is behind, stop and use `$ssot-audit` for protocol-upgrade review.
   - If the installed bundle is behind the project waterline, report the stale install and do not downgrade the project.
5. Read `SSOT/README.md` for task routing.
6. Read `SSOT/architecture/README.md` unless the task is clearly operational, historical, or format-only.
7. Read only the routed SSOT areas needed for the task.

Skip preflight only for non-repository chat, pure command execution, or mechanical typo/format changes that cannot alter architecture, contract, state, behavior, workflow, tests, docs truth, or external surfaces.

## 2. Minimal Read Routing

Start from `SSOT/README.md`. Use its task-entry map as the project-specific router.

General fallback:

| Task signal | Read next |
|---|---|
| Feature, refactor, design unit, state/resource, lifecycle, contract, failure recovery | relevant `architecture/` view/domain, `decisions/`, `gotchas/`, `development/` |
| Bug fix | relevant `architecture/`, `bugs/`, `gotchas/`, and related `testing/` entries |
| Test strategy or fixture changes | `testing/`, related `architecture/`, bug regression records |
| Deployment, release, env, CI/CD | `deployment/`, `release/`, configuration/trust architecture |
| Terms or repo identity | `identity/`, `glossary/` |
| User asks sync/audit/catch-up/protocol upgrade | `$ssot-audit` |
| User asks health check, stop review, CORE-REF, CONSUMPTION | `$ssot-doctor` |

Do not read the full `SSOT/` tree or all bundled references at task start. Load more only when the task discovers a specific need.

## 3. In-Task Write Triggers

While working, watch for durable facts. If one appears, update SSOT immediately when the authority is clear, or record a short delta to resolve with `$ssot-closeout` before final response, `claim_done`, or commit.

Durable facts include:

- new or removed design units, public APIs, schema, routes, protocols, runtime surfaces, workflows, or configuration authorities
- changed state/resource ownership, lifecycle, concurrency, locks, transactions, retries, recovery, trust boundaries, deployment, release, or test policy
- deleted legacy surfaces, deprecated concepts, "do not revive" paths, or architecture migrations
- confirmed bug root cause, recurring failure mode, gotcha, technical debt, or prevention test
- user-confirmed long-term decisions, terminology, constraints, rejected options, or external source material
- startup/reference docs such as `AGENTS.md`, `CLAUDE.md`, `.cursor/rules`, `.windsurf/rules`, or `GEMINI.md` gaining or changing durable repository facts

Detailed write mechanics are not loaded here. Use `$ssot-closeout` for final absorption and its references for write routing.

## 4. Bundle Routing

| Need | Skill |
|---|---|
| Repository has no `SSOT/`, `.bootstrap/` exists, or bootstrap must continue | `$ssot-bootstrap` |
| Final response, `claim_done`, or commit after substantive changes | `$ssot-closeout` |
| User asks to catch up commits/sessions or protocol version is behind | `$ssot-audit` |
| Health check, independent stop review, adapter/core-ref, consumption audit | `$ssot-doctor` |
| Old prompt asks for `$ssot-skill` | compatibility shim routes back to this bundle |

## 5. Shared References

Read these only when the current task needs the detail:

- `references/status-protocol.md` - `STATUS.md`, coverage states, adjudications, gaps, stop gates, and waterlines
- `references/source-material.md` - README/docs/ADR/runbook/PRD/core-ref classification and absorption
- `references/knowledge-integrity.md` - confidence state machine and blocking rules
- `references/architecture.md` - architecture root/views/domains, Reader Map, diagrams, decomposition, and coverage depth
- `references/area-model.md` - top-level SSOT area responsibilities and task-entry mapping rules

## 6. Anti-Patterns

- Do not use SSOT as a second code/schema/router source. Current implemented facts come from code, config, schema, tests, and actual behavior.
- Do not copy full source documents into SSOT. Absorb durable facts into one authority with evidence.
- Do not leave candidate or hypothesis knowledge inside authoritative architecture bodies.
- Do not advance `tracked_commit`, `tracked_session`, `tracked_skill_version`, language lock, bootstrap `passed`, or `converged` without the required independent review.
- Do not re-expand this preflight file with full bootstrap, doctor, audit, or closeout procedures. Route to the lifecycle skills instead.
