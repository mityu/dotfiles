SetUndoFtplugin delcommand HelpEdit | delcommand HelpView | set spell<
SetUndoFtplugin nunmap <buffer> <C-n>
SetUndoFtplugin nunmap <buffer> <C-p>

if &modifiable
  setlocal spell
endif

" Thanks to thinca!
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
  setlocal buftype= modifiable noreadonly noexpandtab nosmarttab
  setlocal list textwidth=78 shiftwidth=8 tabstop=8 softtabstop=0
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
  " Do not resize if
  " - window is too wide.
  " - there're already two or more help windows.
  " - the previous buffer of this window is also a help window.
  if &l:textwidth * 2 > winwidth(0) ||
    \ tabpagebuflist()->filter('getbufvar(v:val, "&buftype") ==# "help"')->len() > 1 ||
    \ getbufvar('#', '&buftype') ==# 'help'
    return
  endif

  wincmd L
  execute $'vertical resize {&l:textwidth + 5}'
endfunction

if &buftype ==# 'help'
  SetUndoFtplugin nunmap <buffer> <C-\>
  SetUndoFtplugin nunmap <buffer> q
  nnoremap <buffer> <silent> q :<C-u>quit<CR>
  nnoremap <buffer> <C-\> <C-]>

  call s:resize()
  augroup vimrc-ftplugin-help
      autocmd! BufWinEnter <buffer>
      autocmd BufWinEnter <buffer> call s:resize()
  augroup END
else
  " While editing only

  " SetUndoFtplugin silent! nunmap <C-]>
  SetUndoFtplugin setlocal buftype< tabstop< textwidth<
  SetUndoFtplugin setlocal conceallevel< expandtab< softtabstop<
  SetUndoFtplugin delcommand GenerateContents
  SetUndoFtplugin delcommand TOC

  command! -buffer -bar GenerateContents call s:generate_contents()
  command! -buffer -bar TOC call s:generate_contents()
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
      keeppatterns /^License:\|Maintainer:\|Author:/+1
      let caption = ja ? "目次" : 'CONTENTS'
      let tag = printf('*%s-contents*', plug_name)
      let tag_column = &l:textwidth - strdisplaywidth(tag)
      let tabcount = tag_column / &l:tabstop - strdisplaywidth(caption) / &l:tabstop
      let header = caption . repeat("\t", tabcount) . tag
      silent put =[repeat('=', &l:textwidth), header, '']
    endif

    let contents_pos = getpos('.')

    let captions = []
    while search('^\([=-]\)\1\{77}$', 'W')
      let prefix = getline('.') =~# '=' ? '' : '  '
      .+1
      let caption = matchlist(getline('.'), '^\(\%(\u\|-\| \)*\)\s\+\*\(\S*\)\*$')
      if !empty(caption)
        let caption = caption[1 : 2]
        let caption[0] = prefix . caption[0]
        call add(captions, caption)
      endif
    endwhile

    let max_tag_length = captions
          \->mapnew('strdisplaywidth(v:val[1])')
          \->max()
    let tag_column = &l:textwidth - max_tag_length
    let tag_column -= tag_column % &l:tabstop
    let lines = []
    for [title, tag] in captions
      let title_len = strdisplaywidth(title)
      if &l:expandtab
        let margin = repeat(' ', tag_column - title_len)
      else
        let charcount = tag_column / &l:tabstop - title_len / &l:tabstop
        let margin = repeat("\t", charcount)
      endif
      call add(lines, printf('%s%s|%s|', title, margin, tag))
    endfor

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

if !exists('*s:search_link')
  function s:search_link_skip() abort
    const syngroup = synID(line('.'), col('.'), 1)->synIDattr('name')
    return syngroup !~# '\v^%(helpOption|helpHyperTextJump)$'
  endfunction

  function s:search_link(go_up) abort
    const flags = 'W' .. (a:go_up ? 'b' : '')
    call search('[''|]\zs.', flags, 0, 0, function('s:search_link_skip'))
  endfunction
endif

nnoremap <buffer> <C-p> <Cmd>call <SID>search_link(1)<CR>
nnoremap <buffer> <C-n> <Cmd>call <SID>search_link(0)<CR>
