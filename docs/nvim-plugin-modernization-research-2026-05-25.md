# Neovim 插件现代化调研报告

调研日期：2026-05-25

调研对象：本仓库 `nvim/` 配置，重点是插件是否过时、近一年半值得关注的新插件与升级替代方案。

本报告只记录调研与建议，没有直接修改 `nvim/` 配置。

## 结论摘要

当前配置不是整体不可用，也不是所有插件都过时；真正的问题是“核心栈进入迁移窗口，体验层插件有明显重复”。建议先升级 Neovim 与 LSP 基线，再分批迁移补全、格式化、诊断、搜索、Markdown 和 UI 体验层。

关键判断：

- 本机 Neovim 版本是 `NVIM v0.10.4`。
- 2026-05-25 调研时，Neovim GitHub 最新 release 是 `v0.12.2`。
- `lazy-lock.json` 锁定插件数为 95。
- 执行 `Lazy check` 后，95 个插件中有 48 个落后上游，18 个落后 20+ commits。
- 22 个本地插件当前锁定提交早于 2024-11-25。
- `nvim-lspconfig` 上游已经把旧 `require("lspconfig").xxx.setup({})` 配置方式标记为 deprecated，并要求 `Nvim 0.11.3+`。
- Telescope 上游已有破坏性提交，要求 Nvim 0.11 并移除旧兼容 shim。
- `barbecue.nvim` 上游仓库已 archived，应替换。
- `markdown-preview.nvim` 的本地插件安装目录有脏文件，可能阻止 Lazy 正常更新。

建议路线：

1. 先升级 Neovim 到 `0.12.2`，最低也应到 `0.11.3+`。
2. 先迁移 LSP 配置到 `vim.lsp.config()` / `vim.lsp.enable()`。
3. 再升级 Treesitter、Telescope、Mason、LSP 相关插件。
4. 第二阶段引入 `blink.cmp`、`conform.nvim`、`nvim-lint`。
5. 第三阶段按模块试用 `snacks.nvim`，再决定是否替代 Telescope、nvim-tree、alpha、dressing、notify、terminal 等体验层。

## 本地配置现状

插件配置集中在：

- `nvim/lua/plugins/init.lua`
- `nvim/lua/plugins/colorscheme.lua`
- `nvim/lua/plugins/ui.lua`
- `nvim/lua/plugins/editor.lua`
- `nvim/lua/plugins/completion.lua`
- `nvim/lua/plugins/lsp/init.lua`
- `nvim/lua/plugins/treesitter.lua`
- `nvim/lua/plugins/telescope.lua`
- `nvim/lua/plugins/git.lua`
- `nvim/lua/plugins/terminal.lua`
- `nvim/lua/plugins/markdown.lua`
- `nvim/lua/plugins/tools.lua`

Lazy 配置特点：

- `nvim/lua/core/lazy.lua` 中 `checker.enabled = false`，平时不会自动提示插件更新。
- `defaults.lazy = false`，默认非懒加载；具体插件里再通过 `event`、`cmd`、`keys` 等局部懒加载。
- `lazy-lock.json` 锁定 95 个插件快照。

当前主要栈：

- 补全：`nvim-cmp` + `cmp-*` + `LuaSnip`
- LSP：`nvim-lspconfig` + `mason.nvim` + `mason-lspconfig.nvim`
- 格式化：`none-ls.nvim` + EFM
- 搜索：Telescope + fzf native
- 文件树：`nvim-tree.lua`
- UI：`which-key`、`bufferline`、`lualine`、`alpha`、`wilder`、`navic`、`barbecue`、`incline`、`aerial`
- 编辑增强：`Comment.nvim`、`vim-visual-multi`、`nvim-spectre`、`flash.nvim`、`vim-illuminate`、`vim-cursorword`、`nvim-spider` 等
- Markdown：`markdown-preview.nvim`、`vim-markdown-toc`、`vim-table-mode`
- Terminal：`vim-floaterm` + `toggleterm.nvim`

## 明确风险点

### Neovim 版本成为主风险

当前 `NVIM v0.10.4` 已经低于多个上游主流插件的新基线。

重点风险：

- `nvim-lspconfig` 当前 README 要求 `Nvim 0.11.3+`。
- `nvim-lspconfig` 旧 `require("lspconfig")` framework 已进入 deprecated 路线。
- Telescope 上游已有 `feat!: require Nvim 0.11 and drop compat shims` 提交。

因此不要在 `0.10.4` 上直接全量 `Lazy update`，风险较高。

### LSP 配置路径需要迁移

当前配置：

- `nvim/lua/config/lsp/servers.lua` 使用 `require("lspconfig")` 后逐个 `lspconfig.xxx.setup({})`。
- `nvim/lua/config/lsp/handlers.lua` 里仍围绕传统 `on_attach` / `capabilities` 组织。

建议迁移到：

- `vim.lsp.config("lua_ls", {...})`
- `vim.lsp.enable({ "lua_ls", "clangd", "pyright", ... })`
- 保留 `nvim-lspconfig` 作为 server config 来源，而不是旧 setup framework。

### 需要清理的已归档或老化插件

建议优先处理：

- `utilyre/barbecue.nvim`：上游 archived，替换为 `dropbar.nvim` 或直接用 `lualine` / `incline` / `aerial` 简化。
- `kazhala/close-buffers.nvim`：多年不活跃，可用 `snacks.bufdelete` 或自定义小函数替代。
- `itchyny/vim-cursorword`：多年不活跃，且和 `vim-illuminate`、`snacks.words` 功能重叠。
- `gelguy/wilder.nvim`：偏旧，可用 `noice.nvim`、`snacks.input`、`blink.cmp` cmdline 等替代。
- `gbrlsnchs/telescope-lsp-handlers.nvim`：多年不活跃，Telescope 与 LSP 内置能力已足够覆盖大部分场景。
- `lukas-reineke/cmp-under-comparator`：非常旧，如果迁移 `blink.cmp` 可删除。
- `anuvyklack/hydra.nvim`：上游不活跃，除非已有强依赖，否则不建议继续扩展。

### 功能重复较多

当前有多处重复或重叠：

- `none-ls.nvim` 与 EFM 都在做外部工具接入。
- `vim-floaterm` 与 `toggleterm.nvim` 都在做终端管理。
- `indent-blankline.nvim` 与 `mini.indentscope` 都在做缩进视觉辅助。
- `vim-illuminate` 与 `vim-cursorword` 都在做光标词/引用高亮。
- `nvim-tree`、Telescope、Aerial、barbecue、navic、incline 多个 UI 导航插件职责交错。
- `markdown-preview.nvim`、`vim-markdown-toc`、`vim-table-mode` 偏传统，缺少现代 Neovim 内渲染体验。

重复本身不是错误，但会增加升级与调试成本。

### `markdown-preview.nvim` 本地插件目录有脏文件

`Lazy check` 提示本地插件安装目录有改动：

- `~/.local/share/nvim/lazy/markdown-preview.nvim/app/yarn.lock`
- `~/.local/share/nvim/lazy/markdown-preview.nvim/app/package-lock.json`

这不是本仓库文件，但会影响该插件更新。后续如要更新，可以先卸载重装该插件，或清理该插件目录里的本地生成文件。

## 值得引入或替换的现代插件

### 1. `blink.cmp`

定位：现代补全引擎，可替代大部分 `nvim-cmp` 生态拼装。

适合替代：

- `hrsh7th/nvim-cmp`
- `hrsh7th/cmp-buffer`
- `hrsh7th/cmp-path`
- `hrsh7th/cmp-nvim-lsp`
- `hrsh7th/cmp-nvim-lua`
- `ray-x/cmp-treesitter`
- `saadparwaiz1/cmp_luasnip`
- `lukas-reineke/cmp-under-comparator`

保留或评估：

- `LuaSnip` 可以先保留，`blink.cmp` 支持 LuaSnip。
- 如果愿意进一步现代化，可后续评估 `vim.snippet` 或 `mini.snippets`。

为什么值得：

- 活跃度高。
- 内置 LSP、path、buffer、cmdline、snippet 等能力。
- 支持 typo-resistant fuzzy、frecency、proximity 等现代排序能力。
- 相比 `nvim-cmp + 多个 source 插件`，配置面和依赖面更小。

建议优先级：高。

### 2. `conform.nvim`

定位：格式化插件。

适合替代：

- `none-ls.nvim` 中的 formatting 使用。
- 当前 EFM 中仅为格式化服务的部分职责。

为什么值得：

- 职责单一，只管 formatting。
- 支持按 filetype 配置 formatter。
- 支持 format-on-save。
- 对 range format、嵌入代码块格式化、LSP fallback 等场景支持更清晰。

建议优先级：高。

### 3. `nvim-lint`

定位：异步 lint 插件。

适合替代：

- EFM 或 none-ls 中 lint 相关职责。

为什么值得：

- 和 Neovim 内置 LSP 互补。
- 职责比 none-ls/EFM 更窄，更容易维护。
- 对 shell、markdown、yaml、GitHub Actions、commit message 等工具型 lint 适配清晰。

建议优先级：高。

### 4. `snacks.nvim`

定位：一组可选 QoL 模块，不建议一次全开。

值得在当前体系中试用的模块：

- `snacks.bigfile`：大文件保护。
- `snacks.quickfile`：快速打开单文件。
- `snacks.input`：替代部分 `dressing.nvim` 场景。
- `snacks.notifier`：替代 `nvim-notify` 场景。
- `snacks.dashboard`：替代 `alpha-nvim`。
- `snacks.bufdelete`：替代 `close-buffers.nvim`。
- `snacks.words`：替代或补强 `vim-illuminate` / `vim-cursorword`。
- `snacks.indent` / `snacks.scope`：替代 `indent-blankline` + `mini.indentscope` 的部分组合。
- `snacks.terminal`：可评估替代部分 terminal 管理。
- `snacks.picker` / `snacks.explorer`：可作为 Telescope / nvim-tree 替代候选，但应后置评估。
- `snacks.lazygit`：如果常用 lazygit，可直接受益。

为什么值得：

- 活跃度高。
- Folke 生态维护质量较好。
- 可逐模块启用，适合渐进式替换多个小插件。

建议优先级：高，但必须按模块渐进接入。

### 5. `render-markdown.nvim`

定位：Neovim 内 Markdown 渲染增强。

适合替代或补强：

- `markdown-preview.nvim` 的部分阅读体验。
- `vim-markdown-toc` 的部分文档浏览需求。

为什么值得：

- 直接在 Neovim buffer 内增强 Markdown 显示。
- 支持 headings、code blocks、tables、callouts、latex blocks 等渲染元素。
- 对“边写边看”的体验比浏览器预览轻。

建议优先级：中高。

### 6. `markview.nvim`

定位：Markdown / Typst / LaTeX / HTML inline / Asciidoc 预览增强。

与 `render-markdown.nvim` 的选择：

- 偏 Markdown 轻量阅读与稳定体验：优先 `render-markdown.nvim`。
- 偏多标记语言、可 hack、想要更强预览：评估 `markview.nvim`。

建议优先级：中。

### 7. `grug-far.nvim`

定位：项目级 find/replace。

适合替代或并存评估：

- `nvim-spectre`

为什么值得：

- 直接围绕 `rg` / `ast-grep`。
- 支持 multiline search/replace。
- UI 不隐藏底层工具概念，适合熟悉命令行搜索的人。

建议优先级：中高。

### 8. `trouble.nvim`

定位：diagnostics、references、quickfix/location list 统一 UI。

适合补齐：

- 当前只有 Telescope diagnostics 与 loclist，缺少一个统一问题面板。

为什么值得：

- 诊断、引用、quickfix、Telescope 结果都能统一看。
- 对 LSP 日常工作流收益明显。

建议优先级：中高。

### 9. `fzf-lua`

定位：基于 fzf 的 picker。

可替代：

- Telescope 主搜索路径。

为什么值得：

- 活跃度高。
- 与 `fzf`、`rg`、`fd`、`bat` 等命令行工具契合。
- 性能和交互风格更贴近命令行用户。

是否应替换 Telescope：

- 如果当前 Telescope 用得顺手，先升级 Telescope 即可。
- 如果追求速度、fzf 习惯、命令行一致性，可新建并行 keymap 试用 `fzf-lua`。

建议优先级：中，后置评估。

### 10. `oil.nvim` 或 `mini.files`

定位：文件系统编辑器。

可替代：

- `nvim-tree.lua`

选择建议：

- 想用“编辑 buffer 一样编辑目录”的模型：`oil.nvim`。
- 想用 column view、轻依赖、mini 生态：`mini.files`。
- 如果仍偏好传统树形文件浏览：`nvim-tree.lua` 仍活跃，可以保留。

建议优先级：中。

### 11. `dropbar.nvim`

定位：breadcrumbs / winbar 导航。

可替代：

- `barbecue.nvim`

为什么值得：

- `barbecue.nvim` 已 archived。
- `dropbar.nvim` 活跃，定位更接近“IDE-like breadcrumbs”。

建议优先级：中高。

### 12. AI 插件候选

当前配置没有明显 AI 层。是否加入取决于你的工作流。

候选：

- `CodeCompanion.nvim`：偏工程化 AI coding assistant，支持多 provider、chat buffer、inline transform、agent/tools/workflows、ACP/MCP 等。更适合在 Neovim 内接入 Codex/Claude/Gemini/Ollama 等工作流。
- `Avante.nvim`：偏 Cursor-like 编辑体验，强调在 Neovim 中做 AI 代码建议与应用改动。
- `copilot.lua`：偏 GitHub Copilot 行内补全和 Copilot Lua 生态。

建议：

- 如果你主要使用 CLI Agent，不一定要引入重型 AI 插件。
- 如果希望 Neovim 内直接做上下文聊天、局部改写、代码生成，优先评估 `CodeCompanion.nvim`。
- 如果希望 Cursor-like UI，评估 `Avante.nvim`。
- 如果只要行内补全，评估 `copilot.lua`。

建议优先级：可选。

## 分批迁移路线

### 第 0 批：升级前准备

目标：避免在旧 Neovim 上全量更新导致连锁断裂。

建议动作：

- 升级 Neovim 到 `0.12.2`，最低 `0.11.3+`。
- 备份当前 `nvim/lazy-lock.json`。
- 清理或重装 `markdown-preview.nvim` 本地插件目录，避免本地脏文件阻止更新。
- 临时打开 Lazy checker 或定期执行 `:Lazy check`。

风险：低。

### 第 1 批：核心运行时升级

目标：让现代插件基线稳定。

建议动作：

- 更新 `lazy.nvim`。
- 更新 `nvim-lspconfig`、`mason.nvim`、`mason-lspconfig.nvim`。
- 更新 `nvim-treesitter`、`nvim-treesitter-textobjects`。
- 更新 Telescope，但必须基于 Nvim 0.11+。

风险：中。

### 第 2 批：LSP 配置迁移

目标：脱离 deprecated 路线。

建议动作：

- 把 `nvim/lua/config/lsp/servers.lua` 从 `lspconfig.xxx.setup({})` 迁移到 `vim.lsp.config()`。
- 使用 `vim.lsp.enable()` 启用 server。
- 保留现有 keymap 与 diagnostics 配置，但检查是否有 API 变更。
- 重新验证 `lua_ls`、`clangd`、`pyright`、`bashls`、`jsonls`、`marksman`。

风险：中高。

### 第 3 批：格式化与 lint 重构

目标：降低 none-ls/EFM 的维护复杂度。

建议动作：

- 引入 `conform.nvim` 管理 `stylua`、`prettier`、`shfmt`。
- 引入 `nvim-lint` 管理 shellcheck、markdownlint、yamllint 等需要的 linter。
- 移除或降级 `none-ls.nvim` 的职责。
- 评估是否彻底移除 EFM。

风险：中。

### 第 4 批：补全体系升级

目标：减少 `nvim-cmp` 生态碎片依赖。

建议动作：

- 新分支试用 `blink.cmp`。
- 先保留 `LuaSnip` 与 `friendly-snippets`。
- 替换 `cmp-*` source。
- 迁移 `<Tab>`、`<S-Tab>`、`<CR>` 行为。
- 验证 LSP completion、path、buffer、cmdline、snippet。

风险：中高。

### 第 5 批：UI 与体验层瘦身

目标：用少数维护活跃的模块替代多个边际插件。

建议动作：

- 用 `dropbar.nvim` 替换 `barbecue.nvim`，或直接移除 breadcrumb 层。
- 用 `snacks.bufdelete` 替换 `close-buffers.nvim`。
- 用 `snacks.words` 替换 `vim-cursorword`，并评估是否保留 `vim-illuminate`。
- 用 `snacks.input` 替代部分 `dressing.nvim` 场景。
- 用 `snacks.dashboard` 替代 `alpha-nvim`。
- 用 `snacks.indent` / `snacks.scope` 评估是否替代 `indent-blankline` + `mini.indentscope`。
- 用 `snacks.terminal` 评估是否替代 `vim-floaterm` 或 `toggleterm.nvim` 中的一部分。

风险：中。

### 第 6 批：搜索、文件浏览、Markdown 体验升级

目标：改善日常使用体验。

建议动作：

- 搜索替换：评估 `grug-far.nvim` 替代 `nvim-spectre`。
- Picker：保留 Telescope 或并行试用 `fzf-lua` / `snacks.picker`。
- 文件浏览：保留 `nvim-tree` 或试用 `oil.nvim` / `mini.files`。
- Markdown：引入 `render-markdown.nvim`，再决定是否保留 `markdown-preview.nvim`。

风险：低到中。

## 插件分类建议

### 建议保留并更新

- `lazy.nvim`
- `catppuccin`
- `which-key.nvim`
- `lualine.nvim`
- `gitsigns.nvim`
- `vim-fugitive`
- `diffview.nvim`
- `flash.nvim`
- `aerial.nvim`
- `LuaSnip`
- `friendly-snippets`
- `nvim-treesitter`
- `nvim-treesitter-textobjects`
- `mason.nvim`
- `mason-lspconfig.nvim`
- `nvim-lspconfig`
- `overseer.nvim`
- `leetcode.nvim`
- `img-clip.nvim`
- `nvim-spider`
- `vim-matchup`

### 建议替换

- `barbecue.nvim` -> `dropbar.nvim` 或移除。
- `close-buffers.nvim` -> `snacks.bufdelete` 或自定义 buffer delete。
- `vim-cursorword` -> `snacks.words` 或只保留 `vim-illuminate`。
- `none-ls.nvim` formatting 职责 -> `conform.nvim`。
- EFM lint/format 职责 -> `nvim-lint` + `conform.nvim`。
- `nvim-cmp` 生态 -> 评估 `blink.cmp`。
- `wilder.nvim` -> `blink.cmp` cmdline / `noice.nvim` / `snacks.input`。
- `markdown-preview.nvim` 部分场景 -> `render-markdown.nvim`。
- `nvim-spectre` -> 评估 `grug-far.nvim`。

### 可以暂时保留，但不建议继续重度扩展

- `nvim-tree.lua`：仍活跃，但可被 `oil.nvim` / `mini.files` / `snacks.explorer` 替代。
- `telescope.nvim`：仍活跃，但上游要求 Nvim 0.11；也可评估 `fzf-lua`。
- `toggleterm.nvim`：可用，但可与 `snacks.terminal` 对比。
- `vim-floaterm`：仍活跃，但与 `toggleterm.nvim` 重复。
- `vim-visual-multi`：仍能用，但多光标插件维护节奏偏慢。
- `hydra.nvim`：如果没实际使用，可以移除。
- `tabout.nvim`：可用但非核心。
- `nvim-FeMaco.lua`：如果经常编辑 Markdown fenced code block 可保留，否则边际。

## 上游状态抽样

以下是 2026-05-25 调研时通过 GitHub API 或上游仓库 README 核验的代表性状态。

活跃且值得关注：

- `Saghen/blink.cmp`：2026-05-24 附近仍活跃，约 6300+ stars。
- `folke/snacks.nvim`：2026-05-21 附近仍活跃，约 7600+ stars。
- `ibhagwan/fzf-lua`：2026-05-24 附近仍活跃，约 4200+ stars。
- `stevearc/conform.nvim`：2026-05-24 附近仍活跃，约 5100+ stars。
- `mfussenegger/nvim-lint`：2026-05-19 附近仍活跃，约 2700+ stars。
- `stevearc/oil.nvim`：2026-05-24 附近仍活跃，约 6500+ stars。
- `MeanderingProgrammer/render-markdown.nvim`：2026-05-25 附近仍活跃，约 4600+ stars。
- `OXY2DEV/markview.nvim`：2026-05-17 附近仍活跃，约 3400+ stars。
- `MagicDuck/grug-far.nvim`：2026-05-19 附近仍活跃，约 1900+ stars。
- `olimorris/codecompanion.nvim`：2026-05-16 附近仍活跃，约 6600+ stars。
- `yetone/avante.nvim`：2026-05-23 附近仍活跃，约 17900+ stars。

需要谨慎：

- `utilyre/barbecue.nvim`：仓库 archived。
- `kazhala/close-buffers.nvim`：上游多年不活跃。
- `itchyny/vim-cursorword`：上游多年不活跃。
- `gelguy/wilder.nvim`：上游维护节奏偏慢。
- `gbrlsnchs/telescope-lsp-handlers.nvim`：上游多年不活跃。
- `cmp-under-comparator`：非常旧。
- `plenary.nvim`：README 已提示不再积极维护并将归档；短期仍会因为 Telescope 等依赖存在，但长期应减少直接新增依赖。

## 推荐最终形态

一个更现代、维护成本更低的目标形态可以是：

- 插件管理：`lazy.nvim`
- LSP：Neovim 内置 LSP + `nvim-lspconfig` configs + `mason.nvim`
- 补全：`blink.cmp`
- Snippet：先保留 `LuaSnip`，后续再评估 `mini.snippets` / `vim.snippet`
- 格式化：`conform.nvim`
- Lint：`nvim-lint`
- Treesitter：`nvim-treesitter` + `nvim-treesitter-textobjects`
- Picker：Telescope、`fzf-lua` 或 `snacks.picker` 三选一主路径
- 文件浏览：`nvim-tree`、`oil.nvim` 或 `mini.files` 三选一主路径
- UI 小组件：用 `snacks.nvim` 分模块替代多个小插件
- Git：`gitsigns.nvim` + `vim-fugitive` + `diffview.nvim`
- Markdown：`render-markdown.nvim` + `img-clip.nvim`，浏览器预览作为可选
- Diagnostics UI：`trouble.nvim`
- AI：按需接入 `CodeCompanion.nvim` / `Avante.nvim` / `copilot.lua`

## 验证命令记录

本次调研中使用过的本地命令包括：

```bash
rg --files nvim
find nvim -maxdepth 3 -type f \( -name '*.lua' -o -name '*.vim' -o -name 'lazy-lock.json' \) -print
jq -r 'keys[]' nvim/lazy-lock.json | sort
jq 'to_entries | length' nvim/lazy-lock.json
nvim --version | head -n 5
nvim --headless '+Lazy! check' '+qa'
git status --short
```

上游状态抽样使用：

```bash
curl -fsSL https://api.github.com/repos/<owner>/<repo>
curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest
curl -fsSL https://raw.githubusercontent.com/neovim/nvim-lspconfig/master/README.md
```

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
- fzf-lua：https://github.com/ibhagwan/fzf-lua
- oil.nvim：https://github.com/stevearc/oil.nvim
- mini.nvim：https://github.com/nvim-mini/mini.nvim
- render-markdown.nvim：https://github.com/MeanderingProgrammer/render-markdown.nvim
- markview.nvim：https://github.com/OXY2DEV/markview.nvim
- grug-far.nvim：https://github.com/MagicDuck/grug-far.nvim
- trouble.nvim：https://github.com/folke/trouble.nvim
- noice.nvim：https://github.com/folke/noice.nvim
- dropbar.nvim：https://github.com/Bekaboo/dropbar.nvim
- CodeCompanion.nvim：https://github.com/olimorris/codecompanion.nvim
- Avante.nvim：https://github.com/yetone/avante.nvim
- copilot.lua：https://github.com/zbirenbaum/copilot.lua
- plenary.nvim：https://github.com/nvim-lua/plenary.nvim
