" Plugin Name: cmdhist.vim
" Author: mityu
" Last Change: 03-Mar-2019.
" License: The MIT License
" Requirement: gram.vim

let s:cpoptions_save = &cpoptions
set cpoptions&vim


if !exists('s:did_initialize')
    let s:cmdhist_all = []
    let s:cmdhist_filtered = []

    let s:shelter = {
                \ 'user_input': '',
                \ 'matcher': '',
                \ }

    let s:did_initialize = 1
endif

func! vimrc#cmdhist#start() abort "{{{
    let s:cmdhist_all = filter(
                \ map(range(histnr(':'), 1, -1), 'histget(":", v:val)'),
                \ 'v:val !=# ""')
    call vimrc#gram#launch(s:bearer)
endfunc "}}}
func! s:bearer_filter(user_input) abort "{{{
    if a:user_input ==# ''
        let s:shelter.user_input = ''
        return s:cmdhist_all
    endif
    if s:shelter.user_input || stridx(a:user_input, s:shelter.user_input) != 0
        let s:cmdhist_filtered = deepcopy(s:cmdhist_all)
    endif
    let s:shelter.user_input = a:user_input
    let s:shelter.matcher = '\m\c' . substitute(escape(a:user_input, '.$^?:~'),
                \ '\*', '.*', 'g') " TODO: Substitute only non-escaped *.
    call filter(s:cmdhist_filtered, 'v:val =~? s:shelter.matcher')
    return s:cmdhist_filtered
endfunc "}}}
func! s:bearer_regpat(user_input) abort "{{{
    return s:shelter.matcher
endfunc "}}}
func! s:bearer_selected(selected_item) abort "{{{
    execute a:selected_item
    call histadd(':', a:selected_item)
endfunc "}}}

let s:bearer = {
            \ 'name': 'cmdhist',
            \ 'filter': function('s:bearer_filter'),
            \ 'regpat': function('s:bearer_regpat'),
            \ 'selected': function('s:bearer_selected'),
            \ }

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
