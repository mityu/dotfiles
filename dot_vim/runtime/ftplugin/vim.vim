vim9script

SetUndoFtplugin setlocal shiftwidth<
SetUndoFtplugin delcommand AddAbort
SetUndoFtplugin setlocal foldexpr< foldmethod<
setlocal shiftwidth=2
setlocal foldmethod=expr
&l:foldexpr = expand('<SID>') .. 'FoldExpr()'

def FoldIsBlockOpen(line: string): bool
  return line =~# '\v^%(fu%[nction]|%(export\s+)?def|if|for|while|try)|augroup\s+%(END)@!'
enddef

def FoldIsBlockClose(line: string): bool
  return line =~# '\v^%(end%(func%[tion]|def|if|for|while|try)|augroup\s+END)'
enddef

def FoldExpr(): any
  # TODO: Fold with marker
  var line = getline(v:lnum)
  if line =~# '^\s'
    return '='
  elseif s:FoldIsBlockOpen(line)
    return '>1'
  elseif v:lnum == 1 ||
        s:FoldIsBlockClose(getline(prevnonblank(v:lnum - 1)))
    if getline(v:lnum) ==# '' && (v:lnum - 1) == prevnonblank(v:lnum - 1)
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
