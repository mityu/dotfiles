" Plugin Name: prompt.vim
" Author: mityu
" Last Change: 10-Mar-2019.

let s:cpoptions_save = &cpoptions
set cpoptions&vim

if !exists('s:did_initialize_variables')
    let s:is_active = v:false
    let s:prompter = {}
    let s:default_config = {
                \ 'prompt': '>> ',
                \ 'default_input' : '',
                \ }
    let s:did_initialize_variables = v:true
endif

" Callbacks:
"  on_changed : When CmdlineChanged is fired.
"  on_decided : When a user finished inutting.
"  on_exit : Just after leaving from prompt.
" Config:
"  prompt : prompt text.
"  default_input : default input text.
function! vimrc#prompt#launch(prompter) abort "{{{
    if s:is_active | return | endif
    let s:is_active = 1
    let s:prompter = a:prompter

    if !has_key(s:prompter, 'config')
        let s:prompter.config = {}
    endif
    let s:prompter.config =
                \ extend(s:prompter.config, s:default_config, 'keep')

    augroup prompt_observer
        autocmd!
        autocmd CmdlineEnter,CmdlineChanged @ call s:eat_default_inputs()
    augroup END

    try
        let input = input(s:prompter.config.prompt, s:prompter.config.default_input)
        call s:callback('on_decided', input)
    finally
        autocmd! prompt_observer
        let s:is_active = 0
        call s:callback('on_exit')
    endtry
endfunction "}}}
function! s:callback(func_name, ...) abort "{{{
    if has_key(s:prompter, a:func_name)
        call call(s:prompter[a:func_name], a:000)
    endif
endfunction "}}}
function! s:eat_default_inputs() abort "{{{
    if getcmdline() !=# s:prompter.config.default_input
        return
    endif
    augroup prompt_observer
        autocmd!
        autocmd CmdlineChanged @ call s:callback('on_changed', getcmdline())
    augroup END
endfunction "}}}

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
