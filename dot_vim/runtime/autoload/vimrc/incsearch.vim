vim9script

# TODO: Implement c_CTRL-G and c_CTRL-T like key-mapping

export def Setup()
  final cmdwintype = getcmdwintype()
  if !(cmdwintype ==# '/' || cmdwintype ==# '?')
    return
  endif

  var flags = 'cw'
  var flags_turn = flags
  if cmdwintype ==# '?'
    flags ..= 'b'
  else
    flags_turn ..= 'b'
  endif

  final winID = win_getid(winnr('#'))
  final curpos = WinExecute(winID, 'echon getcurpos()')->eval()
  State = {
    winID: winID,
    matchID: -1,
    search_flags: flags,
    search_flags_turn: flags_turn,
    restore_curpos_command: printf('call setpos(".", %s)', curpos),
  }

  augroup vimrc-incsearch
    autocmd!
    autocmd TextChanged,TextChangedI,CursorMoved * DoIncsearch()
    autocmd CmdwinLeave * ++once Terminate()
  augroup END
enddef

def Terminate()
  augroup vimrc-incsearch
    autocmd!
  augroup END
  ClearHighlight()
  AlterWinExecute(State.restore_curpos_command)
enddef

def ClearHighlight()
  if State.matchID != -1
    matchdelete(State.matchID, State.winID)
    State.matchID = -1
  endif
enddef

def DoIncsearch()
  ClearHighlight()
  AlterWinExecute(State.restore_curpos_command)

  var pattern = getline('.')
  if pattern ==# '' || !IsValidRegexp(pattern)
    return
  endif

  State.matchID = matchadd('Search', pattern, 10, -1, {window: State.winID})
  AlterWinExecute(printf('call search(%s, "%s")', string(pattern), State.search_flags))
  redraw
enddef

def InitializeState()
  State = {
    winID: 1000,
    matchID: -1,
    search_flags: '',
    search_flags_turn: '',
    restore_curpos_command: '',
  }
enddef
var State: dict<any>

def WinExecute(winID: number, command: string): any
  var eventignore_save = &eventignore
  set eventignore=all
  try
    return win_execute(winID, command)
  finally
    &eventignore = eventignore_save
  endtry
  return ''
enddef

def AlterWinExecute(command: string): any
  return WinExecute(State.winID, command)
enddef

def IsValidRegexp(regexp: string): bool
  try
    eval '' =~# regexp
  catch
    # TODO: Show error?
    return false
  endtry
  return true
enddef
