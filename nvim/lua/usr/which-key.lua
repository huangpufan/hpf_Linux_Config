-- whichkey configuration
local wk = require "which-key"
wk.setup {
  plugins = {
    marks = false, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mo
  },
}

------------------------------------------ Ctrl related. ------------------------------------------
wk.add({
  { "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
})

-- Normal mode keybindings
wk.add({
  { "K", "<cmd>lua vim.lsp.buf.hover()<cr>", desc = "document" },
  { "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", desc = "go to declaration" },
  { "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "go to definition" },
  { "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", desc = "go to implementation" },
  { "gr", "<cmd>lua vim.lsp.buf.references()<cr>", desc = "go to reference" },
  { "gw", "<cmd>Telescope diagnostics<cr>", desc = "diagnostics" },

  { "<space>a", group = "misc" },
  { "<space>ad", "<cmd>call TrimWhitespace()<cr>", desc = "remove trailing space" },
  { "<space>at", "<Plug>Translate", desc = "translate current word" },

  { "<space>c", group = "Switch h/c" },
  { "<space>cc", "<cmd>Ouroboros<cr>", desc = "open file in current window" },
  { "<space>ch", "<cmd>split | Ouroboros<cr>", desc = "open file in a horizontal split" },
  { "<space>cv", "<cmd>vsplit | Ouroboros<cr>", desc = "open file in a vertical split" },

  { "<space>f", group = "Find" },
  { "<space>fo", "<cmd>NvimTreeFindFile<cr>", desc = "Open file in dir" },
  { "<space>fb", "<cmd>Telescope buffers<cr>", desc = "Searcher buffers" },
  { "<space>ff", "<cmd>Telescope find_files<cr>", desc = "Search files (include submodules)" },
  { "<space>fF", "<cmd>Telescope git_files<cr>", desc = "Search files (exclude gitignore)" },
  { "<space>fw", "<cmd>Telescope live_grep<cr>", desc = "Search string" },
  { "<space>fc", "<cmd>Telescope grep_string<cr>", desc = "Search word under cursor" },
  { "<space>fv", "<cmd>Telescope help_tags<cr>", desc = "Search vim manual" },
  { "<space>fj", "<cmd>Telescope jumplist<cr>", desc = "Search jumplist" },
  { "<space>fe", "<cmd>Telescope emoji<cr>", desc = "Search emoji" },
  { "<space>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols <cr>", desc = "Search symbols in project" },

  { "<space>md", "<cmd>MarkdownPreview<cr>", desc = "Markdown preview" },
  { "<space>mp", "<cmd>PasteImage<cr>", desc = "Paste image in md" },

  { "<space>ot", "<cmd>AerialToggle!<cr>", desc = "Code outline" },

  { "<space>l", group = "Language" },
  { "<space>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code action" },
  { "<space>lf", "<cmd> lua vim.lsp.buf.format{ async = true }<cr>", desc = "Format current buffer" },
  { "<space>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", desc = "Lsp goto next" },
  { "<space>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", desc = "Lsp goto prev" },
  { "<space>ln", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
  { "<space>ls", "<cmd>lua vim.lsp.buf.signature_help()<cr>", desc = "Signature help" },
  { "<space>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Set loc list" },
  { "<space>lr", "<cmd>RunCode<cr>", desc = "run code" },

  { "<space>q", "<cmd>qa<cr>", desc = "Close nvim" },

  { "<space>r", group = "rename" },
  { "<space>rn",
    function()
      return ":IncRename " .. vim.fn.expand "<cword>"
    end,
    desc = "Rename sign",
    expr = true,
    replace_keycodes = false,
  },

  { "<space>s", group = "Search" },
  { "<space>sP", "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", desc = "Search cursor word by spectre" },
  { "<space>sp", "<cmd>lua require('spectre').open()<cr>", desc = "Search string by spectre" },
  { "<space>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in current buffer by telescope" },
  { "<space>sg", "<cmd>Telescope git_status<cr>", desc = "Search git status " },

  { "<space>t", group = "Toggle/Theme" },
  { "<space>t7", "<cmd>let &cc = &cc == '' ? '75' : ''<cr>", desc = "highlight 75 line" },
  { "<space>t8", "<cmd>let &cc = &cc == '' ? '81' : ''<cr>", desc = "highlight 80 line" },
  { "<space>tb", "<cmd>let &tw = &tw == '0' ? '80' : '0'<cr>", desc = "automaticall break line at 80" },
  { "<space>th",
    function()
      require("telescope.builtin").colorscheme { enable_preview = true }
    end,
    desc = "search theme",
  },
  { "<space>tm", "<cmd>TableModeToggle<cr>", desc = "markdown table edit mode" },
  { "<space>ts", "<cmd>set spell!<cr>", desc = "spell check" },
  { "<space>tw", "<cmd>set wrap!<cr>", desc = "wrap line" },
  { "<space>tt", "<cmd>set nocursorline<cr> <cmd>TransparentToggle<cr>", desc = "make background transparent" },

  { "q", "<cmd>q<cr>", desc = "close window" },

  { "m", group = "bookmarks" },
  { "ma", "<cmd>Telescope bookmarks<cr>", desc = "search bookmarks" },
  { "md", "<cmd>lua require'bookmarks.list'.delete_on_virt()<cr>", desc = "Delete bookmark at virt text line" },
  { "mm", "<cmd>lua require'bookmarks'.add_bookmarks()<cr>", desc = "add bookmarks" },
  { "mn", "<cmd>lua require'bookmarks.list'.show_desc() <cr>", desc = "Show bookmark note" },

  { "<C-l>", "<cmd>wincmd w<cr>", desc = "Switch to window right" },
  { "<C-h>", "<cmd>wincmd W<cr>", desc = "Switch to window left" },
  { "<C-j>", "<C-w>j", desc = "Switch to window below" },
  { "<C-k>", "<C-w>k", desc = "switch to window above" },
}, { mode = "n" })

-- Visual mode keybindings
wk.add({
  { "<space>s", group = "search" },
  { "<space>sp", "<cmd>lua require('spectre').open_visual()<cr>", desc = "search" },
  { "q", "<cmd>q<cr>", desc = "Close window" },
}, { mode = "v" })

-- 部分格式化
-- https://vi.stackexchange.com/questions/36946/how-to-add-keymapping-for-lsp-code-formatting-in-visual-mode
function FormatFunction()
  vim.lsp.buf.format {
    async = true,
    range = {
      ["start"] = vim.api.nvim_buf_get_mark(0, "<"),
      ["end"] = vim.api.nvim_buf_get_mark(0, ">"),
    },
  }
end

-- Add executable permission to bash file
vim.cmd "autocmd FileType sh lua BashLeaderX()"
function BashLeaderX()
  vim.api.nvim_set_keymap("n", "<leader>x", ":!chmod +x %<CR>", { noremap = false, silent = true })
end

-- Spider motion (subword navigation)
vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })

-- Buffer navigation
_G.goto_first_buffer = function()
  vim.cmd "BufferLineGoToBuffer 1"
end

_G.goto_last_buffer = function()
  vim.cmd "BufferLineGoToBuffer 1000"
end
vim.api.nvim_set_keymap("n", "<M-Home>", "<cmd>lua goto_first_buffer()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<M-End>", "<cmd>lua goto_last_buffer()<CR>", { noremap = true, silent = true })

-- Live grep with file extension filter
function LiveGrepWithExtension()
  local extension = vim.fn.input "Enter file extension(s) (e.g. lua,py): "
  local glob_args = {}
  if extension ~= "" then
    for match in extension:gmatch "[^,%s]+" do
      table.insert(glob_args, "--glob")
      table.insert(glob_args, "*." .. match)
    end
  end

  require("telescope.builtin").live_grep {
    additional_args = function(opts)
      return glob_args
    end,
  }
end

vim.api.nvim_set_keymap("n", "<space>fg", ":lua LiveGrepWithExtension()<CR>", { noremap = true, silent = true })
