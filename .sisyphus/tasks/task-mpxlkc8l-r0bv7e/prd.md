# PRD: 提升安装流程检查准确性

## Task Context
当前仓库以 `install-script/` 作为安装与检查主入口，runner 通过 `install-script/agent-runner.py` 编排各类工具安装、检查与预设执行，工具目录以 `install-script/agent-tools.json` 为准，安装任务阅读顺序也明确要求先看 `docs/agent-install-playbook.md` 再进入对应脚本。

本次需求的目标不是扩展安装能力，而是让安装流程里的检查判断更可信，减少误报失败、漏报和不稳定的通过/失败结果。用户已明确优先级为：`安装流程` -> `检查准确性` -> `小步修`。

## Goal and Success Criteria
### Goal Statement
收紧安装流程中的检查逻辑，让 runner / check 的结果更接近真实安装状态。

### Non-Goals
- 不做大范围流程重整。
- 不新增新的工具安装能力或新的 preset 组合。
- 不改动与安装检查无关的其他仓库模块。

### Done Definition
- `check` 结果不再因为已知的判定问题而误报失败。
- 检查失败时能更准确地反映真实缺失项或异常项。
- 变更保持命令兼容，现有常用入口仍可用。
- 至少覆盖 `agent-runner.py` 的关键检查路径，并补足对应验证。

## Scope and Constraints
### In Scope
- `install-script/agent-runner.py` 的检查/判定路径。
- 与检查准确性直接相关的 `install-script/agent-tools.json` 解析或消费逻辑。
- 如有必要，补充最小范围的说明文档，确保检查含义与实际行为一致。

### Out of Scope
- 新增工具。
- 调整无关 preset 的整体结构。
- 重写安装架构。
- 修改 `openharmony/`、`nvim/` 等与默认安装链路无关的内容。

### Constraints
- 保持现有命令兼容，尤其是 `list`、`check`、`preset` 这些入口。
- 变更要可在本地通过 runner 复现和验证。
- 优先小步修复，避免引入跨目录联动重构。

## Technical Design and Execution Plan
### Design Boundary
以“检查判定可信度”为边界，只修正导致误报/漏报的逻辑，不顺手做无关重构。

### Steps
1. 定位 runner 中的检查决策链，梳理哪些检查属于真实前置条件，哪些属于可选/软失败。
2. 找出当前误报来源，优先处理判定条件、默认值、依赖顺序或状态采集错误。
3. 在最小改动范围内修正检查逻辑，避免改变命令表面接口。
4. 若输出信息不足以定位失败原因，补充最小必要的错误说明。
5. 为修复路径补回归验证，确保同类问题不会再次被误判。

### Milestones
- M1: 确认误报/漏报来源。
- M2: 完成 runner/check 修复。
- M3: 通过本地验证并补齐回归证据。

## Run and Test Instructions
### Minimum Verification Commands
- `python3 install-script/agent-runner.py list`
- `python3 install-script/agent-runner.py check all`
- `python3 install-script/agent-runner.py preset minimal --dry-run`

### Manual Smoke
- 确认 `list` 能正常列出工具与预设。
- 确认 `check all` 的通过/失败结果与实际状态一致。
- 确认 `preset minimal --dry-run` 不因检查逻辑而产生误报失败。

### Fallback Evidence
如果某些工具依赖本机环境，无法在当前机器完成完整安装验证，则至少提供：
- runner 相关检查命令输出。
- 触发前后的差异说明。
- 对应代码路径与修复点的对照说明。

## Deliverables and Acceptance
### Deliverables
- 代码修复。
- 必要的最小回归测试或检查补充。
- 如有必要的说明文档更新。

### Acceptance Method
- `check` 的结果可重复、稳定，且不再出现已确认的误报。
- 修复后的行为能被上述最小验证命令覆盖。
- 变更范围与小步修的约束一致。

## Risks and Unknowns
### Risks
- 检查判定可能依赖环境变量、外部工具安装状态或平台差异。
- 某些误报可能来自多个层次叠加，单点修复不够，需要确认根因。

### Unknowns
- 当前最主要的误报点尚未在本阶段通过代码读取确认。
- 是否需要同步更新说明文档，取决于最终修复是否改变输出语义。

### Assumptions
- 现有安装主入口仍以 `install-script/agent-runner.py` 为中心。
- `install-script/agent-tools.json` 仍是工具与检查配置的事实来源。

## Agent Execution Notes
- 执行 agent 只处理安装流程检查准确性相关改动。
- 优先修正 runner/check 的真实逻辑问题，不要扩大为架构重构。
- 变更后必须提供命令级验证证据。
- review 时重点关注：误报是否消失、失败原因是否更准确、兼容性是否保持。
- 若需要回滚，回退范围应限制在 runner/check 的最小改动集。

## Supporting References
- `docs/agent-install-playbook.md`
- `install-script/agent-runner.py`
- `install-script/agent-tools.json`
