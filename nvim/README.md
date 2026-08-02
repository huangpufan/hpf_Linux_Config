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
│   │   ├── markdown_preview.lua # Markdown reading-mode controller
│   │   ├── sixel_image.lua   # Short-write-safe Sixel image-buffer renderer
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
│       ├── image.lua         # Direct image-buffer integration
│       ├── tools.lua         # Misc tools
│       └── lsp/              # LSP plugin specs
│           └── init.lua      # LSP plugins
│
├── assets/
│   └── markdown-reading.css  # Browser reading styles
├── scripts/
│   └── markdown-reading-mode.ps1 # Windows Terminal/browser layout helper
├── tests/
│   ├── markdown_preview_spec.lua    # Reading-mode behavior checks
│   ├── scrollview_spec.lua          # First-page scrollbar and Incline coexistence check
│   ├── sixel_image_spec.lua         # Sixel sizing, lifecycle, and write checks
│   └── sixel_ffi_collision_check.lua # Isolated LuaJIT declaration check
│
├── after/
│   └── plugin/               # After-load scripts
│       └── utils.vim         # Utility functions
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
- 💡 Code actions and diagnostics

### Navigation & Search
- 🔍 Fuzzy finding with Telescope
- 🌳 File explorer with nvim-tree
- 🧭 Code outline with Aerial, floating filename context with Incline, and a right-edge reading-position scrollbar with nvim-scrollview
- ⚡ Quick jump with Flash.nvim

### Git Integration
- 📊 Git signs in gutter
- 📋 Git blame display
- 🔀 Diffview for diffs
- 🚀 Lazygit integration (g=)

### Editor Enhancements
- 🎯 Smart indentation with indent-blankline.nvim
- 💬 Easy commenting
- 🔄 Session persistence
- 📐 Multi-cursor editing
- 🧹 Layout-safe buffer deletion, word references, and hidden buffer cleanup with snacks.nvim
- 🖥️ Floating and split terminals through toggleterm.nvim
- 📝 On-demand Markdown browser reading mode through markdown-preview.nvim
- 🖼️ Direct real-image buffers through Windows Terminal's Sixel protocol

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

### Terminal
| Key | Action |
|-----|--------|
| `<C-p>` | Show/hide the floating terminal |
| `<C-q>` | Create a terminal in the current layout; default to floating when no terminal is visible |
| `<C-Left>/<C-Right>` | Switch terminals while preserving the current layout |
| `<C-w>` | On a terminal, kill the current terminal and switch to the previous one; on a normal buffer, still closes it |
| `<C-Up>` | Select a terminal while preserving the current layout |
| `-` / `=` | Show a horizontal/vertical terminal |
| `<C-d>` | Leave terminal input mode and return to Normal mode |

All terminals share one terminal pool. Floating, horizontal, and vertical windows are presentation modes: switching terminals preserves the current layout, and changing layout preserves the terminal session.

### Search (Telescope)
| Key | Action |
|-----|--------|
| `<Space>ff` | Find files |
| `<Space>fw` | Live grep |
| `<Space>fb` | Find buffers |
| `<Space>fc` | Search word under cursor |

### Markdown Reading

| Key | Action |
|-----|--------|
| `<Space>md` | Open or close Markdown reading mode |

From a Markdown buffer, `<Space>md` starts the existing markdown-preview.nvim service. Under WSL2 in Windows Terminal, the preview starts rendering first; once its window is ready, the terminal and the Windows system default browser are placed together on the left 55% and right 45% of the current monitor. This avoids leaving the desktop in a half-finished layout while a cold browser starts. Switching to another Markdown buffer reuses the same preview window.

Editing Markdown updates the page in real time while preserving the browser's current position. Ordinary cursor movement, including `j/k`, mouse selection, and search jumps, does not control the page. Browser position follows only explicit scrolling with `Ctrl-D/U`, `Ctrl-E/Y`, `Ctrl-F/B`, `PageUp/PageDown`, the mouse wheel, or `zz/zt/zb`. Synchronization is one-way: Neovim controls the web preview, but scrolling the web page does not move Neovim.

Press `<Space>md` again, or exit Neovim, to close the dedicated preview window and restore the terminal's previous position and maximized state. Outside WSL2, outside Windows Terminal, or when PowerShell layout control fails, the preview still opens in the normal browser without rearranging windows.

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

- External tools from `languages.json` and provider dependencies
- An isolated candidate under `~/.local/share/hpf-linux-config/nvim/releases/`
- A stable `~/.local/bin/nvim` launcher for the active `current` release
- The `~/.config/nvim` link to `~/hpf_Linux_Config/nvim`
- Candidate-local plugins, Mason LSPs, parsers, and full verification before activation
- `previous` retention, automatic rollback after a failed activation smoke, and persistent user data

Manual post-install checks:

```bash
which -a nvim
nvim --version
test -L ~/.config/nvim && readlink ~/.config/nvim
readlink ~/.local/share/hpf-linux-config/nvim/current
nvim --headless '+qa'
nvim --headless '+checkhealth' '+w! /tmp/hpf-nvim-checkhealth.txt' '+qa'
```

After the first normal Neovim startup, Mason automatically installs every configured LSP server.
`languages.json` is the single catalog for languages, LSPs, Treesitter parsers,
formatters, linters, external tools, and verification fixtures. Both the Lua runtime
and the release installer project their own inputs from it.
You can also manually trigger the full installation:

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

### Markdown
Markdown buffers remain plain editing surfaces without an in-buffer rendering plugin. Use `<Space>md` to open markdown-preview.nvim browser reading mode when rendered output is needed. The browser view uses 17px body text, 1.75 line height, a 900px prose width, and wider space for tables, code blocks, lists, and quotations.

If browser preview doesn't work:
```bash
cd "$(readlink -f ~/.local/share/hpf-linux-config/nvim/current)/xdg/data/nvim/lazy/markdown-preview.nvim/app/" && npm install
```

### Treesitter
Update Just syntax:
```vim
:TSInstall just
```

## 📄 License

MIT
