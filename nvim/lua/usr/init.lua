require("usr.options")
require("usr.lazy")
require("usr.lsp")
require("usr.cmp")
require("usr.bufferline")
--require("usr.code_runner")
-- require("usr.hydra")
require("usr.nvim-tree")
require("usr.nvim-treesitter")
--require("usr.orgmode")
require("usr.telescope")
require("usr.version")
require("usr.which-key")
require("usr.colorscheme")
require("usr.alpha")
require("colorizer").setup({ "css", "javascript", "vim","lua", html = { mode = "foreground" } })
require("nvim-surround").setup()
require("persisted").setup({ autoload = true })
require("gitsigns").setup({ signcolumn = false, numhl = true })
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
require("mason").setup()
-- require("luasnip.loaders.from_lua").lazy_load({ paths = "~/.config/nvim/LuaSnip/" })
require("luasnip.loaders.from_snipmate").lazy_load({ paths = "~/.config/nvim/snippets/" })
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

-- workaround for https://github.com/neovim/neovim/issues/21856
vim.api.nvim_create_autocmd({ "VimLeave" }, {
  callback = function()
    vim.cmd("sleep 10m")
  end,
})

require("aerial").setup({
  backends = { "markdown", "man", "lsp", "treesitter" },
  layout = {
    max_width = { 30, 0.15 },
    placement = "edge",
    default_direction = "left",
  },
  attach_mode = "global",
})

require("bookmarks").setup({
  mappings_enabled = false,
  virt_pattern = { "*.lua", "*.md", "*.c", "*.h", "*.sh" },
})

-- require("tabout").setup()
require("goto-preview").setup({
  default_mappings = true,
})
-- require("ibl").setup()
require("mini.indentscope").setup()
-- instances.
require("neoscroll").setup()
require('copilot').setup({
  panel = {
    enabled = true,
    auto_refresh = false,
    keymap = {
      jump_prev = "[[",
      jump_next = "]]",
      accept = "<CR>",
      refresh = "gr",
      open = "<M-CR>"
    },
    layout = {
      position = "bottom", -- | top | left | right
      ratio = 0.4
    },
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 75,
    keymap = {
      accept = "<M-l>",
      accept_word = false,
      accept_line = false,
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },
  filetypes = {
    markdown = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ["."] = false,
    cpp = true,
    c=true,
    bash=true,
  },
  copilot_node_command = 'node', -- Node.js version must be > 18.x
  server_opts_overrides = {},
})
