# Setup - 系统配置脚本

系统环境配置相关的脚本，不涉及具体工具的安装。

## 目录说明

这些脚本主要用于配置系统环境，包括：
- Shell 配置（bashrc）
- 目录结构创建
- 软件源配置
- Git 身份与 GitHub 认证
- 包管理器源配置

## 脚本列表

| 脚本 | 说明 |
|------|------|
| `bashrc-init.sh` | 初始化 bashrc 配置 |
| `folder-create.sh` | 创建标准工作目录结构 |
| `ubuntu-source-change.sh` | 更换 Ubuntu apt 软件源 |
| `git-identity.sh` | 配置 git user.name / user.email |
| `github-auth.sh` | 使用 gh 完成 GitHub HTTPS 认证 |
| `github-ssh.sh` | 使用 gh 生成/上传 SSH key，并切换到 SSH |
| `npm-registry.sh` | 配置 npm 镜像源 |
| `cargo-registry.sh` | 配置 cargo 镜像源 |
| `profile-set.sh` | 配置 profile 文件 |
| `hosts-adjust.sh` | 调整 hosts 文件 |
| `dns-adjust.sh` | 调整 DNS 配置 |

## 使用方式

这些脚本通常在初始安装时运行，也可以单独运行：

```bash
# 配置 git 身份
HPF_GIT_NAME="Your Name" HPF_GIT_EMAIL="you@example.com" \
bash install-script/setup/git-identity.sh

# 默认完成 GitHub HTTPS 认证
bash install-script/setup/github-auth.sh

# 如果确实需要 SSH，再执行
bash install-script/setup/github-ssh.sh
```
