" Plugin Name: files.vim
" Author: mityu
" Last Change: 06-Sep-2019.

let s:cpoptions_save = &cpoptions
set cpoptions&vim

function! vimrc#files#start(...) abort "{{{
  let s:parent_dir = exists('a:1') ? a:1 : ''
  if s:parent_dir ==# '' || !isdirectory(s:parent_dir)
    let s:parent_dir = getcwd(win_getid())
  endif
  let s:parent_dir = fnamemodify(s:parent_dir, ':p')

  let files = filter(split(glob(s:parent_dir . '*'), "\n"),
        \ 'filereadable(v:val)')
  call map(files, 'fnamemodify(v:val, ":t")')
  let s:gram.items = files
  call gram#select(s:gram)
endfunction "}}}

if !exists('s:did_init')
  let s:parent_dir = ''
  let s:gram = {'name': 'files'}
  function! s:gram.callback(item) abort "{{{
    execute 'edit' fnameescape(fnamemodify(s:parent_dir . a:item.word, ':~:.'))
  endfunction "}}}

  let s:did_init = 1
endif

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
