--[[
  Image preview using image.nvim with Sixel backend.

  Patches applied on startup:
  1. chansend(stderr) → io.stderr:write (fixes E900 in vim.schedule callbacks)
  2. FLUSH_DELAY_MS 50→0 (minimizes flickering by sending sixel data ASAP)
--]]

return {
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      backend = "sixel",
      max_width_window = nil,
      max_height_window = nil,
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
      -- Patch sixel backend before setup
      local sixel_path = vim.fs.joinpath(
        vim.fn.stdpath("data"), "lazy", "image.nvim", "lua", "image", "backends", "sixel.lua"
      )
      local content = vim.fn.readfile(sixel_path)
      local patched = false
      for i, line in ipairs(content) do
        -- Fix 1: chansend(stderr) → io.stderr:write (E900 fix)
        local new_line, n1 = line:gsub(
          'vim%.fn%.chansend%(vim%.v%.stderr, ([^)]+)%s*%)',
          'io.stderr:write(%1)'
        )
        if n1 > 0 then
          content[i] = new_line
          patched = true
        end
        -- Fix 2: FLUSH_DELAY_MS 50 → 0 (reduce flickering)
        local new_line2, n2 = content[i]:gsub(
          'local FLUSH_DELAY_MS = 50',
          'local FLUSH_DELAY_MS = 0'
        )
        if n2 > 0 then
          content[i] = new_line2
          patched = true
        end
      end
      if patched then
        vim.fn.writefile(content, sixel_path)
      end

      require("image").setup(opts)

      -- Fix 3: hijack_buffer doesn't reserve virtual lines for the image,
      -- so nvim redraws erase the sixel data below the first buffer line.
      -- Wrap hijack_buffer to enable inline + with_virtual_padding so the
      -- buffer reserves enough rows for the full image height.
      local api = require("image")
      local orig_hijack = api.hijack_buffer
      api.hijack_buffer = function(path, win, buf, options)
        options = options or {}
        options.inline = true
        options.with_virtual_padding = true
        return orig_hijack(path, win, buf, options)
      end

      -- Force re-render on every decoration cycle to keep sixel images
      -- visible after nvim screen redraws.  The built-in decoration
      -- provider skips re-render when geometry is unchanged; we work
      -- around that by clearing is_rendered so the full pipeline runs
      -- and re-sends sixel data.
      local ns = vim.api.nvim_create_namespace("sixel_refresh")
      vim.api.nvim_set_decoration_provider(ns, {
        on_win = function(_, winid, bufnr)
          local ok, api = pcall(require, "image")
          if not ok then return false end
          local images = api.get_images({ window = winid, buffer = bufnr })
          for _, img in ipairs(images) do
            -- Skip if: has extmark (markdown images re-render fine),
            -- transform pending, or currently in a flush cycle
            if not img.extmark
              and not img.pending_transform_key
              and img.is_rendered
              and img.global_state
              and not img.global_state.disable_decorator_handling
            then
              img.is_rendered = false
              img:render()
            end
          end
          return false
        end,
      })
    end,
  },
}
