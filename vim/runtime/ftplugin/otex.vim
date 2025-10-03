SetUndoFtplugin unlet b:caw_oneline_comment
SetUndoFtplugin set conceallevel<

runtime! ftplugin/tex.vim
if has('nvim')
  source <sfile>:h/tex.vim
endif
let b:caw_oneline_comment = '%'
setlocal conceallevel=1
