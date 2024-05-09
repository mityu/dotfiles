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

SetUndoFtplugin setlocal keywordprg<
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

# Omni completion: just a simple tactics completion
const tactics =<< trim END
intros
simpl
reflexivity
destruct
induction
discriminate
rewrite
replace
apply
injection
split
left
right
unfold
exfalso
forall
exists
symmetry
END

def Omnifunc(findstart: number, base: string): any
  if !!findstart
    const cword = getline('.')[: col('.') - 1]->matchstr('\S*$')
    return col('.') - 1 - strlen(cword)
  endif
  return tactics
    ->copy()
    ->filter((_: number, v: string): bool => stridx(v, base) == 0)
enddef

set omnifunc=<SID>Omnifunc
SetUndoFtplugin set omnifunc&
