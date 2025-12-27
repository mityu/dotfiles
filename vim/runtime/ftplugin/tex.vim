SetUndoFtplugin set backupcopy<

setlocal backupcopy=yes

function s:do_iabbrev_envname(trigger, full) abort
  const line = getline('.')->strpart(0, col('.') - 1)
  if line =~# '\\\%(begin\|end\){' .. a:trigger .. '$'
    return a:full
  else
    return a:trigger
  endif
endfunction

function s:setup_iabbrev_envname(min, full) abort
  const triggers = range(strlen(a:min), strlen(a:full) - 1)->map({_, v -> strpart(a:full, 0, v)})
  for trigger in triggers
    execute $'SetUndoFtplugin iunabbrev <buffer> {trigger}'
    execute $'inoreabbrev <expr> <buffer> {trigger} <SID>do_iabbrev_envname("{trigger}", "{a:full}")'
  endfor
endfunction

call s:setup_iabbrev_envname('eq', 'equation')
call s:setup_iabbrev_envname('ali', 'align')
call s:setup_iabbrev_envname('ga', 'gather')
