# WSL Basic Environment Configuration and Installation Guide

[简体中文](/install-script/basic/README-CN.md)

This folder now follows the repo-wide agent flow:

1. The repository must live at `~/hpf_Linux_Config`.
2. Default GitHub path is `gh + HTTPS`, not manual SSH key upload.
3. Configure git identity first, then GitHub auth, then the rest of the basic environment.

Supported Ubuntu versions:

- Ubuntu 20.04
- Ubuntu 22.04
- Ubuntu 24.04

For Ubuntu 24.04, `ubuntu-source-change.sh` manages
`/etc/apt/sources.list.d/ubuntu.sources` and disables legacy active entries in
`/etc/apt/sources.list` to avoid duplicate mirrors.

Recommended flow:

```bash
cd ~/hpf_Linux_Config
python3 install-script/agent-runner.py install gh
HPF_GIT_NAME="Your Name" HPF_GIT_EMAIL="you@example.com" \
python3 install-script/agent-runner.py install git-identity
python3 install-script/agent-runner.py install github-auth
python3 install-script/agent-runner.py install folder-create
python3 install-script/agent-runner.py install bashrc
python3 install-script/agent-runner.py install configs
```

Only switch GitHub to SSH when you explicitly need it:

```bash
python3 install-script/agent-runner.py install github-ssh
```
