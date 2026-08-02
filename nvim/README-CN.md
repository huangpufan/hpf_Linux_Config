# Neovim 配置

一个现代化、模块化的 Neovim 配置，专为 C/C++ 及通用开发设计。

## 📁 项目结构

```
nvim/
├── init.lua                  # 主入口文件
├── lazy-lock.json            # 插件版本锁定文件
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
│   │   ├── markdown_preview.lua # Markdown 阅读模式控制器
│   │   ├── sixel_image.lua   # 无短写丢失的 Sixel 图片渲染器
│   │   └── lsp/              # LSP 工具模块
│   │       ├── handlers.lua  # LSP 处理器
│   │       └── servers.lua   # 服务器配置
│   │
│   └── plugins/              # 插件配置
│       ├── init.lua          # 插件列表索引
│       ├── snacks.lua        # Snacks 实用模块
│       ├── colorscheme.lua   # 主题设置
│       ├── ui.lua            # UI 插件
│       ├── editor.lua        # 编辑器增强
│       ├── completion.lua    # 补全 (blink.cmp)
│       ├── formatting.lua    # 格式化与 lint
│       ├── treesitter.lua    # Treesitter 配置
│       ├── telescope.lua     # Telescope 搜索
│       ├── git.lua           # Git 集成
│       ├── terminal.lua      # 终端插件
│       ├── markdown.lua      # Markdown 插件
│       ├── image.lua         # 直接打开图片的集成入口
│       ├── tools.lua         # 其他工具
│       └── lsp/              # LSP 插件规格
│           └── init.lua      # LSP 插件
│
├── assets/
│   └── markdown-reading.css  # 浏览器阅读样式
├── scripts/
│   └── markdown-reading-mode.ps1 # Windows Terminal/浏览器摆窗脚本
├── tests/
│   ├── markdown_preview_spec.lua    # 阅读模式行为检查
│   ├── sixel_image_spec.lua         # Sixel 尺寸、生命周期与写入检查
│   └── sixel_ffi_collision_check.lua # 隔离的 LuaJIT 声明冲突检查
│
├── after/
│   └── plugin/               # 后加载脚本
│       └── utils.vim         # 工具函数
```

## ✨ 特性

### 核心特性
- 🚀 延迟加载，快速启动
- 📦 使用 [lazy.nvim](https://github.com/folke/lazy.nvim) 管理插件
- 🍿 通过 snacks.nvim 提供大文件、快速文件显示、buffer 删除、单词引用和 Lazygit 实用模块
- 🎨 美观的 Catppuccin 主题
- ⌨️ 现代快捷键 (Ctrl+C/V/S/A)

### LSP 与补全
- 🔧 多语言 LSP 支持
- ✏️ blink.cmp 自动补全
- 🧹 conform.nvim 格式化与 nvim-lint 异步 lint
- 💡 代码操作与诊断

### 导航与搜索
- 🔍 Telescope 模糊查找
- 🌳 nvim-tree 文件浏览器
- 🧭 Aerial 代码大纲、Incline 浮动文件名上下文，以及 nvim-scrollview 右侧阅读位置滚动条
- ⚡ Flash.nvim 快速跳转

### Git 集成
- 📊 侧边栏 Git 标记
- 📋 Git blame 显示
- 🔀 Diffview 差异视图
- 🚀 Lazygit 集成 (g=)

### 编辑器增强
- 🎯 使用 indent-blankline.nvim 提供缩进视觉层
- 💬 快速注释
- 🔄 会话持久化
- 📐 多光标编辑
- 🧹 使用 snacks.nvim 进行不破坏窗口布局的 buffer 删除、单词引用与隐藏 buffer 清理
- 🖥️ 通过 toggleterm.nvim 提供浮动与分屏终端
- 📝 通过 markdown-preview.nvim 提供按需启动的 Markdown 浏览器阅读模式
- 🖼️ 通过 Windows Terminal Sixel 协议直接打开真实图片

## ⌨️ 快捷键

### 通用
| 快捷键 | 功能 |
|--------|------|
| `<Space>` | Leader 键 |
| `<C-s>` | 保存所有 |
| `<C-w>` | 关闭 buffer |
| `<A-x>` | 关闭隐藏 buffer |
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

### 终端
| 快捷键 | 功能 |
|--------|------|
| `<C-p>` | 显示/隐藏浮动终端 |
| `<C-q>` | 在当前布局中新建终端；没有终端窗口时默认浮动 |
| `<C-Left>/<C-Right>` | 在当前布局中切换上/下一个终端 |
| `<C-w>` | 在终端上杀掉当前终端并切到上一个；普通 buffer 仍为关闭 |
| `<C-Up>` | 选择终端，并保留当前布局 |
| `-` / `=` | 显示横向/纵向终端 |
| `<C-d>` | 退出终端输入模式，回到普通模式 |

所有终端共用同一个终端池。浮动、横向和纵向只是显示方式；切换终端不会改变当前布局，改变布局也不会新建或替换终端会话。

### 搜索 (Telescope)
| 快捷键 | 功能 |
|--------|------|
| `<Space>ff` | 查找文件 |
| `<Space>fw` | 全局搜索 |
| `<Space>fb` | 查找 buffer |
| `<Space>fc` | 搜索光标下的词 |

### Markdown 阅读

| 快捷键 | 功能 |
|--------|------|
| `<Space>md` | 开启或关闭 Markdown 阅读模式 |

在 Markdown buffer 中按 `<Space>md` 会启动现有的 markdown-preview.nvim 预览服务。在 Windows Terminal 的 WSL2 环境中，会先让预览页开始渲染；窗口就绪后，再把终端和 Windows 系统默认浏览器近乎同时放到当前显示器左侧 55% 与右侧 45%。这样冷启动浏览器时，桌面不会长时间停在只摆好一边的半成品状态。切换到其他 Markdown buffer 会复用同一个预览窗口。

编辑 Markdown 时，网页内容会实时更新，但保持当前浏览位置。普通光标移动（包括 `j/k`、鼠标点选和搜索跳转）不会控制网页；只有主动滚屏操作才会同步浏览位置：`Ctrl-D/U`、`Ctrl-E/Y`、`Ctrl-F/B`、`PageUp/PageDown`、鼠标滚轮及 `zz/zt/zb`。同步方向只有 Neovim → 网页；在网页中滚动不会反向移动 Neovim。

再次按 `<Space>md` 或退出 Neovim，会关闭专用预览窗口，并恢复终端原来的位置和最大化状态。如果不在 WSL2、不是 Windows Terminal，或 PowerShell 摆窗失败，Markdown 预览仍会用普通浏览器打开，只是不调整窗口布局。

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

本仓库内的标准安装入口是 `install-script/agent-runner.py`，不要只手动链接配置目录。

```bash
cd ~/hpf_Linux_Config
python3 install-script/agent-runner.py install nvim --dry-run
python3 install-script/agent-runner.py install nvim
python3 install-script/agent-runner.py check nvim
```

安装脚本会完成：

- 按 `languages.json` 安装 Neovim 外部工具与 provider 依赖
- 在 `~/.local/share/hpf-linux-config/nvim/releases/` 构建隔离 candidate
- 通过 `~/.local/bin/nvim` 稳定 launcher 激活 `current` release
- 将 `~/.config/nvim` 链接到 `~/hpf_Linux_Config/nvim`
- 在 candidate 内同步插件、Mason LSP 与 parser，完整验收后才原子切换
- 保留 `previous`，激活后 smoke 失败自动回滚；用户数据放在 `persistent/`

安装后可人工复核：

```bash
which -a nvim
nvim --version
test -L ~/.config/nvim && readlink ~/.config/nvim
readlink ~/.local/share/hpf-linux-config/nvim/current
nvim --headless '+qa'
nvim --headless '+checkhealth' '+w! /tmp/hpf-nvim-checkhealth.txt' '+qa'
```

首次正常启动 Neovim 后，Mason 会自动安装配置中声明的全部 LSP 服务器。
语言、LSP、Treesitter、formatter、linter、外部工具与验证 fixture 的唯一目录是
`languages.json`；Lua 运行时和 release 安装器都从它生成各自的投影。
也可以手动重新触发完整安装：

```vim
:MasonInstallAll
```

## 📝 注意事项

### Ubuntu 24.04 Python provider

Ubuntu 24.04 默认启用 PEP 668，可能拦截普通 `pip3 install --user pynvim`。优先使用：

```bash
sudo apt install python3-pynvim
```

### Node provider

如果 `:checkhealth` 提示缺少 Node provider：

```bash
npm install -g neovim
```

### Markdown
Neovim buffer 内保持普通 Markdown 编辑，不加载本地渲染插件。需要渲染阅读时，使用 `<Space>md` 调用 markdown-preview.nvim 浏览器阅读模式。网页正文默认使用 17px 字号、1.75 行高和 900px 正文宽度，并为表格、代码块、列表和引用保留更宽的可读空间。

如果浏览器预览无法工作：
```bash
cd "$(readlink -f ~/.local/share/hpf-linux-config/nvim/current)/xdg/data/nvim/lazy/markdown-preview.nvim/app/" && npm install
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
