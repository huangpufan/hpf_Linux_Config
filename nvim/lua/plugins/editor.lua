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

  -- Comment
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Better repeat
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },

  -- Visual multi cursor
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "gb",
        ["Find Subword Under"] = "gB",
      }
    end,
  },

  -- Neoclip (clipboard history)
  {
    "AckslD/nvim-neoclip.lua",
    event = "VeryLazy",
  },

  -- Spectre (search and replace)
  {
    "windwp/nvim-spectre",
    cmd = "Spectre",
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
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
  },

  -- Illuminate (highlight word under cursor)
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    opts = {
      delay = 0,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
  },

  -- Cursor word highlight
  {
    "itchyny/vim-cursorword",
    event = "VeryLazy",
  },

  -- Spider (subword motion)
  {
    "chrisgrieser/nvim-spider",
    event = "VeryLazy",
    config = function()
      vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
      vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
      vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })
    end,
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

  -- OSC yank (copy to system clipboard in remote)
  {
    "ojroques/vim-oscyank",
    event = "VeryLazy",
  },

  -- Bookmarks
  {
    "crusj/bookmarks.nvim",
    branch = "main",
    cmd = { "BookmarkToggle", "BookmarkAnnotate", "BookmarkShowAll" },
    config = function()
      require("bookmarks").setup({
        mappings_enabled = false,
        virt_pattern = { "*.lua", "*.md", "*.c", "*.h", "*.sh" },
      })
    end,
  },

  -- Hydra (sticky keymaps)
  {
    "anuvyklack/hydra.nvim",
    event = "VeryLazy",
  },

  -- Session management
  {
    "olimorris/persisted.nvim",
    event = "VeryLazy",
    config = function()
      require("persisted").setup({
        autoload = true,
        before_save = function()
          vim.cmd("NvimTreeClose")
        end,
      })
    end,
  },

  -- Neogen (documentation generator)
  {
    "danymat/neogen",
    cmd = "Neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
  },

  -- Hlargs (highlight arguments)
  {
    "m-demare/hlargs.nvim",
    event = "VeryLazy",
    config = function()
      require("hlargs").setup({
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
      })
    end,
  },

  -- Inc-rename
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = function()
      require("inc_rename").setup({
        input_buffer_type = "dressing",
      })
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

  -- Open browser
  {
    "tyru/open-browser.vim",
    keys = { "gx" },
    init = function()
      vim.g.netrw_nogx = 1
      vim.keymap.set("n", "gx", "<Plug>(openbrowser-smart-search)")
      vim.keymap.set("v", "gx", "<Plug>(openbrowser-smart-search)")
    end,
  },

  -- Goto preview
  {
    "rmagatti/goto-preview",
    keys = { "gp", "gP" },
    config = function()
      require("goto-preview").setup({
        default_mappings = true,
      })
    end,
  },

  -- Ouroboros (switch between h/c files)
  {
    "jakemason/ouroboros",
    cmd = "Ouroboros",
  },
}

