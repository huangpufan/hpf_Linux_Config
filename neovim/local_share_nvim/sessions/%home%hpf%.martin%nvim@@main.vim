let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/.martin/nvim
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +118 ~/.martin/nvim/lua/usr/lazy.lua
badd +1 ~/.martin/nvim/lua/usr/alpha.lua
badd +1 ~/.martin/nvim/lua/usr/bufferline.lua
badd +67 ~/.martin/nvim/lua/usr/cmp.lua
badd +1 ~/.martin/nvim/lua/usr/code_runner.lua
badd +1 ~/.martin/nvim/lua/usr/colorscheme.lua
badd +20 ~/.martin/nvim/lua/usr/hydra.lua
badd +1 ~/.martin/nvim/lua/usr/orgmode.lua
badd +1 ~/.martin/nvim/efm.yaml
badd +23 ~/.martin/nvim/vim/debug.vim
badd +26 ~/.martin/nvim/vim/misc.vim
badd +18 ~/.martin/nvim/lua/usr/lsp/settings/ccls.lua
badd +1 ~/.martin/nvim/lua/usr/lsp/settings/efm.lua
badd +197 ~/.martin/nvim/lua/usr/lsp/settings/jsonls.lua
badd +12 ~/.martin/nvim/lua/usr/lsp/settings/lua_ls.lua
badd +1 ~/.martin/nvim/lua/usr/lsp/settings/pyright.lua
badd +34 ~/.martin/nvim/lua/usr/lsp/handlers.lua
badd +1 ~/.martin/nvim/lua/usr/lsp/init.lua
badd +16 ~/.martin/nvim/lua/usr/lsp/mason.lua
badd +10 ~/.martin/nvim/lua/usr/lsp/null-ls.lua
badd +98 ~/.martin/nvim/lua/usr/which-key.lua
argglobal
%argdel
edit ~/.martin/nvim/lua/usr/which-key.lua
argglobal
balt ~/.martin/nvim/lua/usr/cmp.lua
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 98 - ((25 * winheight(0) + 21) / 42)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 98
normal! 05|
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
