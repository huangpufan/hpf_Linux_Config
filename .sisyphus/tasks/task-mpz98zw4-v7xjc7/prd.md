## Task Context

用户当前需求只有一句“简化项目”，仓库为 `/home/hpf/hpf_Linux_Config`。
已知仓库约定显示：
- 仓库以 `install-script/` 为核心。
- 安装相关任务默认应先读 `docs/agent-install-playbook.md`。
- 默认执行入口是 `python3 install-script/agent-runner.py ...`。
- `install-script/agent-tools.json` 是工具目录与 `tool id` / `check_cmd` 的唯一来源。
- 常用入口包括 `list`、`check all`、`preset minimal --dry-run`、`preset minimal`。

当前问题是需求语义过宽，尚未确定“简化”落在哪个层面：仓库结构、安装流程、配置面，还是综合治理。因此还不能直接形成单一路径的实现方案。

## Goal and Success Criteria

### Goal
把“简化项目”收敛成一个可执行的改造任务，使后续执行 agent 能在明确范围内实施，并给出可验证的验收方式。

### Success Criteria
- 明确本次简化的主对象（例如安装流程、仓库结构、配置面或多项组合）。
- 明确本次简化主要服务的痛点（首次上手、维护成本、理解成本或决策过多）。
- 明确 in-scope / out-of-scope，避免后续改造发散。
- 明确至少一组可执行的验证命令或人工检查步骤。

### Non-Goals
- 当前阶段不直接实施代码或脚本改动。
- 不在目标未锁定前擅自扩大为全仓库重构。

## Scope and Constraints

### In Scope
- 通过访谈收敛“简化项目”的目标、痛点、边界与验收方式。
- 基于仓库既有约定，为后续实现整理一份可执行 PRD。

### Out of Scope
- 当前阶段不修改 `install-script/`、`docs/`、`nvim/` 或其他代码/配置文件。
- 不在未确认前默认改变 GitHub 认证方式、Ubuntu 兼容边界或 OpenHarmony 相关内容。

### Constraints
- 仓库固定路径为 `~/hpf_Linux_Config`。
- 安装相关改造必须优先考虑 `agent-runner.py` 作为统一入口。
- `agent-tools.json` 作为工具元数据单一来源，不应被旁路。

## Technical Design and Execution Plan

当前处于 discovery 阶段，先按以下顺序闭合关键分支：
1. 确认“简化”的主要对象。
2. 确认本次简化主要解决的痛点。
3. 在对象和痛点确定后，再确认是否需要保持现有 runner/preset 兼容。
4. 最后确认验收口径：是以更少命令、更少目录跳转，还是更少决策分支为主。

在上述分支未闭合前，不进入具体实现设计。

## Run and Test Instructions

当前阶段的验证方式是需求收敛验证，而非代码测试：
- 检查 PRD 是否明确记录目标对象、主痛点、范围与非目标。
- 检查 PRD 是否包含后续实现应执行的最小验证命令占位。

实现阶段的具体测试命令待目标锁定后补充，预计会优先围绕以下命令设计验收：
- `python3 install-script/agent-runner.py list`
- `python3 install-script/agent-runner.py check all`
- `python3 install-script/agent-runner.py preset minimal --dry-run`

## Deliverables and Acceptance

### Deliverables
- 一份收敛后的 PRD，说明本次“简化项目”的目标、范围、设计边界、风险与验收方式。

### Acceptance Method
- 用户确认 PRD 所描述的“简化对象”和“核心痛点”与真实意图一致。
- PRD 中存在明确的后续改造边界，而不是泛泛而谈的“优化项目”。

## Risks and Unknowns

### Top Risks
- 将“简化项目”误判为全仓库大重构，导致任务失控。
- 在未确认用户优先级前，错误聚焦于安装流程而忽略真正痛点。

### Unknowns
- 本次简化优先面向谁：新机器初始化者、仓库维护者还是日常使用者。
- 是否允许改变现有 preset / runner 的外部使用方式。
- 是否只做单点收敛，还是允许跨目录综合治理。

### Assumptions
- 基于仓库说明，安装流程与执行入口是最可能的简化焦点，但这仍需用户确认。

### Rollback Path
- 当前阶段仅产出 PRD，无代码变更，不涉及技术回滚。

## Agent Execution Notes

后续执行 agent 在 PRD 确认后应：
- 仅按最终锁定的简化范围实施改造，避免顺手扩大范围。
- 提供最小验证证据，至少覆盖一个 `agent-runner.py` 命令路径或对应的结构/文档检查。
- review 重点放在：入口是否收敛、兼容边界是否被破坏、文档与执行路径是否一致。
- 若实现失败，应先回退到不改变现有默认入口与兼容边界的保守方案。

## Open Questions

当前仍待确认：
- “简化项目”主要指哪一层。
- 这次简化主要要解决哪类痛点。
- 是否接受兼容性变化以换取更少的命令/结构复杂度。