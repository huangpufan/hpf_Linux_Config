---
name: ssot-audit
description: Audit or catch up repository SSOT against commits, conversation sessions, or SSOT protocol versions. Use when the user asks to sync/catch up/audit SSOT, when tracked_commit/tracked_session/tracked_skill_version is behind, or when ssot-preflight detects protocol-version lag. Do not use for routine per-change closeout.
---

# SSOT Audit

Use this skill for explicit catch-up work and protocol upgrades. The bundle protocol version is owned by `$ssot-preflight`.

## Route

| Audit signal | Read |
|---|---|
| `tracked_commit` behind HEAD or user asks commit sync | `references/commit-audit.md` |
| user asks conversation/session transcript catch-up | `references/conversation-audit.md` |
| `tracked_skill_version` behind `ssot-preflight` protocol version | `references/protocol-upgrades.md` |

## Rules

- Do not silently run audit during ordinary work except when `$ssot-preflight` finds protocol-version lag.
- Segment large diffs before loading too much context.
- Use `$ssot-closeout` references for update routing and write mechanics when an audit produces SSOT edits.
- Use `$ssot-doctor` when an audit needs independent health checks, stop gates, or final waterline review.
- Advancing `tracked_commit`, `tracked_session`, or `tracked_skill_version` is high impact and requires the configured independent stop review.

## References

- `references/commit-audit.md` - commit-level catch-up
- `references/conversation-audit.md` - session and transcript catch-up
- `references/protocol-upgrades.md` - protocol upgrade ledger and review rules
- `../ssot-closeout/references/update-routing.md` - mapping changed files to SSOT areas
- `../ssot-doctor/references/doctor.md` - verification and stop review
