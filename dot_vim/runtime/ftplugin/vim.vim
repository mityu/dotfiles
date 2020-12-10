vim9script

SetUndoFtplugin setlocal shiftwidth<
SetUndoFtplugin delcommand AddAbort
SetUndoFtplugin setlocal foldexpr< foldmethod<
setlocal shiftwidth=2
setlocal foldmethod=expr
&l:foldexpr = expand('<SID>') .. 'FoldExpr()'

def FoldIsBlockOpen(line: string): bool
  if line =~# '\v^<%(fu%[nction]|%(export\s+)?def|if|for|while|try)>' ||
     line =~# '\v^augroup\s+%(<\cEND>)@!' ||
     line =~# '\V' .. split(&l:foldmarker, ',')[0] .. '\d\*\s\*\$'
    return true
  endif
  return false
enddef

def FoldIsBlockClose(line: string): bool
  if line =~# '\v^<end%(func%[tion]|def|if|for|while|try)>' ||
     line =~# '\v^augroup\s+<\cEND>' ||
     line =~# '\V' .. split(&l:foldmarker, ',')[1] .. '\d\*\s\*\$'
    return true
  endif
  return false
enddef

def FoldExpr(): any
  var line = getline(v:lnum)
  if line =~# '^\s'
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
  endif
  return '='
enddef

command! -bar -buffer -range=% AddAbort call AddAbort(<line1>, <line2>)
def AddAbort(start: number, end: number)
  var curpos_save = getcurpos()
  var cmd = printf('keeppatterns :%d,%d ', start, end)
  cmd ..= ' s/^\s*\%(end\)\@<!fu\%[nction]!\?\s\+.\+)\zs\%(\s*abort\)\@!/ abort/g'
  execute cmd
  setpos('.', curpos_save)
enddef
