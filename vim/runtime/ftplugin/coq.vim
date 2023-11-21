vim9script

nnoremap <buffer> <Space>r <Nop>
nnoremap <buffer> <Space>rl <Cmd>execute v:count 'CoqToLine'<CR>
nnoremap <buffer> <Space>rj <Cmd>execute v:count1 'CoqNext'<CR>
nnoremap <buffer> <Space>rk <Cmd>execute v:count1 'CoqUndo'<CR>
nnoremap <buffer> gd <Cmd>execute 'CoqGotoDef' coqtail#util#getcurword()<CR>
SetUndoFtplugin nunmap <buffer> <Space>r
SetUndoFtplugin nunmap <buffer> <Space>rl
SetUndoFtplugin nunmap <buffer> <Space>rj
SetUndoFtplugin nunmap <buffer> <Space>rk
SetUndoFtplugin nunmap <buffer> gd

execute $'SetUndoFtplugin let &l:keywordprg={string(&l:keywordprg)}'
setlocal keywordprg=:Coq\ Search

def Abbrev(target: string): string
  if strpart(getline('.'), 0, col('.') - 1)->trim() ==# target
    return toupper(target[0]) .. target[1 :]
  else
    return target
  endif
enddef

const abbrevs =<< trim END
inductive
definition
fixpoint
example
theorem
proof
notation
check
compute
module
qed
END

for target in abbrevs
  execute $'inoreabbrev <expr> <buffer> {target} Abbrev({string(target)})'
  execute $'SetUndoFtplugin iunabbrev <buffer> {target}'
endfor