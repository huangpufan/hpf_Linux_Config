" Utility functions

" Redirect command output to buffer
" https://gist.github.com/romainl/eae0a260ab9c135390c30cd370c20cd7
function! Redir(cmd, rng, start, end)
  for win in range(1, winnr('$'))
    if getwinvar(win, 'scratch')
      execute win . 'windo close'
    endif
  endfor
  if a:cmd =~ '^!'
    let cmd = a:cmd =~' %'
      \ ? matchstr(substitute(a:cmd, ' %', ' ' . expand('%:p'), ''), '^!\zs.*')
      \ : matchstr(a:cmd, '^!\zs.*')
    if a:rng == 0
      let output = systemlist(cmd)
    else
      let joined_lines = join(getline(a:start, a:end), '\n')
      let cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''", "\\\\'", 'g')
      let output = systemlist(cmd . " <<< $" . cleaned_lines)
    endif
  else
    redir => output
    execute a:cmd
    redir END
    let output = split(output, "\n")
  endif
  vnew
  let w:scratch = 1
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  call setline(1, output)
endfunction

command! -nargs=1 -complete=command -bar -range Redir silent call Redir(<q-args>, <range>, <line1>, <line2>)

" Trim trailing whitespace and convert tabs to spaces
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
    retab
endfun
command! TrimWhitespace call TrimWhitespace()

" Get current file path
fun! GetFilePath()
  exec "Redir echo expand('%:p')"
endfun
command! GetFilePath call GetFilePath()

" Zoxide integration
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

nnoremap <silent> <space>z :call ZoxideQuery()<CR>

" Macros
let @j = 'ysiw`' " Surround word with backticks
let @k = 'ysiw"' " Surround word with quotes

