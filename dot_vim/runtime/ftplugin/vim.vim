" Vim filetype plugin.
" Last Change: 23-Dec-2018.

if exists('b:did_ftplugin_after')
	finish
endif
let b:did_ftplugin_after = 1


com! -buffer -range=% AddAbort call s:add_abort(<line1>,<line2>)
func! s:add_abort(start,end) abort
	let curpos_save = getcurpos()
	let cmd = printf('keeppatterns %d,%d ',a:start,a:end)
	let cmd .= ' s/fu\%[nction][!]\s\+.\+)\zs\%(\s*abort\)\@!/ abort/g'
	exec cmd
	call setpos('.',curpos_save)
endfunc
