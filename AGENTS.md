# AGENTS

本仓库以 `install-script/` 为核心。凡是“安装环境”“检查安装状态”“自动化执行安装”
这类任务，不要先在历史脚本里随意翻找，先按下面的顺序读。

## 安装任务阅读顺序

1. 先读 [docs/agent-install-playbook.md](docs/agent-install-playbook.md)
2. 默认使用 [install-script/agent-runner.py](install-script/agent-runner.py)
3. 把 [install-script/agent-tools.json](install-script/agent-tools.json) 当作唯一工具目录与 `tool id` / `check_cmd` 来源
4. 再进入 `install-script/` 下对应的子目录看具体脚本

## 安装时该看哪个文件夹

- `install-script/presets/`：预设组合入口，例如 `minimal`、`dev-cli`、`dev-full`、`all-tools`
- `install-script/setup/`：系统与账号配置，例如 Git 身份、GitHub 认证、apt 镜像、npm/cargo registry
- `install-script/basic/`：基础环境引导与兼容性脚本
- `install-script/tools/`：单工具安装脚本，一个工具一个脚本
- `install-script/openharmony/`：OpenHarmony 专用环境与依赖，不属于默认机器初始化
- `nvim/`：编辑器配置，不是整机安装主入口

## 仓库约定

- 仓库路径固定为 `~/hpf_Linux_Config`
- runner 优先：优先用 `python3 install-script/agent-runner.py ...`，不要默认直接执行脚本
- `github-auth` 单工具默认走 `gh + HTTPS`
- `bootstrap` / `all-tools` 是本仓库所有者的个人新机路径，默认会生成/上传 SSH key，并把 GitHub git protocol 切到 `ssh`
- 执行 `bootstrap` / `all-tools` 前先探测当前账户；如果是 `hpf`，直接执行；如果不是 `hpf`，必须先问用户是否仍要执行个人 SSH bootstrap，并确认 Git 邮箱，获准后用 `HPF_BOOTSTRAP_CONFIRM_PERSONAL=yes` 和 `HPF_GIT_EMAIL` 执行
- 支持 Ubuntu 20.04 / 22.04 / 24.04；其中 Ubuntu 24.04 的换源走 `ubuntu.sources`，不是旧的 `sources.list`
- 所有修改完成后必须 `git add -A && git commit && git push`，不允许只改不推

## 常用命令

```bash
python3 install-script/agent-runner.py list
python3 install-script/agent-runner.py check all
python3 install-script/agent-runner.py preset minimal --dry-run
python3 install-script/agent-runner.py preset minimal
```
