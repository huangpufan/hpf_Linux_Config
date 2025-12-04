--[[
  Colorscheme and theme plugins
--]]

return {
  -- Catppuccin theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Transparent background
  {
    "xiyaowong/nvim-transparent",
    lazy = true,
    cmd = "TransparentToggle",
  },

  -- Color picker
  {
    "uga-rosa/ccc.nvim",
    cmd = { "CccPick", "CccConvert", "CccHighlighter" },
  },

  -- Color highlighter
  {
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    config = function()
      require("colorizer").setup({
        "css",
        "javascript",
        "vim",
        "lua",
        html = { mode = "foreground" },
      })
    end,
  },

  -- Colorful window separator
  {
    "nvim-zh/colorful-winsep.nvim",
    event = "VeryLazy",
    config = true,
  },
}

