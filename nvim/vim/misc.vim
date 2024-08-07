
"""""""""""""""""""""""" Markdown Preview Setting""""""""""""""""""""""
" 在 markdown 中间编辑 table
let g:table_mode_corner='|'

" 默认 markdown preview 在切换到其他的 buffer 或者 vim
" 失去焦点的时候会自动关闭 preview
let g:mkdp_auto_close = 0
""""""""""""""""""""""" Markdown Preview End """"""""""""""""""""""""""

let g:which_key_disable_health_check = 1

" 书签选中之后自动关闭 quickfix window
let g:bookmark_auto_close = 1

" 让光标自动进入到 popup window 中间
let g:git_messenger_always_into_popup = v:true

let g:vista_sidebar_position = "vertical topleft"
let g:vista_default_executive = 'nvim_lsp'
" let g:vista_finder_alternative_executives = 'ctags'

let g:git_messenger_no_default_mappings = 1

" 使用 gx 在 vim 中间直接打开链接
let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)

let g:bookmark_save_per_working_dir = 1
let g:bookmark_no_default_key_mappings = 1

"""""""""""""""" Clipboard Related Setting """"""""""""""""""""""""""""
" Config 1 
" Work with clipboard-provider
"
"
" if executable('clipboard-provider')
"   let g:clipboard = {
"           \ 'name': 'myClipboard',
"           \     'copy': {
"           \         '+': 'clipboard-provider copy',
"           \         '*': 'clipboard-provider copy',
"           \     },
"           \     'paste': {
"           \         '+': 'clipboard-provider paste',
"           \         '*': 'clipboard-provider paste',
"           \     },
"           \ }
" endif


"Config 2
"Work with Osc52.nvim
"
autocmd TextYankPost *
    \ if v:event.operator is 'y' && v:event.regname is '+' |
    \ execute 'OSCYankRegister +' |
    \ endif

autocmd TextYankPost *
    \ if v:event.operator is 'd' && v:event.regname is '+' |
    \ execute 'OSCYankRegister +' |
    \ endif
" 让远程的 server 内容拷贝到系统剪切板中，具体参考 https://github.com/ojroques/vim-oscyank


""""""""""""""""""""""""""  buffer set """"""""""""""""""""""""""""""""""
" To ban the completion when the line is empty or no content before the cursor.misc
augroup DisableCompletionOnEmptyLine
  autocmd!
  autocmd FileType * if getline('.') =~# '^\s*$' | setlocal complete-=k | endif
augroup END

hi BufferLineBufferSelected guifg=white guibg=none gui=bold,underline

" 在 VimEnter 事件后检查并关闭名为 NvimTree_1 的空 buffer
" autocmd VimEnter * if bufexists("NvimTree_1") | bdelete NvimTree_1 | endif


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

" zoxide setting
nnoremap <silent> <space>z :call ZoxideQuery()<CR>

" nvim tree setting.
let g:nvim_tree_auto_refresh = 1




" Use ESC to enter normal mode in terminal.
" tnoremap  <Esc>  <C-\><C-n>

" Lazygit exit settings.
" 定义一个新的命令来启动 lazygit 在 floaterm 中
command! LazyGit FloatermNew --height=0.9 --width=0.9 lazygit

" 设置自动命令，在退出 lazygit 时关闭 floaterm
autocmd! TermClose term://*lazygit* FloatermKill

" " set 'enter' as i in floaterm mode.
autocmd FileType floaterm vnoremap <buffer> <Enter> :normal! i<Enter><CR>
" autocmd FileType floaterm nnoremap <buffer> <Enter> i<CR>

autocmd TermOpen * nnoremap <buffer> <Enter> a
autocmd TermOpen * vnoremap <buffer> <Enter> a


" 绑定 g= 快捷键到 LazyGit 命令
nnoremap g= :LazyGit<CR>
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" Map C-d as Esc in terminal mode
tnoremap <C-d> <C-\><C-n>





""""""""""""""""""""""""""  ToggleTerm """"""""""""""""""""""""""
function! ToggleTermWithNvimTree()
  NvimTreeClose

  let height = float2nr(winheight(0) * 0.32)

  " 打开或关闭 ToggleTerm
  execute 'ToggleTerm size=' . height . ' direction=horizontal'
  " 可能需要稍微延迟打开 NvimTree，以确保它在 ToggleTerm 之后显示
  " 使用 100 毫秒的延迟，根据需要调整
  execute 'sleep 1m | NvimTreeOpen'
  let term_win_id = win_getid(winnr('#'))
  call win_gotoid(term_win_id)
endfunction

" 打开位于布局下侧的 ToggleTerm ：Press -
nnoremap - :call ToggleTermWithNvimTree()<CR>

" 打开位于布局右侧的 ToggleTerm ：Press =
nnoremap = :let width=float2nr(winwidth(0) * 0.5) \| execute 'ToggleTerm size=' . width . ' direction=vertical'<CR>

" Fix toggle term related bug: Ensure cursor to be normal mode.
" 定义一个全局变量来确保 EnsureNormalMode 只在启动时执行一次
" let g:has_ensured_normal_mode = 0
"
" function! EnsureNormalMode(timer)
"   " 检查是否已经执行过此函数
"   if g:has_ensured_normal_mode
"     return
"   endif
"   " 如果当前处于插入模式，则停止插入模式
"   if mode() == 'i'
"     stopinsert
"   endif
"   " 设置变量以避免再次执行此函数
"   let g:has_ensured_normal_mode = 1
" endfunction

" 使用 VimEnter 事件设置定时器，仅在 Neovim 启动时调用 EnsureNormalMode 函数
" autocmd VimEnter * if g:has_ensured_normal_mode == 0 | call timer_start(30, 'EnsureNormalMode') | endif

"""""""""""""""""""""""" ToggleTerm End """"""""""""""""""""""""""

