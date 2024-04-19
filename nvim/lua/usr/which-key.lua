-- whichkey configuration
local wk = require "which-key"
wk.setup {
  plugins = {
    marks = false, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mo
  },
}

------------------------------------------ Ctrl related. ------------------------------------------
wk.register {
  -- ["<C-A-l>"] = { "<cmd> lua vim.lsp.buf.format{ async = true }<cr>", "format current buffer" },
  ["<C-n>"] = { "<cmd>NvimTreeToggle<cr>", "Toggle file tree" },
}
wk.register {
  -- lsp
  ["K"] = { "<cmd>lua vim.lsp.buf.hover()<cr>", "document" },

  ["g"] = {
    d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "go to definition" },
    r = { "<cmd>lua vim.lsp.buf.references()<cr>", "go to reference" },
    w = { "<cmd>Telescope diagnostics<cr>", "diagnostics" },
    i = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "go to implementation" },
    D = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "go to declaration" },
    -- x 打开文件
    -- s 用于 leap 跳转到下一个窗口
  },

  -- search
  ["<leader>"] = {
    -- leader x used for map language specific function
  },
  ["<space>"] = {
    a = {
      name = "+misc",
      d = { "<cmd>call TrimWhitespace()<cr>", "remove trailing space" },
      t = { "<Plug>Translate", "translate current word" },
    },
    -- b = {
    -- name = "+buffer",
    -- c = { "<cmd>BDelete hidden<cr>", "close invisible buffers" },
    -- d = { "<cmd>bdelete %<cr>", "close current buffers" },
    -- },
    c = {
      -- only works in a c/cpp file
      name = "+Switch h/c",
      c = { "<cmd>Ouroboros<cr>", "open file in current window" },
      h = { "<cmd>split | Ouroboros<cr>", "open file in a horizontal split" },
      v = { "<cmd>vsplit | Ouroboros<cr>", "open file in a vertical split" },
    },
    f = {
      name = "+Find",
      -- Mostly used for seaching.
      o = { "<cmd>NvimTreeFindFile<cr>", "Open file in dir" },
      b = { "<cmd>Telescope buffers<cr>", "Searcher buffers" },
      f = { "<cmd>Telescope find_files<cr>", "Search files (include submodules)" },
      F = { "<cmd>Telescope git_files<cr>", "Search files (exclude gitignore)" },
      w = { "<cmd>Telescope live_grep<cr>", "Search string" },
      c = { "<cmd>Telescope grep_string<cr>", "Search word under cursor" },

      -- Seldom used.
      v = { "<cmd>Telescope help_tags<cr>", "Search vim manual" },
      j = { "<cmd>Telescope jumplist<cr>", "Search jumplist" },
      e = { "<cmd>Telescope emoji<cr>", "Search emoji" },
      -- o = { "<cmd>Telescope lsp_document_symbols<cr>", "search symbols in file" },
      -- leader p used for paste from system clipboard
      s = { "<cmd>Telescope lsp_dynamic_workspace_symbols <cr>", "Search symbols in project" },
    },
    -- g = { "<cmd>FloatermToggle<cr>lazygit<cr>", "lazygit" },
    m = {
      d = { "<cmd>MarkdownPreview<cr>", "Markdown preview" },
      p = { "<cmd>PasteImage<cr>", "Paste image in md" },
    },
    o = {
      t = { "<cmd>AerialToggle!<cr>", "Code outline" },
    },
    --          {
    --name = "+git",
    --a = { "<cmd>Git add -A<cr>", "git stage all changes" },
    --               b = { "<cmd>Git blame<cr>", "git blame" },
    --             c = { "<cmd>Git commit<cr>", "git commit" },
    --             m = { "<cmd>GitMessenger<cr>", "show git blame of current line" },
    --             p = { "<cmd>Git push<cr>", "git push" },
    --             l = { "<cmd>FloatermNew tig %<cr>", "log of file" },
    --             L = { "<cmd>FloatermNew tig<cr>", "log of project" },
    --             s = { "<cmd>FloatermNew tig status<cr>", "git status" },
    --
    --          },
    -- 因为 ctrl-i 实际上等同于 tab
    --i = { "<c-i>", "go to newer jumplist" },
    l = {
      name = "+Language",
      a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code action" },
      f = { "<cmd> lua vim.lsp.buf.format{ async = true }<cr>", "Format current buffer" },
      j = { "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", "Lsp goto next" },
      k = { "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", "Lsp goto prev" },
      n = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
      s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Signature help" },
      q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Set loc list" },
      r = { "<cmd>RunCode<cr>", "run code" },
    },
    -- o 被 orgmode 使用
    q = { "<cmd>qa<cr>", "Close nvim" },

    r = {
      name = "+rename",
      n = {
        function()
          return ":IncRename " .. vim.fn.expand "<cword>"
        end,
        "Rename sign",
        expr = true,
      },
    },
    s = {
      name = "+Search",
      P = { "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", "Search cursor word by spectre" },
      p = { "<cmd>lua require('spectre').open()<cr>", "Search string by spectre" },
      b = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Search in current buffer by telescope" },
      g = { "<cmd>Telescope git_status<cr>", "Search git status " },
    },
    t = {
      name = "+Toggle/Theme",
      ["7"] = { "<cmd>let &cc = &cc == '' ? '75' : ''<cr>", "highlight 75 line" },
      ["8"] = { "<cmd>let &cc = &cc == '' ? '81' : ''<cr>", "highlight 80 line" },
      b = { "<cmd>let &tw = &tw == '0' ? '80' : '0'<cr>", "automaticall break line at 80" },
      -- @todo 警告说这个 feature 会被移除，但是没有对应的文档
      s = { "<cmd>set spell!<cr>", "spell check" },
      w = { "<cmd>set wrap!<cr>", "wrap line" },
      -- h = { "<cmd>noh<cr>", "Stop the highlighting" },
      h = {
        function()
          require("telescope.builtin").colorscheme { enable_preview = true }
        end,
        "search theme",
      },
      m = { "<cmd>TableModeToggle<cr>", "markdown table edit mode" },
      t = { "<cmd>set nocursorline<cr> <cmd>TransparentToggle<cr>", "make background transparent" },
    },
    -- x = { "<cmd>FloatermNew ipython<cr>", "calculated" },
  },
  q = { "<cmd>q<cr>", "close window" },
  -- c = {
  --    name = "+window",
  --    -- i f a t 被 textobject 所使用
  --    g = { "<cmd>vsp<cr>", "vertical split window" },
  --    s = { "<cmd>sp<cr>", "horizontal split window" },
  --    m = { "<cmd>only<cr>", "delete other window" },
  --    u = { "<cmd>UndotreeToggle<cr>", "open undo tree" },
  --    n = { "<cmd>AerialToggle!<cr>", "toggle navigator" },
  --    h = { "<C-w>h", "go to the window left" },
  --    j = { "<C-w>j", "go to the window below" },
  --    k = { "<C-w>k", "go to the window up" },
  --    l = { "<C-w>l", "go to the window right" },
  -- },
  m = {
    name = "+bookmarks",
    a = { "<cmd>Telescope bookmarks<cr>", "search bookmarks" },
    d = { "<cmd>lua require'bookmarks.list'.delete_on_virt()<cr>", "Delete bookmark at virt text line" },
    m = { "<cmd>lua require'bookmarks'.add_bookmarks()<cr>", "add bookmarks" },
    n = { "<cmd>lua require'bookmarks.list'.show_desc() <cr>", "Show bookmark note" },
  },
  ["<C-l>"] = { "<cmd>wincmd w<cr>", "Switch to window right" },
  ["<C-h>"] = { "<cmd>wincmd W<cr>", "Switch to window left" },
  ["<C-j>"] = { "<C-w>j", "Switch to window below" },
  ["<C-k>"] = { "<C-w>k", "switch to window above" },
}

-- Shortcut under visual mode
wk.register({
  ["<space>"] = {
    s = {
      name = "+search",
      p = { "<cmd>lua require('spectre').open_visual()<cr>", "search" },
    },
  },
  q = { "<cmd>q<cr>", "Close window" },
}, { mode = "v" })

-- 部分格式化，which-key 的设置方法有问题，似乎只是语法没有理解到位
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

-- Code format
-- vim.api.nvim_set_keymap("v", "<space>lf", "<Esc><cmd>lua FormatFunction()<CR>", { noremap = true })

-- Add executable permission to bash file
vim.cmd "autocmd FileType sh lua BashLeaderX()"
function BashLeaderX()
  vim.api.nvim_set_keymap("n", "<leader>x", ":!chmod +x %<CR>", { noremap = false, silent = true })
end

-- vim.cmd("autocmd FileType markdown lua MarkdownLeaderX()")
-- function MarkdownLeaderX()
--  vim.api.nvim_set_keymap("n", "<leader>x", ":MarkdownPreview<CR>", { noremap = false, silent = true })
-- end
--
--

vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })

_G.goto_first_buffer = function()
  vim.cmd "BufferLineGoToBuffer 1"
end

-- Go to the last buffer
_G.goto_last_buffer = function()
  -- This assumes that the maximum buffer number won't exceed 1000
  -- You might need to adjust this if you work with more buffers
  vim.cmd "BufferLineGoToBuffer 1000"
end
vim.api.nvim_set_keymap("n", "<M-Home>", "<cmd>lua goto_first_buffer()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<M-End>", "<cmd>lua goto_last_buffer()<CR>", { noremap = true, silent = true })

function LiveGrepWithExtension()
  -- 询问用户想要搜索的文件后缀
  local extension = vim.fn.input "Enter file extension(s) (e.g. lua,py): "
  -- 如果用户没有输入，不添加任何 glob 参数
  local glob_args = {}
  if extension ~= "" then
    -- 拆分用户输入的后缀，并为每个后缀创建一个 glob 参数
    for match in extension:gmatch "[^,%s]+" do
      table.insert(glob_args, "--glob")
      table.insert(glob_args, "*." .. match)
    end
  end

  -- 启动 live_grep 时传递 glob 参数
  require("telescope.builtin").live_grep {
    additional_args = function(opts)
      return glob_args
    end,
  }
end

-- 将该函数绑定到一个快捷键
vim.api.nvim_set_keymap("n", "<space>fg", ":lua LiveGrepWithExtension()<CR>", { noremap = true, silent = true })
