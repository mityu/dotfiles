" Vim filetype plugin.
" Last Change: 30-Mar-2019.

SetUndoFtplugin setlocal shiftwidth<
SetUndoFtplugin delcommand AddAbort
setlocal shiftwidth=2

command! -buffer -range=% AddAbort call s:add_abort(<line1>,<line2>)
function! s:add_abort(start,end) abort
    let curpos_save = getcurpos()
    let cmd = printf('keeppatterns %d,%d ',a:start,a:end)
    let cmd .= ' s/fu\%[nction][!]\s\+.\+)\zs\%(\s*abort\)\@!/ abort/g'
    exec cmd
    call setpos('.',curpos_save)
endfunction
