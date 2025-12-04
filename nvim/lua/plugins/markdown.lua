--[[
  Markdown related plugins
--]]

return {
  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview" },
    ft = { "markdown" },
    build = "cd app && npm install",
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

