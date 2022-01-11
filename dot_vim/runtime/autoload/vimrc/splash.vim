vim9script

final MODIFIERS = ["\<Cmd>", "\<Plug>", "\<SNR>"]
final ASCIIART =<< END
吾輩はやれば出来る子である。

        ∩ ∩
       ('･ω･)
   ____|⊃ ／(____
  /    *--(______/
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

やる気はまだない。

    ⊂⌒／`-..____
   /⊂_/_________/


END

def GetTextBlockWidth(text: list<string>): number
  return text->mapnew((_, val) => strdisplaywidth(val))->max()
enddef

def GetIntroMessage(): list<string>
  # Get :intro message
  silent intro

  var intro: list<string>
  for row in range(1, &lines)
    var line: string
    for column in range(1, &columns)
      line ..= screenstring(row, column)
    endfor
    add(intro, line)
  endfor
  intro->uniq()->map((_, val) => trim(val, ' ', 2))

  final index = mapnew(intro, (_, val) => match(val, '\S'))
                      ->filter((_, val) => val != -1)->min()
  intro->map((_, val) => val ==# '' ? '' : strpart(val, index))

  return intro
enddef

def GenerateSplash(): list<string>
  # Declare original splash
  var splash = copy(ASCIIART)
  var intro = GetIntroMessage()


  # Concatenate :intro message and original splash.
  final intro_width = GetTextBlockWidth(intro)
  final splash_width = GetTextBlockWidth(splash)
  final padding = repeat(' ', abs(intro_width - splash_width) / 2)
  if intro_width != splash_width
    (intro_width > splash_width ? splash : intro)->map((_, val) => padding .. val)
  endif

  return splash + intro
enddef

final SPLASH = GenerateSplash()


var RestoreSettings: func(): void

def ComputePadding(text: list<string>): list<number>
  final text_height = len(text)
  final text_width = GetTextBlockWidth(text)
  final win_height = &lines
  final win_width = &columns

  var padding = [0, 0, 0, 0]
  padding[0] = (win_height - text_height) / 2
  padding[1] = (win_width - text_width) / 2
  padding[2] = win_height - text_height - padding[0]
  padding[3] = win_width - text_width - padding[1]
  padding->map((_, val) => max([0, val]))

  return padding
enddef

def PopupFilter(winID: number, key: string): bool
  if key[0] !=# "\x80" || index(MODIFIERS, key) >= 0
    popup_close(winID)
  endif

  # Do not process <CR>
  if key ==# "\<CR>"
    return true
  endif
  return false
enddef

def PopupCallback(winID: number, result: number)
  augroup splash-vim
    autocmd!
  augroup END
  RestoreSettings()
enddef

def vimrc#splash#show()
  final splash = SPLASH[: &lines - 3]
  final popupID = popup_create(splash, {
    minwidth: &columns,
    minheight: &lines,
    highlight: 'Normal',
    scroll: 0,
    scrollbar: 0,
    wrap: 0,
    filter: expand('<SID>') .. 'PopupFilter',
    callback: expand('<SID>') .. 'PopupCallback',
    padding: ComputePadding(splash)
  })

  RestoreSettings = (t_ve: string): void => {
    &t_ve = t_ve
    setcellwidths([])
    redraw  # Reflect t_ve
  }->function([&t_ve])

  set t_ve= # Hide cursor
  setcellwidths([0x3c9, 0x2229]->mapnew('[v:val, v:val, 1]'))
  matchadd('SpecialKey', '<.\{-}>', 10, -1, {window: popupID})

  # It seems that popup-callback isn't called when quitting.
  augroup splash-vim
    autocmd!
    autocmd VimLeavePre * RestoreSettings()
  augroup END
enddef

def vimrc#splash#intro()
  if argc() == 0 && bufnr('$') == 1
    vimrc#splash#show()
  endif
enddef
