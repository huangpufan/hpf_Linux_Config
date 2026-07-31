--[[
  Editor enhancement plugins
--]]

return {
  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Better repeat
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },

  -- Multiple cursors
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    keys = require("config.actions").lazy_keys "multicursor",
    config = function()
      local mc = require "multicursor-nvim"
      mc.setup()

      mc.addKeymapLayer(function(layer_set)
        layer_set("n", "<esc>", function()
          if mc.cursorsEnabled() then
            mc.clearCursors()
          else
            mc.enableCursors()
          end
        end)
      end)
    end,
  },

  -- Grug-far (search and replace)
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    opts = {},
    keys = require("config.actions").lazy_keys "grug_far",
  },

  -- Editable quickfix and location lists
  {
    "stevearc/quicker.nvim",
    ft = "qf",
    opts = {
      edit = {
        enabled = true,
        autosave = "unmodified",
      },
      keys = {
        {
          ">",
          function()
            require("quicker").expand { before = 2, after = 2, add_to_existing = true }
          end,
          desc = "Expand quickfix context",
        },
        {
          "<",
          function()
            require("quicker").collapse()
          end,
          desc = "Collapse quickfix context",
        },
      },
    },
  },

  -- Vim matchup
  {
    "andymass/vim-matchup",
    event = "VeryLazy",
  },

  -- Flash (jump to any location)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      label = {
        after = { 0, 2 },
      },
    },
    keys = require("config.actions").lazy_keys "flash",
  },

  -- Spider (subword motion)
  {
    "chrisgrieser/nvim-spider",
    keys = require("config.actions").lazy_keys "spider",
  },

  -- Better escape (jk to escape)
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
  },

  -- Tabout
  {
    "abecodes/tabout.nvim",
    event = "InsertEnter",
    config = function()
      require("tabout").setup()
    end,
  },

  -- Bookmarks
  {
    "crusj/bookmarks.nvim",
    branch = "main",
    cmd = { "BookmarkToggle", "BookmarkAnnotate", "BookmarkShowAll" },
    config = function()
      local bookmarks = require "bookmarks"
      bookmarks.setup {
        mappings_enabled = false,
        virt_pattern = { "*.lua", "*.md", "*.c", "*.h", "*.sh" },
      }

      vim.api.nvim_create_user_command("BookmarkToggle", function()
        bookmarks.add_bookmarks(false)
      end, {})
      vim.api.nvim_create_user_command("BookmarkAnnotate", function()
        bookmarks.add_bookmarks(false)
      end, {})
      vim.api.nvim_create_user_command("BookmarkShowAll", function()
        bookmarks.toggle_bookmarks()
      end, {})
    end,
  },

  -- Session management
  {
    "olimorris/persisted.nvim",
    event = "VeryLazy",
    config = function()
      require("persisted").setup {
        autoload = true,
        before_save = function()
          vim.cmd "NvimTreeClose"
        end,
      }
    end,
  },

  -- Hlargs (highlight arguments)
  {
    "m-demare/hlargs.nvim",
    event = "VeryLazy",
    config = function()
      require("hlargs").setup {
        color = "#FF7F7F",
        highlight = {},
        excluded_filetypes = {},
        paint_arg_declarations = true,
        paint_arg_usages = true,
        paint_catch_blocks = {
          declarations = false,
          usages = false,
        },
        extras = {
          named_parameters = false,
        },
        hl_priority = 10000,
        excluded_argnames = {
          declarations = {},
          usages = {
            python = { "self", "cls" },
            lua = { "self" },
          },
        },
        performance = {
          parse_delay = 1,
          slow_parse_delay = 50,
          max_iterations = 400,
          max_concurrent_partial_parses = 30,
          debounce = {
            partial_parse = 3,
            partial_insert_mode = 100,
            total_parse = 700,
            slow_parse = 5000,
          },
        },
      }
    end,
  },

  -- Inc-rename
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = function()
      require("inc_rename").setup {
        input_buffer_type = "snacks",
      }
    end,
  },

  -- FeMaco (edit fenced code blocks)
  {
    "AckslD/nvim-FeMaco.lua",
    event = "VeryLazy",
    config = function()
      require("femaco").setup()
    end,
  },

  -- Img-clip (paste images)
  {
    "HakonHarnes/img-clip.nvim",
    event = "InsertEnter",
    opts = {},
  },

  -- Goto preview
  {
    "rmagatti/goto-preview",
    keys = require("config.actions").lazy_keys "goto_preview",
    config = function()
      require("goto-preview").setup {
        default_mappings = false,
      }
    end,
  },

  -- Ouroboros (switch between h/c files)
  {
    "jakemason/ouroboros.nvim",
    cmd = "Ouroboros",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      local ouroboros = require "ouroboros"
      ouroboros.setup {}
      vim.api.nvim_create_user_command("Ouroboros", function()
        ouroboros.switch()
      end, {})
    end,
  },
}
