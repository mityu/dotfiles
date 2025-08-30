if exists('b:current_syntax')
  finish
endif

runtime! syntax/tex.vim

syntax keyword otexOttExpressions placeholder
syntax clear otexOttExpressions
syntax region otexCodeBlock keepend containedin=@texSectionGroup,@texSubSectionGroup,@texSubSubSectionGroup,@texMathZones,@texStyleGroup,@texMatchGroup contains=@otexOttExpressions matchgroup=otexCodeBlockDelimiter start=/\[\[/ end=/]]/
syntax region otexComment keepend containedin=texComment start=/\[\[/ end=/]]/

highlight default link otexCodeBlock Normal
highlight default link otexCodeBlockDelimiter Delimiter
highlight default link otexComment Comment

if expand('%') !=# '' && expand('%:p') =~# 'dev[/\\]tex'
  let s:script = vimrc#Findfile('syntax.vim', '.;')
  if s:script->fnamemodify(':h:h') =~# 'dev[/\\]tex$'
    source `=s:script`
  endif
  unlet! s:script
endif

let b:current_syntax = 'otex'
