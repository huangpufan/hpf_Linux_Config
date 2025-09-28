# 轻量化测试环境（Docker/Podman）

目的：提供一次性、可丢弃、对宿主零副作用的沙箱，自动为常见发行版准备最小依赖，便于在“干净环境”中验证脚本。默认使用 Docker，如不可用自动回退 Podman。

适用：
- Ubuntu 20.04/22.04/24.04（推荐）
- 也可传入其他镜像（如 `debian:12`、`fedora:39`、`alpine:3.19` 等），脚本会尝试自动安装必需工具

---

## 准备
- 已安装 Docker 或 Podman（二选一即可）
- 本仓库在宿主机上可访问

---

## 快速开始

- 进入交互式 Ubuntu 22.04 容器：
```bash
bash tools/testenv/run.sh jammy
```

- 进入交互式 Ubuntu 20.04 容器：
```bash
bash tools/testenv/run.sh focal
```

- 指定完整镜像（示例：Ubuntu 24.04）：
```bash
bash tools/testenv/run.sh ubuntu:24.04
```

- 非交互执行一条命令（示例：打印发行版信息）：
```bash
bash tools/testenv/run.sh jammy 'cat /etc/os-release && (lsb_release -a || true)'
```

- 在容器内执行仓库脚本（示例：从容器内运行基础安装流程，容器内执行失败也不会影响宿主）：
```bash
bash tools/testenv/run.sh jammy 'cd /root/ws/basic && bash ./install-after-sshkey.sh || true'
```

说明：
- 仓库会以只读方式挂载到容器 `/mnt/ws`，脚本会复制到 `/root/ws` 后再执行，防止意外修改宿主文件。
- 容器中会自动安装最小依赖集合：`sudo git make curl ca-certificates xz-utils`（按发行版自动选择包管理器）。
- `snap` 在多数容器中不可用；后续重构将为相关步骤增加“环境检测并安全跳过”。

---

## 批量测试矩阵

对多个基础镜像做同一条命令的批量验证：
```bash
# 在 20.04 / 22.04 / 24.04 三个版本上批量执行命令
bash tools/testenv/matrix.sh 'cd /root/ws && echo READY && true'
```

可编辑 `tools/testenv/matrix.sh` 中的镜像数组以适配其他系统（如 Debian/Fedora/Alpine 等）。

---

## 典型用法建议
- 先用 `run.sh jammy` 进入交互式环境手动尝试；
- 稳定后把命令塞进 `run.sh jammy '<cmd>'` 做一次性校验；
- 最后用 `matrix.sh '<cmd>'` 做多版本批量验证。

---

## 已知限制
- 容器内无 systemd，`snap` 相关步骤会失败（属于预期行为）；
- 如需完整 WSL/snap 行为，请改用“独立 WSL 发行版沙箱”或真实虚拟机；
- 跨发行版包名可能存在差异，本脚本仅安装最小通用工具，不保证所有功能在非 Debian 系系发行版一次过。


