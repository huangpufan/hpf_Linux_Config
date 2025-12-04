--[[
  Neovim Configuration
  
  Project Structure:
  ├── init.lua              # Main entry point
  ├── lua/
  │   ├── core/             # Core configuration
  │   │   ├── init.lua      # Core entry
  │   │   ├── options.lua   # Vim options
  │   │   ├── keymaps.lua   # Key mappings
  │   │   ├── autocmds.lua  # Auto commands
  │   │   └── lazy.lua      # Plugin manager
  │   └── plugins/          # Plugin configurations
  │       ├── init.lua      # Plugin specs list
  │       ├── lsp/          # LSP related
  │       ├── ui.lua        # UI plugins
  │       ├── editor.lua    # Editor enhancements
  │       ├── git.lua       # Git integration
  │       ├── treesitter.lua
  │       ├── telescope.lua
  │       └── completion.lua
  ├── snippets/             # Custom snippets
  └── ftplugin/             # Filetype specific configs
--]]

-- Set leader key before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable some built-in providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Load core configuration
require("core")

