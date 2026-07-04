--[[
  Plugin specifications index
  
  This file returns all plugin specs by importing from sub-modules.
  Each module returns a table of plugin specs.
--]]

return {
  -- Dependencies
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "kkharji/sqlite.lua" },

  -- Import plugin modules
  { import = "plugins.snacks" },
  { import = "plugins.colorscheme" },
  { import = "plugins.ui" },
  { import = "plugins.editor" },
  { import = "plugins.completion" },
  { import = "plugins.lsp" },
  { import = "plugins.formatting" },
  { import = "plugins.treesitter" },
  { import = "plugins.telescope" },
  { import = "plugins.git" },
  { import = "plugins.terminal" },
  { import = "plugins.markdown" },
  { import = "plugins.tools" },
}
