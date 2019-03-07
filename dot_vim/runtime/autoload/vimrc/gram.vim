"Plugin Name: gram.vim
"Author: mityu
"Last Change: 07-Mar-2019.

let s:cpo_save = &cpo
set cpo&vim

" Script local variables
if !exists('s:did_initialize_variables') "{{{
    let s:NULL = 0
    let s:gram = {
                \ 'line_prompt' : 1,
                \ 'user_input' : '',
                \ 'prompt' : '',
                \ 'bearer': {}
                \ }
    let s:active_bearer = ''
    let s:gram_default_config = {
                \ 'prompt': '>> ',
                \ 'name' : '',
                \ }
    let s:window = {
                \ 'bufnr' : s:NULL,
                \ 'alter_bufnr' : s:NULL
                \ }
    let s:gram_prompter = {}
endif
let s:did_initialize_variables = v:true
 "}}}

" Utility
let s:notify = {}
func! s:notify.notify(msg,hl_group,cmd) abort "{{{
    execute 'echohl' a:hl_group
    execute a:cmd string('[gram] ' . a:msg)
    echohl None
endfunc "}}}
func! s:notify.error(msg) abort "{{{
    call self.notify(a:msg,'Error','echomsg')
endfunc "}}}
func! s:notify.warning(msg) abort "{{{
    call self.notify(a:msg,'Warning','echomsg')
endfunc "}}}
" s:shellslash(){{{
if has('win32')
    func! s:shellslash() abort
        if exists('+shellslash') && &shellslash
            return '/'
        else
            return '\'
        endif
    endfunc
else
    func! s:shellslash() abort
        return '/'
    endfunc
endif "}}}
func! s:mod(n,law) abort "{{{
    if a:n >= 0
        return a:n % a:law
    else
        return a:n + (-a:n/a:law + ((-a:n%a:law) ? 1 : 0)) * a:law
    endif
endfunc "}}}

" Window management
func! s:win_foreground() abort "{{{
    if s:win_is_active()
        call win_gotoid(win_findbuf(s:window.bufnr)[0])
        return
    endif

    let s:window.alter_bufnr = bufnr('%')
    if s:window.bufnr != s:NULL && bufexists(s:window.bufnr)
        execute 'silent buffer' s:window.bufnr
    else
        silent e [gram]
        setlocal bufhidden=hide buftype=nofile nobuflisted noswapfile noundofile nomodifiable nomodified
        augroup gram_buffer
            au! * <buffer>
            au BufWipeout <buffer> call s:win_bufwipeouted()
            au BufWinLeave <buffer> call s:win_bufhidden()
        augroup END
    endif
    let s:window.bufnr = bufnr('%')
endfunc "}}}
func! s:win_background() abort "{{{
    if !s:win_is_active() | return | endif
    augroup gram_buffer
        au! BufWinLeave <buffer>
    augroup END
    if s:window.alter_bufnr == s:NULL ||
                \!bufexists(s:window.alter_bufnr) ||
                \bufnr('%') == s:window.alter_bufnr
        enew
    else
        execute 'silent buffer' s:window.alter_bufnr
    endif
    let s:window.alter_bufnr = s:NULL
endfunc "}}}
func! s:win_is_active() abort "{{{
    if s:window.bufnr == s:NULL | return v:false | endif
    return !empty(win_findbuf(s:window.bufnr))
endfunc "}}}
func! s:win_call_buffer_modify_function(func_name,args) abort "{{{
    let bufnr = s:window.bufnr
    call setbufvar(bufnr,'&modifiable',1)
    call call(a:func_name,[bufnr] + a:args)
    call setbufvar(bufnr,'&modified',0)
    call setbufvar(bufnr,'&modifiable',0)
endfunc "}}}
func! s:win_setline(lnum,text) abort "{{{
    call s:win_call_buffer_modify_function('setbufline',[a:lnum,a:text])
endfunc "}}}
func! s:win_append(lnum,expr) abort "{{{
    call s:win_call_buffer_modify_function('appendbufline',[a:lnum,a:expr])
endfunc "}}}
func! s:win_deleteline(first,...) abort "{{{
    silent call s:win_call_buffer_modify_function('deletebufline',[a:first] + a:000)
endfunc "}}}
func! s:win_bufwipeouted() abort "{{{
    let s:window.bufnr = s:NULL
    let s:window.alter_bufnr = s:NULL
    call s:gram_exit()
endfunc "}}}
func! s:win_bufhidden() abort "{{{
    let s:window.alter_bufnr = s:NULL
    call s:gram_exit()
endfunc "}}}
func! s:win_is_cmdwin() abort "{{{
    return getcmdwintype() != ''
endfunc "}}}

" gram
func! vimrc#gram#launch(bearer) abort "{{{
    if s:gram_is_active()
        call s:notify.warning('gram is already active with a bearer: ' . s:active_bearer)
        call s:win_foreground()
        return
    endif
    if s:win_is_cmdwin()
        call s:notify.error('gram cannot be used on command-line window.')
        return
    endif
    for require in ['filter','regpat','selected','name']
        if !has_key(a:bearer,require)
            call s:notify.error('This bearer does not have required element: ' . require)
            return
        endif
    endfor

    let s:gram.bearer = a:bearer
    call extend(s:gram.bearer,s:gram_default_config,'keep')
    let s:active_bearer = s:gram.bearer.name
    let s:gram.prompt = s:gram.bearer.name . ' ' . s:gram.bearer.prompt
    let s:gram.user_input = ''
    call s:win_foreground()
    call s:gram_define_mapping()
    call s:gram_initialize_coloring()

    " Define dummy autocommands in order to avoid "No matching autocommands"
    " error.
    augroup gram-open-dummy
        au!
        au User gramOpen "Do nothing.
        execute 'au User' s:active_bearer . 'Open "Do nothing'
    augroup END
    doautocmd User gramOpen
    execute 'doautocmd User' s:active_bearer . 'Open'
    augroup gram-open-dummy
        au!
    augroup END

    call s:gram_flush_display(s:gram.user_input)
    call cursor(2,0)
endfunc "}}}
func! s:gram_initialize_coloring() abort "{{{
    highlight link gramMatch Number
    highlight link gramNoMatches Comment
    call s:gram_set_user_input_syntax(s:gram.user_input)
    syntax match gramNoMatches /\m\_^(No matches)$/
    augroup gram_coloring
        au!
        au ColorScheme * call s:gram_initialize_coloring()
    augroup END
endfunc "}}}
func! s:gram_set_user_input_syntax(input) abort "{{{
    silent syntax clear gramMatch
    exec 'syntax match gramMatch /\c\%>1l' . call(s:gram.bearer.regpat,[a:input]) . '/'
endfunc "}}}
func! s:gram_is_active() abort "{{{
    return s:active_bearer !=# ''
endfunc "}}}
func! s:gram_exit() abort "{{{
    if !s:gram_is_active() | return | endif
    call s:win_background()
    au! gram_coloring
    if has_key(s:gram.bearer,'exit')
        call call(s:gram.bearer.exit,[])
    endif
    let s:active_bearer = ''
    let s:gram.bearer = {}
    let s:gram.user_input = ''
endfunc "}}}
func! s:gram_flush_display(input) abort "{{{
    let prompt = s:gram.prompt . a:input
    let contents = call(s:gram.bearer.filter,[a:input])
    if empty(contents) | let contents = ['(No matches)'] | endif
    call s:win_deleteline(1,'$')
    call s:win_setline(1,[prompt] + contents)
    call s:gram_set_user_input_syntax(a:input) " It must be called after calling bearer's filter function.
    redraw
endfunc "}}}
func! s:gram_is_line_prompt(lnum) abort "{{{
    return a:lnum == s:gram.line_prompt
endfunc "}}}
func! s:gram_select() abort "{{{
    if s:gram_is_line_prompt(line('.')) | return | endif
    let selected_item = getline('.')
    call s:win_background()
    call call(s:gram.bearer.selected,[selected_item])
    call s:gram_exit()
endfunc "}}}
func! s:gram_loop_cursor(movement) abort "{{{
    let move_to = line('.') - s:gram.line_prompt + a:movement - 1
    let law = line('$') - s:gram.line_prompt
    let move_to = s:mod(move_to,law) + 2
    call cursor(move_to,col('%'))
endfunc "}}}
func! s:gram_prompter.on_changed(input) abort "{{{
    call s:gram_flush_display(a:input)
endfunc "}}}
func! s:gram_prompter.on_decided(input) abort "{{{
    let s:gram.user_input = a:input
endfunc "}}}
func! s:gram_prompter.on_exit() abort "{{{
    call s:gram_flush_display(s:gram.user_input)
    call cursor(2,0)
endfunc "}}}
func! s:gram_start_filtering() abort "{{{
    let s:gram_prompter.config = {
                \ 'prompt' : s:gram.prompt,
                \ 'default_input' : s:gram.user_input,
                \ }
    call vimrc#prompt#launch(s:gram_prompter)
endfunc "}}}
func! s:gram_define_mapping() abort "{{{
    let map = [
                \ ['loop-cursor-up','gram_loop_cursor(-v:count1)'],
                \ ['loop-cursor-down','gram_loop_cursor(v:count1)'],
                \ ['select-item','gram_select()'],
                \ ['start-filtering','gram_start_filtering()'],
                \ ['exit','gram_exit()'],
                \]
    call map(map,{key,val ->
                \'nnoremap <silent><buffer> <Plug>(gram-' . val[0] . ') ' .
                \':<C-u>call <SID>' . val[1] . '<CR>'})
    execute join(map,"\n")
endfunc "}}}

" User utility
func! vimrc#gram#escape_regpat(pat) abort "{{{
    return escape(a:pat,'.~/\^$[]:+*')
endfunc "}}}
func! vimrc#gram#glob2regpat(glob) abort "{{{
    let separator = '\' . s:shellslash()
    let special_chars_adapter = {
                \ '.' : {-> '\.'},
                \ '?' : {-> '.'},
                \ '*' : {char,pat_remnant->
                \       empty(pat_remnant) || pat_remnant[0] != '*' ?
                \       '\_[^\' . separator . ']\+' :
                \       [remove(pat_remnant,0),'.\+'][-1]
                \   },
                \}
    let regpat = '\m'
    let each_char = split(a:glob,'\zs')
    let normal_chars = ''
    while !empty(each_char)
        let char = remove(each_char,0)
        if has_key(special_chars_adapter,char)
            let regpat .= vimrc#gram#escape_regpat(normal_chars)
            let regpat .= special_chars_adapter[char](char,each_char)
            let normal_chars = ''
        else
            let normal_chars .= char
        endif
    endwhile
    if !empty(normal_chars)
        let regpat .= vimrc#gram#escape_regpat(normal_chars)
    endif
    return regpat
endfunc
"}}}

let &cpo = s:cpo_save
unlet s:cpo_save
