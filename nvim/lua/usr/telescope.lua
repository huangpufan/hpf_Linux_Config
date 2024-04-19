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

local telescope = require("telescope").setup {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "-L",
      "-F",
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
    db_safe_mode = false
  },

  extensions_list = { "themes", "terms" },
}

-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension "fzf"
require("telescope").load_extension "emoji"
require("telescope").load_extension "neoclip"
require("telescope").load_extension "lsp_handlers"
require("telescope").load_extension "bookmarks"
-- require("telescope").load_extension "projects"
