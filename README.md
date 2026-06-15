# HPF Linux Config

**[English](README.md) | [中文](README-CN.md)**

> A modular Linux and WSL2 development environment config with a fixed repo path, agent-first install playbook, and deterministic script runner.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-WSL2%20%7C%20Linux-green.svg)]()
[![Neovim](https://img.shields.io/badge/Editor-Neovim-brightgreen.svg)](https://neovim.io/)

## Features

- **Agent Playbook** - Probe first, ask on ambiguity, execute second, verify last.
- **Deterministic Runner** - Standard-library Python entrypoint for `list`, `check`, `install`, and `preset`.
- **GitHub Auth Flow** - The `github-auth` tool defaults to `gh + HTTPS`; the personal-machine `bootstrap` preset generates/uploads an SSH key and switches GitHub to SSH.
- **Modular Scripts** - Each tool keeps its own install script under `install-script/`.
- **Preset Bundles** - `minimal`, `dev-cli`, `dev-full`, and `all-tools`, where `all-tools` means the default `bootstrap + dev-full` preset chain.
- **Neovim Config** - Included config for C/C++ development with LSP support and scoped snacks.nvim utility modules.

## Quick Start

The repository is expected to live at `~/hpf_Linux_Config`.

```bash
git clone https://github.com/huangpufan/hpf_Linux_Config.git ~/hpf_Linux_Config
cd ~/hpf_Linux_Config

# Deploy runtime configs with GNU stow
sudo apt-get install -y stow
stow home -t $HOME

# Install GitHub CLI if needed
python3 install-script/agent-runner.py install gh

# Configure git identity
HPF_GIT_NAME="Your Name" \
HPF_GIT_EMAIL="you@example.com" \
python3 install-script/agent-runner.py install git-identity

# Authenticate GitHub with HTTPS first for the standalone auth tool
python3 install-script/agent-runner.py install github-auth

# Personal-machine bootstrap also uploads an SSH key and switches GitHub to SSH
# Run directly on the hpf account; on any other account confirm first and set HPF_BOOTSTRAP_CONFIRM_PERSONAL=yes plus HPF_GIT_EMAIL
python3 install-script/agent-runner.py preset bootstrap

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

# Optional after standalone auth; preset bootstrap does this by default
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
`all-tools` is the default `bootstrap + dev-full` preset chain; it does not include `nvim`, OpenHarmony, or personal-purpose scripts.
On non-`hpf` accounts, `bootstrap` / `all-tools` require
`HPF_BOOTSTRAP_CONFIRM_PERSONAL=yes` and `HPF_GIT_EMAIL` so an agent cannot silently upload an SSH key on someone else's machine.

## Project Structure

```text
hpf_Linux_Config/
├── AGENTS.md
├── ARCHITECTURE.md
├── docs/
│   └── agent-install-playbook.md
├── home/                          # stow root — deploy with: stow home -t $HOME
│   ├── .bash-aliases              #   → ~/.bash-aliases
│   ├── .bash-env                  #   → ~/.bash-env
│   ├── .bash-source               #   → ~/.bash-source
│   ├── .tmux.conf                 #   → ~/.tmux.conf
│   ├── .cargo/
│   │   └── config.toml            #   → ~/.cargo/config.toml
│   ├── .cgdb/
│   │   └── cgdbrc                 #   → ~/.cgdb/cgdbrc
│   └── .config/
│       └── herdr/
│           └── config.toml        #   → ~/.config/herdr/config.toml
├── install-script/
│   ├── agent-runner.py
│   ├── agent-tools.json
│   ├── tools/
│   ├── presets/
│   ├── setup/
│   ├── basic/
│   └── lib/
├── nvim/                          # linked manually: make link-nvim
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

## Managing Runtime Configs with GNU Stow

Runtime configurations (shell aliases, tmux, git, herdr, etc.) live under `home/` and are deployed to `$HOME` with [GNU Stow](https://www.gnu.org/software/stow/).

### Deploy

```bash
cd ~/hpf_Linux_Config
stow home -t $HOME
# or: make stow
```

### Undeploy (remove all symlinks)

```bash
cd ~/hpf_Linux_Config
stow -D home -t $HOME
```

### Adding a new config file

1. Place the file at the correct path under `home/` matching where it should appear in `$HOME`.
   - Example: `~/.config/kitty/kitty.conf` → `home/.config/kitty/kitty.conf`
2. Commit and push.
3. Re-deploy:

```bash
stow home -t $HOME
```

Stow automatically creates symlinks for any new files under `home/` and skips existing ones.

## Neovim Configuration

Neovim is managed separately (not through stow) because it lives at the repo root for historical reasons.

## Requirements

- Ubuntu 20.04/22.04/24.04 (WSL2 recommended)
- Python 3.8+
- Git
- `gh` can be installed by this repo via `install-script/tools/apt/gh.sh`

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
