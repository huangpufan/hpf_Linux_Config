-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
-- local telescope = require("telescope").setup({
-- 	defaults = {
-- 		layout_strategy = "horizontal",
--
-- 		layout_config = {
-- 			vertical = {
-- 				height = 0.9,
-- 				preview_cutoff = 0,
-- 				width = 0.9,
-- 			},
-- 			-- other layout configuration here
-- 		},
-- 		-- other defaults configuration here
-- 	},
--
-- 	extensions = {
-- 		fzf = {
-- 			fuzzy = true, -- false will only do exact matching
-- 			override_generic_sorter = true, -- override the generic sorter
-- 			override_file_sorter = true, -- override the file sorter
-- 			case_mode = "respect_case", -- or "ignore_case" or "respect_case"
-- 			-- the default case_mode is "smart_case"
-- 		},
-- 		bookmarks = {
-- 			-- Available: 'brave', 'buku', 'chrome', 'edge', 'safari', 'firefox'
-- 			selected_browser = "chrome",
-- 		},
-- 		emoji = {
-- 			action = function(emoji)
-- 				vim.api.nvim_put({ emoji.value }, "c", false, true) -- 选择 emoji 之后直接插入符号
-- 			end,
-- 		},
-- 	},
-- })
--

local telescope = require("telescope").setup({
defaults = {
    vimgrep_arguments = {
      "rg",
      "-L",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    prompt_prefix = "   ",
    selection_caret = "  ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
        results_width = 0.8,
      },
      vertical = {
        mirror = false,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    file_ignore_patterns = { "node_modules" },
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    path_display = { "truncate" },
    winblend = 0,
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    color_devicons = true,
    set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
    mappings = {
      n = { ["q"] = require("telescope.actions").close },
    },
  },

  extensions_list = { "themes", "terms" },
  })


--   local function find_files_by_type()
--   -- 获取用户输入的搜索内容
--   local query = vim.fn.input("Search for: ")
--   -- 获取用户输入的文件类型
--   local types = vim.fn.input("Filetypes (separated by ','): ")
--   
--   -- 如果用户没有输入文件类型，则搜索所有文件
--   if types == "" then
--     require('telescope.builtin').find_files({search = query})
--     return
--   end
--   
--   -- 分割文件类型字符串为一个数组
--   local type_list = vim.split(types, ',', true)
--   -- 构建rg命令的参数
--   local rg_type_args = {}
--   for _, t in ipairs(type_list) do
--     table.insert(rg_type_args, '-g')
--     table.insert(rg_type_args, '*.' .. t)
--   end
--   
--   -- 调用Telescope的find_files函数并传递参数
--   require('telescope.builtin').find_files({
--     search = query,
--     find_command = vim.tbl_flatten({'rg', '--files', '--color=never', unpack(rg_type_args)})
--   })
-- end
--
-- -- 定义一个命令或键绑定来调用这个函数
-- vim.api.nvim_set_keymap('n', '<leader>fF', '<cmd>lua find_files_by_type()<CR>', { noremap = true, silent = true })
--
--
-- 精确搜索的设置
-- local exact_match = function()
-- 	telescope.setup({
-- 		defaults = {
-- 			vimgrep_arguments = {
-- 				"rg",
-- 				"--color=never",
-- 				"--no-heading",
-- 				"--with-filename",
-- 				"--line-number",
-- 				"--column",
-- 				"--smart-case",
-- 				"--fixed-strings", -- 精确字符串匹配
-- 			},
-- 			-- 其他需要的配置...
-- 		},
-- 	})
-- 	-- 执行精确搜索
-- 	telescope.builtin.grep_string({})
-- end
--
-- -- 正则表达式搜索的设置
-- local regex_search = function()
-- 	telescope.setup({
-- 		defaults = {
-- 			vimgrep_arguments = {
-- 				"rg",
-- 				"--color=never",
-- 				"--no-heading",
-- 				"--with-filename",
-- 				"--line-number",
-- 				"--column",
-- 				"--smart-case",
-- 				-- 此处不使用 "--fixed-strings"，以支持正则搜索
-- 			},
-- 			-- 其他需要的配置...
-- 		},
-- 	})
-- 	-- 执行正则搜索
-- 	telescope.builtin.live_grep({})
-- end
--
-- -- 绑定快捷键
-- vim.api.nvim_set_keymap('n', '<leader>w', ':lua exact_match()<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<leader>g', ':lua regex_search()<CR>', { noremap = true })
--
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("fzf")
require("telescope").load_extension("emoji")
require("telescope").load_extension("neoclip")
-- require('telescope').load_extension("frecency")
require("telescope").load_extension("lsp_handlers")
require("telescope").load_extension("bookmarks")
