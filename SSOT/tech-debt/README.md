# 技术债务

| 债务 | 当前状态 | 为什么是债 | 证据 |
|---|---|---|---|
| Neovim 旧 `lspconfig` 配置路径已进入 deprecated 路线 | active | 编辑器子树需要继续现代化，否则后续升级成本上升 | `docs/nvim-plugin-modernization-research-2026-05-25.md` |
| release / 决策治理仍偏轻量 | active | 当前长期约束多数仍散落在 README/AGENTS，而不是独立条目 | 当前 SSOT 与仓库结构 |
| 一些脚本与注释仍保留 legacy/HACK 过渡痕迹 | active | 说明某些安装路径仍有兼容层与临时处理 | `install-script/nvim/clipboard-provider`、`basic/ubuntu-source-change.sh` 等 |
