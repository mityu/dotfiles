SetUndoFtplugin set backupcopy<

setlocal backupcopy=yes

function s:range_str(min, full) abort
  return range(strlen(a:min), strlen(a:full))->map({_, v -> strpart(a:full, 0, v)})
endfunction

function s:getline_before_cursor() abort
  return getline('.')->strpart(0, col('.') - 1)
endfunction

function s:do_iabbrev_envname(trigger, full) abort
  " When the abbreviation is triggered by <CR>, then the cursor is already on
  " the next line.  In that case, we need to do check with the previous line's
  " text instead of the current line's one to decide whether we'll apply an
  " abbreviation.
  let line = s:getline_before_cursor()
  if trim(line) ==# ''
    let line = getline(line('.') - 1)
  endif

  if line =~# '\\\%(begin\|end\){' .. a:trigger .. '$'
    return a:full
  elseif line =~# '^\s*\\' .. a:trigger .. '$'
    " NOTE: Here, we use `v:char` to get the trigger character of this
    " abbreviation.  However, it's undocumented and may be broken somewhere or
    " sometime.
    if v:char !=# '*'
      return printf('begin{%s}', a:full)
    else
      " The `getchar(0)` is for eating the trigger character.
      return printf("begin{%s*}\<Cmd>call getchar(0)\<CR>", a:full)
    endif
  else
    return a:trigger
  endif
endfunction

function s:setup_iabbrev_envname(min, full) abort
  for trigger in s:range_str(a:min, a:full)
    execute $'SetUndoFtplugin iunabbrev <buffer> {trigger}'
    execute $'inoreabbrev <expr> <buffer> {trigger} <SID>do_iabbrev_envname("{trigger}", "{a:full}")'
  endfor
endfunction

call s:setup_iabbrev_envname('enum', 'enumerate')
call s:setup_iabbrev_envname('enump', 'enumproof')
call s:setup_iabbrev_envname('itemi', 'itemize')
call s:setup_iabbrev_envname('eq', 'equation')
call s:setup_iabbrev_envname('ali', 'align')
call s:setup_iabbrev_envname('ga', 'gather')
call s:setup_iabbrev_envname('lem', 'lem')
call s:setup_iabbrev_envname('proo', 'proof')
