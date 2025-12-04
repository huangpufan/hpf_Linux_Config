--[[
  Core configuration entry point
  Loads all core modules in the correct order
--]]

-- Load options first
require("core.options")

-- Bootstrap and setup lazy.nvim
require("core.lazy")

-- Load keymaps after plugins are loaded
require("core.keymaps")

-- Load auto commands
require("core.autocmds")

