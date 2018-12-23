"Plugin Name: buffers.vim
"Author: mityu
"Last Change: 23-Dec-2018.

let s:cpo_save = &cpo
set cpo&vim

func! vimrc#buffers#start() abort "{{{
	call s:generate_buflist()
	call vimrc#gram#launch(s:hilt)
endfunc "}}}
func! s:generate_buflist() abort "{{{
	let buflist = range(1,bufnr('$'))
	call filter(buflist,'buflisted(v:val)')
	call map(buflist,'[bufname(v:val),v:val]')
	call filter(buflist,'v:val[0]!=#""')
	for [bufname,bufnr] in buflist
		let s:buflist_all[bufname] = bufnr
	endfor
endfunc "}}}
func! s:hilt_filter(user_input) abort "{{{
	if a:user_input ==# ''
		return keys(s:buflist_all)
	endif
	let regpat = vimrc#gram#glob2regpat(a:user_input)
	if s:user_input_save ==# '' || stridx(a:user_input,s:user_input_save) != 0
		let s:buflist_filtered = keys(s:buflist_all)
	endif
	call filter(s:buflist_filtered,'v:val=~?regpat')
	let s:user_input_save = a:user_input
	return s:buflist_filtered
endfunc "}}}
func! s:hilt_selected(selected_item) abort "{{{
	execute 'buffer' s:buflist_all[a:selected_item]
endfunc "}}}
func! s:initialize_variables() "{{{
	let s:buflist_all = {}
	let s:buflist_filtered = []
	let s:user_input_save =''
endfunc "}}}

if !exists('s:did_initialize_variables')
	call s:initialize_variables()
	let s:hilt = {
				\ 'name' : 'buffers',
				\ 'filter' : function('s:hilt_filter'),
				\ 'regpat' : 'vimrc#gram#glob2regpat',
				\ 'selected' : function('s:hilt_selected'),
				\ 'exit' : function('s:initialize_variables'),
				\}
endif
let s:did_initialize_variables = 1

let &cpo = s:cpo_save
unlet s:cpo_save
