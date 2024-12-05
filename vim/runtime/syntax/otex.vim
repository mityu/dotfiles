if exists('b:current_syntax')
  finish
endif

runtime! syntax/tex.vim

if expand('%') !=# '' && expand('%:p') =~# 'dev[/\\]tex'
  let s:script = findfile('syntax.vim', '.;')->fnamemodify(':p')
  if s:script->fnamemodify(':h:h') =~# 'dev[/\\]tex$'
    source `=s:script`
  endif
endif

let b:current_syntax = 'otex'
