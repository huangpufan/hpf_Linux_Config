--[[
  LSP configuration
--]]

return {
  -- LSP config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("config.lsp.handlers").setup()
      require("config.lsp.servers")
    end,
  },

  -- Mason (LSP/DAP/linter installer)
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
    opts = {
      ensure_installed = {
        "lua-language-server",
        "clangd",
        "pyright",
        "bash-language-server",
        "json-lsp",
        "marksman",
      },
      ui = {
        icons = {
          package_pending = " ",
          package_installed = "󰄳 ",
          package_uninstalled = " 󰚌",
        },
      },
      max_concurrent_installers = 10,
    },
    config = function(_, opts)
      require("mason").setup(opts)
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        if opts.ensure_installed and #opts.ensure_installed > 0 then
          vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
        end
      end, {})
    end,
  },

  -- Mason-lspconfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
  },

  -- None-ls (formatters and linters)
  {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.shfmt,
        },
      })
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

  -- LSP lightbulb
  {
    "kosayoda/nvim-lightbulb",
    event = "VeryLazy",
    config = function()
      require("nvim-lightbulb").update_lightbulb()
    end,
  },

  -- LSP signature
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    config = function()
      require("lsp_signature").setup()
    end,
  },

  -- LSP lens
  {
    "VidocqH/lsp-lens.nvim",
    event = "VeryLazy",
    config = function()
      local SymbolKind = vim.lsp.protocol.SymbolKind
      require("lsp-lens").setup({
        enable = true,
        include_declaration = false,
        ignore_filetype = { "prisma" },
        target_symbol_kinds = { SymbolKind.Function, SymbolKind.Method, SymbolKind.Interface },
        wrapper_symbol_kinds = { SymbolKind.Class, SymbolKind.Struct },
        sections = {
          definition = function(count)
            return "Definitions: " .. count
          end,
          references = function(count)
            return "References: " .. count
          end,
          implements = function(count)
            return "Implements: " .. count
          end,
          git_authors = false,
        },
      })
    end,
  },

  -- EFM language server
  {
    "mattn/efm-langserver",
    ft = "bash",
  },
}

