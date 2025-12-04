--[[
  Vim/Neovim options configuration
--]]

local opt = vim.opt

-- General
opt.backup = false
opt.swapfile = false
opt.writebackup = false
opt.undofile = true
opt.autoread = true
opt.autowrite = true

-- UI
opt.termguicolors = true
opt.number = true
opt.cursorline = true
opt.showmode = false
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.pumheight = 10
opt.laststatus = 3 -- Global statusline
opt.splitkeep = "screen"
opt.fillchars:append("eob: ") -- Hide ~ on empty lines

-- Editor behavior
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartcase = true
opt.ignorecase = true
opt.hlsearch = true
opt.wrap = true
opt.linebreak = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Completion
opt.completeopt = { "menuone", "noselect" }

-- Fold
opt.foldmethod = "manual"
opt.foldminlines = 1
opt.foldlevel = 999

-- Encoding
opt.fileencoding = "utf-8"
opt.conceallevel = 0

-- Performance
opt.timeoutlen = 300
opt.updatetime = 300

-- Spell
opt.spell = false
opt.spelllang = "en_us"

-- Other
opt.whichwrap = "bs<>[]hl"
opt.guifont = "monospace:h17"

-- Session options
opt.sessionoptions = "buffers,curdir,folds,tabpages,winpos,winsize"

-- Shortmess
opt.shortmess:append("c")
opt.iskeyword:append("-")
opt.formatoptions:remove({ "c", "r", "o" })
opt.runtimepath:remove("/usr/share/vim/vimfiles")

