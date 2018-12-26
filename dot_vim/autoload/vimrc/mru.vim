"Plugin Name: mru.vim
"Author: mityu
"Last Change: 26-Dec-2018.

let s:cpo_save = &cpo
set cpo&vim

" Script local variables
if !exists('s:did_initialize_variables')
	let s:default_ignore_pattern = ['\.git']
	let s:default_history_max= 300
	let s:default_auto_delete_unexist_file_history = 0

	let s:mru = {
				\ 'user_input_save' : '',
				\ 'history_all' : [],
				\ 'history_filtered' : [],
				\}
endif
let s:did_initialize_variables = v:true

" Utility
let s:notify = {}
func! s:notify.notify(msg,hl_group,cmd) abort "{{{
	execute 'echohl' a:hl_group
	execute a:cmd '[mru]' a:msg
	echohl None
endfunc "}}}
func! s:notify.error(msg) abort "{{{
	call self.notify(a:msg,'Error','echomsg')
endfunc "}}}
func! s:notify.warning(msg) abort "{{{
	call self.notify(a:msg,'Warning','echomsg')
endfunc "}}}
func! s:get_config(kind) abort "{{{
	if exists('g:mru_' . a:kind)
		return eval('g:mru_' . a:kind)
	else
		return eval('s:default_' . a:kind)
	endif
endfunc "}}}

" mru
func! vimrc#mru#onReadFile() abort "{{{
	if !s:is_available() | return | endif
	let bufnr = expand('<abuf>') + 0
	let file_name = fnamemodify(resolve(bufname(bufnr+0)),':p')
	if file_name ==# '' || &buftype !=# '' || !filereadable(file_name)
		return
	endif
	for ignore_pattern in s:get_config('ignore_pattern')
		if match(file_name,ignore_pattern) != -1
			return
		endif
	endfor
	call s:load_history()
	let index = index(s:mru.history_all,file_name)
	if index != -1 | call remove(s:mru.history_all,index) | endif
	call insert(s:mru.history_all,file_name)
	call s:save_history()
endfunc "}}}
func! vimrc#mru#start() abort "{{{
	if !s:is_available() | return | endif
	if s:get_config('auto_delete_unexist_file_history')
		call vimrc#mru#delete_unexist_file_history()
	endif
	call s:load_history()
	call vimrc#gram#launch(s:hilt)
endfunc "}}}
func! vimrc#mru#try_to_enable() abort "{{{
	if !exists('g:mru_history_file')
		call s:notify.error('Please set `g:mru_history_file`')
		return v:false
	endif
	let perm = getfperm(g:mru_history_file)
	if perm ==# '' " File does not exists
		if writefile([],g:mru_history_file) == -1 "Cannot write file.
			call s:notify.error('Cannot write file: ' . g:mru_history_file)
			return v:false
		endif
		let perm = getfperm(g:mru_history_file)
	endif
	if strpart(perm,0,2) !=# 'rw'
		call s:notify.error('Cannnot read or write file: ' . g:mru_history_file)
		return v:false
	endif
	return v:true
endfunc "}}}
func! vimrc#mru#delete_unexist_file_history() abort "{{{
	call s:load_history()
	call filter(s:mru.history_all,'filereadable(v:val)')
	call s:save_history()
endfunc "}}}
func! s:is_available() abort "{{{
	return s:is_available
endfunc "}}}
func! s:load_history() abort "{{{
	if !s:is_available() | return | endif
	let s:mru.history_all = readfile(g:mru_history_file)
endfunc "}}}
func! s:save_history() abort "{{{
	if !s:is_available() | return | endif
	let history_max = s:get_config('history_max')
	if len(s:mru.history_all) > history_max
		call remove(s:mru.history_all,history_max,-1)
	endif
	call writefile(s:mru.history_all,g:mru_history_file)
endfunc "}}}
func! s:hilt_filter(user_input) abort "{{{
	if a:user_input == ''
		return s:mru.history_all
	endif
	let regpat = vimrc#gram#glob2regpat(a:user_input)
	if s:mru.user_input_save ==# '' || stridx(a:user_input,s:mru.user_input_save) != 0
		let s:mru.history_filtered = copy(s:mru.history_all)
	endif
	call filter(s:mru.history_filtered,'v:val=~?regpat')
	let s:mru.user_input_save = a:user_input
	return s:mru.history_filtered
endfunc "}}}
func! s:hilt_selected(selected_item) abort "{{{
	execute 'edit' fnameescape(a:selected_item)
endfunc "}}}

if !exists('s:is_available')
	let s:is_available = vimrc#mru#try_to_enable()
endif
if !exists('s:hilt')
	let s:hilt = {
				\ 'name' : 'mru',
				\ 'filter' : function('s:hilt_filter'),
				\ 'regpat' : 'vimrc#gram#glob2regpat',
				\ 'selected' : function('s:hilt_selected')
				\}
endif

let &cpo = s:cpo_save
unlet s:cpo_save
