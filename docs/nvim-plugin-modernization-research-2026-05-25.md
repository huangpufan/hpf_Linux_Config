# Neovim 插件现代化调研与进度记录

调研日期：2026-05-25
进度更新：2026-07-05

本文件现在作为历史调研与进度记录保存，不再作为待办清单或安装入口。当前 Neovim 配置事实以 `nvim/lua/plugins/`、`nvim/lazy-lock.json`、`nvim/README-CN.md` 和 `nvim/README.md` 为准。

## 当前状态摘要

2026-05-25 的调研结论是：配置不是整体不可用，主要问题是核心栈进入迁移窗口，体验层插件有明显重复。随后配置已经完成多批现代化工作，并在 2026-07-05 做了旧插件与重复层收敛。

当前主路径：

- LSP：使用 Neovim 新 LSP API 组织 server 配置。
- 补全：`blink.cmp`。
- 格式化：`conform.nvim`。
- Lint：`nvim-lint`。
- QoL：保留已启用的 `snacks.nvim` 部分模块，包括 bigfile、quickfile、bufdelete、words 与 lazygit 等。
- 搜索与导航：Telescope + nvim-tree + Aerial + Incline。
- 终端：`toggleterm.nvim`。
- 缩进视觉：`indent-blankline.nvim`。
- Markdown：`render-markdown.nvim` 作为 Neovim 内渲染路径，`markdown-preview.nvim` 作为可选浏览器预览路径。

## 已完成项

### 核心栈现代化

- 已迁移到新的 Neovim LSP 配置路径，不再把旧 `require("lspconfig").xxx.setup({})` 作为目标架构。
- 已引入并使用 `blink.cmp`，减少旧 `nvim-cmp` source 拼装依赖。
- 已引入 `conform.nvim` 管理格式化。
- 已引入 `nvim-lint` 管理异步 lint。
- 已按模块启用 `snacks.nvim`，用于大文件保护、快速文件显示、buffer 删除、单词引用与 Lazygit。

### 2026-07-05 体验层收敛

- 已移除旧命令行补全层 `wilder.nvim`，同时删除其 `fzy-lua-native` 依赖。
- 已移除 breadcrumb 层 `nvim-navic` + `barbecue.nvim`；当前导航模型收敛到 Telescope、nvim-tree、Aerial 与 Incline。
- 已移除无实际配置的 `hydra.nvim`。
- 已移除 `vim-floaterm`；终端主路径收敛为 Lua-native `toggleterm.nvim`。
- 已移除 `mini.indentscope`；缩进视觉层收敛为 `indent-blankline.nvim`。
- 已移除 `vim-illuminate`；单词/引用高亮依赖已启用的 `snacks.words`。
- 已移除传统 Markdown 辅助插件 `vim-markdown-toc` 与 `vim-table-mode`。
- 已引入 `render-markdown.nvim`，暂时保留 `markdown-preview.nvim` 避免同时改动浏览器预览安装/验证路径。
- 已将旧仓库名 `kyazdani42/nvim-web-devicons` 与 `kyazdani42/nvim-tree.lua` 改为 canonical `nvim-tree/nvim-web-devicons` 与 `nvim-tree/nvim-tree.lua`。

## 仍保留的设计选择

- Telescope、nvim-tree、Aerial、Incline 都保留。它们共同构成当前搜索、文件树、代码大纲与轻量文件上下文模型。
- `markdown-preview.nvim` 继续保留，作为需要浏览器预览时的路径；内渲染日常阅读优先用 `render-markdown.nvim`。
- `indent-blankline.nvim` 保留为唯一缩进视觉层，暂不切到 `snacks.indent` / `snacks.scope`。
- `toggleterm.nvim` 保留为终端主路径，暂不切到 `snacks.terminal`。
- `dressing.nvim`、`alpha-nvim`、`nvim-tree.lua`、Telescope 等仍在使用；是否进一步替换为 snacks 模块或其他插件应另开任务评估。

## 历史风险记录

2026-05-25 调研时记录过以下风险，供理解历史背景：

- 当时本机 Neovim 版本为 `NVIM v0.10.4`，低于多个上游主流插件的新基线。
- 当时 `lazy-lock.json` 锁定插件数为 95，多个插件落后上游。
- `barbecue.nvim` 上游已 archived。
- `markdown-preview.nvim` 的本地插件安装目录曾出现生成文件，可能影响 Lazy 更新；这是本机插件目录问题，不是仓库文件。
- 旧配置中存在多处重复：`vim-floaterm` 与 `toggleterm.nvim`、`indent-blankline.nvim` 与 `mini.indentscope`、`vim-illuminate` 与 `snacks.words` / `vim-cursorword`、多个 breadcrumb / navigation 插件、传统 Markdown 辅助插件等。

这些风险中的一部分已经在当前配置中处理；如果后续继续现代化，应先以当前配置和 lockfile 为准重新核验，而不是直接执行 2026-05-25 的旧待办。

## 后续可选方向

这些不是当前待办，只是未来可评估项：

- 继续评估 Telescope、nvim-tree、alpha、dressing、notify 是否需要由 snacks 模块或其他现代插件替代。
- 评估是否增加统一 diagnostics UI，例如 `trouble.nvim`。
- 评估是否用 `grug-far.nvim` 替换或补强 `nvim-spectre`。
- 评估 snippets 是否继续使用 LuaSnip，或迁移到 Neovim 内置 snippet / mini.snippets。
- 若需要 Neovim 内 AI 工作流，再独立评估 CodeCompanion、Avante 或 Copilot 类插件。

## 验证口径

修改 Neovim 配置后至少执行：

```bash
python3 -m json.tool nvim/lazy-lock.json >/dev/null
nvim --headless '+qa'
python3 install-script/agent-runner.py check nvim
```

如果新增插件需要刷新 lockfile，优先使用 Lazy 同步生成真实 commit；如网络或本机 Neovim 不可用，应在变更说明中记录跳过原因，并至少保证 JSON 与 Lua 静态检查通过。

## 参考链接

- Neovim releases：https://github.com/neovim/neovim/releases
- nvim-lspconfig：https://github.com/neovim/nvim-lspconfig
- lazy.nvim：https://github.com/folke/lazy.nvim
- nvim-treesitter：https://github.com/nvim-treesitter/nvim-treesitter
- telescope.nvim：https://github.com/nvim-telescope/telescope.nvim
- blink.cmp：https://github.com/Saghen/blink.cmp
- snacks.nvim：https://github.com/folke/snacks.nvim
- conform.nvim：https://github.com/stevearc/conform.nvim
- nvim-lint：https://github.com/mfussenegger/nvim-lint
- render-markdown.nvim：https://github.com/MeanderingProgrammer/render-markdown.nvim
- markview.nvim：https://github.com/OXY2DEV/markview.nvim
- grug-far.nvim：https://github.com/MagicDuck/grug-far.nvim
- trouble.nvim：https://github.com/folke/trouble.nvim
