setlocal shiftwidth=2
SetUndoFtplugin setlocal shiftwidth<

function s:abbrev_directive_function(trigger)
  const word = getline('.')->strpart(0, col('.') - 1)
  if word =~# '^\s*fu\%[nctio]$'
    return 'function'
  else
    return a:trigger
  endif
endfunction

" 'function' is not need to be expanded.
for s:word in range(2, strlen('functio'))->mapnew('strpart("functio", 0, v:val)')
  execute $'iabbrev <expr> <buffer> {s:word} <SID>abbrev_directive_function("{s:word}")'
  execute $'SetUndoFtplugin iunabbrev <buffer> {s:word}'
endfor
unlet s:word
