""""""""""""""""""""""""""""""" Leader key set """""""""""""""""""""""""""""
let g:mapleader = ','
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" load lua config
lua require 'usr'

" laod vim config, 参考 https://github.com/jdhao/nvim-config
let s:core_conf_files = [
      \ 'misc.vim',
      \ 'color.vim',
      \ 'debug.vim',
      \ 'wilder.vim',
      \ 'keymaps.vim',
      \ ]

for s:fname in s:core_conf_files
  execute printf('source %s/vim/%s', stdpath('config'), s:fname)
endfor

set termguicolors
set autoread
au FocusGained,BufEnter * :checktime
" 当失去焦点或者离开当前的 buffer 的时候保存
set autowrite
autocmd FocusLost,BufLeave * silent! update



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


