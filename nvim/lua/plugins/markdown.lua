--[[
  Markdown related plugins
--]]

return {
  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install_sync"](1)
    end,
    init = function()
      vim.g.mkdp_auto_close = 0
    end,
  },

  -- Markdown TOC
  {
    "mzlogin/vim-markdown-toc",
    ft = "markdown",
  },

  -- Table mode
  {
    "dhruvasagar/vim-table-mode",
    ft = "markdown",
    init = function()
      vim.g.table_mode_corner = "|"
    end,
  },
}
