--[[
  Terminal plugins
--]]

local terminal_manager = require "config.terminal_manager"

return {
  -- Toggleterm
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec", "TermNew", "TermSelect" },
    keys = {
      {
        "<C-p>",
        function()
          terminal_manager.toggle "float"
        end,
        mode = { "n", "t" },
        desc = "Toggle floating terminal",
      },
      {
        "<C-q>",
        terminal_manager.new_terminal,
        mode = { "n", "t" },
        desc = "New terminal in current layout",
      },
      {
        "<C-left>",
        function()
          terminal_manager.cycle(-1)
        end,
        mode = { "n", "t" },
        desc = "Previous terminal in current layout",
      },
      {
        "<C-right>",
        function()
          terminal_manager.cycle(1)
        end,
        mode = { "n", "t" },
        desc = "Next terminal in current layout",
      },
      {
        "<C-up>",
        terminal_manager.select_terminal,
        mode = { "n", "t" },
        desc = "Select terminal in current layout",
      },
      { "-", desc = "Toggle horizontal terminal" },
      { "=", desc = "Toggle vertical terminal" },
    },
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
      float_opts = { border = "rounded", title_pos = "center" },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      vim.keymap.set("n", "-", function()
        terminal_manager.toggle "horizontal"
      end, { desc = "Toggle horizontal terminal" })
      vim.keymap.set("n", "=", function()
        terminal_manager.toggle "vertical"
      end, { desc = "Toggle vertical terminal" })
    end,
  },
}
