## Task Context

当前仓库以 `install-script/` 为核心安装入口，仓库约定明确要求优先阅读 `docs/agent-install-playbook.md`，默认使用 `python3 install-script/agent-runner.py ...`，并将 `install-script/agent-tools.json` 作为唯一工具目录与 `tool id` / `check_cmd` 来源。当前需求是“优化当前项目”，经访谈已收敛为安装流程优化，且边界限定在 runner 与安装文档，不进入各具体工具安装脚本。

已确认事实与决策：
- 主目标是优化安装流程与成功率。
- 任务边界限定为 `runner + 安装文档`。
- 本轮优先解决的问题是安装入口混乱，而不是安装逻辑故障修复。
- 成功标准以首次上手成功率为中心，而不是失败后诊断速度或底层稳定性。
- 首次安装默认推荐 `minimal` preset。
- 顶层路径应收敛为单一主入口：`agent-runner.py + minimal`。
- 本轮禁止改动实际工具安装行为，只允许重构入口表达、命令组织和文档导航。
- 最小充分验收以 `list/check/dry-run` 级别证据为主，不要求真实执行 `preset minimal`。

问题陈述：当前仓库虽然已有安装说明与 runner 入口约定，但“优化”需求的实质是降低首次使用者在多个脚本、多个路径、多个 preset 面前的选择成本，避免误入历史脚本或并列入口，提升从顶层文档进入 `minimal` 安装路径的一次成功率。

## Goal and Success Criteria

### Goal

将仓库的首次安装路径收敛为一个清晰、稳定、低认知负担的主入口：用户从顶层文档出发，能够明确知道应使用 `python3 install-script/agent-runner.py`，并以 `minimal` preset 作为唯一默认起点。

### Non-Goals

- 不修改 `install-script/tools/` 下具体工具脚本的安装逻辑。
- 不修复工具自身安装失败、系统兼容性或幂等性问题，除非这些内容只体现在文档表述中。
- 不扩展到 `nvim/`、OpenHarmony、全仓库结构重组等非安装入口问题。
- 不把 `dev-cli`、`dev-full`、`all-tools` 作为并列首次推荐入口。

### Done Definition

任务完成后应满足：
- 顶层安装引导只保留一个明确主入口，并明确指向 `agent-runner.py`。
- 首次安装默认推荐 `minimal` preset，其他 preset 仅作为后续扩展路径说明。
- 文档与 runner 的命令示例、术语、入口顺序保持一致，不再鼓励用户直接查找或执行历史脚本。
- 用户仅通过文档即可完成以下认知闭环：先看哪里、先跑什么命令、如何检查状态、何时再进入其它 preset。
- 验收命令 `list`、`check all`、`preset minimal --dry-run` 能作为文档中主路径的直接证据出现并被执行 agent 用于验证。

## Scope and Constraints

### In Scope

- 调整 `docs/agent-install-playbook.md` 及与首次安装主路径直接相关的安装文档表述。
- 调整 `install-script/agent-runner.py` 的入口表达、帮助信息、命令组织或输出文案，只要这些变更不改变真实安装行为。
- 调整与主入口表达直接相关的说明，使 `agent-tools.json` 继续作为唯一工具目录来源。
- 重新组织对 `minimal`、`dev-cli`、`dev-full`、`all-tools` 的介绍顺序，突出 `minimal` 的默认地位。

### Out of Scope

- 修改任一工具安装脚本的真实安装逻辑。
- 调整工具定义本身、`check_cmd` 语义或工具依赖图。
- 改造具体 preset 的实际组成，除非只是文档说明层面的重新排序或澄清。
- 新增安装系统、替换 runner 架构、引入新的顶层入口脚本。

### Constraints

- 必须保留 `python3 install-script/agent-runner.py ...` 作为唯一推荐执行入口。
- 必须保留 `install-script/agent-tools.json` 作为工具目录和检查命令来源，不建立第二套目录。
- 文档必须兼容 Ubuntu 20.04 / 22.04 / 24.04 的既有约定，但本任务不负责验证真实安装结果。
- 本轮验收不依赖真实副作用安装，重点是主路径清晰且 dry-run/check 证据自洽。

## Technical Design and Execution Plan

### Design Boundary

本任务是一次“安装入口收口”而不是“安装系统重构”。设计重点是减少首次使用者的入口分叉，建立清晰顺序：
1. 顶层说明先指向 `docs/agent-install-playbook.md`。
2. 文档明确 `python3 install-script/agent-runner.py preset minimal` 是唯一默认起点。
3. `list`、`check all`、`preset minimal --dry-run` 作为进入真实安装前的理解与验证链路。
4. 其他 preset 与具体子目录（`setup/`、`basic/`、`tools/`）降级为二级说明，不与主入口并列竞争。

### Execution Steps

1. 审阅当前 `docs/agent-install-playbook.md`、`install-script/agent-runner.py`、`install-script/agent-tools.json` 与顶层安装相关说明，找出并列入口、旧路径、命令顺序不一致、preset 推荐不清的问题。
2. 重写或重排首次安装文档结构，确保用户先看到主入口、再看到检查命令、最后看到扩展 preset。
3. 如有必要，调整 runner 的帮助文本、示例命令或输出提示，使其与文档使用同一术语与推荐顺序。
4. 确认所有文档与提示中对工具目录来源的描述统一指向 `agent-tools.json`。
5. 用只读与无副作用命令完成验证，确保主路径与文档闭环成立。

### Milestones

- M1：定位现有入口分叉与文档不一致点。
- M2：完成单一主入口文案与命令顺序收口。
- M3：完成 runner 帮助信息与文档对齐。
- M4：以 `list/check/dry-run` 证据完成验收。

### Change Impact

受影响内容应主要集中在：
- 安装文档的导航顺序与推荐命令。
- runner 的用户可见帮助文案或提示信息。
- 首次上手用户对 preset 选择的心智模型。

不应影响：
- 单工具安装行为。
- 已有工具定义数据。
- 真实安装结果与系统状态。

## Run and Test Instructions

### Test Commands

后续执行 agent 至少应运行以下命令作为最小充分验证：

```bash
python3 install-script/agent-runner.py list
python3 install-script/agent-runner.py check all
python3 install-script/agent-runner.py preset minimal --dry-run
```

### Manual Smoke

执行 agent 应手工检查以下内容：
- 从顶层安装说明出发，是否只会看到一个明确主入口。
- `minimal` 是否被清晰定义为首次安装默认推荐，而非多个 preset 并列推荐。
- 文档中是否明确说明 `check all` 与 `--dry-run` 的作用和顺序。
- 文档或帮助文本中是否仍然鼓励用户直接进入历史脚本或手动翻找 `install-script/` 子目录作为首次路径。

### Fallback Evidence

如果某些命令因本地环境缺失而无法完整执行，至少要提供：
- runner `--help` 或等效帮助输出中主入口与示例命令的证据。
- 文档截图或 diff 证据，证明主路径已收敛为单一入口。
- 对无法执行命令的具体原因说明，而不是笼统写“未测试”。

## Deliverables and Acceptance

### Deliverables

- 一组收敛后的安装文档改动，明确单一主入口与 `minimal` 默认路径。
- 一组与文档一致的 runner 用户可见提示或帮助文案改动（如需要）。
- 一份最小验证证据，覆盖 `list`、`check all`、`preset minimal --dry-run`。

### Acceptance Method

验收通过需同时满足：
- 文档中只存在一个首次安装主入口。
- 主入口明确使用 `python3 install-script/agent-runner.py`。
- 主入口明确推荐 `minimal` preset。
- 其他 preset 被降级为扩展路径，而非首次路径。
- 最小验证命令能够支撑文档中描述的路径，不出现命令与文档脱节。

### Traceability Req to Test

- “单一主入口” 对应文档审阅与 runner 帮助输出检查。
- “默认 `minimal`” 对应文档审阅与 `preset minimal --dry-run`。
- “工具目录唯一来源” 对应对 `agent-tools.json` 引用的一致性检查。
- “首次上手成功率提升” 对应首次阅读路径是否无需在多个入口间做额外判断的手工审阅。

## Risks and Unknowns

### Top Risks

- 只改文档和入口文案，可能无法解决隐藏在真实安装逻辑中的失败问题；但这是本轮明确接受的边界。
- 历史脚本或旧文档若仍在其他位置暴露，可能继续形成隐性并列入口。
- runner 当前帮助信息若结构受限，可能需要有限代码调整才能与文档对齐。

### Unknowns

- 当前顶层是否还存在未被访谈覆盖的安装入口文件或 README 段落，需要执行阶段先排查。
- `agent-runner.py` 当前帮助输出是否已经足够承载推荐路径，需实际检查后决定是否修改。

### Assumptions

- `minimal` preset 已可作为首次安装的最小可用路径，无需在本任务内调整其具体组成。
- `list/check/dry-run` 足以作为本轮入口优化的最小充分验证证据。

### Rollback Path

如果调整后的文档导航或帮助文本引起歧义，可回滚到本轮修改前的文档/提示变更；由于本任务不改真实安装逻辑，回滚应仅涉及文档与 runner 的用户可见文本。

## Agent Execution Notes

### Handoff Boundary

后续执行 agent 只负责：
- 修改安装文档与 runner 用户可见入口提示。
- 验证单一主入口是否成立。
- 产出最小验证证据。

后续执行 agent 不负责：
- 修改工具安装脚本逻辑。
- 修复真实安装失败。
- 扩展到全仓库结构整理。

### Verification Evidence

执行结果中应明确给出：
- 修改了哪些文档/文件。
- `list`、`check all`、`preset minimal --dry-run` 的关键结果摘要。
- 若有命令无法执行，提供阻塞原因与替代证据。

### Review Focus

review 时重点检查：
- 是否真的消除了并列首次入口，而不是只换了措辞。
- 是否把 `minimal` 明确设为唯一默认起点。
- 是否意外改动了实际安装行为或工具定义。
- 文档与 runner 术语是否完全一致。

### Commit Push Policy

执行 agent 完成后应提交一个聚焦本任务的单独 commit。提交说明应突出“安装入口收口 / 单一主入口 / minimal 默认路径”主题。除非用户后续明确要求，否则不要求在本阶段处理额外优化项。