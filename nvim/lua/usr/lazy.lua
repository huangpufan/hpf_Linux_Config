local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  --------------------------------------- Basic config ----------------------------------
  "nvim-lua/plenary.nvim",        -- 很多 lua 插件依赖的库
  "kyazdani42/nvim-web-devicons", -- 显示图标
  "folke/which-key.nvim",         -- 用于配置和提示快捷键
  -- "kkharji/sqlite.lua",           -- 数据库

  --------------------------------------- Edit Related ----------------------------------
  -- 补全
  { "hrsh7th/nvim-cmp" },         -- The completion plugin
  { "hrsh7th/cmp-buffer" },       -- buffer completions
  { "hrsh7th/cmp-path" },         -- path completions
  { "saadparwaiz1/cmp_luasnip" }, -- snippet completions
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-nvim-lua" },
  { "folke/neodev.nvim",       opts = {} },

  -- Eazily add bracket
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
  -- Snippets
  { "L3MON4D3/LuaSnip" },             --snippet engine
  { "rafamadriz/friendly-snippets" }, -- a bunch of snippets to use

  -- LSP
  { "neovim/nvim-lspconfig" },           -- enable LSP
  { "williamboman/mason.nvim" },         -- simple to use language server installer
  { "williamboman/mason-lspconfig.nvim" },
  { "jose-elias-alvarez/null-ls.nvim" }, -- for formatters and linters
  { "j-hui/fidget.nvim",                tag = "legacy" },
  { "SmiteshP/nvim-navic" },
  { "utilyre/barbecue.nvim" },
  { "kosayoda/nvim-lightbulb" },

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
    build = ":TSUpdate",
  },
  "RRethy/nvim-treesitter-textsubjects",
  "nvim-treesitter/nvim-treesitter-textobjects",
  {
    "cshuaimin/ssr.nvim",
    module = "ssr",
    vim.keymap.set({ "n", "x" }, "<leader>r", function()
      require("ssr").open()
    end),
  }, -- 结构化查询和替换

  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
  },

  "rmagatti/goto-preview",

  -- indent
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
    },
  },

  -- Yank Improve
  -- {
  --   "gbprod/yanky.nvim",
  --   opts = {
  --     -- your configuration comes here
  --     -- or leave it empty to use the default settings
  --     -- refer to the configuration section below
  --   },
  -- },
  --
  --
  -- "abecodes/tabout.nvim",
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
  "stevearc/aerial.nvim",     -- 导航栏
  "kyazdani42/nvim-tree.lua", -- 文件树
  -- {
  -- 	"nvim-neo-tree/neo-tree.nvim",
  -- 	branch = "v3.x",
  -- 	dependencies = {
  -- 		"nvim-lua/plenary.nvim",
  -- 		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
  -- 		"MunifTanjim/nui.nvim",
  -- 		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  -- 	},
  -- },
  "akinsho/bufferline.nvim",    -- buffer
  "nvim-lualine/lualine.nvim",  -- 状态栏
  -- "kazhala/close-buffers.nvim", -- 一键删除不可见 buffer
  "gelguy/wilder.nvim",         -- 更加智能的命令窗口
  "romgrk/fzy-lua-native",      -- wilder.nvim 的依赖
  "xiyaowong/nvim-transparent", -- 可以移除掉背景色，让 vim 透明
  --{ "lukas-reineke/virt-column.nvim", opts = {} }, -- not know why no effect.
  { "goolord/alpha-nvim", event = "VimEnter" },
  -- Good looking dressing.nvim. To be updating.
  -- {
  -- 	"stevearc/dressing.nvim",
  -- 	opts = {},
  -- },
  -- 颜色主题
  "folke/tokyonight.nvim",
  { "catppuccin/nvim",    name = "catppuccin", priority = 1000 },
  "rebelot/kanagawa.nvim",
  -- git 版本管理
  "tpope/vim-fugitive",      -- 显示 git blame，实现一些基本操作的快捷执行
  "rhysd/git-messenger.vim", -- 利用 git blame 显示当前行的 commit message
  "lewis6991/gitsigns.nvim", -- 显示改动的信息
  "f-person/git-blame.nvim", -- 显示 git blame 信息
  "sindrets/diffview.nvim",
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
  "nvim-telescope/telescope.nvim",
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim.fn.executable("make") == 1
    end,
  },
  "nvim-telescope/telescope-frecency.nvim", -- 查找最近打开的文件
  -- 命令执行
  "voldikss/vim-floaterm",                  -- 终端
  "akinsho/toggleterm.nvim",                -- 性能好点，但是易用性和稳定性都比较差
  "CRAG666/code_runner.nvim",               -- 一键运行代码
  "samjwill/nvim-unception",                -- 嵌套 nvim 自动 offload 到 host 中
  -- markdown
  -- 如果发现插件有问题， 可以进入到 ~/.local/share/nvim/lazy/markdown-preview.nvim/app && npm install
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview" },
    ft = { "markdown" },
    build = "cd app && npm install",
  },
  "mzlogin/vim-markdown-toc",       -- 自动目录生成
  "dhruvasagar/vim-table-mode",     -- 快速编辑 markdown 的表格
  "xiyaowong/telescope-emoji.nvim", -- 使用 telescope 搜索 emoji 表情
  -- 高效编辑
  -- "tpope/vim-commentary", -- 快速注释代码
  "kylechui/nvim-surround",      -- 快速编辑单词两侧的符号
  -- "tpope/vim-sleuth",               -- 自动设置 tabstop 之类的
  "tpope/vim-repeat",            -- 更加强大的 `.`
  "windwp/nvim-autopairs",       -- 自动括号匹配
  "honza/vim-snippets",          -- 安装公共的的 snippets
  --"mbbill/undotree", -- 显示编辑的历史记录
  "mg979/vim-visual-multi",      -- 同时编辑多个位置
  "AckslD/nvim-neoclip.lua",     -- 保存 macro
  "windwp/nvim-spectre",         -- 媲美 vscode 的多文件替换
  -- 高亮
  "norcalli/nvim-colorizer.lua", -- 显示 #FFFFFF
  "andymass/vim-matchup",        -- 高亮匹配的元素，例如 #if 和 #endif
  -- 时间管理
  -- "nvim-orgmode/orgmode", -- orgmode 日程管理

  -- lsp 增强
  "jackguo380/vim-lsp-cxx-highlight", -- ccls 高亮
  "mattn/efm-langserver",             -- 支持 bash
  "gbrlsnchs/telescope-lsp-handlers.nvim",
  "jakemason/ouroboros",              -- quickly switch between header and source file in C/C++ project
  -- 其他
  --"ggandor/leap.nvim", -- 快速移动
  { "crusj/bookmarks.nvim", branch = "main" }, -- 书签
  "tyru/open-browser.vim",                     -- 使用 gx 打开链接
  --"keaising/im-select.nvim", -- 自动切换输入法
  "olimorris/persisted.nvim",                  -- 打开 vim 的时候，自动回复上一次打开的样子
  --"anuvyklack/hydra.nvim", -- 消除重复快捷键，可以用于调整 window 大小等
  "ojroques/vim-oscyank",                      -- 让 nvim 在远程 server 上拷贝到本地剪切板上
  "azabiong/vim-highlighter",                  -- 高亮多个搜索内容
  -- "dstein64/vim-startuptime", -- 分析 nvim 启动时间
  --"vldikss/vim-translator", -- 翻译
  -- {
  -- 	"OscarCreator/rsync.nvim", -- 自动同步代码远程
  -- 	build = "make", -- 实在不行，进入到 ~/.local/share/nvim/lazy/rsync.nvim 中执行下 make
  -- },
  --"kkharji/sqlite.lua", -- for Trans.nvim
  --{
  --	"JuanZoran/Trans.nvim",
  --	build = function()
  --		require("Trans").install()
  --	end,
  --	keys = {
  --		-- 可以换成其他你想映射的键
  --		{ "dt", mode = { "n", "x" }, "<Cmd>Translate<CR>", desc = " Translate" },
  --		{ "mk", mode = { "n", "x" }, "<Cmd>TransPlay<CR>", desc = " Auto Play" },
  --		-- 目前这个功能的视窗还没有做好，可以在配置里将view.i改成hover
  --		{ "mi", "<Cmd>TranslateInput<CR>", desc = " Translate From Input" },
  --	},
  --	dependencies = { "kkharji/sqlite.lua" },
  --	opts = {
  --		-- your configuration there
  --	},
  --},

  {
    "folke/flash.nvim",
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
      {
        "<c-s>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc =
        "Toggle Flash Search"
      },
    },
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    lazy = false,
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
  -- tokyonight
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = true,
  --   opts = { style = "moon" },
  -- },
  -- instances.
  --"RRethy/vim-illuminate",
  {
    "danymat/neogen",
    event = "VeryLazy",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
  },
  "karb94/neoscroll.nvim",
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
  },
  { "ellisonleao/gruvbox.nvim", priority = 1000 , config = true,opt={background = light,}},
  "m-demare/hlargs.nvim",
}, {})
