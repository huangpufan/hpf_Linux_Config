# 重构任务清单与详细设计（v0.1）

更新时间：2025-09-28

目的：将安装脚本体系逐步重构为“可重复执行、非交互、可回滚、WSL 友好”的形态，不改变现有功能选择，仅修正不一致、隐患与易炸点。所有任务均为“最小可行修改”，按顺序逐步落地，确保每步可独立验收。

---

## 任务总览（可打勾追踪）

- [ ] [T0] 轻量化测试环境：文档与脚本（Docker/Podman）
- [ ] [T1] 底座统一：严格模式、脚本自定位、HOME 替换、公共库
- [ ] [T2] 非交互与幂等：apt/add-apt/pipx/fzf 规范化
- [ ] [T3] APT 源与密钥统一：按 codename、keyring、移除 apt-key
- [ ] [T4] 代理策略收敛：默认关闭、显式启用、统一实现
- [ ] [T5] DNS/hosts 安全化：改为可选、WSL 检测、去 chattr
- [ ] [T6] 编译器策略：默认 GCC、提供切换、避免互相覆盖
- [ ] [T7] 修复具体问题脚本：nvim/git/pip/apt-snap/clang/openharmony 等
- [ ] [T8] 顶层入口与文档：统一 Make 目标/命名、README 更正

实施顺序建议：T1 → T2 → T3 → T4 → T5 → T6 → T7 → T8

---

## 详细设计与验收标准
### [T0] 轻量化测试环境：文档与脚本（Docker/Podman）

目标：提供最自动化、最轻的安全沙箱，支持多发行版镜像；后续重构在此环境中进行验证。

范围：新增 `TEST_ENV.md`、`tools/testenv/run.sh`、`tools/testenv/matrix.sh`。

设计：
- `run.sh`：
  - 输入 `jammy|focal|IMAGE[:TAG]`，自动挑选 Docker 或 Podman；
  - 以只读挂载仓库到容器 `/mnt/ws`，复制到 `/root/ws` 后执行，避免污染宿主；
  - 自动安装最小依赖（按包管理器识别 `apt/dnf/apk/zypper`）。
- `matrix.sh`：
  - 对一组镜像批量执行同一命令，默认包含 `20.04/22.04/24.04`。
- `TEST_ENV.md`：
  - 使用说明、限制与矩阵示例。

完成标准：
- 一条命令可进入交互式容器；
- 一条命令可对多版本做批量验证；
- 容器中脚本执行不写宿主；
- snap 在容器不可用时不影响测试流程（后续任务将加入跳过逻辑）。

风险/回滚：
- 若宿主无 Docker/Podman，则任务失败并提示安装要求。

---

### [T1] 底座统一：严格模式、脚本自定位、HOME 替换、公共库

目标：在不改变行为的前提下，建立统一脚本“底座”，为后续重构提供一致的执行环境与最基本安全网。

范围：仓库内所有 `*.sh` 脚本。

设计：
1. 统一脚本头模板：
   - `#!/usr/bin/env bash`
   - `set -Eeuo pipefail`
   - `trap 'echo "[ERROR] $0:$LINENO: $BASH_COMMAND" >&2' ERR`
2. 自定位与路径：
   - 每个脚本定义 `SCRIPT_DIR` 与 `REPO_ROOT`，禁止依赖当前工作目录。
   - 禁止硬编码 `/home/hpf`，一律使用 `$HOME`。
3. 公共库：新增 `lib/common.sh`，提供最小工具函数（KISS）：
   - `require_cmd`、`is_wsl`、`ubuntu_codename`、`ubuntu_version_id`
   - `apt_update_once`、`apt_install`、`add_apt_repo_once`
   - `symlink_safe`、`line_in_file`、`file_append_once`
   - `log_info/log_warn/log_err`

完成标准：
- 所有脚本可在任意当前目录下执行且行为不变；未定义变量将导致脚本立即失败并输出位置。
- 未对用户系统产生新增副作用（仅新增 `lib/common.sh`）。

风险/回滚：
- 若个别脚本存在未定义变量（如 `nvim/nvim-install.sh` 中 `ubuntu_version`），在严格模式下会提前暴露；先记录清单到 T7 修复，再临时加安全默认值避免阻断执行。

---

### [T2] 非交互与幂等：apt/add-apt/pipx/fzf 规范化

目标：消除执行过程中的交互阻塞，并保证重复执行不会重复污染或报错。

范围：涉及包安装与系统配置的脚本（`basic/apt-snap-install.sh`、`basic/pip-install.sh`、`basic/git-install.sh` 等）。

设计：
1. `apt`/`apt-get`/`add-apt-repository` 全部使用非交互参数（`-y`）。
2. `apt_update_once`：本次执行内只更新一次索引，避免频繁 `update`。
3. `pipx` 安装前确保 `python3-venv`（非交互）。
4. `fzf` 安装改为非交互选项（不自动修改 rc 文件）。
5. 幂等检查：存在性检测后再创建/追加/软链，避免重复。

完成标准：
- 在无人工输入情况下，`install-after-sshkey.sh` 能从头到尾跑完；二次执行不重复污染，不阻塞。

风险/回滚：
- 若个别工具需交互确认（极少数），以安全默认值替代，并在日志提示。

---

### [T3] APT 源与密钥统一：按 codename、keyring、移除 apt-key

目标：用现代安全方式管理第三方仓库与密钥，适配 focal/jammy 等版本。

范围：`basic/ubuntu-source-change.sh`、`basic/clang13-install.sh` 等涉及仓库与密钥的脚本。

设计：
1. 使用 `VERSION_CODENAME` 自动选择源（`/etc/os-release`）。
2. 统一使用 `gpg --dearmor` + `signed-by=/usr/share/keyrings/*.gpg`；彻底去除 `apt-key`。
3. 写入“已变更”标记，幂等检测后再修改系统源。
4. LLVM、Git PPA 等根据 codename 选择列表名与 URL，避免 22.04 写入 focal-14。

完成标准：
- 22.04 与 20.04 均可一次性正确配置仓库；重复执行不重复添加；无 `apt-key` 用法。

风险/回滚：
- 若仓库不可达，脚本失败即停；不保留半配置状态。

---

### [T4] 代理策略收敛：默认关闭、显式启用、统一实现

目标：统一代理控制，默认不启用，避免“开机自动代理”等副作用。

范围：`basic/bashrc-init.sh`、`basic/bash/aliases`、其他脚本中的临时代理段。

设计：
1. 新增 `tools/proxy.sh`：`enable_proxy` / `disable_proxy`，读取 `~/.config/hpf/proxy.env`（协议、host、port）。
2. 支持 http 或 socks5 二选一；同时设置 `apt`/`git`/环境变量；显式调用才生效。
3. 移除自动在 `.bashrc` 注入开机 `proxy` 的行为；保留别名但默认不执行。

完成标准：
- 不执行任何脚本时，环境不带代理；显式运行 `enable_proxy` 后各组件生效；`disable_proxy` 可完全关闭。

风险/回滚：
- 若用户依赖旧行为，提供一键开启脚本并在 README 标注变更。

---

### [T5] DNS/hosts 安全化：改为可选、WSL 检测、去 chattr

目标：杜绝“锁死 resolv.conf”等高风险改动；DNS/hosts 仅在用户明确需要时执行。

范围：`basic/dns-permanently-adjust.sh`、`basic/hosts-adjust.sh`。

设计：
1. 增加 `is_wsl` 检测与强提示，默认不执行；只在用户显式调用时执行。
2. 严格使用 `sudo tee` 写系统文件，不使用 `sudo echo >>`；去除 `chattr +i`。
3. `/etc/hosts` 仅在缺失时追加，可逆移除；`/etc/wsl.conf` 修改后提示“需重启 WSL 生效”。

完成标准：
- 默认安装流程不会触碰 DNS/hosts；可选脚本执行后不影响系统自恢复能力。

风险/回滚：
- 提供还原脚本，恢复原 hosts/DNS 设置。

---

### [T6] 编译器策略：默认 GCC、提供切换、避免互相覆盖

目标：避免 `update-alternatives` 相互覆盖导致默认编译器混乱。

范围：`basic/latestgccg++-install.sh`、`basic/clang13-install.sh`、`tools/makefile`。

设计：
1. 默认 `cc/gcc` 指向 GCC（如 gcc-11）；`clang` 使用 `clang/clang++` 命令，不抢占 `cc/c++`。
2. 新增 `tools/select-compiler.sh`：一键切换 gcc/clang，明确提示影响范围。

完成标准：
- 默认使用 GCC；可显式切换；重跑脚本不会无意改变默认编译器。

风险/回滚：
- 切换即刻生效，提供 `select-compiler.sh --reset` 恢复默认。

---

### [T7] 修复具体问题脚本：nvim/git/pip/apt-snap/clang/openharmony 等

目标：逐点修复已经识别出的脚本问题。

清单与改动要点：
1. `nvim/nvim-install.sh`
   - 定义 `ubuntu_version` 或改为 `UBUNTU_CODENAME` 检测；移除多余冒号行；全程幂等。
2. `basic/git-install.sh`
   - 补 shebang；`~/.fzf/install` 改为非交互参数，不改 rc。
3. `basic/pip-install.sh`
   - `sudo apt-get install -y python3-venv`；`pipx` PATH 保障；尽量用镜像但可配置。
4. `basic/apt-snap-install.sh`
   - `add-apt-repository -y`；snap 在 WSL 环境不可用时跳过或提供 APT 替代。
5. `basic/clang13-install.sh`
   - 去 `apt-key`，用 keyring + signed-by；按 codename 选择源。
6. `basic/ubuntu-source-change.sh`
   - 用 `VERSION_CODENAME` 选择源；写“已变更”标记；避免 22.04 写入 focal-14。
7. `basic/linux-repository-install.sh`
   - 修正注释/语法疏漏；目录/权限/失败处理；`git clone` 加 `--depth=1` 保留。
8. `basic/config-install.sh`
   - 补齐 neofetch/tmux 安装过程或给明确提示；保证幂等。
9. `basic/dns-permanently-adjust.sh`、`basic/hosts-adjust.sh`
   - 纳入 T5 策略；安全写入 + 还原能力。
10. `openharmony/dependencies-install.sh`
   - 移除 `zlib*` 等通配符包名；目录存在性检查；失败立刻退出；日志汇总。

完成标准：
- 上述脚本二次执行不报错；所有安装步骤非交互；WSL 环境下不会因 snap/DNS 卡死。

---

### [T8] 顶层入口与文档：统一 Make 目标/命名、README 更正

目标：对外暴露清晰稳定的入口；文档与实际目标名一致；危险操作明确为“可选”。

设计：
1. 顶层新增统一入口（`bootstrap.sh` 或 `Makefile`）：
   - `make prepare`：SSH key + 基础环境（不含可选危险项）。
   - `make dev`：nvim/tmux 等开发器配置。
   - `make optional`：hosts/DNS/代理等可选操作。
2. 修正文档中目标名错拼（如 `genarate` → `generate`），并与实际 Make 目标一致。
3. README 明示：支持 20.04/22.04，24.04 视情况提示；危险项默认不执行。

完成标准：
- 新用户只需 1-2 条命令即可完成基础环境；README 与实际一致；危险项需要显式调用。

---

## 待你确认的策略开关

- 编译器默认：是否保持 GCC 为默认 `cc`，clang 不抢占？（建议：是）
- 代理策略：默认关闭，仅显式启用时生效？（建议：是）
- DNS/hosts：改为可选脚本，默认不执行？（建议：是）
- 支持的 Ubuntu 版本：覆盖 20.04/22.04；24.04 提示或后续补？（建议：先 20/22）
- 顶层入口：采用 `Makefile` 统一还是 `bootstrap.sh`？（建议：两者皆提供）

---

## 备注

- 全过程遵循 KISS：不做花哨框架，仅最小公共库；不引入外部依赖。
- 每个任务在合入前均保持可独立执行与回滚；提交信息包含 `[T#]` 便于追踪。


