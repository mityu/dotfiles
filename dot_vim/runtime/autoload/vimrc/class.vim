" Plugin Name: class.vim
" Author: mityu
" Last Change: 07-Mar-2019.

let s:cpoptions_save = &cpoptions
set cpoptions&vim

func! vimrc#class#new(class_name, ...) abort "{{{
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
endfunc "}}}

" Classes
" filterbox{{{
let s:filterbox = {
            \ 'items_all_': [],
            \ 'items_filtered_' : [],
            \ 'last_input_': '',
            \ }
func! s:filterbox.filterbox(expression) abort "{{{
    if has_key(self, 'expression')
        unlet! self.expression
    endif
    let self.expression = a:expression
endfunc "}}}
func! s:filterbox.set_items(items) abort "{{{
    let self.items_all_ = a:items
    let self.last_input_ = ''
endfunc "}}}
func! s:filterbox.filter(input) abort "{{{
    if a:input ==# ''
        return self.items_all_
    endif
    if self.last_input_ ==# '' || stridx(a:input, self.last_input_) != 0
        let self.items_filtered_ = copy(self.items_all_)
    endif
    call filter(self.items_filtered_, call(self.expression, [a:input]))
    let self.last_input_ = a:input
    return self.items_filtered_
endfunc "}}}
"}}}
" save_options{{{
let s:save_options = {}
func! s:save_options.save_options() abort "{{{
    call self.clear()
endfunc "}}}
func! s:save_options.store(options) abort "{{{
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
endfunc "}}}
func! s:save_options.restore(option_name) abort "{{{
    if !has_key(self._shelter, a:option_name)
        call s:echomsg_error('option have not been stored: ' . a:option_name)
        return
    endif
    execute printf('let &l:%s=%s',
                \ a:option_name,
                \ string(self._shelter[a:option_name]))
endfunc "}}}
func! s:save_options.restore_all() abort "{{{
    for option_name in keys(self._shelter)
        call self.restore(option_name)
    endfor
endfunc "}}}
func! s:save_options.clear() abort "{{{
    let self._shelter = {}
endfunc "}}}
"}}}

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save