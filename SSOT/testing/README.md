# 测试策略

> 当前仓库的主要验证方式不是单元测试，而是通过 runner 调用 `check_cmd` 回读真实机器状态。换句话说，这个仓库的“测试”更接近安装验收与环境自检。

## 核心策略

| 策略 | 说明 | 证据 |
|---|---|---|
| `check_cmd` 为主 | 每个 tool/preset 通过 catalog 定义自己的验证命令。 | `agent-tools.json` |
| preset 成员汇总验收 | preset 的 `check_cmd` 调用 `presets/check-preset.py`，逐项运行成员 tool 的 `check_cmd`。 | `agent-tools.json`、`presets/check-preset.py` |
| runner 区分执行失败与验收失败 | 脚本 exit 非 0 与 check 失败是两个结果。 | playbook |
| 高风险区域保留专项验证 | 例如 Neovim 通过 `nvim-verify.sh` 做更细检查。 | playbook |

## 常用验证命令

| 场景 | 命令 | 目的 | 证据 | 风险 |
|---|---|---|---|---|
| 查看全目录 | `python3 install-script/agent-runner.py list` | 确认 catalog 可解析 | runner | 不验证状态 |
| 单项验收 | `python3 install-script/agent-runner.py check <tool>` | 验证 конкрет tool 状态 | playbook | 外部认证类工具可能受账户状态影响 |
| Dotfiles 验收 | `python3 install-script/agent-runner.py check bashrc` / `python3 install-script/agent-runner.py check configs` | 验证 `.bash-*`、`.tmux.conf`、herdr 配置链接指向仓库 `home/` 权威文件 | catalog | 只能证明链接目标，不证明交互式 shell 已重新 source |
| Preset 验收 | `python3 install-script/agent-runner.py check preset-minimal` / `python3 install-script/presets/check-preset.py dev-full` | 汇总 preset 成员工具状态 | catalog、helper script | 仍是当前主机状态检查，不会执行安装 |
| 个人 bootstrap 前置保护 | 非 `hpf` 环境模拟 `python3 install-script/agent-runner.py preset bootstrap` | 确认 runner 在 sudo 前要求 `HPF_BOOTSTRAP_CONFIRM_PERSONAL=yes` 和 `HPF_GIT_EMAIL` | runner | 只验证保护分支，不执行真实 bootstrap |
| 全量盘点 | `python3 install-script/agent-runner.py check all` | 快速查看环境覆盖情况 | AGENTS | 输出多，需按失败项回溯 |
| Neovim 深验 | `python3 install-script/agent-runner.py check nvim` / `install-script/nvim/nvim-verify.sh` | 覆盖 headless 启动、插件、provider 等 | playbook | 环境差异大 |

## 验收不变量

| 不变量 | 为什么重要 | 证据 |
|---|---|---|
| 新工具必须定义 `check_cmd` | 否则无法自动验收 | tools README / catalog |
| 新增/删除 preset 成员必须同步 `check-preset.py` | 否则 preset 验收会和实际安装承诺漂移 | preset scripts / helper script |
| 只读 README 不能替代真实验证 | 安装脚本是否成功必须由实际系统状态说话 | playbook |
| 认证/外部依赖类工具要明确失败来源 | 方便区分脚本 bug 与外部条件未满足 | setup docs / playbook |

## 已知测试缺口

| Gap / unknown | 所需证据 | 阻塞级别 |
|---|---|---|
| 缺少统一 CI 对所有脚本做自动回归 | 若引入 CI 配置再吸收 | non-blocking |
| 大量验证依赖真实主机环境 | 需要容器/虚拟机矩阵时再补 | non-blocking |
