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

-- Auto save when losing focus
autocmd({ "FocusLost", "BufLeave" }, {
  pattern = "*",
  command = "silent! update",
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

-- Floaterm: Enter key behavior
autocmd("FileType", {
  pattern = "floaterm",
  callback = function()
    vim.keymap.set("v", "<Enter>", ":normal! i<Enter><CR>", { buffer = true })
  end,
})

--------------------------------------------------------------------------------
-- Clipboard (OSC52 for remote)
--------------------------------------------------------------------------------

autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    local event = vim.v.event
    if event.operator == "y" and event.regname == "+" then
      vim.cmd("OSCYankRegister +")
    elseif event.operator == "d" and event.regname == "+" then
      vim.cmd("OSCYankRegister +")
    end
  end,
})

--------------------------------------------------------------------------------
-- Lazygit
--------------------------------------------------------------------------------

-- Close floaterm when lazygit exits
autocmd("TermClose", {
  pattern = "term://*lazygit*",
  command = "FloatermKill",
})

-- Define LazyGit command
vim.api.nvim_create_user_command("LazyGit", "FloatermNew --height=0.9 --width=0.9 lazygit", {})
vim.keymap.set("n", "g=", ":LazyGit<CR>", { desc = "Open LazyGit" })

--------------------------------------------------------------------------------
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

-- Start with alpha or nvim-tree depending on arguments
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc(-1) == 0 then
      -- No file arguments: show alpha dashboard
      -- Alpha is loaded lazily, will be triggered by the plugin
    else
      -- Has file arguments: open nvim-tree
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

