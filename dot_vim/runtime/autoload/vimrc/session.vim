let s:cpoptions_save = &cpoptions
set cpoptions&vim

let s:session_dir = VimrcFunc('VimrcVar')('SessionDir')
function! vimrc#session#make() abort "{{{
  let name = VimrcFunc('Input')('Session name >> ')
  if name ==# ''
    call VimrcFunc('Echo')('Canceled.')
    return
  endif
  let file = vimrc#session#get_file(name)
  if filereadable(file)
    call VimrcFunc('Echomsg')('Session already exists: ' . name)
    if !VimrcFunc('Ask')('Overwrite?')
      call VimrcFunc('Echo')('Canceled.')
      return
    endif
  endif
  silent mksession! `=file`
endfunction "}}}
function! vimrc#session#delete(need_ask, ...) abort "{{{
  if a:need_ask
    call VimrcFunc('Echo')(join(a:000, "\n") . "\n")
    if !VimrcFunc('ask')('Delete these sessions?')
      call VimrcFunc('Echo')('Canceled.')
      return
    endif
  endif

  let sessions = map(copy(a:000), 'vimrc#session#get_file(v:val)')
  for session in sessions
    if !filereadable(session)
      call VimrcFunc('EchomsgError')('Session file does not exist: ' . session)
      continue
    endif
    call delete(session)
  endfor
endfunction "}}}
function! vimrc#session#list() abort "{{{
  return map(
        \ VimrcFunc('glob')(VimrcFunc('JoinPath')(s:session_dir, '*.vim')),
        \ 'fnamemodify(v:val, ":t:r")')
endfunction "}}}
function! vimrc#session#restore(session) abort "{{{
  silent source `=vimrc#session#get_file(a:session)`
  call vimrc#session#delete(a:session)
endfunction "}}}
function! vimrc#session#get_file(session) abort "{{{
  return VimrcFunc('JoinPath')(s:session_dir, a:session . ".vim")
endfunction "}}}
function! vimrc#session#complete(A, L, P) abort "{{{
  return join(vimrc#session#list(), "\n")
endfunction "}}}

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
