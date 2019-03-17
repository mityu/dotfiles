" Last Change: 16-Mar-2019.
scriptencoding utf-8
" if exists('b:did_ftplugin_after')
"   finish
" endif
" let b:did_ftplugin_after = 1

" Thanks to thinca!
" Global
function! s:option_to_view()
    setlocal buftype=help nomodifiable readonly
    setlocal nolist
    if exists('+colorcolumn')
        setlocal colorcolumn=
    endif
    if has('conceal')
        setlocal conceallevel=2
    endif
endfunction

function! s:option_to_edit()
    setlocal buftype= modifiable noreadonly
    setlocal list tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab textwidth=78
    if exists('+colorcolumn')
        setlocal colorcolumn=+1
    endif
    if has('conceal')
        setlocal conceallevel=0
    endif
endfunction

command! -buffer -bar HelpEdit call s:option_to_edit()
command! -buffer -bar HelpView call s:option_to_view()

if &buftype ==# 'help'
    nnoremap <buffer> <silent> q :<C-u>quit<CR>

    " Resize only when window isn't splited vertically and there's one help
    " window.
    if (&l:textwidth * 2) <= winwidth(0) &&
                \ len(filter(range(1,winnr('$')),
                \ 'getwinvar(v:val,"&buftype")==#"help"')) == 1
        wincmd L
        execute 'vertical resize' (&l:textwidth+5)
    endif
else
    " While editing only
    command! -buffer -bar GenerateContents call s:generate_contents()
    function! s:generate_contents()
        let cursor = getpos('.')

        let file_name = matchstr(expand('%:p:r:gs?\\?/?'), '.*/doc/\zs.*')
        let plug_name = substitute(file_name, '/', '-', 'g')
        let ja = expand('%:e') ==? 'jax'
        1

        if search('-contents\*$', 'W')
            silent .+1;/^=\{78}$/-1 delete _
            .-1
            put =''
        else
            keeppatterns /^License:\|Maintainer:/+1
            let header = printf('%s%s*%s-contents*', (ja ? "目次" : 'CONTENTS'),
            \                       repeat(' ', 50), plug_name)
            silent put =[repeat('=', 78), header, '']
        endif

        let contents_pos = getpos('.')

        let lines = []
        while search('^\([=-]\)\1\{77}$', 'W')
            let prefix = getline('.') =~# '=' ? '' : '  '
            .+1
            let caption = matchlist(getline('.'), '^\(\u*\)\s\+\*\(\S*\)\*$')
            if !empty(caption)
                let [title, tag] = caption[1 : 2]
                let margin = repeat(' ', 30 - strlen(prefix . title))
                call add(lines, printf('%s%s%s|%s|', prefix, title, margin, tag))
            endif
        endwhile

        call setpos('.', contents_pos)

        silent put =lines + repeat([''], 2)

        call setpos('.', cursor)
    endfunction

    function! s:get_text_on_cursor(pat)
        let line = getline('.')
        let pos = col('.')
        let s = 0
        while s < pos
            let [s, e] = [match(line, a:pat, s), matchend(line, a:pat, s)]
            if s < 0
                break
            elseif s < pos && pos <= e
                return line[s : e - 1]
            endif
            let s += 1
        endwhile
        return ''
    endfunction

    function! s:jump_to_tag() abort
        let tag = s:get_text_on_cursor('|\zs[^|]\+\ze|')
        if tag !=# ''
            let pat = escape(tag, '\')
            if !search('\V*\zs' . pat . '*', 'w')
                execute 'help' tag
            endif
        endif
    endfunction
    nnoremap <buffer> <silent> <C-]> :<C-u>call <SID>jump_to_tag()<CR>
endif
