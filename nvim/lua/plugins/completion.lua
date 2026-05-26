--[[
  Completion plugins (blink.cmp and snippets)
--]]

return {
  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_snipmate").lazy_load({ paths = "~/.config/nvim/snippets/" })
    end,
  },

  -- Public snippets
  {
    "honza/vim-snippets",
    event = "InsertEnter",
  },

  -- Completion engine
  {
    "Saghen/blink.cmp",
    event = "InsertEnter",
    version = "1.*",
    dependencies = {
      "L3MON4D3/LuaSnip",
    },
    opts = function()
      local luasnip = require("luasnip")

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local expand_or_jump_snippet = function()
        if luasnip.expand_or_locally_jumpable then
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
            return true
          end
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
          return true
        end

        return false
      end

      local jump_back_snippet = function()
        if luasnip.locally_jumpable then
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
            return true
          end
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
          return true
        end

        return false
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
              if expand_or_jump_snippet() then
                return true
              end

              if has_words_before() then
                return cmp.show()
              end

              return false
            end,
            "fallback",
          },
          ["<S-Tab>"] = {
            "select_prev",
            function()
              return jump_back_snippet()
            end,
            "fallback",
          },
        },
        snippets = {
          preset = "luasnip",
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
          default = { "lsp", "path", "snippets", "buffer" },
        },
        fuzzy = {
          implementation = "prefer_rust",
        },
      }
    end,
    opts_extend = { "sources.default" },
  },
}
