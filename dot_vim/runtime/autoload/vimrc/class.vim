" Plugin Name: class.vim
" Author: mityu
" Last Change: 06-Sep-2019.

let s:cpoptions_save = &cpoptions
set cpoptions&vim

function! vimrc#class#new(class_name, ...) abort "{{{
  let class = 's:' . a:class_name
  if !exists(class)
    echohl Error
    echomsg 'vimrc#class#new(): Class does not exist:' a:class_name
    echohl None
    return {}
  endif
  let new_obj = deepcopy(eval(class))
  if exists('*new_obj.' . a:class_name)
    cal call(new_obj[a:class_name], a:000)  " Call constructor.
  endif
  return new_obj
endfunction "}}}

" Classes
" save_options{{{
let s:save_options = {}
function! s:save_options.save_options() abort "{{{
  call self.clear()
endfunction "}}}
function! s:save_options.store(options) abort "{{{
  let type = type(a:options)
  if type == v:t_list
    let options = a:options
  elseif type == v:t_string
    let options = [a:options]
  else
    call s:echomsg_error('save_options.store(): String or List is required')
  endif
  for option in options
    let self._shelter[option] = eval('&l:' . option)
  endfor
endfunction "}}}
function! s:save_options.restore(option_name) abort "{{{
  if !has_key(self._shelter, a:option_name)
    call s:echomsg_error('option have not been stored: ' . a:option_name)
    return
  endif
  execute printf('let &l:%s=%s',
         \ a:option_name,
         \ string(self._shelter[a:option_name]))
endfunction "}}}
function! s:save_options.restore_all() abort "{{{
  for option_name in keys(self._shelter)
    call self.restore(option_name)
  endfor
endfunction "}}}
function! s:save_options.clear() abort "{{{
  let self._shelter = {}
endfunction "}}}
"}}}
" notify{{{
let s:notify = {}
function! s:notify.notify(identifier) abort "{{{
  let self.identifier_ = a:identifier
endfunction "}}}
function! s:notify._base(cmd, hlgroup, msg) abort "{{{
  execute 'echohl' a:hlgroup
  execute a:cmd string(printf('[%s] %s', self.identifier_, a:msg))
  echohl None
endfunction "}}}
function! s:notify.echo_color(hlgroup, msg) abort "{{{
  call self._base('echo', a:hlgroup, a:msg)
endfunction "}}}
function! s:notify.echomsg_color(hlgroup, msg) abort "{{{
  call self._base('echomsg', a:hlgroup, a:msg)
endfunction "}}}
function! s:notify.error_msg(msg) abort "{{{
  call self.echomsg_color('Error', a:msg)
endfunction "}}}
function! s:notify.warning_msg(msg) abort "{{{
  call self.echomsg_color('WarningMsg', a:msg)
endfunction "}}}
function! s:notify.error(msg) abort "{{{
  call self.echo_color('Error', a:msg)
endfunction "}}}
function! s:notify.warning(msg) abort "{{{
  call self.echo_color('WarningMsg', a:msg)
endfunction "}}}
"}}}

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
