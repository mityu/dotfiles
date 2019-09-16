"Plugin Name: mru.vim
"Author: mityu
"Last Change: 16-Sep-2019.

let s:cpoptions_save = &cpoptions
set cpoptions&vim

" Utility
let s:notify = {}
function! s:notify.notify(msg,hl_group,cmd) abort "{{{
  execute 'echohl' a:hl_group
  execute a:cmd string('[mru] ' . a:msg)
  echohl None
endfunction "}}}
function! s:notify.error(msg) abort "{{{
  call self.notify(a:msg,'Error','echomsg')
endfunction "}}}
function! s:notify.warning(msg) abort "{{{
  call self.notify(a:msg,'Warning','echomsg')
endfunction "}}}
function! s:get_config(kind) abort "{{{
  if exists('g:mru_' . a:kind)
    return eval('g:mru_' . a:kind)
  else
    return eval('s:default_' . a:kind)
  endif
endfunction "}}}

" mru
function! vimrc#mru#onReadFile() abort "{{{
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
  if file_name ==# g:mru_history_file
    return
  endif
  call s:load_history()
  let index = index(s:history,file_name)
  if index != -1 | call remove(s:history,index) | endif
  call insert(s:history,file_name)
  call s:save_history()
endfunction "}}}
function! vimrc#mru#start() abort "{{{
  if !s:is_available() | return | endif
  if s:get_config('auto_delete_unexist_file_history')
    call vimrc#mru#delete_unexist_file_history()
  endif
  call s:load_history()
  call gram#select({
        \ 'name': 'MRU',
        \ 'items': s:history,
        \ 'callback': {item -> execute('edit ' . fnameescape(item.word))},
        \ })
endfunction "}}}
function! vimrc#mru#try_to_enable() abort "{{{
  let s:is_available = s:try_to_enable_impl()
endfunction "}}}
function! s:try_to_enable_impl() abort "{{{
  if !exists('g:mru_history_file')
    call s:notify.error('Please set `g:mru_history_file` to a file name')
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
endfunction "}}}
function! vimrc#mru#delete_unexist_file_history() abort "{{{
  call s:load_history()
  call filter(s:history,'filereadable(v:val)')
  call s:save_history()
endfunction "}}}
function! s:is_available() abort "{{{
  return s:is_available
endfunction "}}}
function! s:load_history() abort "{{{
  if !s:is_available() | return | endif
  let s:history = readfile(g:mru_history_file)
endfunction "}}}
function! s:save_history() abort "{{{
  if !s:is_available() | return | endif
  let history_max = s:get_config('history_max')
  if len(s:history) > history_max
    call remove(s:history,history_max,-1)
  endif
  call writefile(s:history,g:mru_history_file)
endfunction "}}}

" Editing history
function! vimrc#mru#edit_history_start(...) abort "{{{
  if !s:is_available() | return | endif

  let open_cmd = get(a:000,0,'')
  if open_cmd ==# '' | let open_cmd = 'tabedit' | endif
  try
    execute open_cmd fnameescape(g:mru_history_file)
  catch
    call s:notify.error(v:exception)
    return
  endtry
  setlocal nobuflisted noswapfile noundofile
endfunction "}}}

if !exists('s:did_initialize')
  let s:default_ignore_pattern = ['\.git\>']
  let s:default_history_max = 300
  let s:default_auto_delete_unexist_file_history = 0

  let s:history = []

  let s:is_available = 0
  call vimrc#mru#try_to_enable()

  let s:did_initialize = v:true
endif

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
