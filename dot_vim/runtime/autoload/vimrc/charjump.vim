" NOTE: This script doesn't consider 'selection'
vim9script

nnoremap <Plug>(VimrcCharJumpDo) <Cmd>call <SID>CharJumpDo()<CR>
onoremap <Plug>(VimrcCharJumpDo) <Cmd>call <SID>CharJumpDo()<CR>
vnoremap <Plug>(VimrcCharJumpDo) <Cmd>call <SID>CharJumpDo()<CR>

var CharJump: dict<any>
def CharJumpInit()
  CharJump = {
    forward: v:true,
    exclusive: v:false, # should be inclusive?
    char: '',
  }
enddef
CharJumpInit()

export def vimrc#charjump#jump(forward: bool, exclusive: bool): string
  var char = GetChar()
  if char ==# "\<ESC>"
    return "\<ESC>"
  elseif char ==# "\<C-k>"  # Support digraph
    for i in [0, 1]
      var graph = GetChar()
      if graph ==# "\<ESC>"  # Cancel
        return "\<ESC>"
      endif
      char ..= graph
    endfor
  elseif char ==# "\<C-v>"
    var graph = GetChar()
    if graph ==# "\<ESC>" # Cancel
      return "\<ESC>"
    endif
    char ..= graph
  endif
  CharJump.forward = forward
  CharJump.exclusive = exclusive
  CharJump.char = char
  return "\<Plug>(VimrcCharJumpDo)"  # A trick to make this dot-repeatable
enddef

export def vimrc#charjump#repeat(reverse: bool)
  var forward_save = CharJump.forward
  if reverse
    CharJump.forward = !CharJump.forward
  endif
  try
    CharJumpDo()
  finally
    CharJump.forward = forward_save
  endtry
enddef

def CharJumpDo()
  if CharJump.char ==# ''
    # Not valid
    return
  elseif CharJump.char[0] =~# '\a'
    CharJumpDo_alphabet()
  elseif CharJump.char[0] ==# "\<C-v>"
    CharJumpDo_theother(CharJump.char[1])
  else
    CharJumpDo_theother(CharJump.char)
  endif
enddef

def CharJumpDo_alphabet_search_pattern(): string
  # Jump to only boundary of words (support CamelCase and snake_case)
  var elements: list<string>
  if CharJump.char =~# '\l'
    var upper = toupper(CharJump.char)
    var lower = tolower(CharJump.char)
    elements = [
      '%(^|<|\A)@<=[' .. upper .. lower .. ']', # snake_case
      '[' .. upper .. lower .. ']%(>|\A|$)@=', # snake_case
      lower .. '\u@=', # CamelCase
      '\l@<=' .. upper, # CamelCase
    ]
  else
    elements = [
      '%(^|<|\A)@<=' .. CharJump.char,
      CharJump.char .. '%(>|\A|$)@=',
      '\l@<=' .. CharJump.char,
    ]
  endif
  return '\C\v%(' .. join(elements, '|') .. ')'
enddef

def CharJumpDo_alphabet()
  var curpos_save = getpos('.')
  var pattern = CharJumpDo_alphabet_search_pattern()
  if CharJump.exclusive
    if CharJump.forward
      pattern = '.' .. pattern .. '@='
    else
      pattern ..= '@<=.'
    endif
  endif
  var stopline = line('.')
  var flags = CharJump.forward ? '' : 'b'
  for i in range(v:count1)
    if search(pattern, flags, stopline) == 0  # Pattern not found
      setpos('.', curpos_save)
      return
    endif
  endfor
  if mode(1) ==# 'no'
    normal! v
    setpos('.', curpos_save)
  endif
enddef

def CharJumpDo_theother(char: string)
  var first_cur_pos = getcurpos()
  var operator = (CharJump.forward ? (CharJump.exclusive ? 't' : 'f') : (CharJump.exclusive ? 'T' : 'F'))
  execute 'normal! ' .. v:count1 .. operator .. char
  if mode(1) ==# 'no' && getcurpos() != first_cur_pos
    normal! v
    setpos('.', first_cur_pos)
  endif
enddef

def GetChar(): string
  var key: any = getchar()
  if type(key) == v:t_string
    return key
  endif
  return nr2char(key)
enddef

