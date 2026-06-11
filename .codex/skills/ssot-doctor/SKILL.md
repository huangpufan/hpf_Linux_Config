---
name: ssot-doctor
description: Verify SSOT health, run deterministic lint checks, perform independent stop review, CORE-REF startup/reference doc review, ADAPTER checks, CONSUMPTION checks, or coverage/converged validation. Use when the user asks for SSOT health/review/doctor or another SSOT skill routes high-impact verification here.
---

# SSOT Doctor

Use this skill for verification, not for ordinary preflight or per-change closeout. Doctor checks whether existing SSOT remains credible; it does not itself catch up new commits or sessions.

## Workflow

1. Read `references/doctor.md`.
2. Run `assets/scripts/ssot-lint.sh` when deterministic L1 checks are useful.
3. For startup/reference docs, use `references/adapter-strategy.md` and `references/consumption-audit.md` as needed.
4. For high-impact stop conclusions, act as an independent reviewer or request one. Updater cannot self-certify `converged`, bootstrap `passed`, waterline advancement, or language lock changes.
5. Return `no-more-required-changes` only when the reviewed scope has no remaining required fixes; otherwise return `needs-fix` with concrete remaining items.

## References

- `references/doctor.md` - health checks, tags, stop gates
- `references/adapter-strategy.md` - thin adapter rules
- `references/consumption-audit.md` - trigger-side behavior probes
- `assets/scripts/ssot-lint.sh` - deterministic L1 lint
- `assets/scripts/test/run-tests.sh` - script smoke tests
- `../ssot-audit/references/commit-audit.md` - commit catch-up boundary
- `../ssot-audit/references/conversation-audit.md` - session catch-up boundary
- `../ssot-audit/references/protocol-upgrades.md` - protocol upgrade boundary
