-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
local telescope = require("telescope").setup({
	defaults = {
		layout_strategy = "horizontal",

		layout_config = {
			vertical = {
				height = 0.9,
				preview_cutoff = 0,
				width = 0.9,
			},
			-- other layout configuration here
		},
		-- other defaults configuration here
	},

	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "respect_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		},
		bookmarks = {
			-- Available: 'brave', 'buku', 'chrome', 'edge', 'safari', 'firefox'
			selected_browser = "chrome",
		},
		emoji = {
			action = function(emoji)
				vim.api.nvim_put({ emoji.value }, "c", false, true) -- 选择 emoji 之后直接插入符号
			end,
		},
	},
})
-- 精确搜索的设置
local exact_match = function()
	telescope.setup({
		defaults = {
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--fixed-strings", -- 精确字符串匹配
			},
			-- 其他需要的配置...
		},
	})
	-- 执行精确搜索
	telescope.builtin.grep_string({})
end

-- 正则表达式搜索的设置
local regex_search = function()
	telescope.setup({
		defaults = {
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				-- 此处不使用 "--fixed-strings"，以支持正则搜索
			},
			-- 其他需要的配置...
		},
	})
	-- 执行正则搜索
	telescope.builtin.live_grep({})
end

-- 绑定快捷键
vim.api.nvim_set_keymap('n', '<leader>w', ':lua exact_match()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>g', ':lua regex_search()<CR>', { noremap = true })
--
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("fzf")
require("telescope").load_extension("emoji")
require("telescope").load_extension("neoclip")
-- require('telescope').load_extension("frecency")
require("telescope").load_extension("lsp_handlers")
require("telescope").load_extension("bookmarks")
