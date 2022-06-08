scriptencoding utf-8
" if exists('b:did_ftplugin_after')
"   finish
" endif
" let b:did_ftplugin_after = 1

SetUndoFtplugin delcommand HelpEdit | delcommand HelpView | set spell<
SetUndoFtplugin nunmap <buffer> <C-n>
SetUndoFtplugin nunmap <buffer> <C-p>

if &modifiable
  setlocal spell
endif

" Thanks to thinca!
" Global
function! s:option_to_view()
  setlocal buftype=help nomodifiable readonly
  setlocal nolist
  if exists('+colorcolumn')
    setlocal colorcolumn=
  endif
  if has('conceal')
    setlocal conceallevel=2
  endif
endfunction

function! s:option_to_edit()
  setlocal buftype= modifiable noreadonly
  setlocal list textwidth=78
  if exists('+colorcolumn')
    setlocal colorcolumn=+1
  endif
  if has('conceal')
    setlocal conceallevel=0
  endif
endfunction

command! -buffer -bar HelpEdit call s:option_to_edit()
command! -buffer -bar HelpView call s:option_to_view()

function! s:resize()
  " Resize only when window isn't splited vertically and there's one help
  " window.
  if (&l:textwidth * 2) <= winwidth(0) &&
        \ len(filter(range(1,winnr('$')),
        \ 'getwinvar(v:val,"&buftype")==#"help"')) == 1
    wincmd L
    execute 'vertical resize' (&l:textwidth+5)
  endif
endfunction

if &buftype ==# 'help'
  nnoremap <buffer> <silent> q :<C-u>quit<CR>

  call s:resize()
  augroup vimrc_ftplugin_vim
      autocmd! BufWinEnter <buffer>
      autocmd BufWinEnter <buffer> call s:resize()
  augroup END
else
  " While editing only

  " SetUndoFtplugin silent! nunmap <C-]>
  SetUndoFtplugin setlocal buftype< tabstop< textwidth<
  SetUndoFtplugin setlocal conceallevel< expandtab< softtabstop<
  SetUndoFtplugin delcommand GenerateContents

  command! -buffer -bar GenerateContents call s:generate_contents()
  function! s:generate_contents()
    let cursor = getpos('.')

    let file_name = matchstr(expand('%:p:r:gs?\\?/?'), '.*/doc/\zs.*')
    let plug_name = substitute(file_name, '/', '-', 'g')
    let ja = expand('%:e') ==? 'jax'
    1

    if search('-contents\*$', 'W')
      silent .+1;/^=\{78}$/-1 delete _
      .-1
      put =''
    else
      keeppatterns /^License:\|Maintainer:/+1
      let header = printf('%s%s*%s-contents*', (ja ? "目次" : 'CONTENTS'),
      \             repeat(' ', 50), plug_name)
      silent put =[repeat('=', 78), header, '']
    endif

    let contents_pos = getpos('.')

    let lines = []
    while search('^\([=-]\)\1\{77}$', 'W')
      let prefix = getline('.') =~# '=' ? '' : '  '
      .+1
      let caption = matchlist(getline('.'), '^\(\%(\u\|-\)*\)\s\+\*\(\S*\)\*$')
      if !empty(caption)
        let [title, tag] = caption[1 : 2]
        let margin = repeat(' ', 30 - strlen(prefix . title))
        call add(lines, printf('%s%s%s|%s|', prefix, title, margin, tag))
      endif
    endwhile

    call setpos('.', contents_pos)

    silent put =lines + repeat([''], 2)

    call setpos('.', cursor)
  endfunction

  function! s:get_text_on_cursor(pat)
    let line = getline('.')
    let pos = col('.')
    let s = 0
    while s < pos
      let [s, e] = [match(line, a:pat, s), matchend(line, a:pat, s)]
      if s < 0
        break
      elseif s < pos && pos <= e
        return line[s : e - 1]
      endif
      let s += 1
    endwhile
    return ''
  endfunction
endif

if !exists('*' .. expand('<SID>') .. 'search_link')
  function s:search_link(go_up) abort
    let l:SearchSkip = {->
          \ synID(line('.'), col('.'), 1)->synIDattr('name') !~#
          \ '\v^%(helpOption|helpHyperTextJump)$'}

    let flags = 'W'
    if a:go_up
      let flags ..= 'b'
    endif
    call search('[''|]\zs.', flags, 0, 0, l:SearchSkip)
  endfunction
endif

nnoremap <buffer> <C-p> <Cmd>call <SID>search_link(1)<CR>
nnoremap <buffer> <C-n> <Cmd>call <SID>search_link(0)<CR>
