# Neovim Configuration

A modern, modular Neovim configuration for C/C++ and general development.

## 📁 Project Structure

```
nvim/
├── init.lua                  # Main entry point
├── lazy-lock.json            # Plugin version lock file
├── efm.yaml                  # EFM language server config
│
├── lua/
│   ├── core/                 # Core configuration
│   │   ├── init.lua          # Core entry point
│   │   ├── options.lua       # Vim options
│   │   ├── keymaps.lua       # Key mappings
│   │   ├── autocmds.lua      # Auto commands
│   │   └── lazy.lua          # Plugin manager (lazy.nvim)
│   │
│   ├── config/               # Non-plugin configurations
│   │   ├── keybindings.lua   # Which-key bindings
│   │   └── lsp/              # LSP utility modules
│   │       ├── handlers.lua  # LSP handlers
│   │       └── servers.lua   # Server configs
│   │
│   └── plugins/              # Plugin configurations
│       ├── init.lua          # Plugin specs index
│       ├── colorscheme.lua   # Theme settings
│       ├── ui.lua            # UI plugins
│       ├── editor.lua        # Editor enhancements
│       ├── completion.lua    # Completion (nvim-cmp)
│       ├── treesitter.lua    # Treesitter config
│       ├── telescope.lua     # Telescope and pickers
│       ├── git.lua           # Git integration
│       ├── terminal.lua      # Terminal plugins
│       ├── markdown.lua      # Markdown plugins
│       ├── tools.lua         # Misc tools
│       └── lsp/              # LSP plugin specs
│           └── init.lua      # LSP plugins
│
├── after/
│   └── plugin/               # After-load scripts
│       ├── wilder.vim        # Wilder config
│       └── utils.vim         # Utility functions
│
└── snippets/                 # Custom snippets
    ├── c.snippets
    ├── cpp.snippets
    ├── markdown.snippets
    └── sh.snippets
```

## ✨ Features

### Core Features
- 🚀 Fast startup with lazy loading
- 📦 Plugin management via [lazy.nvim](https://github.com/folke/lazy.nvim)
- 🎨 Beautiful UI with Catppuccin theme
- ⌨️ Modern keybindings (Ctrl+C/V/S/A)

### LSP & Completion
- 🔧 LSP support for multiple languages
- ✏️ Auto-completion with nvim-cmp
- 📝 Snippets with LuaSnip
- 💡 Code actions and diagnostics

### Navigation & Search
- 🔍 Fuzzy finding with Telescope
- 🌳 File explorer with nvim-tree
- ⚡ Quick jump with Flash.nvim
- 📌 Bookmarks support

### Git Integration
- 📊 Git signs in gutter
- 📋 Git blame display
- 🔀 Diffview for diffs
- 🚀 Lazygit integration (g=)

### Editor Enhancements
- 🎯 Smart indentation
- 💬 Easy commenting
- 🔄 Session persistence
- 📐 Multi-cursor editing

## ⌨️ Key Bindings

### General
| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `<C-s>` | Save all |
| `<C-w>` | Close buffer |
| `<C-n>` | Toggle file tree |
| `q` | Close window |
| `<Space>q` | Quit Neovim |

### Navigation
| Key | Action |
|-----|--------|
| `<A-j>/<A-k>` | Previous/Next buffer |
| `<A-1-9>` | Go to buffer N |
| `<C-h>/<C-l>` | Switch windows |
| `\` / `\|` | Horizontal/Vertical split |

### Search (Telescope)
| Key | Action |
|-----|--------|
| `<Space>ff` | Find files |
| `<Space>fw` | Live grep |
| `<Space>fb` | Find buffers |
| `<Space>fc` | Search word under cursor |

### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<Space>la` | Code action |
| `<Space>lf` | Format code |
| `<Space>rn` | Rename symbol |

### Git
| Key | Action |
|-----|--------|
| `g=` | Open Lazygit |
| `<Space>sg` | Git status |

## 🔧 Installation

1. Backup your existing Neovim configuration:
   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
   ```

2. Clone or link this configuration:
   ```bash
   ln -s /path/to/this/nvim ~/.config/nvim
   ```

3. Open Neovim and let lazy.nvim install plugins:
   ```bash
   nvim
   ```

4. Install LSP servers:
   ```vim
   :MasonInstallAll
   ```

## 📝 Notes

### Markdown Preview
If markdown preview doesn't work:
```bash
cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app/ && npm install
```

### Treesitter
Update Just syntax:
```vim
:TSInstall just
```

## 📄 License

MIT
