# Neovim 配置

一个现代化、模块化的 Neovim 配置，专为 C/C++ 及通用开发设计。

## 📁 项目结构

```
nvim/
├── init.lua                  # 主入口文件
├── lazy-lock.json            # 插件版本锁定文件
├── efm.yaml                  # EFM 语言服务器配置
│
├── lua/
│   ├── core/                 # 核心配置
│   │   ├── init.lua          # 核心入口
│   │   ├── options.lua       # Vim 选项
│   │   ├── keymaps.lua       # 快捷键映射
│   │   ├── autocmds.lua      # 自动命令
│   │   └── lazy.lua          # 插件管理器 (lazy.nvim)
│   │
│   ├── config/               # 非插件配置模块
│   │   ├── keybindings.lua   # Which-key 快捷键绑定
│   │   └── lsp/              # LSP 工具模块
│   │       ├── handlers.lua  # LSP 处理器
│   │       └── servers.lua   # 服务器配置
│   │
│   └── plugins/              # 插件配置
│       ├── init.lua          # 插件列表索引
│       ├── colorscheme.lua   # 主题设置
│       ├── ui.lua            # UI 插件
│       ├── editor.lua        # 编辑器增强
│       ├── completion.lua    # 补全 (nvim-cmp)
│       ├── treesitter.lua    # Treesitter 配置
│       ├── telescope.lua     # Telescope 搜索
│       ├── git.lua           # Git 集成
│       ├── terminal.lua      # 终端插件
│       ├── markdown.lua      # Markdown 插件
│       ├── tools.lua         # 其他工具
│       └── lsp/              # LSP 插件规格
│           └── init.lua      # LSP 插件
│
├── after/
│   └── plugin/               # 后加载脚本
│       ├── wilder.vim        # Wilder 配置
│       └── utils.vim         # 工具函数
│
└── snippets/                 # 自定义代码片段
    ├── c.snippets
    ├── cpp.snippets
    ├── markdown.snippets
    └── sh.snippets
```

## ✨ 特性

### 核心特性
- 🚀 延迟加载，快速启动
- 📦 使用 [lazy.nvim](https://github.com/folke/lazy.nvim) 管理插件
- 🎨 美观的 Catppuccin 主题
- ⌨️ 现代快捷键 (Ctrl+C/V/S/A)

### LSP 与补全
- 🔧 多语言 LSP 支持
- ✏️ nvim-cmp 自动补全
- 📝 LuaSnip 代码片段
- 💡 代码操作与诊断

### 导航与搜索
- 🔍 Telescope 模糊查找
- 🌳 nvim-tree 文件浏览器
- ⚡ Flash.nvim 快速跳转
- 📌 书签支持

### Git 集成
- 📊 侧边栏 Git 标记
- 📋 Git blame 显示
- 🔀 Diffview 差异视图
- 🚀 Lazygit 集成 (g=)

### 编辑器增强
- 🎯 智能缩进
- 💬 快速注释
- 🔄 会话持久化
- 📐 多光标编辑

## ⌨️ 快捷键

### 通用
| 快捷键 | 功能 |
|--------|------|
| `<Space>` | Leader 键 |
| `<C-s>` | 保存所有 |
| `<C-w>` | 关闭 buffer |
| `<C-n>` | 切换文件树 |
| `q` | 关闭窗口 |
| `<Space>q` | 退出 Neovim |

### 导航
| 快捷键 | 功能 |
|--------|------|
| `<A-j>/<A-k>` | 上/下一个 buffer |
| `<A-1-9>` | 跳转到第 N 个 buffer |
| `<C-h>/<C-l>` | 切换窗口 |
| `\` / `\|` | 水平/垂直分屏 |

### 搜索 (Telescope)
| 快捷键 | 功能 |
|--------|------|
| `<Space>ff` | 查找文件 |
| `<Space>fw` | 全局搜索 |
| `<Space>fb` | 查找 buffer |
| `<Space>fc` | 搜索光标下的词 |

### LSP
| 快捷键 | 功能 |
|--------|------|
| `gd` | 跳转到定义 |
| `gr` | 跳转到引用 |
| `K` | 悬浮文档 |
| `<Space>la` | 代码操作 |
| `<Space>lf` | 格式化代码 |
| `<Space>rn` | 重命名符号 |

### Git
| 快捷键 | 功能 |
|--------|------|
| `g=` | 打开 Lazygit |
| `<Space>sg` | Git 状态 |

## 🔧 安装

1. 备份现有 Neovim 配置：
   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
   ```

2. 克隆或链接此配置：
   ```bash
   ln -s /path/to/this/nvim ~/.config/nvim
   ```

3. 打开 Neovim，lazy.nvim 会自动安装插件：
   ```bash
   nvim
   ```

4. 安装 LSP 服务器：
   ```vim
   :MasonInstallAll
   ```

## 📝 注意事项

### Markdown 预览
如果 Markdown 预览无法工作：
```bash
cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app/ && npm install
```

### Treesitter
更新 Just 语法：
```vim
:TSInstall just
```

## 🤔 设计理念

### 不要有工具崇拜

任何工具在历史当中都是短暂的，不同的工具适用于不同的场景。不存在 all in one 的工具。

永远会有更好用的工具出现，因此对于工具的无休止的争论是毫无意义的，无需盲目崇拜一类工具，也无需诋毁你不了解的工具。

了解，然后选择即可。

### 重要的是 Feature

我认为好的工具流选择策略是，首先思考，你需要的是什么特性。接着去寻找能提供这些特性的工具。

而 Neovim 比其他编辑器强的地方就在于，不仅拥有一个活跃的社区，提供常规编辑器所拥有的大部分功能插件，还降低了插件实现门槛（相比 vim），能够提供你自己实现这些特性的能力。

Neovim 是可编程的，而可编程的工具，能约束你的只有想象力。

## 📄 许可证

MIT
