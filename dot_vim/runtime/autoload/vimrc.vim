let s:cpoptions_save = &cpoptions
set cpoptions&vim

function! vimrc#delete_undofiles() abort "{{{
  let Echomsg = VimrcFunc('echomsg')
  let undodir_save = &undodir
  try
    noautocmd set undodir-=.
    let undofiles = globpath(&undodir, '*', v:true, v:true)
  finally
    noautocmd let &undodir = undodir_save
  endtry

  " Remove unreadable undofiles.
  call filter(undofiles, 'filereadable(v:val)')

  " List undofiles whose files haven't already existed.
  let slash = VimrcFunc('vars')().filesystem.slash
  call filter(undofiles,
        \ '!filereadable(tr(fnamemodify(v:val, ":t"), "%", slash))')

  if empty(undofiles)
    call Echomsg('All undofiles are used. It''s already clean.')
    return
  endif

  echo join(undofiles, "\n") . "\n"
  if !VimrcFunc('ask')('Delete the above unused undofiles?')
    call Echomsg('Canceled.')
    return
  endif

  for file in undofiles
    if delete(file)
      call Echomsg('Failed to delete: ' . file)
    endif
  endfor
  call Echomsg('Deleted.')
endfunction "}}}
" Path completion{{{
let s:path_complete = {
      \ 'target_path': '',
      \ 'completions': [],
      \ 'slash': VimrcFunc('vars')().filesystem.slash,
      \ 'non_escaped_space': '\v%(%(\_^|[^\\])%(\\\\)*)@<=\s',
      \ }
function! vimrc#path_complete(findstart, base) abort "{{{
  if a:findstart
    let line = getline('.')[: col('.') - 1]
    if line ==# ''
      let s:path_complete.target_path = ''
    else
      let s:path_complete.target_path = split(line,
            \ s:path_complete.non_escaped_space)[-1]
    endif
    let completions = VimrcFunc('glob')(s:path_complete.target_path . '*')
    let dirs = []
    let files = []
    for path in completions
      let completion = fnamemodify(path, ':t')
      if filereadable(path)
        call add(files, completion)
      else
        call add(dirs, completion . s:path_complete.slash)
      endif
    endfor
    call sort(dirs)
    call sort(files)
    let s:path_complete.completions = dirs + files

    return col('.') - strlen(fnamemodify(s:path_complete.target_path, ':t')) - 1
  endif

  return s:path_complete.completions
endfunction "}}}
 "}}}

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
