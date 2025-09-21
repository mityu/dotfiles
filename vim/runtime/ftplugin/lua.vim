SetUndoFtplugin setlocal shiftwidth<
setlocal shiftwidth=2

function s:abbrev_directive(trigger, matcher, full) abort
  const word = getline('.')->strpart(0, col('.') - 1)
  if word =~# a:matcher
    return a:full
  else
    return a:trigger
  endif
endfunction

function s:define_abbrev_directive(shortest, full) abort
  let longest = strpart(a:full, 0, strlen(a:full) - 1)

  let len_shortest = strlen(a:shortest)
  let len_longest = strlen(longest)
  if len_shortest > len_longest
    throw $'Shortest keyword is too long: ("{a:shortest}", "{full}")'
  endif

  " The substring that `longest` has while `a:shortest` doesn't have.
  let diff = strpart(longest, len_shortest, len_longest)
  let matcher = $'^\s*{a:shortest}\%[{diff}]$'

  let smatcher = string(matcher)
  let sfull = string(a:full)
  for word in range(len_shortest, len_longest)->map({ _, v -> strpart(a:full, 0, v) })
    execute $'iabbrev <expr> <buffer> {word} <SID>abbrev_directive({string(word)}, {smatcher}, {sfull})'
    execute $'SetUndoFtplugin iunabbrev <buffer> {word}'
  endfor
endfunction

function s:abbrev_function(trigger) abort
  const word = getline('.')->strpart(0, col('.') - 1)
  if word =~# '^\s*\%(local\s\+\)\?fu\%[nctio]' || v:char ==# '('
    return 'function'
  else
    return a:trigger
  endif
endfunction


call s:define_abbrev_directive('loc', 'local')

for s:word in range(strlen('fu'), strlen('functio'))->map('strpart("functio", 0, v:val)')
  execute $'iabbrev <expr> <buffer> {s:word} <SID>abbrev_function("{s:word}")'
  execute $'SetUndoFtplugin iunabbrev <buffer> {s:word}'
endfor
unlet s:word

iabbrev <buffer> req( require(
SetUndoFtplugin iunabbrev <buffer> req(
