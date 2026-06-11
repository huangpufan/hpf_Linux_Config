# 开发工作流

<!-- 模板实例化说明：写入渲染后的 SSOT 文件前，必须把标题、表格标签、占位符和辅助说明翻译为 Phase 0 或 STATUS.md 锁定的 documentation_language。代码标识符、路径、命令、API 名、枚举值和直接引用保持原文。 -->

> 本区域记录如何把项目跑起来，以及新 Agent 写代码时必须遵守的开发约定。只记录长期有用的语义、前置条件和风险；完整脚本源码以代码仓库为准。

## 开发一眼看懂 / Reader Map

| 读者问题 | 一句话答案 | 权威位置 | Evidence | 风险 / 前置条件 |
|---|---|---|---|---|
| 如何启动本地开发？ | | [本地运行](#本地运行) | | |
| 哪些脚本/工具常用且有前置条件？ | | [脚本 / 工具目录](#脚本--工具目录) | | |
| 新增功能时遵守哪些代码模式？ | | [模式语言](#模式语言) | | |

## 本地运行

用短叙述说明本仓库的开发路径：依赖如何安装，服务如何启动，哪些步骤必须先后执行。

| 场景 | 命令 | 目的 | Required setup | Evidence | Known risk |
|---|---|---|---|---|---|
| | | | | package.json / Makefile / Dockerfile / docs | |

## 脚本 / 工具目录

> 若存在脚本目录、package manifest、CI、Makefile 或配置中的工具入口，按语义吸收。不要复制脚本源码；只记录用途、何时使用、证据和风险。若没有此类脚本，写 `not_applicable` 和原因。

| Filename | Purpose | Category | When to use | Evidence | Risk or prerequisite | Architecture link if any |
|---|---|---|---|---|---|---|
| | | build / dev-server / codegen / lint-format / diagnostics / other | | | | |

## 模式语言

> 只记录 linter/formatter 不能自动保证、且新 Agent 容易违反的编码约定。

| 模式 | 什么时候使用 | 为什么重要 | Evidence | Risk |
|---|---|---|---|---|
| | | | | |

## 端到端骨架流程

| 功能类型 | 需要触碰的权威位置 | 代表性示例 | 验证方式 | 风险 |
|---|---|---|---|---|
| | | | | |

## 开放缺口

| Gap / unknown | 所需证据 | 阻塞级别 |
|---|---|---|
| | | blocking / non-blocking |
