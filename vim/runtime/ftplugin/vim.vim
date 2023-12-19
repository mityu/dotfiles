vim9script

SetUndoFtplugin setlocal shiftwidth<
SetUndoFtplugin setlocal foldexpr< foldmethod<
# The below is already set by textobj-function
# SetUndoFtplugin unlet! b:textobj_function_select
setlocal shiftwidth=2
setlocal foldmethod=expr
setbufvar('%', 'textobj_function_select', function('vimrc#textobj_vim#Select'))
&l:foldexpr = expand('<SID>') .. 'FoldExpr()'

def FoldIsBlockOpen(line: string): bool
  if line =~# '\v^<%(%(export\s+|legacy\s+|static\s+)?%(fu%[nction]|def|class)|if|for|while|try)>' ||
     line =~# '\v^augroup\s+%(<\cEND>)@!' ||
     line =~# '\V' .. split(&l:foldmarker, ',')[0] .. '\d\*\s\*\$'
    return true
  endif
  return false
enddef

def FoldIsBlockClose(line: string): bool
  if line =~# '\v^<end%(func%[tion]|def|endclass|if|for|while|try)>' ||
     line =~# '\v^augroup\s+<\cEND>' ||
     line =~# '\V' .. split(&l:foldmarker, ',')[1] .. '\d\*\s\*\$'
    return true
  endif
  return false
enddef

def FoldExpr(): any
  var line = getline(v:lnum)
  if line =~# '^\s'
    # :def functions in class
    line = trim(line)
    if line =~# '\v^%(static\s+)?def>'
      return '>2'
    elseif line ==# 'enddef' && (v:lnum + 1) == nextnonblank(v:lnum + 1)
      return '<2'
    endif
    return '='
  elseif FoldIsBlockOpen(line)
    return '>1'
  elseif v:lnum == 1 || FoldIsBlockClose(getline(prevnonblank(v:lnum - 1)))
    if getline(v:lnum) ==# '' &&
        (v:lnum - 1) == prevnonblank(v:lnum - 1) &&
        getline(v:lnum - 1) =~# '\v^end%(func%[tion]|def)'
      return '='
    endif
    return 0
  elseif getline(prevnonblank(v:lnum - 1)) =~# '^\s\+enddef\s*$' # :enddef in class
    if getline(v:lnum) ==# '' && (v:lnum - 1) == prevnonblank(v:lnum - 1)
      return '='
    endif
    return '<2'
  endif
  return '='
enddef
