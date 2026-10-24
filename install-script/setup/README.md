# Setup - 系统配置脚本

系统环境配置相关的脚本，不涉及具体工具的安装。

如果你是 agent，且任务是“安装整机环境”，不要从这个目录开始自由发挥。
先读仓库根目录 `AGENTS.md`，再读 `docs/agent-install-playbook.md`，最后再回到
这个目录执行具体 setup 步骤。

## 目录说明

这些脚本主要用于配置系统环境，包括：
- Shell 配置（bashrc）
- 目录结构创建
- 软件源配置
- Git 身份与 GitHub 认证
- 包管理器源配置

当前支持 Ubuntu 20.04/22.04/24.04。
其中 Ubuntu 24.04 的 `ubuntu-source-change.sh` 会写入
`/etc/apt/sources.list.d/ubuntu.sources`，而不是旧版的
`/etc/apt/sources.list`。

## 脚本列表

本目录（`install-script/setup/`）里的脚本：

| 脚本 | 说明 |
|------|------|
| `git-identity.sh` | 配置 git user.name / user.email |
| `github-auth.sh` | 使用 gh 完成 GitHub HTTPS 认证 |
| `github-ssh.sh` | 使用 gh 生成/上传 SSH key，并切换到 SSH |
| `npm-registry.sh` | 配置 npm 镜像源 |
| `cargo-registry.sh` | 配置 cargo 镜像源 |

下列同属 runner 目录“系统配置”一类，但脚本实际放在 `install-script/basic/`：
`bashrc-init.sh`（bashrc）、`folder-create.sh`、`ubuntu-source-change.sh`（`source-change`）、
`config-install.sh`（`configs`）。`profile-set.sh`、`hosts-adjust.sh`、`dns-adjust.sh` 也在 `basic/`，
没有 catalog 条目，runner 不会调度它们。
以 `python3 install-script/agent-runner.py list` 的输出为准。

## 使用方式

这些脚本通常应通过 runner 调用；只有在明确需要时才直接执行脚本。

推荐：

```bash
python3 install-script/agent-runner.py install git-identity
python3 install-script/agent-runner.py install github-auth
python3 install-script/agent-runner.py install source-change
```

直接脚本：

```bash
# 配置 git 身份
HPF_GIT_NAME="Your Name" HPF_GIT_EMAIL="you@example.com" \
bash install-script/setup/git-identity.sh

# 默认完成 GitHub HTTPS 认证
bash install-script/setup/github-auth.sh

# 如果确实需要 SSH，再执行
bash install-script/setup/github-ssh.sh
```
