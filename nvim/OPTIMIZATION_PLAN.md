# Neovim 配置优化方案

> 本文档基于对现有配置的完整审阅，提出保守性优化建议，确保不破坏现有功能。

## 📋 任务清单

### 优先级：高（推荐立即处理）

- [x] **[H1] 修复 spell 设置冲突** ✅ (commit: 9bd1851)
- [x] **[H2] 修复 nvim-tree 重复配置** ✅ (commit: 96314a3)
- [x] **[H3] 修复 inc_rename 重复配置** ✅ (commit: ba819c2)
- [x] **[H4] 更新过时的 LSP 名称引用** ✅ (commit: 6921789)

### 优先级：中（建议处理）

- [x] **[M1] 合并多次 nvim-treesitter 配置调用** ✅ (commit: ee0e355)
- [x] **[M2] 清理 which-key.lua 中的注释代码** ✅ (commit: bab1eea, -174 lines)
- [x] **[M3] 移除重复的快捷键绑定** ✅ (commit: 90890f3)
- [x] **[M4] 修复 README-CN.md 代码块格式** ✅ (commit: 32fc96f)
- [x] **[M5] 修复文件名拼写错误** ✅ (commit: bc51d4b)

### 优先级：低（可选优化）

- [x] **[L1] 使用 vim.uv 替代 vim.loop（兼容性）** ✅ (commit: 2761954)
- [x] **[L2] 考虑迁移 null-ls 到 none-ls** ✅ (commit: f04c473)
- [x] **[L3] 更新 fidget.nvim 到新版本** ✅ (commit: cbd18e0)
- [x] **[L4] 清理 init.lua 中的注释代码** ✅ (commit: e67ed1d, -41 lines)

---

## 🔍 详细分析

### [H1] 修复 spell 设置冲突

**问题位置：**
- `lua/usr/cmp.lua` 第 17-18 行：
```lua
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }
```
- `lua/usr/init.lua` 第 271 行：
```lua
vim.opt.spell = false
```

**问题描述：**
`cmp.lua` 开启了拼写检查，但 `init.lua` 末尾又关闭了它。这导致配置意图不明确。

**建议方案：**
将 spell 相关设置统一放到 `options.lua` 中，并从 `cmp.lua` 中移除：

```lua
-- 在 options.lua 中添加
spell = false,  -- 或 true，取决于你的需求
spelllang = { "en_us" },
```

然后删除 `cmp.lua` 中的第 17-18 行和 `init.lua` 中的第 271 行。

---

### [H2] 修复 nvim-tree 重复配置

**问题位置：**
- `lua/usr/nvim-tree.lua` 第 27-118 行：完整配置
- `lua/usr/init.lua` 第 177-184 行：部分配置

**问题描述：**
nvim-tree 被配置了两次，可能导致配置冲突或覆盖。

**当前 init.lua 中的配置：**
```lua
require("nvim-tree").setup {
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true,
  },
}
```

**当前 nvim-tree.lua 中的配置：**
```lua
sync_root_with_cwd = false,
update_focused_file = {
  enable = true,
  update_cwd = true,
  update_root = false,
},
```

**建议方案：**
删除 `init.lua` 第 177-184 行的 nvim-tree 配置，只保留 `nvim-tree.lua` 中的完整配置。如果需要 `sync_root_with_cwd = true` 的行为，请在 `nvim-tree.lua` 中修改。

---

### [H3] 修复 inc_rename 重复配置

**问题位置：**
- `lua/usr/lazy.lua` 第 128-134 行
- `lua/usr/init.lua` 第 255-260 行

**问题描述：**
`inc_rename` 在两处都有配置和快捷键绑定。

**lazy.lua 配置：**
```lua
{
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  config = function()
    require("inc_rename").setup()
  end,
},
```

**init.lua 配置：**
```lua
require("inc_rename").setup {
  input_buffer_type = "dressing",
}
vim.keymap.set("n", "<space>rn", function()
  return ":IncRename " .. vim.fn.expand "<cword>"
end, { expr = true })
```

**建议方案：**
保留 `init.lua` 中的配置（因为有 dressing 集成），删除 `lazy.lua` 中的 `config` 函数，只保留懒加载设置：

```lua
{
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
},
```

---

### [H4] 更新过时的 LSP 名称引用

**问题位置：**
- `lua/usr/lsp/handlers.lua` 第 61-63 行

**问题描述：**
`sumneko_lua` 已重命名为 `lua_ls`。

**当前代码：**
```lua
if client.name == "sumneko_lua" then
  client.server_capabilities.documentFormattingProvider = false
end
```

**建议方案：**
```lua
if client.name == "lua_ls" then
  client.server_capabilities.documentFormattingProvider = false
end
```

---

### [M1] 合并多次 nvim-treesitter 配置调用

**问题位置：**
- `lua/usr/nvim-treesitter.lua` 全文件

**问题描述：**
`require("nvim-treesitter.configs").setup` 被调用了 3 次（第 1、52、64 行），这是冗余的。

**建议方案：**
将三个配置合并为一个调用：

```lua
require("nvim-treesitter.configs").setup {
  highlight = {
    enable = true,
    use_languagetree = true,
    disable = { "org", "c", "cpp" },
  },
  ensure_installed = { ... },
  textsubjects = { ... },
  textobjects = { ... },
}
```

---

### [M2] 清理 which-key.lua 中的注释代码

**问题位置：**
- `lua/usr/which-key.lua` 第 14-168 行

**问题描述：**
大量使用旧 `wk.register` 格式的注释代码，占据了约 150 行。这些已被新的 `wk.add` 格式替代。

**建议方案：**
删除第 14-168 行的注释块，只保留当前使用的 `wk.add` 配置。

---

### [M3] 移除重复的快捷键绑定

**问题位置：**
- `lua/usr/which-key.lua` 第 12 行
- `lua/usr/init.lua` 第 265 行

**问题描述：**
`<C-n>` 绑定 `NvimTreeToggle` 被定义了两次。

**建议方案：**
删除 `init.lua` 第 265 行的重复绑定，只保留 `which-key.lua` 中的定义。

---

### [M4] 修复 README-CN.md 代码块格式

**问题位置：**
- `README-CN.md` 第 102-105 行

**问题描述：**
代码块使用了六个反引号，应该是三个。

**当前内容：**
```
``````
cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app/ && npm install
Lazy build markdown-preview.nvim
``````
```

**建议方案：**
```
```bash
cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app/ && npm install
Lazy build markdown-preview.nvim
```
```

---

### [M5] 修复文件名拼写错误

**问题位置：**
- `vim-turoial-cn.md`

**问题描述：**
文件名 `turoial` 应为 `tutorial`。

**建议方案：**
```bash
mv vim-turoial-cn.md vim-tutorial-cn.md
```

---

### [L1] 使用 vim.uv 替代 vim.loop

**问题位置：**
- `lua/usr/lazy.lua` 第 2 行
- `lua/usr/code_runner.lua` 第 2 行

**问题描述：**
`vim.loop` 在 Neovim 0.10+ 中已被 `vim.uv` 替代，虽然目前仍兼容。

**建议方案：**
可以在 `version.lua` 中检查版本后条件性使用：

```lua
local uv = vim.uv or vim.loop
```

---

### [L2] 考虑迁移 null-ls 到 none-ls

**问题位置：**
- `lua/usr/lazy.lua` 第 102 行
- `lua/usr/lsp/null-ls.lua` 全文件

**问题描述：**
`jose-elias-alvarez/null-ls.nvim` 已归档停止维护，社区 fork 为 `nvimtools/none-ls.nvim`。

**建议方案：**
此变更较大，建议在有充足时间测试时进行迁移：

```lua
-- lazy.lua 中修改
{ "nvimtools/none-ls.nvim", event = "VeryLazy" },
```

API 基本兼容，但建议详细测试后再迁移。

---

### [L3] 更新 fidget.nvim 到新版本

**问题位置：**
- `lua/usr/lazy.lua` 第 103 行

**问题描述：**
当前使用 `tag = "legacy"` 锁定旧版本。

**建议方案：**
新版 fidget.nvim 配置方式有变化，需要测试后迁移：

```lua
{ "j-hui/fidget.nvim", event = "VeryLazy" },
```

并更新 `init.lua` 中的配置。

---

### [L4] 清理 init.lua 中的注释代码

**问题位置：**
- `lua/usr/init.lua` 多处

**问题描述：**
有一些注释掉的 require 语句和功能代码，如：
- 第 35-36 行：code_runner, hydra
- 第 39 行：orgmode
- 第 60-65 行：各种注释配置
- 第 86-91 行：VimLeave workaround

**建议方案：**
如果这些功能确定不再使用，可以删除相关注释代码。如果可能会用到，可以保留但整理成更清晰的格式。

---

## 📝 执行顺序建议

1. 首先处理高优先级任务 [H1-H4]，这些是配置冲突和错误
2. 然后处理中优先级任务 [M1-M5]，这些是代码质量改进
3. 最后考虑低优先级任务 [L1-L4]，这些涉及依赖更新

## ⚠️ 注意事项

- 每次修改后建议重启 nvim 测试功能是否正常
- 建议使用 `:checkhealth` 检查配置健康状态
- 修改前建议 git commit 当前状态，便于回滚
- 对于 [L2] null-ls 迁移，建议单独分支测试

---

*文档生成时间：2024年12月*
*基于 Neovim 0.10+ 配置分析*

