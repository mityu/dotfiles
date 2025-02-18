let g:vimrc#mruw#filename = get(g:, 'vimrc#mruw#filename', '~/.cache/mr/mruw')
let g:vimrc#mruw#predicates = get(g:, 'vimrc#mruw#predicates', [])
let s:mruw = mr#recorder#new(expand(g:vimrc#mruw#filename), {
  \   'predicates': g:vimrc#mruw#predicates,
  \ })

function! vimrc#mruw#list() abort
  return s:mruw.list()
endfunction

function! vimrc#mruw#start_recording() abort
  augroup mr-mruw-internal
    autocmd!
    autocmd BufReadPost * call s:mruw.record(expand('<afile>'))
    autocmd BufWritePost * call s:mruw.record(expand('<afile>'))
    autocmd VimLeave    * call s:mruw.dump()
  augroup END
endfunction

function! vimrc#mruw#stop_recording() abort
  augroup mr-mruw-internal
    autocmd!
  augroup END
endfunction

function! vimrc#mruw#delete(filename) abort
  return s:mruw.delete(a:filename)
endfunction

