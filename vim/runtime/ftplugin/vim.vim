vim9script

SetUndoFtplugin setlocal shiftwidth<
SetUndoFtplugin setlocal foldexpr< foldmethod<
# The below is already set by textobj-function
# SetUndoFtplugin unlet! b:textobj_function_select
setlocal shiftwidth=2
# setlocal foldmethod=expr
# setlocal foldexpr=<SID>FoldExpr()
setbufvar('%', 'textobj_function_select', function('vimrc#textobj_vim#Select'))
setlocal foldmethod=indent

def FoldIsBlockOpen(line: string): bool
  if line =~# '\v^<%(%(export\s+|legacy\s+|static\s+)?%(fu%[nction]|def|class)|if|for|while|try)>' ||
     line =~# '\v^augroup\s+%(<\cEND>)@!' ||
     line =~# '\V' .. split(&l:foldmarker, ',')[0] .. '\d\*\s\*\$'
    return true
  endif
  return false
enddef

def FoldIsBlockClose(line: string): bool
  if line =~# '\v^<end%(f%[unction]|def|class|fo%[r]|w%[hile]|t%[ry])>' ||
     line =~# '^\<en\%[dif]\>' ||
     line =~# '\v^augroup\s+<\cEND>' ||
     line =~# '\V' .. split(&l:foldmarker, ',')[1] .. '\d\*\s\*\$'
    return true
  endif
  return false
enddef

def FoldExpr(): any
  if v:lnum == 1
    return 0
  elseif FoldIsBlockOpen(getline(v:lnum - 1)->trim())
    if FoldIsBlockClose(getline(v:lnum + 1)->trim()) || FoldIsBlockClose(getline(v:lnum)->trim())
      return '='
    else
      return 'a1'
    endif
  elseif FoldIsBlockClose(getline(v:lnum + 1)->trim())
    return 's1'
  else
    return '='
  endif
enddef

def AbbrevDirectiveFunction(trigger: string): string
  const word = getline('.')->strpart(0, col('.') - 1)
  if word =~# '^\s*fu\%[nctio]$'
    return 'function'
  else
    return trigger
  endif
enddef

# 'function' is not need to be expanded.
for word in range(2, strlen('functio'))->mapnew('strpart("functio", 0, v:val)')
  execute $'iabbrev <expr> <buffer> {word} AbbrevDirectiveFunction("{word}")'
  execute $'SetUndoFtplugin iunabbrev <buffer> {word}'
endfor
