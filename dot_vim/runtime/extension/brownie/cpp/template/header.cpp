:call brownie#highlight('\C\<LOADGUARD\>')
:call brownie#replace('\C\<LOADGUARD\>', toupper(brownie#input('load guard? ', substitute(expand('%:p:t'),'\.','_','g'))))
#ifndef LOADGUARD
#define LOADGUARD

{{_cursor_}}

#endif //  LOADGUARD
