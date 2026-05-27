# Neovim Configuration

A modern, modular Neovim configuration for C/C++ and general development.

## 📁 Project Structure

```
nvim/
├── init.lua                  # Main entry point
├── lazy-lock.json            # Plugin version lock file
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
│       ├── snacks.lua        # Snacks utility modules
│       ├── colorscheme.lua   # Theme settings
│       ├── ui.lua            # UI plugins
│       ├── editor.lua        # Editor enhancements
│       ├── completion.lua    # Completion (blink.cmp)
│       ├── formatting.lua    # Formatting and linting
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
- 🍿 Utility modules via snacks.nvim for big files, quick file display, buffer deletion, word references, and Lazygit
- 🎨 Beautiful UI with Catppuccin theme
- ⌨️ Modern keybindings (Ctrl+C/V/S/A)

### LSP & Completion
- 🔧 LSP support for multiple languages
- ✏️ Auto-completion with blink.cmp
- 🧹 Formatting with conform.nvim and linting with nvim-lint
- 📝 Snippets with LuaSnip and custom `snippets/`
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
- 🧹 Layout-safe buffer deletion and hidden buffer cleanup with snacks.nvim

## ⌨️ Key Bindings

### General
| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `<C-s>` | Save all |
| `<C-w>` | Close buffer |
| `<A-x>` | Close hidden buffers |
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

The standard installation entrypoint in this repository is
`install-script/agent-runner.py`. Do not only link the config directory by hand.

```bash
cd ~/hpf_Linux_Config
python3 install-script/agent-runner.py install nvim --dry-run
python3 install-script/agent-runner.py install nvim
python3 install-script/agent-runner.py check nvim
```

The install script handles:

- Neovim dependencies and provider dependencies
- The pinned Neovim build under `~/.local/nvim-<version>/`
- The `~/.local/bin/nvim` symlink
- The `~/.config/nvim` link to `~/hpf_Linux_Config/nvim`
- `lazy.nvim` plugin sync and a headless startup smoke check

Manual post-install checks:

```bash
which -a nvim
nvim --version
test -L ~/.config/nvim && readlink ~/.config/nvim
nvim --headless '+qa'
nvim --headless '+checkhealth' '+w! /tmp/hpf-nvim-checkhealth.txt' '+qa'
```

Install LSP servers from inside Neovim as needed:

```vim
:MasonInstallAll
```

## 📝 Notes

### Ubuntu 24.04 Python Provider

Ubuntu 24.04 enables PEP 668 and may reject a plain `pip3 install --user pynvim`.
Prefer the distro package:

```bash
sudo apt install python3-pynvim
```

### Node Provider

If `:checkhealth` reports a missing Node provider:

```bash
npm install -g neovim
```

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
