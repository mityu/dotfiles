let s:cpoptions_save = &cpoptions
set cpoptions&vim

{{_cursor_}}

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
