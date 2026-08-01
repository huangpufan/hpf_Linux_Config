--[[
  Image preview using chafa in a terminal buffer.
  nvim's terminal emulator interprets ANSI escape sequences and renders
  colors correctly. Works everywhere: regular terminal, floating terminal,
  tmux, SSH. No flickering — the terminal content is persistent.
--]]

local function render_image(buf, path)
  local win = vim.fn.bufwinid(buf)
  local width = 80
  local height = 40
  if win ~= -1 then
    width = math.min(vim.api.nvim_win_get_width(win), 200)
    height = math.min(vim.api.nvim_win_get_height(win), 80)
  end

  local cmd = string.format(
    "chafa --format symbols --colors 256 --size %dx%d --dither fs %s",
    width, height,
    vim.fn.shellescape(path)
  )

  -- termopen requires an unmodified buffer; BufReadCmd gives us one.
  -- We must NOT modify the buffer before calling termopen.
  vim.api.nvim_buf_call(buf, function()
    vim.fn.termopen(cmd, {
      on_exit = function(_, code)
        if code ~= 0 then
          vim.notify("chafa exited with code " .. code, vim.log.levels.WARN)
        end
      end,
    })

    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "image_preview"

    if win ~= -1 then
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
    end

    -- Don't start in insert mode
    vim.cmd "stopinsert"
  end)
end

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

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("chafa_image_resize", { clear = true }),
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype == "image_preview" then
      local path = vim.api.nvim_buf_get_name(buf)
      if vim.fn.filereadable(path) == 1 then
        -- Need to close old terminal and re-open with new size
        local win = vim.fn.bufwinid(buf)
        if win ~= -1 then
          vim.api.nvim_win_close(win, true)
          vim.cmd("edit " .. vim.fn.fnameescape(path))
        end
      end
    end
  end,
})

return {}
