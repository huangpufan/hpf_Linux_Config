# WSL 环境基本配置安装指南

这个目录现在遵循仓库统一的 agent 流程：

1. 仓库必须位于 `~/hpf_Linux_Config`
2. GitHub 默认走 `gh + HTTPS`，不再把手工加 SSH key 当主流程
3. 先配置 git identity，再完成 GitHub 认证，然后再装基础环境

当前支持的 Ubuntu 版本：

- Ubuntu 20.04
- Ubuntu 22.04
- Ubuntu 24.04

在 Ubuntu 24.04 上，`ubuntu-source-change.sh` 会改写
`/etc/apt/sources.list.d/ubuntu.sources`，并停用
`/etc/apt/sources.list` 中仍然激活的旧 `deb` 条目，避免双源重复。

推荐顺序：

```bash
cd ~/hpf_Linux_Config
python3 install-script/agent-runner.py install gh
HPF_GIT_NAME="你的名字" HPF_GIT_EMAIL="you@example.com" \
python3 install-script/agent-runner.py install git-identity
python3 install-script/agent-runner.py install github-auth
python3 install-script/agent-runner.py install folder-create
python3 install-script/agent-runner.py install bashrc
python3 install-script/agent-runner.py install configs
```

只有明确需要 SSH 时，再额外执行：

```bash
python3 install-script/agent-runner.py install github-ssh
```
