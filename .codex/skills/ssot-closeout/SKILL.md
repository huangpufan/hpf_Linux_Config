---
name: ssot-closeout
description: SSOT closeout before final response, claim_done, or commit after substantive repository changes. Use to absorb code/diff/conversation/test changes into SSOT, resolve in-task SSOT deltas, and decide whether no-op, status updates, audit, or doctor are needed. Do not use for initial task preflight, full historical catch-up, or full health checks.
---

# SSOT Closeout

Use this skill at the end of each substantive change batch, before final response, `claim_done`, or commit. It does not replace `$ssot-preflight`; it verifies whether the work just performed changed durable repository knowledge.

## Workflow

1. Re-read `SSOT/STATUS.md` and every SSOT file that may be updated.
2. Inspect the actual work: diff, tests, user confirmations, bug findings, design changes, and any in-task SSOT deltas.
3. Read `references/update-routing.md` to map changes to SSOT areas.
4. Read `references/inline-update-guide.md` when writing SSOT.
5. Use `../ssot-preflight/references/source-material.md` for README/docs/ADR/PRD/core-reference material.
6. Use `../ssot-preflight/references/knowledge-integrity.md` when candidate/hypothesis/source-backed knowledge is touched.
7. Update the unique authority location only; do not duplicate durable facts across areas.
8. Run only targeted checks needed for the changed files. Do not run full `$ssot-doctor` by default.
9. If the result would advance high-impact waterlines, claim `covered/converged`, or require independent stop review, route to `$ssot-doctor` or `$ssot-audit` instead of self-certifying.

## No-Op Criteria

Closeout may be a no-op when the batch is purely mechanical, docs wording without durable facts, test-only without policy change, or implementation detail with no architecture/contract/behavior impact. Record no-op only when the affected scope was actually checked.

## References

- `references/update-routing.md` - impact levels, file-to-area mapping, cascade checks
- `references/inline-update-guide.md` - write procedure and status synchronization
- `../ssot-preflight/references/status-protocol.md` - stop gates, waterlines, adjudications
- `../ssot-preflight/references/source-material.md` - source material absorption
- `../ssot-preflight/references/knowledge-integrity.md` - confidence and blocking rules
