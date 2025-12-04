--[[
  Miscellaneous tools and utilities
--]]

return {
  -- Startup time profiler
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
  },

  -- Code runner
  {
    "CRAG666/code_runner.nvim",
    cmd = "RunCode",
  },

  -- Overseer (task runner)
  {
    "stevearc/overseer.nvim",
    cmd = "OverseerToggle",
    config = function()
      require("overseer").setup()
    end,
  },

  -- LeetCode
  {
    "kawre/leetcode.nvim",
    cmd = "Leet",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "rcarriga/nvim-notify",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      cn = {
        enabled = true,
      },
      injector = {
        ["cpp"] = {
          before = { "#include <bits/stdc++.h>", "using namespace std;" },
          after = "int main() {}",
        },
      },
    },
  },

}

