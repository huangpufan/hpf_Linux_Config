--[[
  Auto commands configuration
--]]

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------

-- Auto reload file when changed externally
autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})

-- Auto save when losing focus / switching buffers.
-- Guard against recreating files that were removed on disk (e.g. nvim-tree
-- delete, trash, git operations): `:update` re-creates a missing file from
-- the in-memory buffer even when &modified is false, so it must be skipped
-- when the file no longer exists. See issue: deleting an open file in
-- nvim-tree first closes the buffer and requires a second delete.
autocmd({ "FocusLost", "BufLeave" }, {
  pattern = "*",
  callback = function(args)
    local bo = vim.bo[args.buf]
    if bo.buftype ~= "" or bo.readonly or not bo.modifiable then
      return
    end
    -- Only persist buffers whose backing file still exists on disk; otherwise
    -- `:update` would resurrect a file that was just removed.
    if vim.fn.filereadable(args.file) ~= 1 then
      return
    end
    vim.cmd("silent! update")
  end,
})

-- Return to last edit position
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 1 and line <= vim.fn.line("$") then
      vim.cmd('normal! g`"')
    end
  end,
})

--------------------------------------------------------------------------------
-- Terminal
--------------------------------------------------------------------------------

-- Terminal keymaps
autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.keymap.set("n", "<Enter>", "a", { buffer = true })
    vim.keymap.set("v", "<Enter>", "a", { buffer = true })
  end,
})

-- Exit terminal mode with C-d
vim.keymap.set("t", "<C-d>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

--------------------------------------------------------------------------------
-- Filetype specific
--------------------------------------------------------------------------------

-- Bash: Add executable permission shortcut
autocmd("FileType", {
  pattern = "sh",
  callback = function()
    vim.keymap.set("n", "<leader>x", ":!chmod +x %<CR>", { buffer = true, noremap = false, silent = true })
  end,
})

-- Highlights
--------------------------------------------------------------------------------

-- Custom comment color
vim.cmd([[highlight Comment ctermfg=darkgray guifg=#a6d189]])

-- Flash.nvim highlights
vim.cmd([[
  highlight FlashMatch guibg=#4870d9 guifg=#ffffff
  highlight FlashCurrent guibg=#ff966c guifg=#ffffff
  highlight FlashLabel guibg=#ff966c guifg=#ffffff
  highlight FlashCursor guibg=#ca3311 guifg=#ffffff
]])

-- BufferLine selected
vim.cmd([[hi BufferLineBufferSelected guifg=white guibg=none gui=bold,underline]])

--------------------------------------------------------------------------------
-- Startup behavior
--------------------------------------------------------------------------------

-- Open nvim-tree for explicit file arguments. With no arguments,
-- persisted.nvim restores the cwd session or opens Alpha when none is usable.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc(-1) > 0 then
      vim.defer_fn(function()
        local ok, tree_api = pcall(require, "nvim-tree.api")
        if ok then
          tree_api.tree.open()
          vim.cmd("wincmd p")
        end
      end, 0)
    end
  end,
  once = true,
})

--------------------------------------------------------------------------------
-- Suppress warnings
--------------------------------------------------------------------------------

-- Suppress multiple client offset_encodings warning
local notify = vim.notify
vim.notify = function(msg, ...)
  if msg:match("warning: multiple different client offset_encodings") then
    return
  end
  notify(msg, ...)
end
