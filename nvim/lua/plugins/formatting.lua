--[[
  Formatting and linting plugins
--]]

return {
  -- Formatter orchestrator
  {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    event = "VeryLazy",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        rst = { "rst_pandoc" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        javascript = { "prettier" },
        typescript = { "prettier" },
      },
      default_format_opts = {
        lsp_format = "fallback",
        timeout_ms = 1000,
      },
      formatters = {
        rst_pandoc = {
          command = "pandoc",
          args = { "-f", "rst", "-t", "rst", "-s", "--columns=79" },
          stdin = true,
        },
      },
      notify_no_formatters = false,
    },
  },

  -- Async linter runner
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require "lint"
      local parser = require "lint.parser"

      lint.linters.rst_lint = {
        cmd = "rst-lint",
        stdin = false,
        ignore_exitcode = true,
        parser = parser.from_pattern("^(%w+) (.-):(%d+) (.*)$", { "severity", "file", "lnum", "message" }, {
          INFO = vim.diagnostic.severity.INFO,
          WARNING = vim.diagnostic.severity.WARN,
          ERROR = vim.diagnostic.severity.ERROR,
          SEVERE = vim.diagnostic.severity.ERROR,
        }, {
          source = "rst-lint",
        }),
      }

      lint.linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        zsh = { "shellcheck" },
        rst = { "rst_lint" },
      }

      vim.api.nvim_create_user_command("Lint", function()
        lint.try_lint()
      end, {})

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("HPFLint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
