set autoread
au FocusGained,BufEnter * :checktime
" 当失去焦点或者离开当前的 buffer 的时候保存
set autowrite
autocmd FocusLost,BufLeave * silent! update

" 在 terminal 中也是使用 esc 来进入 normal 模式
tnoremap  <Esc>  <C-\><C-n>
" 映射 leader 键为 ,
let g:mapleader = ','
" 将 q 映射为 <leader>q，因为录制宏的操作比较少，而关掉窗口的操作非常频繁
noremap <leader>q q

" 访问系统剪切板
map <leader>y "+y
map <leader>p "+p
map <leader>d "+d

" 让远程的 server 内容拷贝到系统剪切板中，具体参考 https://github.com/ojroques/vim-oscyank
autocmd TextYankPost *
    \ if v:event.operator is 'y' && v:event.regname is '+' |
    \ execute 'OSCYankRegister +' |
    \ endif

autocmd TextYankPost *
    \ if v:event.operator is 'd' && v:event.regname is '+' |
    \ execute 'OSCYankRegister +' |
    \ endif

" 使用 z a 打开和关闭 fold，打开大文件（超过 13万行)的时候可能造成性能问题
" set foldlevelstart=102
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()

" floaterm 永远的神
let g:floaterm_width = 0.90
let g:floaterm_height = 0.90
let g:floaterm_keymap_prev = '<C-k>'
let g:floaterm_keymap_new = '<C-j>'
let g:floaterm_keymap_toggle = '<C-t>'
inoremap <C-t> <Esc>:FloatermToggle<cr>

" 加载 lua 配置
lua require 'usr'

" 加载 vim 配置, 参考 https://github.com/jdhao/nvim-config
let s:core_conf_files = [
      \ 'misc.vim',
      \ 'debug.vim',
      \ 'wilder.vim',
      \ ]

for s:fname in s:core_conf_files
  execute printf('source %s/vim/%s', stdpath('config'), s:fname)
endfor

let g:loaded_perl_provider = 3

" this keymapping originally set by whichkey doesn't work in neovim 3.8
noremap <Space>bc :BDelete hidden<cr>

let g:gitblame_delay = 0
"let g:gitblame_ignored_filetypes = ['lua', 'markdown', 'sh']

" 因为 nvim-treesitter-textobjects 使用 x 来跳转，原始的 x 被映射为 xx
nn xx x


"autocmd VimEnter * NvimTreeOpen
" set tab = 5 space.
"
" Clipboard Related Setting
if executable('clipboard-provider')
  let g:clipboard = {
          \ 'name': 'myClipboard',
          \     'copy': {
          \         '+': 'clipboard-provider copy',
          \         '*': 'clipboard-provider copy',
          \     },
          \     'paste': {
          \         '+': 'clipboard-provider paste',
          \         '*': 'clipboard-provider paste',
          \     },
          \ }
endif

" tab 设置
set tabstop=2
set shiftwidth=2
" Shift tab to space.
set expandtab
" use alter + left/right to switch buffer.
noremap<M-Left> :bp<CR>
noremap<M-Right> :bn<CR>
" use esc to enable nohilight.
noremap<Esc> :noh<CR>
" 复制设置
nnoremap <C-c> "+y
vnoremap <C-c> "+y
" 保存文件
noremap <C-s> :wall<CR>
inoremap <C-s> <C-o>:wall<CR>
" 全选文件
nnoremap <C-a> ggVG
inoremap <C-a> <Esc> ggVG
" 剪切文件
nnoremap <C-x> "+x
vnoremap <C-x> "+x
inoremap <C-x> <C-o>dd
" 复制当前行/选中内容
nnoremap <C-d> yyp
vnoremap <C-d> y<Esc>o<C-R>"<CR>
inoremap <C-d> <Esc>:normal! yy<CR>p`[A
" 重新加载配置文件
noremap <F5> :source $MYVIMRC<CR>
inoremap <F5> <C-O>:source $MYVIMRC<CR>
" ctrl z 映射为撤销，插入模式下也生效
inoremap <C-z> <C-O>u
noremap <C-z> <C-O>u
" 关闭当前缓冲区
nnoremap <C-w> :w<CR>:bd<CR>
inoremap <C-w> <Esc>:w<CR>:bd<CR>
" ctrl r 在插入模式下，redo 也生效
inoremap <C-r> <C-o><C-r>
nnoremap <A-x> :BDelete hidden<cr>
inoremap <A-x> <C-o>:BDelete hidden<cr>
inoremap <C-A-l> <C-o>:lua vim.lsp.buf.format{ async = true }<CR>
" shift 选中内容
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
" 删除一行
nnoremap <C-l> dd
inoremap <C-l> <Esc>:normal! dd<CR>i
" 删除
vnoremap <BS> "_d

" Alt+Right 跳到下一个单词
inoremap <A-Right> <C-\><C-O>e<C-\><C-O>a
" Alt+Left 跳到上一个单词
inoremap <A-Left> <Esc>bi
" 注意，映射的命令后必须要有空格，不然后面的全部不生效
