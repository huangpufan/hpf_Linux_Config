" 在 markdown 中间编辑 table
let g:table_mode_corner='|'

" 默认 markdown preview 在切换到其他的 buffer 或者 vim
" 失去焦点的时候会自动关闭 preview
let g:mkdp_auto_close = 0
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


" 自动关闭 vim 如果 window 中只有一个 filetree
" https://github.com/kyazdani42/nvim-tree.lua
autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif

" 定义预先录制的 macro
let @j = 'ysiw`\<Esc>' " 在一个 word 两侧添加上 `，例如将 abc 变为 `abc`
let @k = 'ysiw"\<Esc>'



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
"

""""""""""""""""""""""""""  flash.nvim """"""""""""""""""""""""""""""""""
highlight FlashMatch guibg=#4870d9 guifg=#ffffff 
highlight FlashCurrent guibg=#ff966c guifg=#ffffff 
" highlight FlashBackdrop guibg=#333333 guifg=#d1dddd 
highlight FlashLabel  guibg=#ff966c guifg=#ffffff 
highlight FlashCursor guibg=#ca3311 guifg=#ffffff
" highlight FlashCursor guibg=#ff446c guifg=#ffffff


" 热情的红色: #FF2D55 (红-粉色调)
" 明亮的橙色: #FF9500 (鲜橙色)
" 鲜黄色: #FFCC00 (柠檬黄)
" 酸橙色: #7CFC00 (草坪绿)
" 亮绿色: #4CD964 (绿色)
" 鲜蓝色: #007AFF (亮蓝色)
" 深天蓝色: #5856D6 (深蓝色)
" 紫罗兰色: #AF52DE (中紫色)
" 粉红色: #FF2D95 (亮粉色)
" 水蓝色: #34AADC (天蓝色)

""""""""""""""""""""""""""  buffer set """"""""""""""""""""""""""""""""""
" To ban the completion when the line is empty or no content before the cursor.misc
augroup DisableCompletionOnEmptyLine
  autocmd!
  autocmd FileType * if getline('.') =~# '^\s*$' | setlocal complete-=k | endif
augroup END

hi BufferLineBufferSelected guifg=white guibg=none gui=bold,underline

" 在 VimEnter 事件后检查并关闭名为 NvimTree_1 的空 buffer
autocmd VimEnter * if bufexists("NvimTree_1") | bdelete NvimTree_1 | endif

" function! CloseBuffersOnStart()
"   " 获取所有 buffer 的列表
"   redir => l:bufferlist
"   silent! ls
"   redir END
"
"   " 逐行处理 buffer 列表
"   for l:line in split(l:bufferlist, '\n')
"     " 匹配 buffer 名称前缀为 'hpf/' 或者精确匹配 'NvimTree_1' 的 buffer
"     if l:line =~ 'hpf*' || l:line =~ 'NvimTree_1'
"       " 提取 buffer 编号
"       let l:matched = matchlist(l:line, '^\s*\zs\d\+')
"       if !empty(l:matched)
"         " 删除对应 buffer
"         execute 'bdelete' l:matched[0]
"       endif
"     endif
"   endfor
" endfunction
"
" " 启动 nvim 时，调用 CloseBuffersOnStart 函数
" autocmd VimEnter * call CloseBuffersOnStart()



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

" set 'enter' as i in floaterm mode.
autocmd FileType floaterm vnoremap <buffer> <Enter> :normal! i<Enter><CR>
autocmd FileType floaterm nnoremap <buffer> <Enter> i<CR>



" 绑定 g= 快捷键到 LazyGit 命令
nnoremap g= :LazyGit<CR>
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>
