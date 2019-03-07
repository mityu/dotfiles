"Plugin Name: buffers.vim
"Author: mityu
"Last Change: 07-Mar-2019.

let s:cpo_save = &cpo
set cpo&vim

func! vimrc#buffers#start() abort "{{{
    call s:list_buffers()
    call vimrc#gram#launch(s:bearer)
endfunc "}}}
func! s:list_buffers() abort "{{{
    let buflist = range(1, bufnr('$'))
    call filter(buflist, 'buflisted(v:val)')
    call map(buflist, '[bufname(v:val), v:val]')
    call filter(buflist, 'v:val[0] !=# ""')
    for [bufname, bufnr] in buflist
        let s:buflist[bufname] = bufnr
    endfor
    call map(buflist, 'v:val[0]')
    call s:filterbox.set_items(buflist)
endfunc "}}}
func! s:bearer_filter(user_input) abort "{{{
    return s:filterbox.filter(a:user_input)
endfunc "}}}
func! s:bearer_regpat(user_input) abort "{{{
    return s:regpat_save
endfunc "}}}
func! s:bearer_selected(selected_item) abort "{{{
    execute 'buffer' s:buflist_all[a:selected_item]
endfunc "}}}
func! s:filterbox_expression(user_input) abort "{{{
    return printf('v:val =~? %s', string(vimrc#gram#glob2regpat(a:user_input)))
endfunc "}}}

if !exists('s:did_initialize_variables')
    let s:buflist = {}
    let s:filterbox = vimrc#class#new('filterbox',
                \ function('s:filterbox_expression'))
    let s:bearer = {
                \ 'name' : 'buffers',
                \ 'filter' : function('s:bearer_filter'),
                \ 'regpat' : 'vimrc#gram#glob2regpat',
                \ 'selected' : function('s:bearer_selected'),
                \}
endif
let s:did_initialize_variables = 1

let &cpo = s:cpo_save
unlet s:cpo_save
