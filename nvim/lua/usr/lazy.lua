local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },

  --------------------------------------- Basic config ----------------------------------
  { "nvim-lua/plenary.nvim" }, -- 很多 lua 插件依赖的库
  { "kyazdani42/nvim-web-devicons" }, -- 显示图标
  { "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup {}
    end,
  }, -- 用于配置和提示快捷键
  "kkharji/sqlite.lua", -- 数据库

  --------------------------------------- Edit Related ----------------------------------
  -- 补全
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "ray-x/cmp-treesitter",
      "lukas-reineke/cmp-under-comparator",
    },
  }, -- The completion plugin
  -- Snippets
  { "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
  }, --snippet engine

  -- LSP
  { "neovim/nvim-lspconfig", event = "VeryLazy" }, -- enable LSP

  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
    opts = function()
      return require "usr.mason"
    end,
    config = function(_, opts)
      require("mason").setup(opts)
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        if opts.ensure_installed and #opts.ensure_installed > 0 then
          vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
        end
      end, {})
      vim.g.mason_binaries_list = opts.ensure_installed
    end,
  }, -- simple to use language server installer
  { "williamboman/mason-lspconfig.nvim", event = "VeryLazy" },
  { "jose-elias-alvarez/null-ls.nvim", event = "VeryLazy" }, -- for formatters and linters
  { "j-hui/fidget.nvim", event = "VeryLazy", tag = "legacy" },
  { "SmiteshP/nvim-navic", event = "VeryLazy" },
  { "utilyre/barbecue.nvim", event = "VeryLazy" },
  { "kosayoda/nvim-lightbulb", event = "VeryLazy" },

  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  },

  --treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = ":TSUpdate",
    dependencies = {
      "RRethy/nvim-treesitter-textsubjects",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
  },

  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    -- config is in init.lua with dressing integration
  },

  { "rmagatti/goto-preview", keys = { "gd", "gD" } },

  -- indent
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
    },
  },

  { "abecodes/tabout.nvim", event = "InsertEnter" },
  ------------------------------------- User Interface -----------------------

  { "stevearc/aerial.nvim", cmd = "AerialToggle" }, -- 导航栏
  { "kyazdani42/nvim-tree.lua", cmd = { "NvimTreeToggle", "NvimTreeFindFile" } }, -- 文件树
  { "akinsho/bufferline.nvim", event = "VeryLazy" }, -- buffer
  { "nvim-lualine/lualine.nvim", event = "VeryLazy" }, -- 状态栏
  {
    "kazhala/close-buffers.nvim",
    event = "VeryLazy",
  }, -- 一键删除不可见 buffer
  { "gelguy/wilder.nvim",
    event = "CmdlineEnter",
    dependencies = { "romgrk/fzy-lua-native" },
    config = function()
      vim.cmd("source " .. vim.fn.stdpath("config") .. "/vim/wilder.vim")
    end,
  }, -- 更加智能的命令窗口
  { "xiyaowong/nvim-transparent", lazy = true }, -- 可以移除掉背景色，让 vim 透明
  { "goolord/alpha-nvim", event = "VimEnter" },
  -- 颜色主题
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },
  -- git 版本管理
  { "tpope/vim-fugitive", cmd = "Git" }, -- 显示 git blame，实现一些基本操作的快捷执行
  { "rhysd/git-messenger.vim", cmd = "GitMessenger" }, -- 利用 git blame 显示当前行的 commit message
  { "lewis6991/gitsigns.nvim", event = "VeryLazy" }, -- 显示改动的信息
  { "f-person/git-blame.nvim", cmd = "GitBlameToggle" }, -- 显示 git blame 信息
  { "sindrets/diffview.nvim", cmd = "DiffviewOpen" },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  -- 基于 telescope 的搜索
  { "nvim-telescope/telescope.nvim", cmd = "Telescope" },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim.fn.executable "make" == 1
    end,
  },
  -- 命令执行
  { "voldikss/vim-floaterm", cmd = { "FloatermToggle", "FloatermNew" } }, -- 终端
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      highlights = {
        Normal = { link = "Normal" },
        NormalNC = { link = "NormalNC" },
        NormalFloat = { link = "NormalFloat" },
        FloatBorder = { link = "FloatBorder" },
        StatusLine = { link = "StatusLine" },
        StatusLineNC = { link = "StatusLineNC" },
        WinBar = { link = "WinBar" },
        WinBarNC = { link = "WinBarNC" },
      },
      size = 10,
      ---@param t Terminal
      on_create = function()
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.signcolumn = "no"
      end,
      shading_factor = 2,
      direction = "float",
      float_opts = { border = "rounded" },
    },
  },
  { "CRAG666/code_runner.nvim", lazy = true }, -- 一键运行代码
  { "samjwill/nvim-unception", lazy = true }, -- 嵌套 nvim 自动 offload 到 host 中

  -- markdown
  -- WARNING: 如果发现插件有问题， 可以进入到 ~/.local/share/nvim/lazy/markdown-preview.nvim/app && npm install
  {
    "iamcco/markdown-preview.nvim",
    lazy = true,
    cmd = { "MarkdownPreview" },
    ft = { "markdown" },
    build = "cd app && npm install",
  },
  { "mzlogin/vim-markdown-toc", lazy = true, 
    ft = "markdown"}, -- 自动目录生成
  { "dhruvasagar/vim-table-mode", lazy = true,
    ft = "markdown"}, -- 快速编辑 markdown 的表格
  { "xiyaowong/telescope-emoji.nvim", cmd = "Telescope" }, -- 使用 telescope 搜索 emoji 表情
  -- 高效编辑
  -- "tpope/vim-sleuth",               -- 自动设置 tabstop 之类的
  { "tpope/vim-repeat", event = "VeryLazy" }, -- 更加强大的 `.`
  { "windwp/nvim-autopairs", event = "InsertEnter" }, -- 自动括号匹配
  { "honza/vim-snippets", event = "InsertEnter" }, -- 安装公共的的 snippets
  --"mbbill/undotree", -- 显示编辑的历史记录
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "gb",
        ["Find Subword Under"] = "gB",
      }
    end,
  }, -- 同时编辑多个位置
  { "AckslD/nvim-neoclip.lua", event = "VeryLazy" }, -- 保存 macro
  { "windwp/nvim-spectre", cmd = "Spectre" }, -- 媲美 vscode 的多文件替换
  -- 高亮
  { "norcalli/nvim-colorizer.lua", event = "VeryLazy" }, -- 显示 #FFFFFF
  { "andymass/vim-matchup", event = "VeryLazy" }, -- 高亮匹配的元素，例如 #if 和 #endif
  -- 时间管理
  -- "nvim-orgmode/orgmode", -- orgmode 日程管理

  -- lsp 增强
  -- { "jackguo380/vim-lsp-cxx-highlight", lazy = false }, -- ccls 高亮
  { "mattn/efm-langserver",
    ft = "bash" }, -- 支持 bash
  { "gbrlsnchs/telescope-lsp-handlers.nvim", event = "VeryLazy" },
  { "jakemason/ouroboros", cmd = "Ouroboros" }, -- quickly switch between header and source file in C/C++ project
  -- 其他
  --"ggandor/leap.nvim", -- 快速移动
  { "crusj/bookmarks.nvim", branch = "main", cmd = { "BookmarkToggle", "BookmarkAnnotate", "BookmarkShowAll" } }, -- 书签
  { "tyru/open-browser.vim", keys = { "gx" } }, -- 使用 gx 打开链接
  --"keaising/im-select.nvim", -- 自动切换输入法
  { "olimorris/persisted.nvim", event = "VeryLazy" }, -- 打开 vim 的时候，自动回复上一次打开的样子
  { "anuvyklack/hydra.nvim", event = "VeryLazy" }, -- 消除重复快捷键，可以用于调整 window 大小等
  { "ojroques/vim-oscyank", event = "VeryLazy" }, -- 让 nvim 在远程 server 上拷贝到本地剪切板上
  -- { "azabiong/vim-highlighter", lazy = false }, -- 高亮多个搜索内容
  "dstein64/vim-startuptime", -- 分析 nvim 启动时间
  -- {
  -- 	"OscarCreator/rsync.nvim", -- 自动同步代码远程
  -- 	build = "make", -- 实在不行，进入到 ~/.local/share/nvim/lazy/rsync.nvim 中执行下 make
  -- },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    -- @type Flash.Config
    opts = {
      label = {
        after = { 0, 2 },
      },
    }, -- stylua: ignore
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
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
  },

  {
    "echasnovski/mini.indentscope",
    event = "VeryLazy",
    version = false,
    opts = {
      -- symbol = "▏",
      symbol = "│",
      options = { try_as_border = true },
    },
  },
  {
    "danymat/neogen",
    cmd = "Neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
  },
  { "m-demare/hlargs.nvim", event = "VeryLazy" },

  {
    "kawre/leetcode.nvim",
    cmd = "Leet",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim", -- telescope 所需
      "MunifTanjim/nui.nvim",

      -- 可选
      "nvim-treesitter/nvim-treesitter",
      "rcarriga/nvim-notify",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      -- 配置放在这里
      cn = {
        enabled = true,
      },
      injector = { ---@type table<lc.lang, lc.inject>
        ["cpp"] = {
          before = { "#include <bits/stdc++.h>", "using namespace std;" },
          after = "int main() {}",
        },
      },
    },
  },

  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
  },
  -- { "kevinhwang91/rnvimr", lazy = false },
  { "itchyny/vim-cursorword", event = "VeryLazy" },

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

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      -- map("]]", "next")
      -- map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      -- vim.api.nvim_create_autocmd("FileType", {
      --   callback = function()
      --     local buffer = vim.api.nvim_get_current_buf()
      --     -- map("]]", "next", buffer)
      --     -- map("[[", "prev", buffer)
      --   end,
      -- })
    end,
    keys = {
      -- { "]]", desc = "Next Reference" },
      -- { "[[", desc = "Prev Reference" },
    },
  },
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "stevearc/overseer.nvim",
    cmd = "OverseerToggle",
  },
  { "uga-rosa/ccc.nvim",
     cmd = {"CccPick", "CccConvert", "CccHighlighter"}
  },


  {
    "chrisgrieser/nvim-spider",
  },
  { "AckslD/nvim-FeMaco.lua", event = "VeryLazy" },
  {
    "HakonHarnes/img-clip.nvim",
    event = "InsertEnter",
    opts = {
      -- add options here
      -- or leave it empty to use the default settings
    },
    keys = {
      -- suggested keymap
      -- { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste clipboard image" },
    },
  },
  -- TODO: Open until use server.
  -- {
  --   "zeioth/garbage-day.nvim",
  --   dependencies = "neovim/nvim-lspconfig",
  --   event = "VeryLazy",
  --   opts = {
  --     -- your options here
  --   },
  -- },
  {
    "VidocqH/lsp-lens.nvim",
    event = "VeryLazy",
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },
  -- {
  --   "zbirenbaum/neodim",
  --   event = "LspAttach",
  --   config = function()
  --     require("neodim").setup {
  --       refresh_delay = 20,
  --       alpha = 0,
  --       blend_color = "#000000",
  --       hide = {
  --         -- underline = true,
  --         -- virtual_text = true,
  --         -- signs = true,
  --       },
  --       regex = {
  --         "[uU]nused",
  --         "[nN]ever [rR]ead",
  --         "[nN]ot [rR]ead",
  --       },
  --       priority = 128,
  --       disable = {},
  --     }
  --   end,
  -- },
  { "IndianBoy42/tree-sitter-just", ft = "just" },
  {
    "nvim-zh/colorful-winsep.nvim",
    event = "VeryLazy",
    config = true,
  },
--   {
--     "OXY2DEV/markview.nvim",
--     -- lazy = false,      -- Recommended
--     ft = "markdown", -- If you decide to lazy-load anyway

--     dependencies = {
--         -- You will not need this if you installed the
--         -- parsers manually
--         -- Or if the parsers are in your $RUNTIMEPATH
--         "nvim-treesitter/nvim-treesitter",

--         "nvim-tree/nvim-web-devicons"
--     }
-- },
}, {})
