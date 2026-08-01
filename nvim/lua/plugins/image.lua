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
      -- Patch sixel backend: use io.stderr:write instead of chansend(stderr).
      -- vim.fn.chansend(vim.v.stderr,...) fails with E900 "Invalid channel id"
      -- when called from vim.schedule callbacks (which is how the flush pipeline
      -- sends sixel data). io.stderr:write goes directly to the fd and works
      -- in any context.
      local sixel_path = vim.fs.joinpath(
        vim.fn.stdpath("data"), "lazy", "image.nvim", "lua", "image", "backends", "sixel.lua"
      )
      local content = vim.fn.readfile(sixel_path)
      local patched = false
      for i, line in ipairs(content) do
        if line:find("vim%.fn%.chansend%(vim%.v%.stderr,") then
          content[i] = line:gsub(
            'vim%.fn%.chansend%(vim%.v%.stderr, ([^)]+)%s*%)',
            'io.stderr:write(%1)'
          )
          patched = true
        end
      end
      if patched then
        vim.fn.writefile(content, sixel_path)
      end

      require("image").setup(opts)

      -- Sixel data is a one-shot escape sequence: any nvim screen redraw
      -- (cursor move, timer, statusline update) erases it.  The decoration
      -- provider skips re-render when geometry is unchanged, so the image
      -- stays invisible.  Fix: periodically force re-render to re-send the
      -- sixel data and keep the image visible.
      local timer = vim.uv.new_timer()
      timer:start(500, 500, vim.schedule_wrap(function()
        local ok, api = pcall(require, "image")
        if not ok then return end
        for _, img in ipairs(api.get_images()) do
          if img.is_rendered and not img.pending_transform_key then
            img.is_rendered = false
            img:render()
          end
        end
      end))

      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          if timer and not timer:is_closing() then
            timer:stop()
            timer:close()
          end
        end,
      })
    end,
  },
}
