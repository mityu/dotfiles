" The below is already set by textobj-function
" SetUndoFtplugin unlet! b:textobj_function_select
let b:textobj_function_select = function('vimrc#textobj_vimspec#Select')

function s:command_abbrev(command) abort
  if getline('.')[: col('.') - 1]->trim() ==# a:command
    return toupper(a:command[0]) .. a:command[1 :]
  else
    return a:command
  endif
endfunction

inoreabbrev <expr> <buffer> describe <SID>command_abbrev('describe')
inoreabbrev <expr> <buffer> context <SID>command_abbrev('context')
inoreabbrev <expr> <buffer> before <SID>command_abbrev('before')
inoreabbrev <expr> <buffer> after <SID>command_abbrev('after')
inoreabbrev <expr> <buffer> it <SID>command_abbrev('it')
inoreabbrev <expr> <buffer> assert <SID>command_abbrev('assert')
inoreabbrev <expr> <buffer> throws <SID>command_abbrev('throws')
inoreabbrev <expr> <buffer> fail <SID>command_abbrev('fail')
inoreabbrev <expr> <buffer> skip <SID>command_abbrev('skip')

function s:subcommand_abbrev(command, trigger, abbrev) abort
  if getline('.')[: col('.') - 1] =~? $'^\s*{a:command}\s\+{a:trigger}$'
    return a:abbrev
  else
    return a:trigger
  endif
endfunction

function s:register_subcommand_abbrev(command, fn) abort
  let trigger = substitute(a:fn, '_', '', 'g')
  let expandto = substitute(a:fn, '\%(^\|_\)\(\w\)', '\=toupper(submatch(1))', 'g')
  execute $'inoreabbrev <expr> <buffer> {trigger} <SID>subcommand_abbrev({string(a:command)}, {string(trigger)}, {string(expandto)})'
endfunction

" Assume that themis.vim is in 'runtimepath'.
eval getcompletion('themis-helper-assert-', 'help')
  \->filter({ _, v -> v =~# '()$' })
  \->map({ _, v -> matchstr(v, '^themis-helper-assert-\zs.*\ze()$') })
  \->foreach({ _, v -> s:register_subcommand_abbrev('Assert', v) })
eval getcompletion('themis-helper-expect-', 'help')
  \->filter({ _, v -> v =~# '()$' })
  \->map({ _, v -> matchstr(v, '^themis-helper-expect-\zs.*\ze()$') })
  \->foreach({ _, v -> s:register_subcommand_abbrev('Expect', v) })
