--[[
  UI related plugins
--]]

return {
  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        plugins = {
          marks = false,
          registers = true,
        },
      })

      -- Keybindings are defined in config/keybindings.lua
      require("config.keybindings").setup(wk)
    end,
  },

  -- File tree
  {
    "kyazdani42/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeOpen" },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          adaptive_size = false,
          width = 35,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
        update_focused_file = {
          enable = true,
        },
        git = {
          enable = true,
        },
      })
    end,
  },

  -- Bufferline (tabs)
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          numbers = "none",
          diagnostics = false,
          themable = false,
          indicator = {
            style = "underline",
          },
          highlights = {
            buffer_selected = {
              guifg = "white",
              gui = "bold",
            },
          },
          show_close_icon = true,
          max_name_length = 80,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "center",
            },
          },
          groups = {
            items = {
              require("bufferline.groups").builtin.pinned:with({ icon = "" }),
            },
          },
        },
      })
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup()
    end,
  },

  -- Close buffers
  {
    "kazhala/close-buffers.nvim",
    event = "VeryLazy",
  },

  -- Alpha dashboard
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    cond = function()
      return vim.fn.argc(-1) == 0
    end,
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                     ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
        dashboard.button("c", "  Configuration", ":e $MYVIMRC<CR>"),
        dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      -- Center dashboard vertically
      dashboard.config.opts.noautocmd = true
      dashboard.config.layout = {
        { type = "padding", val = vim.fn.max({ 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) }) },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        dashboard.section.footer,
      }

      alpha.setup(dashboard.config)
    end,
  },

  -- Wilder (command line completion)
  {
    "gelguy/wilder.nvim",
    event = "CmdlineEnter",
    dependencies = { "romgrk/fzy-lua-native" },
    config = function()
      local wilder = require("wilder")
      wilder.setup({ modes = { ":" } })
      wilder.set_option("use_python_remote_plugin", 0)
      wilder.set_option("pipeline", {
        wilder.branch(
          {
            wilder.check(function()
              return vim.fn.getcmdtype() == ":"
            end),
            function(ctx, x)
              return wilder.cmdline.parse(x).cmd == "Man" and true or false
            end,
          },
          wilder.cmdline_pipeline({
            fuzzy = 1,
            fuzzy_filter = wilder.lua_fzy_filter(),
          }),
          wilder.vim_search_pipeline()
        ),
      })
      wilder.set_option(
        "renderer",
        wilder.renderer_mux({
          [":"] = wilder.popupmenu_renderer({
            highlighter = wilder.lua_fzy_highlighter(),
            left = { " ", wilder.popupmenu_devicons() },
            right = { " ", wilder.popupmenu_scrollbar() },
          }),
          ["/"] = wilder.wildmenu_renderer({
            highlighter = wilder.lua_fzy_highlighter(),
          }),
        })
      )
    end,
  },

  -- Breadcrumb navigation
  {
    "SmiteshP/nvim-navic",
    event = "VeryLazy",
    config = function()
      require("nvim-navic").setup()
    end,
  },
  {
    "utilyre/barbecue.nvim",
    event = "VeryLazy",
    dependencies = { "SmiteshP/nvim-navic" },
    config = function()
      require("barbecue").setup()
    end,
  },

  -- Incline (floating filename)
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    config = function()
      local helpers = require("incline.helpers")
      require("incline").setup({
        window = {
          padding = 0,
          margin = { horizontal = 0 },
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
          local modified = vim.bo[props.buf].modified
          return {
            ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
            " ",
            { filename, gui = modified and "bold,italic" or "bold" },
            " ",
            guibg = "#44406e",
          }
        end,
      })
    end,
  },

  -- Aerial (code outline)
  {
    "stevearc/aerial.nvim",
    cmd = "AerialToggle",
    config = function()
      require("aerial").setup({
        backends = { "markdown", "man", "lsp", "treesitter" },
        layout = {
          max_width = { 35, 0.16 },
          min_width = { 20, 0.1 },
          placement = "edge",
          default_direction = "right",
        },
        attach_mode = "global",
      })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      exclude = {
        filetypes = { "alpha", "dashboard", "help", "lazy", "mason", "NvimTree" },
      },
    },
  },

  -- Mini indentscope
  {
    "echasnovski/mini.indentscope",
    event = "VeryLazy",
    version = false,
    opts = {
      symbol = "│",
      options = { try_as_border = true },
      draw = {
        delay = 100,
      },
    },
    init = function()
      -- Disable on special filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "alpha", "dashboard", "help", "lazy", "mason", "NvimTree", "Trouble" },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
      -- Also check current buffer (for alpha which loads before this plugin)
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          local ft = vim.bo.filetype
          if ft == "alpha" or ft == "dashboard" then
            vim.b.miniindentscope_disable = true
          end
        end,
      })
    end,
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Dressing (better UI)
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },
}

