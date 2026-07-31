--[[
  Completion plugin (blink.cmp)
--]]

return {
  -- Completion engine
  {
    "Saghen/blink.cmp",
    event = "InsertEnter",
    version = "1.*",
    opts = function()
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
      end

      return {
        keymap = {
          preset = "default",
          ["<C-u>"] = { "scroll_documentation_up", "fallback" },
          ["<C-d>"] = { "scroll_documentation_down", "fallback" },
          ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
          ["<C-e>"] = { "hide", "fallback" },
          ["<CR>"] = { "accept", "fallback" },
          ["<Tab>"] = {
            "select_next",
            function(cmp)
              if has_words_before() then
                return cmp.show()
              end

              return false
            end,
            "fallback",
          },
          ["<S-Tab>"] = { "select_prev", "fallback" },
        },
        completion = {
          list = {
            selection = {
              preselect = false,
              auto_insert = false,
            },
          },
          menu = {
            border = "rounded",
          },
          documentation = {
            auto_show = false,
            window = {
              border = "rounded",
            },
          },
          ghost_text = {
            enabled = false,
          },
        },
        sources = {
          default = { "lsp", "path", "buffer" },
        },
        fuzzy = {
          implementation = "prefer_rust",
        },
      }
    end,
    opts_extend = { "sources.default" },
  },
}
