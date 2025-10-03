if exists('b:current_syntax')
  finish
endif

runtime! syntax/tex.vim

syntax keyword otexOttExpressions placeholder
syntax clear otexOttExpressions
syntax region otexCodeBlock keepend containedin=@texSectionGroup,@texSubSectionGroup,@texSubSubSectionGroup,@texMathZones,@texStyleGroup,@texMatchGroup,texCmdBody contains=@otexOttExpressions matchgroup=otexCodeBlockDelimiter start=/\[\[/ end=/]]/
syntax region otexComment keepend containedin=texComment start=/\[\[/ end=/]]/

highlight default link otexCodeBlock Normal
highlight default link otexCodeBlockDelimiter Delimiter
highlight default link otexComment Comment

if has('nvim')
  function s:findfile(filename) abort
    let files = v:lua.vim.fs.find([a:filename], #{
      \ type: 'file',
      \ path: expand('%:p:h'),
      \ upward: v:true,
      \ })
    if !empty(files)
      return files[0]
    endif
    return ''
  endfunction
else
  function s:findfile(filename) abort
    return vimrc#Findfile(a:filename, '.;')
  endfunction
endif

if expand('%') !=# ''
  let s:script = s:findfile('syntax.vim')
  if isdirectory(s:script->fnamemodify(':h') .. '/.git')
    source `=s:script`
  endif
  unlet! s:script
endif

let b:current_syntax = 'otex'
