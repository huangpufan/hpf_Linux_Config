---
name: ssot-skill
description: Legacy compatibility shim for the split SSOT Skill bundle. Use only when old prompts or docs explicitly request ssot-skill; route to ssot-preflight, ssot-bootstrap, ssot-closeout, ssot-audit, or ssot-doctor. Do not treat this shim as the protocol owner.
---

# SSOT Skill Compatibility Shim

The SSOT Skill bundle is split into lifecycle skills. This shim exists only so older prompts that mention `$ssot-skill` still land in the correct bundle.

Use:

- `$ssot-preflight` before substantive repository work
- `$ssot-bootstrap` when `SSOT/` is missing or bootstrap is in progress
- `$ssot-closeout` before final response, `claim_done`, or commit after substantive changes
- `$ssot-audit` for commit/session/protocol catch-up
- `$ssot-doctor` for health checks, stop review, CORE-REF, ADAPTER, or CONSUMPTION checks

When this shim is invoked, immediately classify the request by lifecycle timing:

- ordinary repository work, review, debugging, planning, or refactoring -> read `../ssot-preflight/SKILL.md`
- missing `SSOT/`, `.bootstrap/`, `coverage_result: bootstrap`, or create-SSOT request -> read `../ssot-bootstrap/SKILL.md`
- final answer, `claim_done`, commit, or just-finished substantive change batch -> read `../ssot-closeout/SKILL.md`
- commit/session/protocol sync, catch-up, or lagging `tracked_skill_version` -> read `../ssot-audit/SKILL.md`
- health check, independent stop review, CORE-REF, ADAPTER, CONSUMPTION, or deterministic lint -> read `../ssot-doctor/SKILL.md`

The bundle protocol version is owned by `ssot-preflight/SKILL.md`; do not maintain protocol rules here.
