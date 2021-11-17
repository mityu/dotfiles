function! s:getFocusedWorkspaceID() abort
  let tree = json_decode(system('i3-msg -t get_tree'))
  while !(empty(get(tree, 'focus', [])) || tree.focused)
    let focus = tree.focus[0]
    for n in tree.nodes + tree.floating_nodes
      if n.id == focus
        let tree = n
        break
      endif
    endfor
  endwhile

  if tree.focused
    return tree.id
  endif
  return -1
endfunction

" function! s:log(msg) abort
"   let logfile = expand('~/floating_app_log.txt')
"   let content = []
"   if filereadable(logfile)
"     let content = readfile(logfile)
"   endif
"   call add(content, strftime('%c') . ' ' . a:msg)
"   call writefile(content, logfile)
" endfunction

let s:FAIL = 0
let s:SUCCESS = !s:FAIL
function! OpenFloatingApp(opencmd) abort
  if !executable('i3-msg')
    return s:FAIL
  endif

  let focused = s:getFocusedWorkspaceID()
  if focused == -1
    return s:FAIL
  endif

  silent call system('i3-msg -q "exec --no-startup-id' . escape(a:opencmd, '"') . '"')
  if v:shell_error != 0
    return s:FAIL
  endif

  " Wait until focus is changed
  let wait_count = 0
  let wait_max_count = 100
  while 1
    let id = s:getFocusedWorkspaceID()
    if id == -1
      return s:FAIL
    elseif id != focused
      break
    endif

    sleep 10m
    let wait_count += 1
    if wait_count > wait_max_count
      return s:FAIL
    endif
  endwhile

  silent call system('i3-msg -q floating enable, move position center')
  if v:shell_error != 0
    return s:FAIL
  endif
  return 1
endfunction
