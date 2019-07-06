:let load_guard = substitute(expand('%:p:t'),'\.','_','g')
:if load_guard ==# ''
:  call brownie#highlight('\C\<LOADGUARD\>')
:  let load_guard = brownie#input('Load Guard? ')
:endif
:call brownie#replace('\C\<LOADGUARD\>', toupper(load_guard))
#ifndef LOADGUARD
#define LOADGUARD

{{_cursor_}}

#endif //  LOADGUARD
