"Plugin Name: anything.vim
"Author: mityu
"Last Change: 23-Dec-2018.

let s:cpo_save = &cpo
set cpo&vim

func! vimrc#anything#start(item_list,callback) abort "{{{
	let hilt = copy(s:hilt)
	let hilt.exit = a:callback
	call vimrc#gram#launch(hilt)
endfunc "}}}
func! s:hilt_filter(user_input) abort "{{{
	if a:user_input ==# ''
		return s:item_all
	endif
	let regpat = vimrc#gram#escape_regpat(a:user_input)
	if s:user_input_save ==# '' || stridx(a:user_input,s:user_input_save) != 0
		let s:item_filtered = copy(s:item_all)
	endif
	call filter(s:item_filtered,'v:val=~?regpat')
	let s:user_input_save = a:user_input
	return s:item_filtered
endfunc "}}}
func! s:initialize_variables() abort "{{{
	let s:item_all = []
	let s:item_filtered = []
	let s:user_input_save = ''
endfunc "}}}

if !exists('s:did_initialize_variables')
	call s:initialize_variables()
	let s:hilt = {
				\ 'name' : 'buffers',
				\ 'filter' : function('s:hilt_filter'),
				\ 'regpat' : 'vimrc#gram#escape_regpat',
				\ 'exit' : function('s:initialize_variables')
				\}
endif
let s:did_initialize_variables = 1

let &cpo = s:cpo_save
unlet s:cpo_save
