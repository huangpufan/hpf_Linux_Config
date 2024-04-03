"""""""""""""""""""""""""""" Shortcut Setting """"""""""""""""""""""""""""""""

" Window Split
" Map '\' to split the window horizontally
nnoremap \ :split<CR>
" Map '|' to split the window vertically
nnoremap <Bar> :vsplit<CR>

" use alter + left/right to switch buffer.
noremap<M-Left> :BufferLineCyclePrev<CR>
noremap<M-Right> :BufferLineCycleNext<CR>

noremap<A-j> :BufferLineCyclePrev<CR>
noremap<A-k> :BufferLineCycleNext<CR>

"" 使用 Alt + 数字 切换到对应编号的 buffer
nnoremap <A-1> :BufferLineGoToBuffer 1<CR>
nnoremap <A-2> :BufferLineGoToBuffer 2<CR>
nnoremap <A-3> :BufferLineGoToBuffer 3<CR>
nnoremap <A-4> :BufferLineGoToBuffer 4<CR>
nnoremap <A-5> :BufferLineGoToBuffer 5<CR>
nnoremap <A-6> :BufferLineGoToBuffer 6<CR>
nnoremap <A-7> :BufferLineGoToBuffer 7<CR>
nnoremap <A-8> :BufferLineGoToBuffer 8<CR>
nnoremap <A-9> :BufferLineGoToBuffer 9<CR>

" Pin the tab.
nnoremap <A-p> :BufferLineTogglePin<CR>

nnoremap <A-d> :BufferLineCloseRight<CR>

nnoremap <A-i> :BufferLineMovePrev<CR>
nnoremap <A-o> :BufferLineMoveNext<CR>

" Ensure the cursor is always in the middle of the screen.
nnoremap <C-o> <C-o>zz
nnoremap <C-i> <C-i>zz

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

" Delete
vnoremap <BS> "_d

" Alt + left right to move by word in insert mode.
inoremap <A-Right> <C-\><C-O>e<C-\><C-O>a
inoremap <A-Left> <Esc>bi

" 注意，映射的命令后必须要有空格，不然后面的全部不生效

" Multi-line editting mode.
noremap <C-M> <C-V>

" For Lsp restart case.
nnoremap <Space>rs :LspRestart clangd<CR>
