--[[
  Which-key keybindings configuration
  Centralized place for all which-key mapped keybindings
--]]

local M = {}

function M.setup(wk)
  -- Ctrl related
  wk.add({
    { "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
  })

  -- Normal mode keybindings
  wk.add({
    -- LSP
    { "K", "<cmd>lua vim.lsp.buf.hover()<cr>", desc = "Document" },
    { "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", desc = "Go to declaration" },
    { "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "Go to definition" },
    { "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", desc = "Go to implementation" },
    { "gr", "<cmd>lua vim.lsp.buf.references()<cr>", desc = "Go to reference" },
    { "gw", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },

    -- Misc
    { "<space>a", group = "Misc" },
    { "<space>ad", "<cmd>call TrimWhitespace()<cr>", desc = "Remove trailing space" },
    { "<space>at", "<Plug>Translate", desc = "Translate current word" },

    -- Switch h/c
    { "<space>c", group = "Switch h/c" },
    { "<space>cc", "<cmd>Ouroboros<cr>", desc = "Open file in current window" },
    { "<space>ch", "<cmd>split | Ouroboros<cr>", desc = "Open file in horizontal split" },
    { "<space>cv", "<cmd>vsplit | Ouroboros<cr>", desc = "Open file in vertical split" },

    -- Find
    { "<space>f", group = "Find" },
    { "<space>fo", "<cmd>NvimTreeFindFile<cr>", desc = "Open file in dir" },
    { "<space>fb", "<cmd>Telescope buffers<cr>", desc = "Search buffers" },
    { "<space>ff", "<cmd>Telescope find_files<cr>", desc = "Search files (include submodules)" },
    { "<space>fF", "<cmd>Telescope git_files<cr>", desc = "Search files (exclude gitignore)" },
    { "<space>fw", "<cmd>Telescope live_grep<cr>", desc = "Search string" },
    { "<space>fc", "<cmd>Telescope grep_string<cr>", desc = "Search word under cursor" },
    { "<space>fv", "<cmd>Telescope help_tags<cr>", desc = "Search vim manual" },
    { "<space>fj", "<cmd>Telescope jumplist<cr>", desc = "Search jumplist" },
    { "<space>fe", "<cmd>Telescope emoji<cr>", desc = "Search emoji" },
    { "<space>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Search symbols in project" },
    {
      "<space>fg",
      function()
        local extension = vim.fn.input("Enter file extension(s) (e.g. lua,py): ")
        local glob_args = {}
        if extension ~= "" then
          for match in extension:gmatch("[^,%s]+") do
            table.insert(glob_args, "--glob")
            table.insert(glob_args, "*." .. match)
          end
        end
        require("telescope.builtin").live_grep({
          additional_args = function()
            return glob_args
          end,
        })
      end,
      desc = "Live grep with extension filter",
    },

    -- Markdown
    { "<space>md", "<cmd>MarkdownPreview<cr>", desc = "Markdown preview" },
    { "<space>mp", "<cmd>PasteImage<cr>", desc = "Paste image in md" },

    -- Outline
    { "<space>ot", "<cmd>AerialToggle!<cr>", desc = "Code outline" },

    -- Language/LSP
    { "<space>l", group = "Language" },
    { "<space>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code action" },
    { "<space>lf", "<cmd>lua vim.lsp.buf.format{ async = true }<cr>", desc = "Format current buffer" },
    { "<space>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", desc = "LSP goto next" },
    { "<space>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", desc = "LSP goto prev" },
    { "<space>ln", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
    { "<space>ls", "<cmd>lua vim.lsp.buf.signature_help()<cr>", desc = "Signature help" },
    { "<space>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Set loc list" },
    { "<space>lr", "<cmd>RunCode<cr>", desc = "Run code" },

    -- Rename
    { "<space>r", group = "Rename" },
    {
      "<space>rn",
      function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end,
      desc = "Rename sign",
      expr = true,
      replace_keycodes = false,
    },

    -- Search
    { "<space>s", group = "Search" },
    {
      "<space>sP",
      "<cmd>lua require('spectre').open_visual({select_word=true})<cr>",
      desc = "Search cursor word by spectre",
    },
    { "<space>sp", "<cmd>lua require('spectre').open()<cr>", desc = "Search string by spectre" },
    { "<space>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in current buffer" },
    { "<space>sg", "<cmd>Telescope git_status<cr>", desc = "Search git status" },

    -- Toggle/Theme
    { "<space>t", group = "Toggle/Theme" },
    { "<space>t7", "<cmd>let &cc = &cc == '' ? '75' : ''<cr>", desc = "Highlight 75 line" },
    { "<space>t8", "<cmd>let &cc = &cc == '' ? '81' : ''<cr>", desc = "Highlight 80 line" },
    { "<space>tb", "<cmd>let &tw = &tw == '0' ? '80' : '0'<cr>", desc = "Auto break line at 80" },
    {
      "<space>th",
      function()
        require("telescope.builtin").colorscheme({ enable_preview = true })
      end,
      desc = "Search theme",
    },
    { "<space>tm", "<cmd>TableModeToggle<cr>", desc = "Markdown table edit mode" },
    { "<space>ts", "<cmd>set spell!<cr>", desc = "Spell check" },
    { "<space>tw", "<cmd>set wrap!<cr>", desc = "Wrap line" },
    { "<space>tt", "<cmd>set nocursorline<cr><cmd>TransparentToggle<cr>", desc = "Make background transparent" },

    -- Bookmarks
    { "m", group = "Bookmarks" },
    { "ma", "<cmd>Telescope bookmarks<cr>", desc = "Search bookmarks" },
    { "md", "<cmd>lua require'bookmarks.list'.delete_on_virt()<cr>", desc = "Delete bookmark at virt text line" },
    { "mm", "<cmd>lua require'bookmarks'.add_bookmarks()<cr>", desc = "Add bookmarks" },
    { "mn", "<cmd>lua require'bookmarks.list'.show_desc()<cr>", desc = "Show bookmark note" },
  }, { mode = "n" })

  -- Visual mode keybindings
  wk.add({
    { "<space>s", group = "Search" },
    { "<space>sp", "<cmd>lua require('spectre').open_visual()<cr>", desc = "Search" },
  }, { mode = "v" })
end

return M

