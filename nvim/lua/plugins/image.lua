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
    config = function(_, opts)
      -- Ensure sixel backend uses nvim_ui_send (bypasses nvim's channel system)
      -- instead of chansend(stderr) which can buffer/intercept escape sequences.
      local sixel_path = vim.fs.joinpath(
        vim.fn.stdpath("data"), "lazy", "image.nvim", "lua", "image", "backends", "sixel.lua"
      )
      local content = vim.fn.readfile(sixel_path)
      local patched = false
      for i, line in ipairs(content) do
        local new_line, n = line:gsub(
          'vim%.fn%.chansend%(vim%.v%.stderr, ([^)]+)%s*%)',
          'vim.api.nvim_ui_send(%1)'
        )
        if n > 0 then
          content[i] = new_line
          patched = true
        end
      end
      if patched then
        vim.fn.writefile(content, sixel_path)
      end

      require("image").setup(opts)
    end,
  },
}
