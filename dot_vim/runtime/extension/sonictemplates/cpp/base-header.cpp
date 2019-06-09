:highlight link sonictemplate_LOADGUARD TODO
:let s:match_id = matchadd('sonictemplate_LOADGUARD', '\CLOADGUARD')
:redraw!
:let s:load_guard = ''
:try
:  let s:load_guard = input("LOADGUARD? (Automatically uppercase, and empty to use default)\n", '')
:catch
:  echohl Error
:  echom v:exception
:  echohl None
:finally
:  call matchdelete(s:match_id)
:  highlight sonictemplate_LOADGUARD NONE
:  unlet s:match_id
:endtry
:if s:load_guard ==# ''
:  let s:load_guard = substitute(expand('%:p:t'),'\.','_','g')
:endif
:silent! keeppatterns %s/\CLOADGUARD/\=toupper(s:load_guard)/ge
:unlet s:load_guard
#ifndef LOADGUARD
#define LOADGUARD

{{_cursor_}}

#endif //  LOADGUARD
