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

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
