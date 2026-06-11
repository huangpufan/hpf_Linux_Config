# Commit 级审查参考

本文件是主动追赶中 Commit 审查部分的详细执行参考，仅在执行 commit 级全量审查或决策推翻时按需阅读。

---

## 目录

- [执行流程](#执行流程)
- [规模自适应策略](#规模自适应策略)
- [Diff 到区域的映射指南](#diff-到区域的映射指南)
- [级联检查](#级联检查)
- [Doctor 验真](#doctor-验真)

## 执行流程

独立于任务执行，对 `tracked_commit..HEAD` 的 diff 做全量扫描：

```text
1. 读取 STATUS.md 的 tracked_commit、tracked_skill_version、documentation_language 和 documentation_language_evidence
2. 评估变更规模（见下方"规模自适应策略"）
3. 根据量级选择处理策略，获取 diff
4. 按 [`update-routing.md`](../../ssot-closeout/references/update-routing.md) 将 diff 中的文件变更映射到受影响的区域
   - 遇到重复 fix / revert / hotfix 时，按具体 failure mode 聚类，不按宽泛主题合并
   - 遇到 `AGENTS.md`、`CLAUDE.md`、`.cursor/rules/*`、`.windsurf/rules/*`、`GEMINI.md` 或等价启动参考文件变更时，先按 [`source-material.md`](../../ssot-preflight/references/source-material.md) 分类，再执行 核心参考文档审查；不要只按薄适配器结构处理
5. 逐区域检查：当前文档是否仍然准确？
6. 更新所有受影响区域的内容；新增/修改的 SSOT 正文、标题和表格标签必须使用 `documentation_language`
7. 请求独立 reviewer 审查本次 commit 审查范围、受影响区域更新和任何 `no-op` / `无需更新` 结论
   - reviewer 返回 `no-more-required-changes` → 继续
   - reviewer 返回 `needs-fix` → 按 剩余修改项 修复后回到步骤 7
8. 更新 STATUS.md：
   - 推进 tracked_commit 到当前 HEAD（或段尾 commit）
   - 更新各区域的状态
   - 更新 open gaps
   - 更新 open adjudications（新增冲突、解决已裁决项、或标记延期/替代）
   - 记录停止审查闸门证据
```

---

## 规模自适应策略

在获取完整 diff 之前，Agent 先用 `git diff --stat tracked_commit..HEAD` 评估变更规模。度量指标是 **diff 行数**（insertions + deletions 总和），而非 commit 数量——1 个 commit 可能改 5000 行，100 个 commit 可能每个只改 1 行。

| 量级 | diff 行数 | 策略 |
|---|---|---|
| S | < 1000 行 | 直接全量 diff，按现有流程单次处理 |
| M | 1000–5000 行 | 全量 diff 仍可行，但建议按 merge commit 或 release tag 拆分为逻辑段，保留 commit message 语义 |
| L | 5000–20000 行 | 必须分段处理（见分段策略），启用中间检查点 |
| XL | 20000+ 行 | 对高变更区域考虑"重新提取"而非逐 diff 追踪 |

> 阈值是经验参考值，Agent 应结合变更集中度（分散在 100 个文件 vs 集中在 3 个文件）和自身上下文窗口余量综合判断。

### 分段策略

当量级 >= L 时：

1. 识别自然边界：release tag > merge commit > 时间窗口（周为单位）
2. 用 `git diff --stat` 验证每段的行数是否降到 M 级以下；若仍过大，继续细分
3. 逐段处理，每段完成并通过独立停止审查 后，推进 `tracked_commit` 到段尾 commit
4. 如果某段的 diff 仍然过大且无法按时间边界拆分，按文件类型分批（先处理配置/接口层，再处理实现层）

### 中间检查点

Agent 可在任何段处理完成后将 `tracked_commit` 推进到该段的终止 commit：

- 推进前确认该段涉及的区域已更新
- 推进前必须有独立 reviewer 对该段返回 `no-more-required-changes`
- `coverage_result` 设为 `catching_up`（表示正在追赶，尚未到达 HEAD）
- 到达 HEAD 后，只有最终范围停止审查通过，`coverage_result` 才能恢复为 `converged`；否则保持 `in_progress`

### XL 量级的"重新提取"判断

当某个区域涉及的文件在 diff 中变更比例超过 50% 时（如 `architecture/` 对应 domain 下大量文件重组），对该区域直接从 HEAD 代码重新提取，而非试图从 diff 理解变更链。其他低变更区域仍按 diff 增量更新。

判断依据：该区域映射到的文件中，被 diff 触及的文件数占该区域总文件数的比例。

---

## Diff 到区域的映射指南

Diff 文件类型到区域映射以 [`update-routing.md`](../../ssot-closeout/references/update-routing.md) 为语义所有者。Commit 审查只负责把 `tracked_commit..HEAD` 的 diff 输入到该映射，并逐区域验证当前 SSOT 是否仍准确。

当 diff 涉及 README/docs/ADR/runbook/PRD、核心参考文档或其他源资料时，按 [`source-material.md`](../../ssot-preflight/references/source-material.md) 执行分类、吸收、薄文档检查和冲突裁定，并同步 `STATUS.md` 源资料吸收矩阵。

当 diff 涉及 `AGENTS.md`、`CLAUDE.md`、`.cursor/rules/*`、`.windsurf/rules/*`、`GEMINI.md` 或等价启动参考文件时，还必须同步 `STATUS.md` 的 核心参考文档审查 表：

- `[ADAPTER]` 只检查 SSOT-generated 薄适配器的 marker、体积、可选 source hash 和摘要边界；无 marker 的手写 / mixed 文件不因缺 marker 报此标签。
- `[CONSUMPTION]` 检查启动参考文件是否把 Agent 引到 `SSOT/` 或 `$ssot-*`，以及 `SSOT/README.md` 导航入口是否存在。
- `[CORE-REF]` 检查其中的命令、目录地图、工作流状态、架构约束、模型/配置规则、测试策略和 Agent 操作前置条件是否仍与代码、manifests、CI、SSOT 和当前协议一致。
- 输出必须包含具体建议动作：`update-doc`、`thin-adapterize`、`absorb-to-SSOT`、`record-conflict` 或 `no-op`。

---

## 级联检查

高影响变更和决策推翻的级联检查以 [`update-routing.md`](../../ssot-closeout/references/update-routing.md) 为语义所有者。Commit 审查命中对应场景时，按该文件检查关联区域集；未命中时，不做机械全量扫描。

---

## Doctor 验真

Doctor 是主动追赶的默认附带步骤，也可独立运行。它不追赶新变更，而是验证已有 SSOT 内容是否仍然可信。

完整检查清单、architecture 硬阻断、输出标签和 `passed` / `no-op` review 规则见 [`doctor.md`](../../ssot-doctor/references/doctor.md)。Commit 审查只负责把 `tracked_commit..HEAD` 的代码变更映射到受影响权威位置；Doctor 结果和任何 Doctor 停止结论必须按 `doctor.md` 单独处理并记录 停止审查。
