" Plugin Name: cmdhist.vim
" Author: mityu
" Last Change: 01-Mar-2019.
" License: The MIT License
" Requirement: gram.vim

let s:cpoptions_save = &cpoptions
set cpoptions&vim


if !exists('s:did_initialize')
    let s:cmdhist_all = []
    let s:cmdhist_filtered = []
    let s:user_input_save = ''

    let s:did_initialize = 1
endif

func! vimrc#cmdhist#start() abort "{{{
    let s:cmdhist_all = map(filter(
                \ map(range(histnr(':'), 1, -1), 'histget(":", v:val)'),
                \ 'v:val !=# ""'), '{"matcher": tolower(v:val), "cmd": v:val}')
    call vimrc#gram#launch(s:bearer)
endfunc "}}}
func! s:bearer_filter(user_input) abort "{{{
    if a:user_input ==# ''
        return map(deepcopy(s:cmdhist_all), 'v:val.cmd')
    endif
    if s:user_input_save || stridx(a:user_input, s:user_input_save) != 0
        let s:cmdhist_filtered = deepcopy(s:cmdhist_all)
    endif
    let s:user_input_save = a:user_input
    call filter(s:cmdhist_filtered, 'stridx(v:val.matcher, a:user_input) != -1')
    return map(deepcopy(s:cmdhist_filtered), 'v:val.cmd')
endfunc "}}}
func! s:bearer_selected(selected_item) abort "{{{
    execute a:selected_item
    call histadd(':', a:selected_item)
endfunc "}}}

let s:bearer = {
            \ 'name': 'cmdhist',
            \ 'filter': function('s:bearer_filter'),
            \ 'regpat': 'vimrc#gram#escape_regpat',
            \ 'selected': function('s:bearer_selected'),
            \ }

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
