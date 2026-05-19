After nvim installation:

1. Verify the runner check:

   ```bash
   cd ~/hpf_Linux_Config
   python3 install-script/agent-runner.py check nvim
   ```

2. Verify Neovim can load the repository config without startup errors:

   ```bash
   nvim --headless '+qa'
   ```

3. Optional health report:

   ```bash
   nvim --headless '+checkhealth' '+w! /tmp/hpf-nvim-checkhealth.txt' '+qa'
   ```

4. Optional Copilot setup:

   ```vim
   :CopilotAuto
   ```

   Copilot needs an interactive account authorization step and is not part of
   the automatic install check.
