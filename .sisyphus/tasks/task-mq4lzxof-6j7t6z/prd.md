## Task Context

This repository is centered on `install-script/` for machine setup and tool installation workflows. The current project guidance already establishes a preferred path: read `docs/agent-install-playbook.md` first, use `python3 install-script/agent-runner.py ...` by default, and treat `install-script/agent-tools.json` as the single source of truth for tool ids and `check_cmd` values.

Despite that guidance, the user reports the project still feels too complex because there are too many commands and too many visible installation entrypoints. The simplification target is not a broad refactor of all scripts; it is specifically a user-facing entrypoint simplification effort.

Verified facts from current instructions/context:
- Repository path is `~/hpf_Linux_Config`.
- `install-script/agent-runner.py` is already the preferred execution entrypoint.
- `docs/agent-install-playbook.md` is already the intended first-read document for installation tasks.
- `install-script/agent-tools.json` is already the canonical tool catalog.
- The user explicitly wants simplification focused on installation entrypoints and command count, not generic repository cleanup.

## Goal and Success Criteria

### Goal Statement

Simplify the installation experience so that the repository presents exactly one primary public command path: `python3 install-script/agent-runner.py ...`.

### Non Goals

- Do not rewrite the entire repository structure.
- Do not delete or redesign internal implementation scripts solely for aesthetic cleanup.
- Do not expand scope into OpenHarmony-specific workflow redesign unless required by the public installation entrypoint path.
- Do not change internal script behavior that is not part of a documented public command surface.

### Done Definition

The task is complete when all of the following are true:
- New users can find one clearly recommended installation command path without needing to choose among multiple public entrypoints.
- Public-facing documentation consistently points to `python3 install-script/agent-runner.py ...` as the standard installation interface.
- Previously documented legacy commands are either routed through the runner or emit a clear migration message directing users to the runner path.
- Internal scripts remain available for implementation use but are no longer promoted as direct user entrypoints.

## Scope and Constraints

### In Scope

- Audit documented installation commands in public-facing project docs.
- Reduce public installation guidance to one primary interface: `python3 install-script/agent-runner.py ...`.
- Update README and installation-related docs/playbooks so they expose one main user path.
- Add soft-compat migration handling for previously documented legacy commands.
- Hide internal implementation scripts from public guidance unless they are part of the single public runner flow.

### Out of Scope

- Full audit of every executable script in the repository.
- Compatibility work for undocumented/internal-only scripts beyond keeping them available and unadvertised.
- Reorganization of tool installation internals unless needed to support the simplified public contract.
- Removal of internal scripts purely because they exist.

### Constraints

- Public simplification must preserve compatibility for documented legacy commands through a soft transition, not a hard break.
- The single public entrypoint must remain `python3 install-script/agent-runner.py ...`.
- `install-script/agent-tools.json` must remain the authoritative source for tool ids and checks.
- Internal scripts may remain in place, but user-facing docs must not encourage direct execution unless explicitly retained by design.

## Technical Design and Execution Plan

### Design Boundary

This is a public-interface simplification task, not an implementation-core rewrite. The design should separate:
- Public user interface: one documented command family through `agent-runner.py`.
- Internal implementation surface: existing scripts under `install-script/` that remain callable by the runner or maintainers, but are not advertised to users.
- Legacy public compatibility: previously documented commands that should continue to function short-term while clearly directing users to the runner.

### Execution Steps

1. Inventory the currently documented installation commands across README and installation-related docs.
2. Classify each documented command into one of three buckets:
   - canonical runner command,
   - legacy public command needing migration guidance,
   - internal command that should be removed from public docs.
3. Rewrite public docs so the primary workflow always starts from `docs/agent-install-playbook.md` and uses `python3 install-script/agent-runner.py ...` examples.
4. For each documented legacy command, implement one soft-compat strategy:
   - delegate to the runner, or
   - print a clear migration notice that shows the equivalent runner command.
5. Verify that internal scripts remain available for the runner/maintainers but are no longer presented as the recommended user path.
6. Ensure the command examples remain sufficient for common flows such as `list`, `check all`, and preset execution.

### Milestones

- Milestone 1: documented command inventory and canonical/legacy/internal classification completed.
- Milestone 2: public docs rewritten around one primary runner-based workflow.
- Milestone 3: documented legacy entrypoints provide soft-compat migration guidance.
- Milestone 4: validation confirms both new-user clarity and old-user migration behavior.

### Change Impact

Expected files likely include:
- top-level README or equivalent public entry docs,
- `docs/agent-install-playbook.md`,
- any other public install guidance that currently exposes multiple command paths,
- compatibility wrappers or legacy scripts only if they are already part of documented public usage.

## Run and Test Instructions

### Test Commands

The execution agent should run the minimum sufficient checks below after making changes:

```bash
python3 install-script/agent-runner.py list
python3 install-script/agent-runner.py check all
python3 install-script/agent-runner.py preset minimal --dry-run
```

If any documented legacy public command is preserved through a wrapper or compatibility shim, run that legacy command as well and confirm it either:
- successfully delegates to the runner path, or
- prints a migration message that includes the recommended `python3 install-script/agent-runner.py ...` replacement.

### Manual Smoke

Manual validation must confirm both user journeys:
- New user journey: from the main public documentation, a reader should see one primary way to start installation and should not need to compare multiple command families.
- Existing user journey: if the user follows an old documented command, they should receive a clear path to the new standard runner command without a confusing hard failure.

### Environment Prerequisites

- Python 3 available locally.
- Repository checked out at `~/hpf_Linux_Config`.
- Validation should avoid mutating the machine beyond the minimum necessary for existing check/dry-run commands unless the mission explicitly includes live installation verification.

### Fallback Evidence

If full command execution cannot be completed in the environment, the agent must still provide:
- exact docs changed,
- exact legacy commands audited,
- the migration behavior implemented for each documented legacy command,
- command output or code-path evidence showing how users are redirected.

## Deliverables and Acceptance

### Deliverables

- Updated public documentation that converges on `python3 install-script/agent-runner.py ...` as the sole primary installation interface.
- Soft-compat support for documented legacy public commands.
- A documented mapping from old public commands to the new canonical runner path.

### Acceptance Method

Accept the task only if all of the following are demonstrated:
- Public docs expose one primary installation command family.
- No public docs encourage direct use of internal scripts except where intentionally retained.
- Documented legacy commands are still handled and guide users to the runner path.
- The validation commands above pass, or blocked checks are explained with concrete fallback evidence.

### Traceability Req To Test

- Requirement: one public entrypoint.
  - Evidence: README/playbook/manual smoke review.
- Requirement: documented legacy compatibility.
  - Evidence: legacy command execution or wrapper-path inspection.
- Requirement: runner workflow remains usable.
  - Evidence: `list`, `check all`, and `preset minimal --dry-run` results.

## Risks and Unknowns

### Top Risks

- Multiple docs may expose inconsistent command examples, causing partial simplification and user confusion.
- Some documented legacy commands may encode behavior not trivially representable as a runner equivalent.
- Over-aggressive doc cleanup could accidentally hide maintainer-critical internal workflows if public/internal boundaries are not classified carefully.

### Unknowns

- Exact set of currently documented legacy commands still visible to users.
- Whether any public command examples outside the install playbook have drifted from the runner-first contract.
- Whether legacy command wrappers already exist or must be added.

### Assumptions

- `agent-runner.py` is capable of representing the intended public installation workflows.
- Internal scripts can remain as implementation details without being removed.
- Soft-compat is preferred over hard deprecation for all documented legacy commands in this scope.

### Rollback Path

If simplification introduces confusion or breaks documented flows:
- restore prior documentation wording for affected commands,
- disable or revert compatibility wrapper changes for the affected legacy entrypoints,
- keep the runner-based docs improvements that are proven correct while reopening unresolved legacy mapping gaps.

## Agent Execution Notes

### Handoff Boundary

The implementation agent should only change PRD-execution-relevant repository files needed to simplify the public installation interface. Avoid unrelated cleanup.

### Verification Evidence

The execution agent must provide:
- list of docs updated,
- list of documented legacy commands audited,
- mapping from each legacy command to its runner replacement or migration notice,
- outputs or summaries from the required validation commands.

### Review Focus

Review should prioritize:
- whether the public surface is truly reduced to one primary command family,
- whether migration guidance is explicit and consistent,
- whether internal scripts stopped leaking into user-facing guidance,
- whether compatibility changes preserve existing documented usage without silent breakage.

### Fix Loop

If validation reveals mismatched docs or broken legacy mappings, fix those before any broader cleanup. Do not expand into repository-wide refactors in the same mission.

### Commit Push Policy

The execution agent should keep changes in one reviewable slice if possible. Include the validation evidence in the final handoff. If commit/push is requested later, use a concise commit message describing installation entrypoint simplification and legacy-command soft compatibility.