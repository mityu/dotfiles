let s:cpoptions_save = &cpoptions
set cpoptions&vim

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
