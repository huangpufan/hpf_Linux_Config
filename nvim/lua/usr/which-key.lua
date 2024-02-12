-- whichkey configuration
local wk = require("which-key")
wk.setup({
	plugins = {
		marks = false, -- shows a list of your marks on ' and `
		registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mo
	},
})

------------------------------------------ Ctrl related. ------------------------------------------
wk.register({
	["<C-A-l>"] = { "<cmd> lua vim.lsp.buf.format{ async = true }<cr>", "format current buffer" },
	-- ["<C-_>"] = { "<cmd> Commentary<cr>", "comment code" },
	["<C-n>"] = { "<cmd>NvimTreeToggle<cr>", "toggle file tree" },
})

wk.register({
	-- lsp
	["K"] = { "<cmd>lua vim.lsp.buf.hover()<cr>", "document" },

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

		-- " 使用 <leader> [number] 切换到第 [number] 个 buffer
		["1"] = { "<cmd>BufferLineGoToBuffer 1<cr>", "jump to buffer 1" },
		["2"] = { "<cmd>BufferLineGoToBuffer 2<cr>", "jump to buffer 2" },
		["3"] = { "<cmd>BufferLineGoToBuffer 3<cr>", "jump to buffer 3" },
		["4"] = { "<cmd>BufferLineGoToBuffer 4<cr>", "jump to buffer 4" },
		["5"] = { "<cmd>BufferLineGoToBuffer 5<cr>", "jump to buffer 5" },
		["6"] = { "<cmd>BufferLineGoToBuffer 6<cr>", "jump to buffer 6" },
		["7"] = { "<cmd>BufferLineGoToBuffer 7<cr>", "jump to buffer 7" },
		["8"] = { "<cmd>BufferLineGoToBuffer 8<cr>", "jump to buffer 8" },
		["9"] = { "<cmd>BufferLineGoToBuffer 9<cr>", "jump to buffer 9" },
		["0"] = { "<cmd>BufferLineGoToBuffer 10<cr>", "jump to buffer 10" },
	},
	-- " 使用 space [number] 切换到第 [number] 个 window
	["<space>"] = {
		-- ["1"] = { "<cmd>1wincmd  w <cr>", "jump to window 1" },
		-- ["2"] = { "<cmd>2wincmd  w <cr>", "jump to window 2" },
		-- ["3"] = { "<cmd>3wincmd  w <cr>", "jump to window 3" },
		-- ["4"] = { "<cmd>4wincmd  w <cr>", "jump to window 4" },
		-- ["5"] = { "<cmd>5wincmd  w <cr>", "jump to window 5" },
		-- ["6"] = { "<cmd>6wincmd  w <cr>", "jump to window 6" },
		-- ["7"] = { "<cmd>7wincmd  w <cr>", "jump to window 7" },
		-- ["8"] = { "<cmd>8wincmd  w <cr>", "jump to window 8" },
		-- ["9"] = { "<cmd>9wincmd  w <cr>", "jump to window 9" },
		-- ["0"] = { "<cmd>10wincmd w <cr>", "jump to window 0" },
		--
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
			name = "+switch h/c",
			c = { "<cmd>Ouroboros<cr>", "open file in current window" },
			h = { "<cmd>split | Ouroboros<cr>", "open file in a horizontal split" },
			v = { "<cmd>vsplit | Ouroboros<cr>", "open file in a vertical split" },
		},
		f = {
			name = "+Find",
			-- Mostly used for seaching.
			o = { "<cmd>NvimTreeFindFile<cr>", "open file in dir" },
			b = { "<cmd>Telescope buffers<cr>", "searcher buffers" },
			f = { "<cmd>Telescope find_files<cr>", "search files (include submodules)" },
			F = { "<cmd>Telescope git_files<cr>", "search files (exclude submodules)" },
			w = { "<cmd>Telescope live_grep<cr>", "live grep" },
			c = { "<cmd>Telescope grep_string<cr>", "live grep cursor word" },

			-- Seldom used.
			v = { "<cmd>Telescope help_tags<cr>", "search vim manual" },
			j = { "<cmd>Telescope jumplist<cr>", "search jumplist" },
			e = { "<cmd>Telescope emoji<cr>", "search emoji" },
			-- o = { "<cmd>Telescope lsp_document_symbols<cr>", "search symbols in file" },
			-- leader p used for paste from system clipboard
			s = { "<cmd>Telescope lsp_dynamic_workspace_symbols <cr>", "search symbols in project" },
		},
		g = { "<cmd>FloatermToggle<cr>lazygit<cr>", "lazygit" },
		m = {
			d = { "<cmd>MarkdownPreview<cr>", "markdown preview" },
		},
		o = {
			l = { "<cmd>AerialToggle!<cr>", "code outline" },
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
			name = "+language",
			a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "code action" },
			c = { "<cmd>Commentary<cr>", "comment code" },
			f = { "<cmd> lua vim.lsp.buf.format{ async = true }<cr>", "format current buffer" },
			j = { "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", "lsp goto next" },
			k = { "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", "lsp goto prev" },
			n = { "<cmd>lua vim.lsp.buf.rename()<cr>", "rename" },
			s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "signature help" },
			q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "" },
			r = { "<cmd>RunCode<cr>", "run code" },
		},
		r = {
			n = { "<cmd>IncRename<cr>", "rename" },
		},
		-- o 被 orgmode 使用
		q = { "<cmd>qa<cr>", "save and close nvim" },
		s = {
			name = "+search",
			P = { "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", "search cursor word in project" },
			p = { "<cmd>lua require('spectre').open()<cr>", "search in project" },
			b = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "search in current buffer" },
			g = { "<cmd>Telescope git_status<cr>", "search git status" },
		},
		t = {
			name = "+toggle",
			["7"] = { "<cmd>let &cc = &cc == '' ? '75' : ''<cr>", "highlight 75 line" },
			["8"] = { "<cmd>let &cc = &cc == '' ? '81' : ''<cr>", "highlight 80 line" },
			b = { "<cmd>let &tw = &tw == '0' ? '80' : '0'<cr>", "automaticall break line at 80" },
			-- @todo 警告说这个 feature 会被移除，但是没有对应的文档
			s = { "<cmd>set spell!<cr>", "spell check" },
			w = { "<cmd>set wrap!<cr>", "wrap line" },
			-- h = { "<cmd>noh<cr>", "Stop the highlighting" },
			h = { "<cmd>Telescope colorscheme<cr>", "Theme switch" },
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
	["<C-l>"] = { "<cmd>wincmd w<cr>", "switch window" },
	["<C-h>"] = { "<cmd>wincmd W<cr>", "switch window" },
	["<C-j>"] = { "<C-w>j", "switch to window below" },
	["<C-k>"] = { "<C-w>k", "switch to window above" },
})

-- Shortcut under visual mode
wk.register({
	["<space>"] = {
		s = {
			name = "+search",
			p = { "<cmd>lua require('spectre').open_visual()<cr>", "search" },
		},
	},
	q = { "<cmd>q<cr>", "close window" },
}, { mode = "v" })

-- 部分格式化，which-key 的设置方法有问题，似乎只是语法没有理解到位
-- https://vi.stackexchange.com/questions/36946/how-to-add-keymapping-for-lsp-code-formatting-in-visual-mode
function FormatFunction()
	vim.lsp.buf.format({
		async = true,
		range = {
			["start"] = vim.api.nvim_buf_get_mark(0, "<"),
			["end"] = vim.api.nvim_buf_get_mark(0, ">"),
		},
	})
end

-- Code format
-- vim.api.nvim_set_keymap("v", "<space>lf", "<Esc><cmd>lua FormatFunction()<CR>", { noremap = true })

-- Add executable permission to bash file
vim.cmd("autocmd FileType sh lua BashLeaderX()")
function BashLeaderX()
	vim.api.nvim_set_keymap("n", "<leader>x", ":!chmod +x %<CR>", { noremap = false, silent = true })
end

-- vim.cmd("autocmd FileType markdown lua MarkdownLeaderX()")
-- function MarkdownLeaderX()
-- 	vim.api.nvim_set_keymap("n", "<leader>x", ":MarkdownPreview<CR>", { noremap = false, silent = true })
-- end
--
--

vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })

_G.goto_first_buffer = function()
	vim.cmd("BufferLineGoToBuffer 1")
end

-- Go to the last buffer
_G.goto_last_buffer = function()
	-- This assumes that the maximum buffer number won't exceed 1000
	-- You might need to adjust this if you work with more buffers
	vim.cmd("BufferLineGoToBuffer 1000")
end
vim.api.nvim_set_keymap("n", "<M-Home>", "<cmd>lua goto_first_buffer()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<M-End>", "<cmd>lua goto_last_buffer()<CR>", { noremap = true, silent = true })
require("project_nvim").setup({
	-- your configuration comes here
	-- or leave it empty to use the default settings
	-- refer to the configuration section below
})


