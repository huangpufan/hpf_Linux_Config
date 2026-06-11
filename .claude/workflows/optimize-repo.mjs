// Repository optimization workflow
// Phases: P0 (cleanup) → P1 (restructure) → P2 (polish)
// Each phase commits atomically after verification.

export const meta = {
  name: 'optimize-repo',
  description: 'Optimize repository structure in 3 phases: cleanup, restructure, polish',
  phases: [
    { title: 'P0 Cleanup', detail: 'Delete logs, temp files, dead code' },
    { title: 'P1 Restructure', detail: 'Unify config management with stow' },
    { title: 'P2 Polish', detail: 'Update docs and standardize scripts' },
  ],
}

// ---- P0: Cleanup ----
phase('P0 Cleanup')

log('P0.1: Removing install-script/nvim.log (nvim server start log)')
await agent(`
Delete the file at install-script/nvim.log from the git repository.
It's a log file containing nvim server start warnings, not a config file.
Also ensure *.log is in install-script/.gitignore (it already is).
After deleting, run: git rm install-script/nvim.log
`, { label: 'rm-nvim-log' })

log('P0.2: Removing install-script/todo (temporary task list)')
await agent(`
Delete the file at install-script/todo. It contains a one-line note about an aliases tool.
Run: git rm install-script/todo
`, { label: 'rm-todo' })

log('P0.3: Removing install-script/no-use/ directory (archived/dead scripts)')
await agent(`
Delete the entire install-script/no-use/ directory and all its contents.
These are archived/unmaintained scripts:
- archived-luals-install.sh (ARCHIVED header confirms it)
- pull_nvim_config.sh (old nvim backup approach)
- push_nvim_config.sh (old nvim backup approach)
Run: git rm -r install-script/no-use/
`, { label: 'rm-no-use' })

log('P0.4: Removing nvim/vim-tutorial-cn.md (tutorial doc, not config)')
await agent(`
Delete nvim/vim-tutorial-cn.md — it's an empty Vim tutorial file, not a configuration file.
Run: git rm nvim/vim-tutorial-cn.md
`, { label: 'rm-tutorial' })

log('P0.5: Removing install-script/nvim/readme.md (duplicate, superseded by README.md)')
await agent(`
Delete install-script/nvim/readme.md — it's a short verification guide that duplicates info in the project README.md and nvim/README.md.
Run: git rm install-script/nvim/readme.md
`, { label: 'rm-nvim-readme' })

log('P0 verification: checking git status and committing')
await agent(`
Run: git status --short
Verify that only the expected deletions show up (nvim.log, todo, no-use/, vim-tutorial-cn.md, nvim/readme.md).
Then commit with message:
  chore(cleanup): remove dead code, logs, and temp files

  - install-script/nvim.log: server start log
  - install-script/todo: temp task list
  - install-script/no-use/: archived dead scripts
  - nvim/vim-tutorial-cn.md: non-config tutorial doc
  - install-script/nvim/readme.md: superseded by README.md

  Co-Authored-By: Claude <noreply@anthropic.com>
`, { label: 'p0-commit' })

// ---- P1: Restructure ----
phase('P1 Restructure')

log('P1.1: Understanding current symlink layout')
await agent(`
Run these commands and report what you find:
1. ls -la ~/.config/nvim
2. ls -la ~/.config/herdr/config.toml
3. ls -la ~/.bash-aliases ~/.bash-source ~/.bash-env ~/.tmux.conf 2>/dev/null
4. ls -la ~/.cargo/config.toml 2>/dev/null
5. ls -la ~/.cgdb/cgdbrc 2>/dev/null
6. git ls-files home/ 2>/dev/null | head -5

Report back which symlinks exist and whether home/ already has content.
`, { label: 'analyze-symlinks' })

log('P1.2: Creating home/ stow structure')
await agent(`
Goal: Create a home/ stow directory and migrate config files from install-script/basic/ into it.

Step 1: Create directories:
mkdir -p home/.config/herdr home/.config/bash home/.config/tmux home/.cargo home/.cgdb

Step 2: Git-move files (use 'git mv' so git tracks the history):
git mv install-script/basic/bash/aliases home/.config/bash/aliases
git mv install-script/basic/bash/source home/.config/bash/source
git mv install-script/basic/bash/env home/.config/bash/env
git mv install-script/basic/tmux/tmux.conf home/.config/tmux/tmux.conf
git mv install-script/basic/cargo-config.toml home/.cargo/config.toml
git mv install-script/gdb/cgdbrc home/.cgdb/cgdbrc

Step 3: For herdr config — COPY (not move) since install-script/basic/herdr/config.toml is also used as install source:
cp install-script/basic/herdr/config.toml home/.config/herdr/config.toml
git add home/.config/herdr/config.toml

Report the result of 'git status --short' after all moves.
`, { label: 'migrate-to-stow' })

log('P1.3: Updating herdr install script symlink target')
await agent(`
Read install-script/basic/herdr/install-herdr-config.sh. It creates a symlink from ~/.config/herdr/config.toml to the repo. Update the target path from the old location to the new location: home/.config/herdr/config.toml

After editing, show the updated file with 'cat install-script/basic/herdr/install-herdr-config.sh'
`, { label: 'update-herdr-install' })

log('P1.4: Updating makefile with stow target')
await agent(`
Read the current makefile. Add a new 'stow' target for deploying configs with GNU stow:

Add these lines before the existing targets (or after them):

# Deploy runtime configs with GNU stow
stow:
\tstow home -t $(HOME)

And add stow to the help comment at the top.

Show the updated file with 'cat makefile'
`, { label: 'update-makefile' })

log('P1.5: Verify and commit P1')
await agent(`
Run: git status --short
Verify:
1. home/.config/herdr/config.toml exists ✓
2. home/.config/bash/aliases, source, env exist ✓
3. home/.config/tmux/tmux.conf exists ✓
4. home/.cargo/config.toml exists ✓
5. home/.cgdb/cgdbrc exists ✓
6. install-script/basic/bash/aliases is GONE (was git mv'd) ✓
7. install-script/basic/tmux/tmux.conf is GONE ✓
8. install-script/basic/cargo-config.toml is GONE ✓
9. install-script/gdb/cgdbrc is GONE ✓
10. install-script/basic/herdr/config.toml still exists (was copied) ✓
11. install-script/basic/herdr/install-herdr-config.sh updated ✓
12. makefile updated ✓

If everything looks correct, commit:
  git add -A
  git commit -m 'feat(stow): migrate runtime configs to home/ stow structure

  - Move bash configs to home/.config/bash/
  - Move tmux config to home/.config/tmux/
  - Copy herdr config to home/.config/herdr/ (keep install source)
  - Move cargo config to home/.cargo/
  - Move cgdb config to home/.cgdb/
  - Update herdr install script symlink target
  - Add stow target to makefile

  Co-Authored-By: Claude <noreply@anthropic.com>'
`, { label: 'p1-commit' })

// ---- P2: Polish ----
phase('P2 Polish')

log('P2.1: Update README structure section')
await agent(`
Read the current README.md (cat README.md) and README-CN.md (cat README-CN.md).
The "Project Structure" section in both files is outdated.

Update the project structure tree in BOTH files to reflect the new layout. The accurate structure is:

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

For README-CN.md, translate the structure comments to Chinese.

Also update the "Direct Script Usage" section — remove references to files that were moved (like bash config, tmux config, cargo config).

Don't rewrite the entire file, just update the structure section.
`, { label: 'update-readme' })

log('P2.2: Update .gitignore')
await agent(`
Read current .gitignore (cat .gitignore). Add these entries if not already present:

*.log
.cache/
__pycache__/
*.pyc

Report what you added.
`, { label: 'update-gitignore' })

log('P2.3: Final verification and commit')
await agent(`
Run: git status --short
Review all changes. If everything looks good, commit:
  git add -A
  git commit -m 'docs: update README and polish project structure

  - Update project structure in README.md and README-CN.md
  - Add common entries to .gitignore
  - Add ARCHITECTURE.md documentation

  Co-Authored-By: Claude <noreply@anthropic.com>'

Then push:
  git push

Verify push succeeded.
`, { label: 'p2-final-commit-push' })

return { status: 'completed', message: 'All 3 phases completed and pushed' }
