"""""""""""""""""""""""""""" Shortcut Setting """"""""""""""""""""""""""""""""
" use alter + left/right to switch buffer.
noremap<M-Left> :bp<CR>
noremap<M-Right> :bn<CR>
noremap<A-j> :bp<CR>
noremap<A-k> :bn<CR>
" noremap<A-h> :bp<CR>
" noremap<A-l> :bn<CR>



" use esc to enable nohilight.
noremap<Esc> :noh<CR>

" Copy
nnoremap <C-c> "+y
vnoremap <C-c> "+y

" Store the file
noremap <C-s> :wall<CR>
inoremap <C-s> <C-o>:wall<CR>

" Visual mode choose all the text.
nnoremap <C-a> ggVG
inoremap <C-a> <Esc> ggVG

" Cut the content
nnoremap <C-x> "+x
vnoremap <C-x> "+x
inoremap <C-x> <C-o>dd

" Copy and paste immediately.
" nnoremap <C-d> yyp
vnoremap <C-d> y<Esc>o<C-R>"<CR>
inoremap <C-d> <Esc>:normal! yy<CR>p`[A


" Reload the config file.
noremap <F5> :source $MYVIMRC<CR>
inoremap <F5> <C-O>:source $MYVIMRC<CR>

" Undo.
inoremap <C-z> <C-O>u
noremap <C-z> <C-O>u

" Very important function.
" Unless using this function,the nvimtree will cause random bug to 
" collaps the whole nvim.
function! CloseBuffer()
  let buflisted = getbufinfo({'buflisted': 1})
  let cur_winnr = winnr()
  let cur_bufnr = bufnr('%')

  " 当只剩下一个 buffer 时，新建一个空白 buffer 并关闭当前 buffer
  if len(buflisted) < 2
    enew
    execute 'bd' cur_bufnr
    return
  endif

  " 遍历当前 buffer 的所有窗口
  for winid in getbufinfo(cur_bufnr)[0].windows
    execute win_id2win(winid).'wincmd w'
    if cur_bufnr == buflisted[-1].bufnr
      bp
    else
      bn
    endif
  endfor

  " 返回原先的窗口
  execute cur_winnr.'wincmd w'

  " 检查是否为终端 buffer
  let is_terminal = getbufvar(cur_bufnr, '&buftype') ==# 'terminal'
  if is_terminal
    bd! #
  else
    " 如果不是终端，安静地关闭 buffer 但不退出 Neovim
    silent! bd #
  endif
endfunction
nnoremap <C-w> :wa<CR>:call CloseBuffer()<CR>

" Close current buffer.
" nnoremap <C-w> :w<CR>:bdelete<CR>
" ctrl r 在插入模式下，redo 也生效
"inoremap <C-r> <C-o><C-r>

" Close all the other buffer.
nnoremap <A-x> :BDelete hidden<cr>
inoremap <A-x> <C-o>:BDelete hidden<cr>

" Format the code.
inoremap <C-A-l> <C-o>:lua vim.lsp.buf.format{ async = true }<CR>

" Use shift to visually choose text.
noremap <S-Up>    <Esc>v<Up>
noremap <S-Down>  <Esc>v<Down>
noremap <S-Left>  <Esc>v<Left>
noremap <S-Right> <Esc>v<Right>
vnoremap <S-Up>    <Up>
vnoremap <S-Down>  <Down>
vnoremap <S-Left>  <Left>
vnoremap <S-Right> <Right>
inoremap <S-Up>    <Esc>v<Up>
inoremap <S-Down>  <Esc>lv<Down>
inoremap <S-Left>  <Esc>v<Left>
inoremap <S-Right> <Esc>lv<Right>

" Delete a line.
" nnoremap <C-l> dd
" inoremap <C-l> <Esc>:normal! dd<CR>i
" Delete
vnoremap <BS> "_d

" Alt + left right to move by word in insert mode.
inoremap <A-Right> <C-\><C-O>e<C-\><C-O>a
inoremap <A-Left> <Esc>bi

" 注意，映射的命令后必须要有空格，不然后面的全部不生效

" Multi-line editting mode.
noremap <C-M> <C-V>
