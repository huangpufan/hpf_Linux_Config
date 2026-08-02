--[[
  Image preview using chafa (ANSI art in buffer)
  Works everywhere: regular terminal, floating terminal, tmux, SSH.
  No flickering — the image IS the buffer content.
--]]

local IMAGE_FILETYPES = {
  png = true,
  jpg = true,
  jpeg = true,
  gif = true,
  bmp = true,
  webp = true,
  tiff = true,
  avif = true,
}

local function is_image_file(path)
  local ext = vim.fn.fnamemodify(path, ":e"):lower()
  return IMAGE_FILETYPES[ext] or false
end

local function render_image(buf, path)
  -- Get window dimensions for optimal size
  local win = vim.fn.bufwinid(buf)
  local width = 80
  local height = 40
  if win ~= -1 then
    width = math.min(vim.api.nvim_win_get_width(win) - 2, 120)
    height = math.min(vim.api.nvim_win_get_height(win) - 2, 60)
  end

  -- Run chafa to convert image to ANSI art
  local size_arg = string.format("%dx%d", width, height)
  local output = vim.fn.system({
    "chafa",
    "--format", "symbols",
    "--colors", "256",
    "--size", size_arg,
    "--dither", "fs",
    path,
  })

  if vim.v.shell_error ~= 0 then
    vim.notify("chafa failed: " .. output, vim.log.levels.ERROR)
    return
  end

  -- Split into lines and set buffer content
  local lines = vim.split(output, "\n", { plain = true })
  -- Remove trailing empty lines
  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nowrite"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "image_preview"

  -- Clean up window options for image viewing
  if win ~= -1 then
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].foldcolumn = "0"
    vim.wo[win].wrap = false
    vim.wo[win].cursorline = false
    vim.wo[win].colorcolumn = ""
    vim.wo[win].statuscolumn = ""
  end
end

-- Intercept image file opens
vim.api.nvim_create_autocmd("BufReadCmd", {
  group = vim.api.nvim_create_augroup("chafa_image_preview", { clear = true }),
  pattern = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.bmp", "*.webp", "*.tiff", "*.avif" },
  callback = function(ev)
    local path = ev.match
    if vim.fn.filereadable(path) == 0 then
      vim.notify("File not found: " .. path, vim.log.levels.ERROR)
      return
    end
    render_image(ev.buf, path)
  end,
})

-- Re-render on window resize
vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("chafa_image_resize", { clear = true }),
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype == "image_preview" then
      local path = vim.api.nvim_buf_get_name(buf)
      if vim.fn.filereadable(path) == 1 then
        render_image(buf, path)
      end
    end
  end,
})

return {}
