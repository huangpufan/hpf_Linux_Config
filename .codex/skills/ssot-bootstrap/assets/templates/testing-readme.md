# 测试策略

<!-- 模板实例化说明：写入渲染后的 SSOT 文件前，必须把标题、表格标签、占位符和辅助说明翻译为 Phase 0 或 STATUS.md 锁定的 documentation_language。代码标识符、路径、命令、API 名、枚举值和直接引用保持原文。 -->

> 本区域记录测试策略、测试命令、fixture 约束和高风险回归保护。只记录为什么这样测和何时运行；完整测试实现以测试代码为准。

## 测试一眼看懂 / Reader Map

| 读者问题 | 一句话答案 | 权威位置 | Evidence | 风险 / 前置条件 |
|---|---|---|---|---|
| 改动后先跑什么测试？ | | [测试命令](#测试命令) | | |
| 测试层级为什么这样划分？ | | [测试策略](#测试策略) | | |
| 哪些测试保护历史 bug？ | | [防御性测试来源](#防御性测试来源) | | |

## 测试策略

用短叙述说明测试层级、边界和取舍。若无测试，写 `not_applicable`、原因和风险。

| Test level | 覆盖内容 | 为什么这样划分 | Evidence | Known risk |
|---|---|---|---|---|
| unit / integration / e2e / performance / manual | | | test config / CI / fixture | |

## 测试命令

> 若命令来自脚本清单、外部资料或自动摘要，仍需回到 package manifest、CI、测试配置或实际运行验证。

| Command | Purpose | Test level | Required setup | Evidence | Known risk |
|---|---|---|---|---|---|
| | | unit / integration / e2e / performance / manual | | package.json / CI / Makefile / test config | |

## Fixtures / 测试数据

| Fixture / 数据源 | 用途 | Owner | 更新风险 | Evidence |
|---|---|---|---|---|
| | | | | |

## 防御性测试来源

> 只记录删除后会让历史 critical / major / recurred bug 复发的关键测试；不要求穷尽。

| 测试 | 防御的 failure mode | 关联 bug / gotcha | Evidence | 删除风险 |
|---|---|---|---|---|
| | | | | |

## 开放缺口

| Gap / unknown | 所需证据 | 阻塞级别 |
|---|---|---|
| | | blocking / non-blocking |
