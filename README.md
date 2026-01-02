# HPF Linux Config

**[English](README.md) | [中文](README-CN.md)**

> A modern, modular Linux development environment configuration for WSL2, featuring a TUI installer and curated CLI tools.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-WSL2%20%7C%20Linux-green.svg)]()
[![Neovim](https://img.shields.io/badge/Editor-Neovim-brightgreen.svg)](https://neovim.io/)

## Features

- **TUI Installer** - Interactive terminal UI with Vim-style keybindings for easy tool installation
- **Modular Design** - Each tool has its own installation script, easy to extend and maintain
- **Preset Configurations** - Pre-defined tool combinations for different use cases
- **Modern CLI Tools** - Curated collection of modern replacements for traditional Unix tools
- **Neovim Config** - Optimized configuration for C/C++ development with LSP support

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/hpf_Linux_Config.git
cd hpf_Linux_Config

# Install TUI installer dependencies
cd tui-installer && pip install -e . && cd ..

# Run TUI installer (recommended)
make run_tui_installer
```

### Using Presets

```bash
# Minimal toolset - essential tools only
bash install-script/presets/minimal.sh

# CLI development tools
bash install-script/presets/dev-cli.sh

# Full development environment
bash install-script/presets/dev-full.sh
```

## Project Structure

```
hpf_Linux_Config/
├── install-script/
│   ├── tools/           # Individual tool installation scripts
│   │   ├── apt/         # APT packages
│   │   ├── snap/        # Snap packages
│   │   ├── cargo/       # Rust/Cargo tools
│   │   ├── npm/         # Node.js packages
│   │   ├── pip/         # Python packages
│   │   └── curl/        # Tools installed via curl
│   ├── setup/           # System configuration scripts
│   ├── presets/         # Preset installation combinations
│   ├── basic/           # Basic configurations (tmux, zsh, etc.)
│   └── lib/             # Shared utility functions
├── tui-installer/       # TUI installer application
│   └── tui_installer/   # Python package source
├── nvim/                # Neovim configuration
└── makefile             # Project shortcuts
```

## Included Tools

### Terminal Enhancements

| Tool | Replaces | Description |
|------|----------|-------------|
| [bat](https://github.com/sharkdp/bat) | `cat` | Syntax highlighting and Git integration |
| [eza](https://github.com/eza-community/eza) | `ls` | Modern file listing with icons |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` | Smarter directory navigation |
| [fzf](https://github.com/junegunn/fzf) | - | Fuzzy finder for everything |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` | Fast recursive search |
| [fd](https://github.com/sharkdp/fd) | `find` | User-friendly file finder |

### File Managers

| Tool | Description |
|------|-------------|
| [yazi](https://github.com/sxyazi/yazi) | Blazing fast terminal file manager |
| [broot](https://github.com/Canop/broot) | Tree view with fuzzy search |
| [ranger](https://github.com/ranger/ranger) | Vim-inspired file manager |

### System Monitoring

| Tool | Replaces | Description |
|------|----------|-------------|
| [btop](https://github.com/aristocratos/btop) | `top`/`htop` | Resource monitor with graphs |
| [dust](https://github.com/bootandy/dust) | `du` | Intuitive disk usage |
| [procs](https://github.com/dalance/procs) | `ps` | Modern process viewer |

### Development

| Tool | Description |
|------|-------------|
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for Git |
| [delta](https://github.com/dandavison/delta) | Beautiful Git diffs |
| [xmake](https://github.com/xmake-io/xmake) | Cross-platform build utility |

## TUI Installer

The TUI installer provides an interactive interface for selecting and installing tools.

### Keybindings

| Key | Action |
|-----|--------|
| `h`/`l` | Switch categories |
| `j`/`k` | Navigate items |
| `Space` | Toggle selection |
| `Enter` | Install selected |
| `a` | Select all |
| `n` | Deselect all |
| `q` | Quit |

## Neovim Configuration

Optimized for C/C++ development with:

- **LSP**: clangd, lua-language-server
- **Completion**: nvim-cmp with snippets
- **Fuzzy Finding**: Telescope
- **File Explorer**: nvim-tree
- **Git Integration**: gitsigns, fugitive

```bash
# Link neovim config
make link-nvim
```

## Tmux Configuration

Pre-configured tmux with:

- Vim-style pane navigation (`Ctrl+hjkl`)
- Easy pane resizing (`prefix + HJKL`)
- TPM plugin manager
- Dracula theme

## Requirements

- Ubuntu 20.04/22.04 (WSL2 recommended)
- Python 3.8+
- Git

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- All the amazing open-source tool authors
- The Neovim community
- [Rich](https://github.com/Textualize/rich) library for the beautiful TUI
