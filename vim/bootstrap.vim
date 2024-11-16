const s:parentdir = expand('<sfile>:p')->resolve()->fnamemodify(':h')
execute $'source {s:parentdir->fnameescape()}/vimrc'
unlet s:parentdir
