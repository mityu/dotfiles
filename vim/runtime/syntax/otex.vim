if exists('b:current_syntax')
  finish
endif

runtime! syntax/tex.vim

if expand('%') !=# '' && expand('%:p') =~# 'dev[/\\]tex'
  let s:script = vimrc#Findfile('syntax.vim', '.;')
  if s:script->fnamemodify(':h:h') =~# 'dev[/\\]tex$'
    source `=s:script`
  endif
  unlet! s:script
endif

let b:current_syntax = 'otex'
