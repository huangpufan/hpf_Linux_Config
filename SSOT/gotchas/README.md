# 已知陷阱

| 触发条件 | 陷阱 | 应对方式 | 证据 |
|---|---|---|---|
| 安装任务一开始就翻旧脚本 | 会绕过 runner 与 catalog 约束，导致流程漂移 | 先读 `AGENTS.md`、playbook，再走 runner | AGENTS、playbook |
| 把脚本 exit 0 当成最终成功 | 环境可能仍未满足 `check_cmd` | 必须执行对应 `check` | playbook |
| dotfiles 安装脚本引用旧 `basic/` 子目录 | `basic/bash`、`basic/tmux` 已不是运行时配置权威，缺失路径会让新机初始化失败 | 链接 `home/` 下的权威文件，并让 `check_cmd` 验证 symlink target | `bashrc-init.sh`、`config-install.sh`、catalog |
| Ubuntu 24.04 仍按旧 `sources.list` 换源 | 会改错系统文件 | 按 `ubuntu.sources` 路径处理 | AGENTS、setup docs |
| 默认直接切 GitHub SSH | 会引入额外副作用与认证复杂度 | 先 `github-auth`，明确需要时再 `github-ssh` | README、setup docs |
