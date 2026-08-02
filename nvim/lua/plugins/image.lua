--[[
  Image preview using Sixel protocol.

  Simple and direct: convert image to Sixel with ImageMagick, fill the
  buffer with enough empty lines to match the image height, then write
  the Sixel data to the terminal.  A decoration provider re-sends the
  data after each nvim redraw so the image stays visible.

  No plugins needed — works with just ImageMagick + Sixel-capable terminal.
--]]

local IMAGE_EXTS = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "avif" }

--- Get terminal cell dimensions in pixels via ioctl
local function get_cell_size()
  local ffi = require "ffi"
  ffi.cdef "typedef struct { unsigned short row, col, xpixel, ypixel; } winsize; int ioctl(int, int, ...);"
  local sz = ffi.new "winsize"
  if ffi.C.ioctl(1, 0x5413, sz) == 0 and sz.xpixel > 0 and sz.ypixel > 0 and sz.col > 0 and sz.row > 0 then
    return sz.xpixel / sz.col, sz.ypixel / sz.row
  end
  return 8, 18 -- fallback
end

--- Convert image file to Sixel data, returns data + width in cells + height in cells
local function image_to_sixel(path, max_pixel_w, max_pixel_h)
  local cmd = string.format(
    "convert %s -resize %dx%d sixel:-",
    vim.fn.shellescape(path),
    max_pixel_w,
    max_pixel_h
  )
  local data = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 or #data == 0 then
    return nil
  end

  -- Parse dimensions from sixel header: "pan;pad;pixel_w;pixel_h
  local pw, ph = data:match '"1;1;(%d+);(%d+)'
  if not pw or not ph then
    return nil
  end

  local cw, ch = get_cell_size()
  local cols = math.ceil(tonumber(pw) / cw)
  local rows = math.ceil(tonumber(ph) / ch)

  -- Wrap in DCS if not already wrapped
  if not data:match "^\27P" then
    data = "\27P0;1;0q" .. data
  end
  if not data:match "\27\\$" then
    data = data .. "\27\\"
  end

  return data, cols, rows
end

--- Show an image in the given buffer
local function show_image(buf, path)
  local win = vim.fn.bufwinid(buf)
  if win == -1 then
    return
  end

  local cw, ch = get_cell_size()
  local win_w = vim.api.nvim_win_get_width(win)
  local win_h = vim.api.nvim_win_get_height(win)

  -- Leave 1 row margin at bottom for statusline
  local max_pw = win_w * cw
  local max_ph = (win_h - 1) * ch

  local sixel_data, img_cols, img_rows = image_to_sixel(path, max_pw, max_ph)
  if not sixel_data then
    vim.notify("Failed to convert image: " .. path, vim.log.levels.ERROR)
    return
  end

  -- Fill buffer with empty lines matching the image height
  local lines = {}
  for _ = 1, img_rows do
    lines[#lines + 1] = ""
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nowrite"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "image_sixel"

  -- Window options for clean image display
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = false
  vim.wo[win].colorcolumn = ""
  vim.wo[win].statuscolumn = ""
  vim.wo[win].list = false
  vim.wo[win].spell = false

  -- Get window screen position for placing the sixel image
  local wininfo = vim.fn.getwininfo(win)[1]
  local start_row = wininfo.winrow -- 1-indexed screen row
  local start_col = wininfo.wincol -- 1-indexed screen col

  -- Build the full escape sequence: save cursor, move to position, sixel, restore cursor
  local sequence = "\27[s" .. string.format("\27[%d;%dH", start_row, start_col) .. sixel_data .. "\27[u"

  local function send()
    io.stderr:write(sequence)
    io.stderr:flush()
  end

  -- Send now
  send()

  -- Re-send after every nvim redraw so the image survives screen updates.
  -- vim.schedule defers the write until after the redraw completes.
  local ns = vim.api.nvim_create_namespace("sixel_img_" .. buf)
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, bufnr)
      if bufnr == buf then
        vim.schedule(send)
      end
      return false
    end,
  })

  -- Clean up decoration provider when buffer is closed
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      pcall(vim.api.nvim_set_decoration_provider, ns, {})
    end,
  })

  -- Re-render on window resize
  vim.api.nvim_create_autocmd("VimResized", {
    buffer = buf,
    callback = function()
      if vim.api.nvim_buf_is_valid(buf) then
        show_image(buf, path)
      end
    end,
  })
end

-- Intercept image file opens
local pattern = {}
for _, ext in ipairs(IMAGE_EXTS) do
  pattern[#pattern + 1] = "*." .. ext
end

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = vim.api.nvim_create_augroup("sixel_image_viewer", { clear = true }),
  pattern = pattern,
  callback = function(ev)
    if vim.fn.filereadable(ev.match) == 0 then
      vim.notify("File not found: " .. ev.match, vim.log.levels.ERROR)
      return
    end
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        show_image(ev.buf, ev.match)
      end
    end)
  end,
})

return {}
