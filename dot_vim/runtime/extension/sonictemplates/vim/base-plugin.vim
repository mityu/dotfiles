" Plugin Name: {{_cursor_}}
" Author: mityu
" Last Change: .

let s:cpoptions_save = &cpoptions
set cpoptions&vim

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
