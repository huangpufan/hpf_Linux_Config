require "usr.options"
require "usr.lazy"

require "usr.cmp"
require("catppuccin").setup {
  name = "catppuccin",
  priority = 1000,
  aerial = true,
  alpha = true,
  cmp = true,
  dashboard = true,
  flash = true,
  gitsigns = true,
  headlines = true,
  illuminate = true,
  -- indent_blankline = { enabled = true },
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
}
require "usr.bufferline"

--require("usr.code_runner")
-- require "usr.hydra"
require "usr.nvim-tree"
require "usr.nvim-treesitter"
--require("usr.orgmode")
require "usr.telescope"
require "usr.version"
require "usr.which-key"
require "usr.colorscheme"
require "usr.alpha"
require("colorizer").setup { "css", "javascript", "vim", "lua", html = { mode = "foreground" } }

require("persisted").setup {
  autoload = true,
  before_save = function()
    vim.cmd "NvimTreeClose"
  end,
}
vim.o.sessionoptions = "buffers,curdir,folds,tabpages,winpos,winsize"

require("gitsigns").setup { signcolumn = true, numhl = true }
require("nvim-autopairs").setup()
require("fidget").setup()
require("nvim-navic").setup()
require("barbecue").setup()
require("nvim-lightbulb").update_lightbulb()
-- require("im_select").setup()
require("lualine").setup()
--require("rsync").setup()
require("Comment").setup()
--require("virt-column").setup()
-- require("neo-tree").paste_default_config()
--

-- require("luasnip.loaders.from_lua").lazy_load({ paths = "~/.config/nvim/LuaSnip/" })
require("luasnip.loaders.from_snipmate").lazy_load { paths = "~/.config/nvim/snippets/" }
-- require("luasnip.loaders.from_vscode").load({paths = "~/.config/nvim/snippets"})

require("lsp_signature").setup()

-- Usage:
--     Old text                    Command         New text
-- --------------------------------------------------------------------------------
--     surr*ound_words             ysiw)           (surround_words)
--     *make strings               ys$"            "make strings"
--     [delete ar*ound me!]        ds]             delete around me!
--     remove <b>HTML t*ags</b>    dst             remove HTML tags
--     'change quot*es'            cs'"            "change quotes"
--     <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
--     delete(functi*on calls)     dsf             function calls
--

-- -- workaround for https://github.com/neovim/neovim/issues/21856
-- vim.api.nvim_create_autocmd({ "VimLeave" }, {
--   callback = function()
--     vim.cmd "sleep 10m"
--   end,
-- })

require("aerial").setup {
  backends = { "markdown", "man", "lsp", "treesitter" },
  layout = {
    max_width = { 35, 0.16 },
    min_width = { 20, 0.1 },
    placement = "edge",
    default_direction = "right",
  },
  attach_mode = "global",
}

require("bookmarks").setup {
  mappings_enabled = false,
  virt_pattern = { "*.lua", "*.md", "*.c", "*.h", "*.sh" },
}

require("tabout").setup()

require("goto-preview").setup {
  default_mappings = true,
}
-- require("ibl").setup()
require("mini.indentscope").setup()
-- instances.
-- require("neoscroll").setup()

require("hlargs").setup {
  color = "#FF7F7F",
  -- backup choose:
  -- Dusty Rose: #BC8F8F
  -- Sage Green: #B8C4B1
  -- Slate Blue: #6A7EAB
  -- Mauve: #E0B0FF
  -- Cream: #FFFDD0
  -- Burnt Sienna: #E97451
  -- Powder Blue: #B0E0E6
  -- Pale Pink: #FADADD
  -- Charcoal: #36454F
  -- Teal: #008080
  -- Soft Lavender: #BFA0CB
  -- Warm Beige: #F5F5DC
  -- Ocean Blue: #1CA9C9
  -- Coral Pink: #FF7F7F
  -- Olive Green: #6B8E23
  -- Midnight Blue: #191970
  -- Soft Peach: #FFE5B4
  -- Lilac: #C8A2C8
  -- Turquoise: #40E0D0
  highlight = {},
  excluded_filetypes = {},
  -- disable = function(lang, bufnr) -- If changed, `excluded_filetypes` will be ignored
  -- 	return vim.tbl_contains(opts.excluded_filetypes, lang)
  -- end,
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

require("nvim-tree").setup {
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true,
  },
}

local helpers = require "incline.helpers"
require("incline").setup {
  window = {
    padding = 0,
    margin = { horizontal = 0 },
  },
  render = function(props)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
    local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
    local modified = vim.bo[props.buf].modified
    local buffer = {
      ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
      " ",
      { filename, gui = modified and "bold,italic" or "bold" },
      " ",
      guibg = "#44406e",
    }
    return buffer
  end,
}

require("overseer").setup()

require("diffview").setup {
  hooks = {
    diff_buf_win_enter = function()
      vim.opt_local.foldenable = false
    end,
  },
}

-- To avoid the error message warning: multiple different client offset_encodings
local notify = vim.notify
vim.notify = function(msg, ...)
  if msg:match "warning: multiple different client offset_encodings" then
    return
  end

  notify(msg, ...)
end
require("femaco").setup()
require("better_escape").setup()
require("toggleterm").setup()
local SymbolKind = vim.lsp.protocol.SymbolKind
require("lsp-lens").setup {
  enable = true,
  include_declaration = false, -- Reference include declaration

  ignore_filetype = {
    "prisma",
  },
  -- Target Symbol Kinds to show lens information
  target_symbol_kinds = { SymbolKind.Function, SymbolKind.Method, SymbolKind.Interface },
  -- Symbol Kinds that may have target symbol kinds as children
  wrapper_symbol_kinds = { SymbolKind.Class, SymbolKind.Struct },
  sections = {
    definition = function(count)
      return "Definitions: " .. count
    end,
    references = function(count)
      return "References: " .. count
    end,
    implements = function(count)
      return "Implements: " .. count
    end,
    git_authors = false,
  },
}

require("inc_rename").setup {
  input_buffer_type = "dressing",
}
vim.keymap.set("n", "<space>rn", function()
  return ":IncRename " .. vim.fn.expand "<cword>"
end, { expr = true })

require("tree-sitter-just").setup {}
require("colorful-winsep").setup {}

vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })


-- Other settings:

-- Close all spell check
vim.opt.spell = false
