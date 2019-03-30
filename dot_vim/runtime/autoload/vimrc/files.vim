" Plugin Name: files.vim
" Author: mityu
" Last Change: 30-Mar-2019.

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
  call s:filterbox.set_items(files)
  call vimrc#gram#launch(s:bearer)
endfunction "}}}
function! s:filter(input) abort "{{{
  return s:filterbox.filter(a:input)
endfunction "}}}
function! s:selected(item) abort "{{{
  execute 'edit' fnameescape(fnamemodify(s:parent_dir . a:item, ':~:.'))
endfunction "}}}
function! s:filter_expression(input) abort "{{{
  return s:filterbox.expression_compare_by_regexp(vimrc#gram#glob2regpat(a:input))
endfunction "}}}

if !exists('s:did_init')
  let s:filterbox = vimrc#class#new('filterbox',
        \ function('s:filter_expression'))
  let s:bearer = {
        \ 'name': 'files',
        \ 'filter': function('s:filter'),
        \ 'regpat': 'vimrc#gram#glob2regpat',
        \ 'selected': function('s:selected'),
        \ }
  let s:parent_dir = ''

  let s:did_init = 1
endif

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
