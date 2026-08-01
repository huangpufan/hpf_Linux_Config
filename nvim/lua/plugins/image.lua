--[[
  Image preview in terminal (Sixel backend for Windows Terminal)
--]]

return {
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      backend = "sixel",        -- Windows Terminal supports Sixel protocol
      max_width_window = nil,   -- use full window width
      max_height_window = nil,  -- use full window height
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
        },
        neorg = {
          enabled = false,
        },
      },
    },
  },
}
