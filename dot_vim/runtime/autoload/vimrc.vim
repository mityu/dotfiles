let s:cpoptions_save = &cpoptions
set cpoptions&vim

function! vimrc#delete_undofiles() abort "{{{
  let undodir_save = &undodir
  try
    noautocmd set undodir-=.
    let undofiles = globpath(&undodir, '*', v:true, v:true)
  finally
    noautocmd let &undodir = undodir_save
  endtry
  " Remove unreadable undofiles.
  call filter(undofiles, 'filereadable(v:val)')

  " Get file names from undofiles' name.
  let slash = VimrcGetVar('filesystem').slash
  call map(undofiles, 'tr(fnamemodify(v:val, ":t"), "%", slash)')

  " List undofiles whose files haven't already existed.
  call filter(undofiles, '!filereadable(v:val)')
  if empty(undofiles)
    call VimrcCall('echomsg', 'All undofiles are used. It''s already clean.')
    return
  endif

  echo join(undofiles, "\n")
  if !VimrcCall('ask', 'Delete the above unused undofiles?')
    call VimrcCall('echomsg', 'Canceled.')
    return
  endif

  for file in undofiles
    call delete(file)
  endfor
  call VimrcCall('echomsg', 'Deleted.')
endfunction "}}}

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
