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

" filterbox{{{
let s:filterbox = {
            \ 'items_all_': [],
            \ 'items_filtered_' : [],
            \ 'last_input_': '',
            \ }
func! s:filterbox.filterbox(expression) abort
    if has_key(self, 'expression')
        unlet! self.expression
    endif
    let self.expression = a:expression
endfunc
func! s:filterbox.set_items(items) abort
    let self.items_all_ = a:items
    let self.last_input_ = ''
endfunc
func! s:filterbox.filter(input) abort
    if a:input ==# ''
        return self.items_all_
    endif
    if self.last_input_ ==# '' || stridx(a:input, self.last_input_) != 0
        let self.items_filtered_ = copy(self.items_all_)
    endif
    call filter(self.items_filtered_, call(self.expression, [a:input]))
    let self.last_input_ = a:input
    return self.items_filtered_
endfunc
"}}}

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
