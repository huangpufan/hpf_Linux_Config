--[[
  Markdown related plugins
--]]

return {
  -- Markdown preview in Neovim buffers
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- Browser preview for documents that need it
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
}
