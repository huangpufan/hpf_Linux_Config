"""""""""""""""""""""""""""" Macro Setting """"""""""""""""""""""""""""""""""
" bracket macro
let @j = 'ysiw`' " 在一个 word 两侧添加上 `，例如将 abc 变为 `abc`
let @k = 'ysiw"'
"""""""""""""""""""""""""""" Macro end """"""""""""""""""""""""""""""""""""""



"""""""""""""""""""""""""""" Shortcut Setting """""""""""""""""""""""""""""""
" Quitting the window is very common for me.
" As recording the macro is not common at the same time

" 访问系统剪切板
" map <leader>y "+y
" map <leader>p "+p
" map <leader>d "+d


" Window Split
" Map '\' to split the window horizontally
nnoremap \ :split<CR>
" Map '|' to split the window vertically
nnoremap <Bar> :vsplit<CR>


"""""""""""""""""""""""""""" Buffer Switch """"""""""""""""""""""""""""""""""

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

""""""""""""""""""""""""""" Buffer Switch end """"""""""""""""""""""""""""""""


" Ensure the cursor is always in the middle of the screen.
nnoremap <C-o> <C-o>zz
nnoremap <C-i> <C-i>zz

" use esc to enable nohilight.
noremap<Esc> :noh<CR>


""""""""""""""""""""""""" Modern Editing shortcuts """"""""""""""""""""""""""
" Copy : Ctrl + c
nnoremap <C-c> "+y
vnoremap <C-c> "+y

" Cut the content : Ctrl + x
nnoremap <C-x> "+x
vnoremap <C-x> "+x
inoremap <C-x> <C-o>dd

" Store the file : Ctrl + s
noremap <C-s> :wall<CR>
inoremap <C-s> <C-o>:wall<CR>

" Visual mode choose all the text : Ctrl + a
nnoremap <C-a> ggVG
inoremap <C-a> <Esc> ggVG

" Copy and paste immediately : Ctrl + d
" nnoremap <C-d> yyp
vnoremap <C-d> y<Esc>o<C-R>"<CR>
inoremap <C-d> <Esc>:normal! yy<CR>p`[A


" Reload the config file : F5
noremap <F5> :source $MYVIMRC<CR>
inoremap <F5> <C-O>:source $MYVIMRC<CR>

" Undo : Ctrl + z
inoremap <C-z> <C-O>u
noremap <C-z> <C-O>u

" Delete : Backspace
vnoremap <BS> "_d

" Close : Ctrl + w
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


"""""""""""""""""""""""""" Modern Editing shortcuts end """"""""""""""""""""""

" Close all the other buffer : Alt + x
nnoremap <A-x> :BDelete hidden<cr>
inoremap <A-x> <C-o>:BDelete hidden<cr>

" Format the code : Ctrl + a + l
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


" 注意，映射的命令后必须要有空格，不然后面的全部不生效

" Multi-line editting mode : Ctrl + m
noremap <C-M> <C-V>

" For Lsp restart case.
nnoremap <Space>rs :LspRestart clangd<CR>


"""""""""""""""""""""""""" Visual line jk """"""""""""""""""""""""""""

" Use 'j' and 'k' to move up and down, 
" and use 'gj' and 'gk' to move up and down by line.
" Move down with 'j' or <Down>, using 'gj' in non-numeric modes
nnoremap <expr> j v:count == 0 && mode(1)[0:1] != 'no' ? 'gj' : 'j'
nnoremap <expr> <Down> v:count == 0 && mode(1)[0:1] != 'no' ? 'gj' : 'j'

" Move up with 'k' or <Up>, using 'gk' in non-numeric modes
nnoremap <expr> k v:count == 0 && mode(1)[0:1] != 'no' ? 'gk' : 'k'
nnoremap <expr> <Up> v:count == 0 && mode(1)[0:1] != 'no' ? 'gk' : 'k'

""""""""""""""""""""""" Visual line jk end """""""""""""""""""""""""""

