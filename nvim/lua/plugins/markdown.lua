--[[
  Markdown related plugins
--]]

return {
  -- Browser preview for Markdown documents
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install_sync"](1)
    end,
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_combine_preview = 1
      vim.g.mkdp_combine_preview_auto_refresh = 1
      vim.g.mkdp_refresh_slow = 1
      vim.g.mkdp_page_title = "Markdown Reading - ${name}"
      vim.g.mkdp_markdown_css = vim.fs.joinpath(vim.fn.stdpath "config", "assets", "markdown-reading.css")
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 1,
        sync_scroll_type = "relative",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {},
      }
      require("config.markdown_preview").setup()
    end,
  },
}
