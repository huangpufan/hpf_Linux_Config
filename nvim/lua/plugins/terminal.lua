--[[
  Terminal plugins
--]]

local terminal_manager = require "config.terminal_manager"

return {
  -- Toggleterm
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec", "TermNew", "TermSelect" },
    keys = require("config.actions").lazy_keys "toggleterm",
    opts = {
      highlights = {
        Normal = { link = "Normal" },
        NormalNC = { link = "NormalNC" },
        NormalFloat = { link = "NormalFloat" },
        FloatBorder = { link = "FloatBorder" },
        StatusLine = { link = "StatusLine" },
        StatusLineNC = { link = "StatusLineNC" },
        WinBar = { link = "WinBar" },
        WinBarNC = { link = "WinBarNC" },
      },
      size = 10,
      on_create = terminal_manager.on_create,
      on_open = terminal_manager.on_open,
      on_exit = terminal_manager.on_exit,
      shading_factor = 2,
      direction = "float",
      auto_scroll = false,
      persist_mode = false,
      start_in_insert = true,
      float_opts = { border = "rounded", title_pos = "center" },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
    end,
  },
}
