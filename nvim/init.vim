set termguicolors
set autoread
au FocusGained,BufEnter * :checktime
" 当失去焦点或者离开当前的 buffer 的时候保存
set autowrite
autocmd FocusLost,BufLeave * silent! update


" leader set as ','
let g:mapleader = ','

" Quitting the window is very common for me.
" As recording the macro is not common at the same time
noremap <leader>q q

" 访问系统剪切板
map <leader>y "+y
map <leader>p "+p
map <leader>d "+d



" 使用 z a 打开和关闭 fold，打开大文件（超过 13万行)的时候可能造成性能问题
" set foldlevelstart=102
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()


" floaterm setting
let g:floaterm_width = 0.90
let g:floaterm_height = 0.90
let g:floaterm_keymap_prev = '<C-left>'
let g:floaterm_keymap_next = '<C-right>'
let g:floaterm_keymap_new = '<C-q>'
let g:floaterm_keymap_toggle = '<C-p>'


" load lua config
lua require 'usr'

" laod vim config, 参考 https://github.com/jdhao/nvim-config
let s:core_conf_files = [
      \ 'misc.vim',
      \ 'debug.vim',
      \ 'wilder.vim',
      \ 'keymaps.vim',
      \ ]

for s:fname in s:core_conf_files
  execute printf('source %s/vim/%s', stdpath('config'), s:fname)
endfor

let g:loaded_perl_provider = 3

" This keymapping originally set by whichkey doesn't work in neovim 3.8
" noremap <Space>bc :BDelete hidden<cr>

let g:gitblame_delay = 0
"let g:gitblame_ignored_filetypes = ['lua', 'markdown', 'sh']

" 因为 nvim-treesitter-textobjects 使用 x 来跳转，原始的 x 被映射为 xx
nn xx x


"autocmd VimEnter * NvimTreeOpen
" set tab = 5 space.
"


" Both are ok
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""" Tab Setting """"""""""""""""""""""""""""""""
" tab setting
set tabstop=2
set shiftwidth=2

" Shift tab to space.
set expandtab

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" / : Only when has upper case char,do we seperate upper and lower case.
set ignorecase
set smartcase

" Set ~ as invisible char to make nvim tree show better.
set fillchars+=eob:\ 

" Fold set
set foldmethod=manual
set foldminlines=1 
set foldlevel=999

" Open file and cursor at the last position
autocmd BufReadPost *
   \ if line("'\"") > 1 && line("'\"") <= line("$") |
   \   exe "normal! g`\"" |
   \ endif


" Use 'j' and 'k' to move up and down, and use 'gj' and 'gk' to move up and down by line.
" Move down with 'j' or <Down>, using 'gj' in non-numeric modes
nnoremap <expr> j v:count == 0 && mode(1)[0:1] != 'no' ? 'gj' : 'j'
nnoremap <expr> <Down> v:count == 0 && mode(1)[0:1] != 'no' ? 'gj' : 'j'

" Move up with 'k' or <Up>, using 'gk' in non-numeric modes
nnoremap <expr> k v:count == 0 && mode(1)[0:1] != 'no' ? 'gk' : 'k'
nnoremap <expr> <Up> v:count == 0 && mode(1)[0:1] != 'no' ? 'gk' : 'k'



" Fix toggle term related bug: Ensure cursor to be normal mode.
" 定义一个全局变量来确保 EnsureNormalMode 只在启动时执行一次
let g:has_ensured_normal_mode = 0

function! EnsureNormalMode(timer)
  " 检查是否已经执行过此函数
  if g:has_ensured_normal_mode
    return
  endif
  " 如果当前处于插入模式，则停止插入模式
  if mode() == 'i'
    stopinsert
  endif
  " 设置变量以避免再次执行此函数
  let g:has_ensured_normal_mode = 1
endfunction

" 使用 VimEnter 事件设置定时器，仅在 Neovim 启动时调用 EnsureNormalMode 函数
autocmd VimEnter * if g:has_ensured_normal_mode == 0 | call timer_start(30, 'EnsureNormalMode') | endif
