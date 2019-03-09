"Plugin Name: cwdfile.vim
"Author: mityu
"Last Change: 09-Mar-2019.

let s:cpoptions_save = &cpoptions
set cpoptions&vim

function! vimrc#cwdfile#start() abort "{{{
    let s:cwd = fnamemodify(getcwd(win_getid()),':p')
    let pat = s:cwd . '*'
    let s:item_all = split(glob(pat),"\n")
    call filter(s:item_all,'filereadable(v:val)')
    call map(s:item_all,'fnamemodify(v:val,":t")')
    call vimrc#gram#launch(s:bearer)
endfunction "}}}
function! s:bearer_filter(user_input) abort "{{{
    if a:user_input ==# ''
        let s:regpat_save = ''
        return s:item_all
    endif
    let s:regpat_save = vimrc#gram#escape_regpat(a:user_input)
    if s:user_input_save ==# '' || stridx(a:user_input,s:user_input_save) != 0
        let s:item_filtered = copy(s:item_all)
    endif
    call filter(s:item_filtered,'v:val=~?s:regpat_save')
    let s:user_input_save = a:user_input
    return s:item_filtered
endfunction "}}}
function! s:bearer_regpat(user_input) abort "{{{
    return s:regpat_save
endfunction "}}}
function! s:bearer_selected(selected_item) abort "{{{
    execute printf('edit %s%s',s:cwd,a:selected_item)
endfunction "}}}
function! s:initialize_variables() abort "{{{
    let s:item_all = []
    let s:item_filtered = []
    let s:user_input_save = ''
    let s:regpat_save = ''
    let s:cwd = ''
endfunction "}}}

if !exists('s:did_initialize_variables')
    call s:initialize_variables()
    let s:bearer = {
                \ 'name' : 'cwdfile',
                \ 'filter' : function('s:bearer_filter'),
                \ 'regpat' : function('s:bearer_regpat'),
                \ 'selected' : function('s:bearer_selected'),
                \ 'exit' : function('s:initialize_variables')
                \}
endif
let s:did_initialize_variables = 1

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
