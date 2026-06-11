# HPF Linux Config

**[English](README.md) | [中文](README-CN.md)**

> A modular Linux and WSL2 development environment config with a fixed repo path, agent-first install playbook, and deterministic script runner.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-WSL2%20%7C%20Linux-green.svg)]()
[![Neovim](https://img.shields.io/badge/Editor-Neovim-brightgreen.svg)](https://neovim.io/)

## Features

- **Agent Playbook** - Probe first, ask on ambiguity, execute second, verify last.
- **Deterministic Runner** - Standard-library Python entrypoint for `list`, `check`, `install`, and `preset`.
- **GitHub Auth Flow** - Default `gh + HTTPS`; optional SSH bootstrap only when explicitly needed.
- **Modular Scripts** - Each tool keeps its own install script under `install-script/`.
- **Preset Bundles** - `minimal`, `dev-cli`, `dev-full`, and `all-tools`.
- **Neovim Config** - Included config for C/C++ development with LSP support and scoped snacks.nvim utility modules.

## Quick Start

The repository is expected to live at `~/hpf_Linux_Config`.

```bash
git clone https://github.com/huangpufan/hpf_Linux_Config.git ~/hpf_Linux_Config
cd ~/hpf_Linux_Config

# Install GitHub CLI if needed
python3 install-script/agent-runner.py install gh

# Configure git identity
HPF_GIT_NAME="Your Name" \
HPF_GIT_EMAIL="you@example.com" \
python3 install-script/agent-runner.py install git-identity

# Authenticate GitHub with HTTPS first
python3 install-script/agent-runner.py install github-auth

# Install your base toolset
python3 install-script/agent-runner.py preset minimal
```

## Agent Workflow

For install tasks, read these files in order:

- [AGENTS.md](AGENTS.md)
- [docs/agent-install-playbook.md](docs/agent-install-playbook.md)

Install-related code lives mainly under `install-script/`:

- `install-script/presets/` is the preset entrypoint
- `install-script/setup/` covers system and account setup
- `install-script/basic/` covers base environment bootstrap
- `install-script/tools/` contains one installer per tool
- `install-script/openharmony/` is OpenHarmony-specific and not part of the default machine bootstrap

The runner uses `install-script/agent-tools.json` as the single catalog. Install status is determined only by `check_cmd`; there is no persisted TUI state anymore. The runner also expects this repository to live at `~/hpf_Linux_Config`.

## Runner Commands

```bash
# List all catalog entries
python3 install-script/agent-runner.py list

# Configure git + GitHub
HPF_GIT_NAME="Your Name" HPF_GIT_EMAIL="you@example.com" \
python3 install-script/agent-runner.py install git-identity
python3 install-script/agent-runner.py install github-auth

# Optional: switch GitHub git protocol to SSH and upload a key via gh
python3 install-script/agent-runner.py install github-ssh

# Verify one tool or the whole catalog
python3 install-script/agent-runner.py check git
python3 install-script/agent-runner.py check all

# Run one tool by tool id
python3 install-script/agent-runner.py install git
python3 install-script/agent-runner.py install gh

# Run preset wrappers
python3 install-script/agent-runner.py preset minimal
python3 install-script/agent-runner.py preset dev-cli
python3 install-script/agent-runner.py preset dev-full
python3 install-script/agent-runner.py preset all-tools
```

Each install streams stdout/stderr to the terminal and writes a log to `~/.local/share/hpf-linux-config/logs/`.

## Project Structure

```text
hpf_Linux_Config/
├── AGENTS.md
├── ARCHITECTURE.md
├── docs/
│   └── agent-install-playbook.md
├── home/                          # stow root for runtime configs
│   ├── .config/
│   │   ├── bash/
│   │   │   ├── aliases
│   │   │   ├── env
│   │   │   └── source
│   │   ├── herdr/
│   │   │   └── config.toml
│   │   └── tmux/
│   │       └── tmux.conf
│   ├── .cargo/
│   │   └── config.toml
│   └── .cgdb/
│       └── cgdbrc
├── install-script/
│   ├── agent-runner.py
│   ├── agent-tools.json
│   ├── tools/
│   ├── presets/
│   ├── setup/
│   ├── basic/
│   └── lib/
├── nvim/
└── makefile
```

## Direct Script Usage

If you do not want the runner, the original preset scripts are still available.
These direct scripts are only supported when the repository is located at `~/hpf_Linux_Config`:

```bash
bash install-script/presets/minimal.sh
bash install-script/presets/dev-cli.sh
bash install-script/presets/dev-full.sh
bash install-script/presets/all-tools.sh
```

## Neovim Configuration

Link the bundled config with:

```bash
make link-nvim
```

The Neovim config keeps Telescope, nvim-tree, alpha, and terminal plugins on their existing paths while using snacks.nvim for big files, quick file display, buffer deletion, word references, and Lazygit.

## Requirements

- Ubuntu 20.04/22.04/24.04 (WSL2 recommended)
- Python 3.8+
- Git
- `gh` can be installed by this repo via `install-script/tools/apt/gh.sh`

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
