--[[
  Key mappings configuration
  All keymaps are defined here for easy reference
--]]

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Helper function
local function with_desc(desc)
  return vim.tbl_extend("force", opts, { desc = desc })
end

--------------------------------------------------------------------------------
-- Window splits
--------------------------------------------------------------------------------
map("n", "\\", ":split<CR>", with_desc("Horizontal split"))
map("n", "|", ":vsplit<CR>", with_desc("Vertical split"))

--------------------------------------------------------------------------------
-- Window navigation
--------------------------------------------------------------------------------
map("n", "<C-l>", "<cmd>wincmd w<cr>", with_desc("Switch to next window"))
map("n", "<C-h>", "<cmd>wincmd W<cr>", with_desc("Switch to prev window"))
map("n", "<C-j>", "<C-w>j", with_desc("Switch to window below"))
map("n", "<C-k>", "<C-w>k", with_desc("Switch to window above"))

--------------------------------------------------------------------------------
-- Buffer navigation (BufferLine)
--------------------------------------------------------------------------------
map("n", "<M-Left>", ":BufferLineCyclePrev<CR>", with_desc("Previous buffer"))
map("n", "<M-Right>", ":BufferLineCycleNext<CR>", with_desc("Next buffer"))
map("n", "<A-j>", ":BufferLineCyclePrev<CR>", with_desc("Previous buffer"))
map("n", "<A-k>", ":BufferLineCycleNext<CR>", with_desc("Next buffer"))

-- Buffer number switching
for i = 1, 9 do
  map("n", "<A-" .. i .. ">", ":BufferLineGoToBuffer " .. i .. "<CR>", with_desc("Go to buffer " .. i))
end

map("n", "<A-p>", ":BufferLineTogglePin<CR>", with_desc("Pin buffer"))
map("n", "<A-d>", ":BufferLineCloseRight<CR>", with_desc("Close buffers to right"))
map("n", "<A-i>", ":BufferLineMovePrev<CR>", with_desc("Move buffer left"))
map("n", "<A-o>", ":BufferLineMoveNext<CR>", with_desc("Move buffer right"))
map("n", "<M-Home>", ":BufferLineGoToBuffer 1<CR>", with_desc("Go to first buffer"))
map("n", "<M-End>", ":BufferLineGoToBuffer 1000<CR>", with_desc("Go to last buffer"))

--------------------------------------------------------------------------------
-- Modern editing shortcuts
--------------------------------------------------------------------------------
-- Copy
map("n", "<C-c>", '"+y', with_desc("Copy to clipboard"))
map("v", "<C-c>", '"+y', with_desc("Copy to clipboard"))

-- Cut
map("n", "<C-x>", '"+x', with_desc("Cut to clipboard"))
map("v", "<C-x>", '"+x', with_desc("Cut to clipboard"))
map("i", "<C-x>", "<C-o>dd", with_desc("Cut line"))

-- Save
map("n", "<C-s>", ":wall<CR>", with_desc("Save all"))
map("i", "<C-s>", "<C-o>:wall<CR>", with_desc("Save all"))

-- Select all
map("n", "<C-a>", "ggVG", with_desc("Select all"))
map("i", "<C-a>", "<Esc>ggVG", with_desc("Select all"))

-- Duplicate line
map("v", "<C-d>", 'y<Esc>o<C-R>"<CR>', with_desc("Duplicate selection"))
map("i", "<C-d>", "<Esc>:normal! yy<CR>p`[A", with_desc("Duplicate line"))

-- Undo
map("i", "<C-z>", "<C-O>u", with_desc("Undo"))
map("n", "<C-z>", "<C-O>u", with_desc("Undo"))

-- Delete in visual mode
map("v", "<BS>", '"_d', with_desc("Delete selection"))

-- Reload config
map("n", "<F5>", ":source $MYVIMRC<CR>", with_desc("Reload config"))
map("i", "<F5>", "<C-O>:source $MYVIMRC<CR>", with_desc("Reload config"))

--------------------------------------------------------------------------------
-- Shift selection
--------------------------------------------------------------------------------
map("n", "<S-Up>", "<Esc>v<Up>", opts)
map("n", "<S-Down>", "<Esc>v<Down>", opts)
map("n", "<S-Left>", "<Esc>v<Left>", opts)
map("n", "<S-Right>", "<Esc>v<Right>", opts)
map("v", "<S-Up>", "<Up>", opts)
map("v", "<S-Down>", "<Down>", opts)
map("v", "<S-Left>", "<Left>", opts)
map("v", "<S-Right>", "<Right>", opts)
map("i", "<S-Up>", "<Esc>v<Up>", opts)
map("i", "<S-Down>", "<Esc>lv<Down>", opts)
map("i", "<S-Left>", "<Esc>v<Left>", opts)
map("i", "<S-Right>", "<Esc>lv<Right>", opts)

--------------------------------------------------------------------------------
-- Visual line navigation (j/k wrap support)
--------------------------------------------------------------------------------
map("n", "j", "v:count == 0 && mode(1)[0:1] != 'no' ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 && mode(1)[0:1] != 'no' ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "<Down>", "v:count == 0 && mode(1)[0:1] != 'no' ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "<Up>", "v:count == 0 && mode(1)[0:1] != 'no' ? 'gk' : 'k'", { expr = true, silent = true })

--------------------------------------------------------------------------------
-- Indentation
--------------------------------------------------------------------------------
map("n", ">", ">>", with_desc("Indent right"))
map("n", "<", "<<", with_desc("Indent left"))

--------------------------------------------------------------------------------
-- Scrolling (centered)
--------------------------------------------------------------------------------
map("n", "<C-o>", "<C-o>zz", with_desc("Jump back (centered)"))
map("n", "<C-i>", "<C-i>zz", with_desc("Jump forward (centered)"))
map("n", "<C-e>", "3<C-e>", with_desc("Scroll down"))
map("n", "<C-y>", "3<C-y>", with_desc("Scroll up"))

--------------------------------------------------------------------------------
-- Search
--------------------------------------------------------------------------------
map("n", "<Esc>", ":noh<CR>", with_desc("Clear search highlight"))

--------------------------------------------------------------------------------
-- Multi-line edit mode
--------------------------------------------------------------------------------
map("n", "<C-M>", "<C-V>", with_desc("Visual block mode"))

--------------------------------------------------------------------------------
-- Misc
--------------------------------------------------------------------------------
map("n", "xx", "x", with_desc("Delete char (original x)"))
map("n", "q", "<cmd>q<cr>", with_desc("Close window"))
map("v", "q", "<cmd>q<cr>", with_desc("Close window"))
map("n", "<space>q", "<cmd>qa<cr>", with_desc("Close nvim"))

--------------------------------------------------------------------------------
-- Close buffer function
--------------------------------------------------------------------------------
vim.cmd([[
function! CloseBuffer()
  let buflisted = getbufinfo({'buflisted': 1})
  let cur_winnr = winnr()
  let cur_bufnr = bufnr('%')

  if len(buflisted) < 2
    enew
    execute 'bd' cur_bufnr
    return
  endif

  for winid in getbufinfo(cur_bufnr)[0].windows
    execute win_id2win(winid).'wincmd w'
    if cur_bufnr == buflisted[-1].bufnr
      bp
    else
      bn
    endif
  endfor

  execute cur_winnr.'wincmd w'

  let is_terminal = getbufvar(cur_bufnr, '&buftype') ==# 'terminal'
  if is_terminal
    bd! #
  else
    silent! bd #
  endif
endfunction
]])

map("n", "<C-w>", ":wa<CR>:call CloseBuffer()<CR>", with_desc("Close buffer"))
map("n", "<A-x>", ":BDelete hidden<cr>", with_desc("Close hidden buffers"))
map("i", "<A-x>", "<C-o>:BDelete hidden<cr>", with_desc("Close hidden buffers"))

--------------------------------------------------------------------------------
-- LSP keymaps
--------------------------------------------------------------------------------
map("n", "<Space>rs", ":LspRestart clangd<CR>", with_desc("Restart clangd"))

