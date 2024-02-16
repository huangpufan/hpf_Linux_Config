set termguicolors
set autoread
au FocusGained,BufEnter * :checktime
" 当失去焦点或者离开当前的 buffer 的时候保存
set autowrite
autocmd FocusLost,BufLeave * silent! update

" Use ESC to enter normal mode in terminal.
" tnoremap  <Esc>  <C-\><C-n>

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

" floaterm 永远的神
let g:floaterm_width = 0.90
let g:floaterm_height = 0.90
" let g:floaterm_keymap_prev = '<C-k>'
" let g:floaterm_keymap_new = '<C-j>'
let g:floaterm_keymap_toggle = '<C-t>'
inoremap <C-t> <Esc>:FloatermToggle<cr>

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

" Open file and cursor at the last position
autocmd BufReadPost *
   \ if line("'\"") > 1 && line("'\"") <= line("$") |
   \   exe "normal! g`\"" |
   \ endif


""""""""""""""""""""""""""  color set  """"""""""""""""""""""""""""""""""
" Set the color of the comment
highlight Comment ctermfg=darkgray guifg=#a6d189
" #c5c8c6
" #8abeb7
" #b294bb
" #a8a19f
" #969896
" #d5c4a1
" #f2e5bc
" #e0cfa9
" #d7bd8d
" #f4a460
" #996515
" #8b4513
" #800000
" #a0522d
" #7e3300
" #400000
" #6f4e37
" #d2691e
" #b56a4c
"
""""""""""""""""""""""""""  buffer set """"""""""""""""""""""""""""""""""
" To ban the completion when the line is empty or no content before the cursor.
augroup DisableCompletionOnEmptyLine
  autocmd!
  autocmd FileType * if getline('.') =~# '^\s*$' | setlocal complete-=k | endif
augroup END

hi BufferLineBufferSelected guifg=white guibg=none gui=bold,underline

" 在 VimEnter 事件后检查并关闭名为 NvimTree_1 的空 buffer
" autocmd VimEnter * if bufexists("NvimTree_1") | bdelete NvimTree_1 | endif

function! CloseBuffersOnStart()
  " 获取所有 buffer 的列表
  redir => l:bufferlist
  silent! ls
  redir END

  " 逐行处理 buffer 列表
  for l:line in split(l:bufferlist, '\n')
    " 匹配 buffer 名称前缀为 'hpf/' 或者精确匹配 'NvimTree_1' 的 buffer
    if l:line =~ 'hpf*' || l:line =~ 'NvimTree_1'
      " 提取 buffer 编号
      let l:matched = matchlist(l:line, '^\s*\zs\d\+')
      if !empty(l:matched)
        " 删除对应 buffer
        execute 'bdelete' l:matched[0]
      endif
    endif
  endfor
endfunction

" 启动 nvim 时，调用 CloseBuffersOnStart 函数
autocmd VimEnter * call CloseBuffersOnStart()



function! ZoxideQuery()
    let dir = system('zoxide query ' . shellescape(input('z> ')))
    if v:shell_error == 0
        execute 'cd ' . fnameescape(trim(dir))
    else
        echohl ErrorMsg
        echo "zoxide: directory not found"
        echohl None
    endif
endfunction

" 绑定到某个键，例如 <leader>z
nnoremap <silent> <space>z :call ZoxideQuery()<CR>

let g:nvim_tree_auto_refresh = 1
