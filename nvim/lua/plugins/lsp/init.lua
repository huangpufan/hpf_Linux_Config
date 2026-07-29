--[[
  LSP configuration
--]]

return {
  -- LSP config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "Saghen/blink.cmp",
    },
    config = function()
      require("config.lsp.handlers").setup()
      require("config.lsp.servers").setup()
    end,
  },

  -- Mason (LSP/DAP/linter installer)
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = {
      ui = {
        icons = {
          package_pending = " ",
          package_installed = "󰄳 ",
          package_uninstalled = " 󰚌",
        },
      },
      max_concurrent_installers = 10,
    },
  },

  -- Mason-lspconfig bridge
  {
    "mason-org/mason-lspconfig.nvim",
    event = "VeryLazy",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = require("config.lsp.servers").names,
      automatic_enable = require("config.lsp.servers").names,
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        vim.cmd("LspInstall " .. table.concat(opts.ensure_installed, " "))
      end, {})
    end,
  },

  -- Fidget (LSP progress)
  {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    config = function()
      require("fidget").setup()
    end,
  },
}
