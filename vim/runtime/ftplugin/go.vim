SetUndoFtplugin setlocal expandtab< smarttab<
setlocal noexpandtab nosmarttab

SetUndoFtplugin delcommand EditTest
command! -buffer -bar EditTest
      \ if expand('%')
      \|   echohl Error
      \|   echo 'Current buffer has no file name.'
      \|   echohl NONE
      \| else
      \|   edit %:p:r_test.go
      \| endif
