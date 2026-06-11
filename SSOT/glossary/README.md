# 术语表

| 术语 | 含义 | 证据 |
|---|---|---|
| runner | 指 `install-script/agent-runner.py`，是安装与检查任务的统一入口。 | AGENTS、playbook |
| tool id | `agent-tools.json` 中每个工具/预设的稳定标识。 | `agent-tools.json` |
| check_cmd | 工具或预设的唯一状态验证命令，是安装验收真相。 | playbook、`agent-tools.json` |
| preset | 对多个安装步骤的组合封装，如 `minimal`、`dev-cli`。 | preset docs |
| setup | 系统与账号配置类脚本，如 Git 身份、GitHub 认证、换源。 | setup docs |
| basic | 基础环境引导脚本层。 | README / 目录结构 |
| agent-first | 文档和流程优先为 agent 可执行性设计：先探测、后执行、最后验证。 | README、playbook |
