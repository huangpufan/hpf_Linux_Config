# 薄适配器协议

本文件是 SSOT 与 Agent harness 指令文件（AGENTS.md、CLAUDE.md、.cursor/rules 等）之间“薄适配器”关系的语义所有者。创建或维护 Agent 指令文件、Bootstrap 骨架创建、Doctor 检查生成型适配器文件形态时按需阅读。薄适配器是 SSOT 生成或托管的可选启动入口形态，不是所有启动文件的默认目标。若这些文件包含仓库事实、命令、工作流、架构约束或测试策略，其事实正确性由 [`source-material.md`](../../ssot-preflight/references/source-material.md)、[`status-protocol.md`](../../ssot-preflight/references/status-protocol.md) 的 核心参考文档审查 和 [`doctor.md`](doctor.md) 的 `[CORE-REF]` 检查负责；SSOT 触发链路由 `[CONSUMPTION]` 检查负责。

## 目录

- [1. 原则](#1-原则)
- [2. 适配器内容规范](#2-适配器内容规范)
- [3. 生成时机](#3-生成时机)
- [4. Doctor 集成](#4-doctor-集成)
- [5. 反模式](#5-反模式)

## 1. 原则

SSOT 是 canonical；由 SSOT 生成 / 托管的启动入口应保持薄适配器形态。手写或 mixed 启动文件可以保留仓库命令、工作流、架构约束、模型/配置规则或测试策略，但这些长期事实必须接受 `[CORE-REF]` 审查。

- **唯一权威位置**：长期知识只在 `SSOT/` 中维护。AGENTS.md、CLAUDE.md、.cursor/rules 等文件里的长期事实要么被吸收并指向 SSOT，要么在 核心参考文档审查 中标明仍需保留和复核。
- **生成型适配器是路由器**：带 `<!-- SSOT-generated ... -->` marker 的适配器职责是告诉 Agent "去读 SSOT"，而非复述 SSOT 内容。
- **生成物可重建**：生成型适配器可以随时从 SSOT 重新生成，丢失不影响长期知识。
- **不覆盖用户内容**：生成适配器前检查目标文件是否已存在且非 SSOT 生成（无 generated marker），有冲突时报告而非覆盖。
- **角色分离**：`[ADAPTER]` 只检查 SSOT-generated 薄适配器的 marker、体积、可选 source hash 和摘要边界；`[CONSUMPTION]` 检查启动/参考文件是否形成有效 SSOT 触发链路；`[CORE-REF]` 检查启动/参考文件里的事实是否仍正确。无 marker 的手写文件不因缺 marker 报 `[ADAPTER]`。

权威关系：

| 类型 | 形态 | 检查路径 |
|---|---|---|
| `thin-adapter` | 带 SSOT-generated marker，只含 SSOT 路由和少量摘要 | `[ADAPTER]` + `[CONSUMPTION]`；摘要越界时给 `[CORE-REF]` 建议 |
| `mixed` | 手写或生成文件中既有 SSOT 路由，又有命令、工作流、架构、测试或配置事实 | `[CONSUMPTION]` + `[CORE-REF]`；仅当带 generated marker 时再做 `[ADAPTER]` |
| `source-material` | 主要是手写源资料，可能没有 SSOT 路由 | `[CORE-REF]`；若项目期望 Agent 自动消费 SSOT，再给 `[CONSUMPTION]` 建议 |

---

## 2. 适配器内容规范

生成型薄适配器文件不超过 50 行，包含以下区块：

| 区块 | 必需 | 说明 |
|---|---|---|
| Generated marker | 是 | 首行注释 `<!-- SSOT-generated | generated_at: ... -->`，标明由 SSOT 生成，含生成日期 |
| SSOT 源 hash 行 | 推荐 | 第二行注释 `<!-- SSOT-source: <path>@<hash> ... -->`，记录生成所依据的 SSOT 源文件及内容 hash，供 ssot-lint 漂移校验 |
| 项目身份 | 是 | 一句话定位，来自 `SSOT/identity/` |
| SSOT 读取指令 | 是 | 告诉 Agent 先用 `$ssot-preflight`，再按 `SSOT/README.md` 入口路由导航 |
| 核心不变量 | 推荐 | 来自 architecture 的核心不变量，不超过 5 条，使用 source-backed 或 verified 的知识 |
| 关键 gotcha 摘要 | 可选 | 最高风险的 1-3 条 active gotcha 的一句话摘要 + 指针 |

生成型薄适配器不得包含：

- 完整协议复述或区域全文
- 可从 SSOT 直接读取的详细信息
- confidence 为 hypothesis 或 candidate 的知识
- 独立维护的长期事实

---

## 3. 生成时机

| 时机 | 条件 | 动作 |
|---|---|---|
| Bootstrap Phase 1 | 侦察发现仓库已有或需要 Agent 指令文件 | 按模板生成薄适配器 |
| 用户显式要求 | 用户要求创建或更新 AGENTS.md/CLAUDE.md 等 | 按模板生成或更新 |
| SSOT 核心不变量变更 | 内联更新修改了 architecture 核心不变量 | 提醒用户适配器可能需要同步（不自动更新） |

生成前检查：

1. 目标文件是否已存在？
2. 若存在，是否含 generated marker（首行匹配 `<!-- SSOT-generated` 或等价注释）？
3. 含 marker → 可以更新。不含 marker → 报告冲突，不覆盖。
4. 冲突时报告并分类为 `mixed` 或 `source-material`；只有当仓库希望该文件改由 SSOT 托管，或长期事实已迁入 SSOT 且用户授权时，才建议替换为薄适配器。

生成方式（v2.13）：适配器由 Agent 按模板实例化，**刻意不引入独立生成器程序**以控制复杂度。生成时 `[SHOULD]` 计算所引用 SSOT 源文件的内容 hash，写入 SSOT 源 hash 行，算法 `sha256sum <file> | cut -c1-12`（无 sha256sum 时用 `shasum -a 256`，与 [`assets/scripts/ssot-lint.sh`](../assets/scripts/ssot-lint.sh) 一致）。后续由 ssot-lint 比对当前 hash 检测源漂移——这是“生成靠 Agent、校验靠脚本”的最小组合。

---

## 4. Doctor 集成

适配器检查分为 L1 确定性和 L2 语义两层，与 Doctor 分层验真协议一致。这里的 L1 只覆盖带 SSOT-generated marker 的薄适配器；手写或 mixed 启动文件不因缺 marker 或超过 50 行报 `[ADAPTER]`。这里的 L2 只覆盖“适配器摘要是否越界”；仓库命令、目录地图、工作流、架构约束、模型/配置规则或测试策略的正确性归 `[CORE-REF]`，SSOT 读取链路是否可达归 `[CONSUMPTION]`，都不归 `[ADAPTER]`。

**L1 确定性检查**（可自动判断 pass/fail）：

- SSOT-generated 薄适配器 marker 是否存在且格式正确
- 可选 `SSOT-source` hash 行是否格式正确，源文件是否存在且 hash 是否匹配
- SSOT-generated 薄适配器是否超过 50 行
- 若含 SSOT 源 hash 行：声明的源文件是否存在，且当前内容 hash 是否与声明一致（不一致提示可能 stale）

**L2 语义检查**（需 Agent 判断）：

- 适配器中的核心不变量摘要是否与 SSOT architecture 当前内容一致
- SSOT-generated 薄适配器中是否包含了不在 SSOT 中的独立事实；若包含，输出 `[CORE-REF]` 建议而不是只报 `[ADAPTER]`

输出标签：

- `[ADAPTER]`：SSOT-generated 薄适配器文件形态问题。
- `[CONSUMPTION]`：启动/参考文件的 SSOT 触发链路问题。
- `[CORE-REF]`：事实正确性、长期内容吸收、启动文件更新建议。

---

## 5. 反模式

| 反模式 | 为什么危险 |
|---|---|
| 在 AGENTS.md/CLAUDE.md 中维护独立长期事实 | 权威位置分裂，后续 Agent 无法判断哪个为准 |
| 把 SSOT 协议全文复制到适配器 | 适配器膨胀，两处维护同一规则会漂移 |
| 自动更新适配器而不提醒用户 | 用户可能在适配器中加入了非 SSOT 的 harness 特定配置 |
| 在适配器中放入 hypothesis/candidate 知识 | 不确定的知识泄漏到不受 SSOT 治理的文件中 |
| 把所有 gotcha/decision/architecture 摘要放入适配器 | 适配器应只放最高优先级的核心不变量，详细信息应从 SSOT 读取 |
| 把手写启动文件只当 `[ADAPTER]` 报告 marker/行数问题 | 会漏掉过时命令、工作流状态、架构边界或测试策略；必须另走 `[CORE-REF]` |
| 把所有启动文件默认 `thin-adapterize` | 会丢失 harness 必需的本地命令、工作流或操作约束；`thin-adapterize` 只能作为条件性建议 |
