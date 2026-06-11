---
name: ssot-bootstrap
description: Bootstrap or continue repository SSOT creation. Use when SSOT/ is missing, SSOT/.bootstrap/ exists, SSOT/STATUS.md coverage_result is bootstrap, or the user asks to create a repository SSOT. Do not use for normal code-task preflight or routine closeout in an already bootstrapped repo.
---

# SSOT Bootstrap

Use this skill only for first-time SSOT creation or bootstrap continuation. The bundle protocol version is owned by `$ssot-preflight`.

## Workflow

1. Confirm `SSOT/` is missing, `SSOT/.bootstrap/` exists, or `SSOT/STATUS.md` says `coverage_result: bootstrap`.
2. Read `references/bootstrap.md`.
3. Use the bundled templates under `assets/templates/` as structure helpers, not as semantic authority.
4. Create or continue `SSOT/` according to the bootstrap phase state.
5. Keep generated SSOT Markdown in the detected `documentation_language`.
6. Do not declare bootstrap `passed`, clear `.bootstrap/`, or advance waterlines without the required independent stop review.

## References

- `references/bootstrap.md` - full bootstrap protocol
- `assets/templates/` - SSOT skeleton, architecture, status, bootstrap manifest/session, and adapter templates
- `../ssot-preflight/references/source-material.md` - source material classification
- `../ssot-preflight/references/architecture.md` - architecture structure and evidence requirements
- `../ssot-doctor/references/doctor.md` - convergence and stop-review checks
