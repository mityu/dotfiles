if !(executable('i3-msg') && executable('wezterm'))
  cquit!
endif

function! s:getFocusedWorkspaceID() abort
  let tree = json_decode(system('i3-msg -t get_tree'))
  while !empty(tree.focus)
    let focus = tree.focus[0]
    for n in tree.nodes
      if n.id == focus
        let tree = n
      endif
    endfor
  endwhile

  if tree.focused
    return tree.id
  endif
  return -1
endfunction

let s:focused = s:getFocusedWorkspaceID()
if s:focused == -1
  cquit!
endif

call system('i3-msg "exec --no-startup-id wezterm"')

" Wait for focus is changed
let s:count = 0
let s:wait_max_count = 100
while 1
  let s:id = s:getFocusedWorkspaceID()
  if s:id == -1
    cquit!
  elseif s:id != s:focused
    break
  endif

  sleep 10m
  let s:count += 1
  if s:count > s:wait_max_count
    cquit!
  endif
endwhile

call system('i3-msg floating enable')
qall!
