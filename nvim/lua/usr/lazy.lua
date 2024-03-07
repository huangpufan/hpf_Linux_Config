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
  { "nvim-lua/plenary.nvim" },             -- 很多 lua 插件依赖的库
  { "kyazdani42/nvim-web-devicons" },      -- 显示图标
  { "folke/which-key.nvim",        lazy = true }, -- 用于配置和提示快捷键
  -- "kkharji/sqlite.lua",           -- 数据库

  --------------------------------------- Edit Related ----------------------------------
  -- 补全
  { "hrsh7th/nvim-cmp",            lazy = false }, -- The completion plugin
  { "hrsh7th/cmp-buffer",          lazy = false }, -- buffer completions
  { "hrsh7th/cmp-path",            lazy = false }, -- path completions
  { "saadparwaiz1/cmp_luasnip",    lazy = false }, -- snippet completions
  { "hrsh7th/cmp-nvim-lsp",        lazy = false },
  { "hrsh7th/cmp-nvim-lua",        lazy = false },
  { "folke/neodev.nvim",           lazy = false, opts = {} },

  -- Eazily add bracket
  {
    "kylechui/nvim-surround",
    lazy = false,
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
    end,
  },
  -- Snippets
  { "L3MON4D3/LuaSnip",             lazy = false }, --snippet engine
  { "rafamadriz/friendly-snippets", lazy = false }, -- a bunch of snippets to use

  -- LSP
  { "neovim/nvim-lspconfig",        lazy = false }, -- enable LSP

  {
    "williamboman/mason.nvim",
    lazy = false, -- simple to use language server installer
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
  },                                                   -- simple to use language server installer
  { "williamboman/mason-lspconfig.nvim", lazy = false },
  { "jose-elias-alvarez/null-ls.nvim",   lazy = false }, -- for formatters and linters
  { "j-hui/fidget.nvim",                 lazy = false, tag = "legacy" },
  { "SmiteshP/nvim-navic",               lazy = false },
  { "utilyre/barbecue.nvim",             lazy = false },
  { "kosayoda/nvim-lightbulb",           lazy = false },

  {
    "ray-x/lsp_signature.nvim",
    lazy = false,
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  },

  --treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
  },
  -- { "ahmedkhalf/project.nvim", lazy = false },
  { "RRethy/nvim-treesitter-textsubjects",         lazy = false },
  { "nvim-treesitter/nvim-treesitter-textobjects", lazy = false },
  {
    "cshuaimin/ssr.nvim",
    lazy = true,
    module = "ssr",
    vim.keymap.set({ "n", "x" }, "<leader>r", function()
      require("ssr").open()
    end),
  }, -- 结构化查询和替换

  {
    "smjonas/inc-rename.nvim",
    lazy = false,
    config = function()
      require("inc_rename").setup()
    end,
  },

  { "rmagatti/goto-preview",    lazy = false },

  -- indent
  {
    "lukas-reineke/indent-blankline.nvim",
    lazy = true,
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
    },
  },

  { "abecodes/tabout.nvim",     lazy = false },
  ------------------------------------- User Interface -----------------------
  ---
  ---
  -- {
  -- 	"nvimdev/dashboard-nvim",
  -- 	event = "VimEnter",
  -- 	config = function()
  -- 		require("dashboard").setup({
  -- 			-- config
  -- 		})
  -- 	end,
  -- 	dependencies = { { "nvim-tree/nvim-web-devicons" } },
  -- },
  { "stevearc/aerial.nvim",     lazy = false }, -- 导航栏
  { "kyazdani42/nvim-tree.lua" },           -- 文件树
  { "akinsho/bufferline.nvim" },            -- buffer
  { "nvim-lualine/lualine.nvim" },          -- 状态栏
  {
    "kazhala/close-buffers.nvim",
    lazy = false,
    event = "VeryLazy",
  },                                             -- 一键删除不可见 buffer
  { "gelguy/wilder.nvim",         lazy = false }, -- 更加智能的命令窗口
  { "romgrk/fzy-lua-native",      lazy = false }, -- wilder.nvim 的依赖
  { "xiyaowong/nvim-transparent", lazy = true }, -- 可以移除掉背景色，让 vim 透明
  --{ "lukas-reineke/virt-column.nvim", opts = {} }, -- not know why no effect.
  { "goolord/alpha-nvim",         event = "VimEnter" },
  -- Good looking dressing.nvim. To be updating.
  -- {
  -- 	"stevearc/dressing.nvim",
  -- 	opts = {},
  -- },
  -- 颜色主题
  { "folke/tokyonight.nvim",      lazy = true },
  {
    "catppuccin/nvim",
  },
  { "rebelot/kanagawa.nvim",   lazy = true },
  -- git 版本管理
  { "tpope/vim-fugitive",      lazy = true },  -- 显示 git blame，实现一些基本操作的快捷执行
  { "rhysd/git-messenger.vim", lazy = false }, -- 利用 git blame 显示当前行的 commit message
  { "lewis6991/gitsigns.nvim", lazy = false }, -- 显示改动的信息
  { "f-person/git-blame.nvim", lazy = false }, -- 显示 git blame 信息
  { "sindrets/diffview.nvim",  lazy = false },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  -- 基于 telescope 的搜索
  { "nvim-telescope/telescope.nvim",          lazy = true },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim.fn.executable "make" == 1
    end,
  },
  { "nvim-telescope/telescope-frecency.nvim", lazy = false }, -- 查找最近打开的文件
  -- 命令执行
  { "voldikss/vim-floaterm",                  lazy = false }, -- 终端
  { "akinsho/toggleterm.nvim",                lazy = false }, -- 性能好点，但是易用性和稳定性都比较差
  { "CRAG666/code_runner.nvim",               lazy = true },  -- 一键运行代码
  { "samjwill/nvim-unception",                lazy = true },  -- 嵌套 nvim 自动 offload 到 host 中

  -- markdown
  -- 如果发现插件有问题， 可以进入到 ~/.local/share/nvim/lazy/markdown-preview.nvim/app && npm install
  {
    "iamcco/markdown-preview.nvim",
    lazy = false,
    cmd = { "MarkdownPreview" },
    ft = { "markdown" },
    build = "cd app && npm install",
  },
  { "mzlogin/vim-markdown-toc",              lazy = false }, -- 自动目录生成
  { "dhruvasagar/vim-table-mode",            lazy = true }, -- 快速编辑 markdown 的表格
  { "xiyaowong/telescope-emoji.nvim",        lazy = false }, -- 使用 telescope 搜索 emoji 表情
  -- 高效编辑
  -- "tpope/vim-commentary", -- 快速注释代码
  { "kylechui/nvim-surround",                lazy = false }, -- 快速编辑单词两侧的符号
  -- "tpope/vim-sleuth",               -- 自动设置 tabstop 之类的
  { "tpope/vim-repeat",                      lazy = false }, -- 更加强大的 `.`
  { "windwp/nvim-autopairs",                 lazy = false }, -- 自动括号匹配
  { "honza/vim-snippets",                    lazy = false }, -- 安装公共的的 snippets
  --"mbbill/undotree", -- 显示编辑的历史记录
  { "mg979/vim-visual-multi",                lazy = false }, -- 同时编辑多个位置
  { "AckslD/nvim-neoclip.lua",               lazy = true }, -- 保存 macro
  { "windwp/nvim-spectre",                   lazy = false }, -- 媲美 vscode 的多文件替换
  -- 高亮
  { "norcalli/nvim-colorizer.lua",           lazy = false }, -- 显示 #FFFFFF
  { "andymass/vim-matchup",                  lazy = false }, -- 高亮匹配的元素，例如 #if 和 #endif
  -- 时间管理
  -- "nvim-orgmode/orgmode", -- orgmode 日程管理

  -- lsp 增强
  { "jackguo380/vim-lsp-cxx-highlight",      lazy = false }, -- ccls 高亮
  { "mattn/efm-langserver",                  lazy = false }, -- 支持 bash
  { "gbrlsnchs/telescope-lsp-handlers.nvim", lazy = false },
  { "jakemason/ouroboros",                   lazy = false }, -- quickly switch between header and source file in C/C++ project
  -- 其他
  --"ggandor/leap.nvim", -- 快速移动
  { "crusj/bookmarks.nvim",                  branch = "main", lazy = false }, -- 书签
  { "tyru/open-browser.vim",                 lazy = false }, -- 使用 gx 打开链接
  --"keaising/im-select.nvim", -- 自动切换输入法
  { "olimorris/persisted.nvim",              lazy = true },  -- 打开 vim 的时候，自动回复上一次打开的样子
  { "anuvyklack/hydra.nvim",                 lazy = false }, -- 消除重复快捷键，可以用于调整 window 大小等
  { "ojroques/vim-oscyank",                  lazy = false }, -- 让 nvim 在远程 server 上拷贝到本地剪切板上
  { "azabiong/vim-highlighter",              lazy = false }, -- 高亮多个搜索内容
  -- "dstein64/vim-startuptime", -- 分析 nvim 启动时间
  -- {
  -- 	"OscarCreator/rsync.nvim", -- 自动同步代码远程
  -- 	build = "make", -- 实在不行，进入到 ~/.local/share/nvim/lazy/rsync.nvim 中执行下 make
  -- },

  {
    "folke/flash.nvim",
    lazy = false,
    event = "VeryLazy",
    -- @type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o",               function() require("flash").remote() end,     desc = "Remote Flash" },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc =
        "Treesitter Search"
      },
    },
  },
  {
    "numToStr/Comment.nvim",
    lazy = false,
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    lazy = false,
  },

  {
    "echasnovski/mini.indentscope",
    lazy = true,
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
    lazy = false,
    event = "VeryLazy",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
  },
  -- { "karb94/neoscroll.nvim", lazy = false },
  {
    "zbirenbaum/copilot.lua",
    lazy = false,
    cmd = "Copilot",
    build = ":Copilot auth",
  },

  { "m-demare/hlargs.nvim",   lazy = false },

  {
    "kawre/leetcode.nvim",
    lazy = true,
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

  -- { "kevinhwang91/rnvimr", lazy = false },
  { "itchyny/vim-cursorword", lazy = false },

  {
    "RRethy/vim-illuminate",
    lazy = false,
    -- event = "VeryLazy",
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

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },
  {
    "b0o/incline.nvim",
    opts = {},
    -- Optional: Lazy load Incline
    event = "VeryLazy",
  },

  {
    "stevearc/overseer.nvim",
    opts = {},
  },
  { "uga-rosa/ccc.nvim" },

  {
    "chrisgrieser/nvim-spider",
  },
  { "AckslD/nvim-FeMaco.lua" },
}, {})
