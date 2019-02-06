"Plugin Name: shcmd.vim
"Author: mityu
"Last Change: 06-Feb-2019.

let s:cpo_save = &cpo
set cpo&vim

func! s:warning_msg(msg) abort "{{{
	echohl WarningMsg
	echom a:msg
	echohl None
endfunc "}}}
func! s:expand_all(files) abort "{{{
	return map(a:files,'expand(v:val)')
endfunc "}}}
func! vimrc#shcmd#ls(has_bang,...) abort "{{{
	" If `has_bang` is true, I'll show hidden files.
	let cwd = fnamemodify(get(a:000,0,getcwd(winnr())),':p')
	let children = []
	let [dirs,files] = [[],[]]

	if a:has_bang
		let children += split(glob(cwd . '.*'),"\n")
	endif
	let children += split(glob(cwd . '*'),"\n")
	for child in children
		if isdirectory(child)
			call add(dirs,child)
		else
			call add(files,child)
		endif
	endfor

	call map(dirs,{-> fnamemodify(v:val,':t') . '/'})
	call map(files,{-> fnamemodify(v:val,':t')})
	call filter(dirs,{-> (v:val!=#'./') && (v:val!=#'../')})
	echo join(dirs + files,"\n")
endfunc "}}}
func! vimrc#shcmd#mkdir(has_bang,...) abort "{{{
	" If `has_bang` is true, I'll create intermediate directory.
	let option_path = a:has_bang ? 'p' : ''
	for dir in a:000
		if isdirectory(dir)
			call s:warning_msg(printf('Directory %s exists.', dir))
			continue
		endif
		try
			call mkdir(dir, 'p')
		catch /^Vim\%((\a\+)\)\=:E739/
			call s:warning_msg(printf('File %s exists', dir))
			continue
		endtry
	endfor
endfunc "}}}
func! vimrc#shcmd#touch(...) abort "{{{
	for fname in a:000
		if getftype(fname) != ''
			call s:warning_msg(printf('File %s exists. Overwrite? [y/n]',fname))
			if nr2char(getchar()) !~? 'y'
				continue
			endif
			call writefile([],fname)
		endif
	endfor
endfunc "}}}
func! vimrc#shcmd#cpfile(...) abort "{{{
	" I won't copy directories.
	let args = s:expand_all(copy(a:000))
	if a:0 == 1
	else
		let copy_from = remove(args,0)
	endif
	let file_contents = readfile(copy_from)
	for copy_to in args
		if getftype(copy_to) !=# ''
			" File exists.
			call s:warning_msg(printf('File %s exists. Overwrite? [y/n]',fname))
			if nr2char(getchar()) !~? 'y'
				continue
			endif
		endif
		call writefile(file_contents,copy_to)
	endfor
endfunc "}}}
func! vimrc#shcmd#rm(has_bang,...) abort "{{{
	" If `has_bang` is true, I'll delete directories; Otherwize, I'll delete
	" files.
	if a:has_bang
		call s:delete_dirs(s:expand_all(copy(a:000)))
	else
		call s:delete_files(s:expand_all(copy(a:000)))
	endif
endfunc "}}}
func! s:delete_files(files) abort "{{{
	for file in a:files
		echo printf('Delete %s ? [y/n]', file)
		if nr2char(getchar()) !~? 'y'
			echo 'Cancel.'
			continue
		endif
		if delete(file) == 0 " Succesfully deleted.
			let file = escape(file,'^[]\/*.+?$:')
			if bufexists(bufname(file))
				exec 'bwipeout' bufnr(file)
			endif
		else
			call s:warning_msg(printf('Failed to delete %s', file))
		endif
	endfor
endfunc "}}}
func! s:delete_dirs(dirs) abort "{{{
	for dir in a:dirs
		if delete(dir,'rf') != 0 " Failed to delete.
			call s:warning_msg(printf('Failed to delete %s', dir))
		endif
	endfor
endfunc "}}}

let &cpo = s:cpo_save
unlet s:cpo_save
