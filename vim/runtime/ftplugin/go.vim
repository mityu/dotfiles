execute 'SetUndoFtplugin let &l:expandtab=' . &l:expandtab
execute 'SetUndoFtplugin let &l:smarttab=' . &l:smarttab
SetUndoFtplugin delcommand EditTest
setlocal noexpandtab nosmarttab
command! -buffer -bar EditTest
      \ if expand('%')
      \|   echohl Error
      \|   echo 'Current buffer has no file name.'
      \|   echohl NONE
      \| else
      \|   edit %:p:r_test.go
      \| endif
