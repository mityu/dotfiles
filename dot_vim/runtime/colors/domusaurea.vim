"Last Change: 06-Sep-2019.
"Author: mityu
"This colorscheme based on billw

set background=dark
highlight clear
if exists('g:syntax_on')
  syntax reset
endif

let s:colors_name = expand('<sfile>:t:r')
let g:colors_name = s:colors_name

if !exists('s:TYPE_NUM')
  let s:TYPE_NUM = type(0)
  lockvar s:TYPE_NUM
endif

let s:palette = {
      \ 'black':             '#000000',
      \ 'white':             '#ffffff',
      \ 'yellow':            '#ffff00',
      \ 'darkred':           '#650000',
      \ 'red':               '#ff0000',
      \ 'tomato':            '#ff6347',
      \ 'orange':            '#ffa500',
      \ 'vividorange':       '#ff7f00',
      \ 'dullorange':        '#ff9932',
      \ 'darkorange':        '#5c4709',
      \ 'deeplydarkorange':  '#322705',
      \ 'tan':               '#ffa54f',
      \ 'cornsilk':          '#fff8dc',
      \ 'gray':              '#bebebe',
      \ 'lightgray':         '#555555',
      \ 'darkgray':          '#333333',
      \ 'blackgray':         '#1f1f1f',
      \ 'lightlightgray':    '#666666',
      \ 'gold':              '#ffd700',
      \ 'cyan':              '#00ffff',
      \ 'darkcyan':          '#008b8b',
      \ 'deeplydarkblue':    '#002a40',
      \ 'mediumspringgreen': '#00fa9a',
      \ 'green':             '#006519',
      \ 'darkgreen':         '#00320c',
      \ 'purple':            '#a020f0',
      \ 'violet':            '#ee82ee',
      \ 'lightsteelblue':    '#b0c4de',
      \ 'russet':            '#8b8b00',
      \ 'NONE':              'NONE'
      \ }

let s:gui_running = has('gui_running') || &termguicolors

function! s:get_color(name) abort "{{{
  return a:name ==# 'NONE' ? 'NONE' : s:get_raw_color(s:palette[a:name])
endfunction "}}}

if s:gui_running
  function! s:get_raw_color(code) abort "{{{
    return a:code
  endfunction "}}}
else
  let s:converted_colors = {}
  function! s:get_raw_color(color_code) abort "{{{
    let colorcode = a:color_code[1 :]
    if !has_key(s:converted_colors, colorcode)
      let code = str2nr(colorcode, 16)
      for kind in ['b', 'g', 'r']
        let {kind} = code % 256
        let code = code / 256
      endfor
      let s:converted_colors[colorcode] = s:color(r, g, b)
    endif
    return s:converted_colors[colorcode]
  endfunction "}}}


  " These functions are from thinca/vim-guicolorscheme. Thank you!
  function! s:greynum(x) "{{{
      if &t_Co == 88
          if a:x < 23
              return 0
          elseif a:x < 69
              return 1
          elseif a:x < 103
              return 2
          elseif a:x < 127
              return 3
          elseif a:x < 150
              return 4
          elseif a:x < 173
              return 5
          elseif a:x < 196
              return 6
          elseif a:x < 219
              return 7
          elseif a:x < 243
              return 8
          else
              return 9
          endif
      else
          if a:x < 14
              return 0
          else
              let l:n = (a:x - 8) / 10
              let l:m = (a:x - 8) % 10
              if l:m < 5
                  return l:n
              else
                  return l:n + 1
              endif
          endif
      endif
  endfunction "}}}
  function! s:greylvl(n) "{{{
      if &t_Co == 88
          if a:n == 0
              return 0
          elseif a:n == 1
              return 46
          elseif a:n == 2
              return 92
          elseif a:n == 3
              return 115
          elseif a:n == 4
              return 139
          elseif a:n == 5
              return 162
          elseif a:n == 6
              return 185
          elseif a:n == 7
              return 208
          elseif a:n == 8
              return 231
          else
              return 255
          endif
      else
          if a:n == 0
              return 0
          else
              return 8 + (a:n * 10)
          endif
      endif
  endfunction "}}}
  function! s:grey(n) "{{{
      if &t_Co == 88
          if a:n == 0
              return 16
          elseif a:n == 9
              return 79
          else
              return 79 + a:n
          endif
      else
          if a:n == 0
              return 16
          elseif a:n == 25
              return 231
          else
              return 231 + a:n
          endif
      endif
  endfunction "}}}
  function! s:rgbnum(x) "{{{
      if &t_Co == 88
          if a:x < 69
              return 0
          elseif a:x < 172
              return 1
          elseif a:x < 230
              return 2
          else
              return 3
          endif
      else
          if a:x < 75
              return 0
          else
              let l:n = (a:x - 55) / 40
              let l:m = (a:x - 55) % 40
              if l:m < 20
                  return l:n
              else
                  return l:n + 1
              endif
          endif
      endif
  endfunction "}}}
  function! s:rgblvl(n) "{{{
      if &t_Co == 88
          if a:n == 0
              return 0
          elseif a:n == 1
              return 139
          elseif a:n == 2
              return 205
          else
              return 255
          endif
      else
          if a:n == 0
              return 0
          else
              return 55 + (a:n * 40)
          endif
      endif
  endfunction "}}}
  function! s:rgb(r, g, b) "{{{
      if &t_Co == 88
          return 16 + (a:r * 16) + (a:g * 4) + a:b
      else
          return 16 + (a:r * 36) + (a:g * 6) + a:b
      endif
  endfunction "}}}
  function! s:color(r, g, b) "{{{
      " get the closest grey
      let l:gx = s:greynum(a:r)
      let l:gy = s:greynum(a:g)
      let l:gz = s:greynum(a:b)

      " get the closest color
      let l:x = s:rgbnum(a:r)
      let l:y = s:rgbnum(a:g)
      let l:z = s:rgbnum(a:b)

      let l:level = (a:r * a:r) + (a:g * a:g) + (a:b * a:b)
      if l:gx == l:gy && l:gy == l:gz
          " there are two possibilities
          let l:dgr = s:greylvl(l:gx)
          let l:dgg = s:greylvl(l:gy)
          let l:dgb = s:greylvl(l:gz)
          let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb) - l:level

          let l:dr = s:rgblvl(l:gx)
          let l:dg = s:rgblvl(l:gy)
          let l:db = s:rgblvl(l:gz)
          let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db) - l:level

          if l:dgrey < l:drgb
              " use the grey
              return s:grey(l:gx)
          else
              " use the color
              return s:rgb(l:x, l:y, l:z)
          endif
      else
          " only one possibility
          return s:rgb(l:x, l:y, l:z)
      endif
  endfunction "}}}
endif

function! s:hi(group, fg, bg, attr) "{{{
  let has_fg = type(a:fg) != s:TYPE_NUM
  let has_bg = type(a:bg) != s:TYPE_NUM
  let has_attr = type(a:attr) != s:TYPE_NUM

  if has_fg && !has_key(s:palette, a:fg)
    call s:echoerr(printf('color: %s does not exists. (specified in %s)',
                  \ a:fg, a:group))
    return
  endif
  if has_bg && !has_key(s:palette, a:bg)
    call s:echoerr(printf('color: %s does not exists. (specified in %s)',
                  \ a:bg, a:group))
    return
  endif

  let fg = has_fg ? a:fg : 'NONE'
  let bg = has_bg ? a:bg : 'NONE'
  let attr = has_attr ? a:attr : 'NONE'

  let type = s:gui_running ? 'gui' : 'cterm'
  let fg = printf('%sfg=%s', type, s:get_color(fg))
  let bg = printf('%sbg=%s', type, s:get_color(bg))

  if s:gui_running && &termguicolors
    let type = 'cterm'
  endif
  let attr = printf('%s=%s', type, attr)
  execute 'highlight' a:group fg bg attr
endfunction "}}}
function! s:echoerr(msg) "{{{
  echohl Error
  echom printf('[%s] %s', s:colors_name, a:msg)
  echohl None
endfunction "}}}


call s:hi('Normal','cornsilk','blackgray',0)
call s:hi('Comment','gold',0,0)
call s:hi('Constant','mediumspringgreen',0,0)
call s:hi('String','orange',0,0)
call s:hi('Character','orange',0,0)
call s:hi('Number','mediumspringgreen',0,0)
call s:hi('Boolean','mediumspringgreen',0,0)
call s:hi('Float','mediumspringgreen',0,0)

call s:hi('Statement','cyan',0,0)
call s:hi('Conditional','cyan',0,0)
call s:hi('Repeat','cyan',0,0)
call s:hi('Label','cyan',0,0)
call s:hi('Operator','cyan',0,0)

call s:hi('PreProc','lightsteelblue',0,0)
call s:hi('Include','lightsteelblue',0,0)
call s:hi('Define','lightsteelblue',0,0)
call s:hi('Macro','lightsteelblue',0,0)
call s:hi('PreCondit','lightsteelblue',0,0)

call s:hi('Type','yellow',0,0)
call s:hi('StorageClass','violet',0,0)
call s:hi('Structure','violet',0,0)

call s:hi('Identifier','yellow',0, 0)
call s:hi('Function','mediumspringgreen',0,0)

call s:hi('ErrorMsg','white','red',0)
call s:hi('WarningMsg','white','tomato',0)

call s:hi('Cursor',0,'cornsilk',0)
call s:hi('CursorIM',0,'purple',0)
call s:hi('CursorLine',0,'black', 0)
call s:hi('CursorColumn',0,'black',0)

call s:hi('LineNr','lightgray',0,0)
call s:hi('CursorLineNr','yellow',0,0)

call s:hi('Search','NONE','lightlightgray',0)
call s:hi('Visual','NONE','lightlightgray',0)
call s:hi('VisualNOS','black',0,0)
call s:hi('Title','orange',0,0)
call s:hi('Folded','gray','blackgray',0)
call s:hi('FoldColumn','lightlightgray','blackgray',0)
call s:hi('SignColumn',0,'blackgray',0)

call s:hi('StatusLine', 'darkgray', 'orange',0)
call s:hi('StatusLineNC', 'darkgray','russet',0)
call s:hi('TabLine','black','russet',0)
call s:hi('TabLineSel','black','orange',0)

call s:hi('Underlined',0,0,'underline')
call s:hi('Ignore','NONE',0,0)
call s:hi('SpecialKey','gray',0,0)

call s:hi('Directory','cyan',0,0)
call s:hi('Question','mediumspringgreen',0,0)
call s:hi('VertSplit','cornsilk','cornsilk',0)
call s:hi('MatchParen','NONE','purple',0)

call s:hi('WileMenu',0,'yellow',0)
call s:hi('Pmenu','cornsilk','vividorange',0)
call s:hi('PmenuSel','cornsilk','orange',0)
call s:hi('PmenuSbar',0,'white',0)
call s:hi('PmenuThumb',0,'gray',0)


call s:hi('DiffAdd', 0, 'deeplydarkorange', 0)
call s:hi('DiffDelete', 'deeplydarkblue', 'deeplydarkblue', 0)
call s:hi('DiffChange', 0, 'deeplydarkorange', 0)
call s:hi('DiffText', 0, 'darkorange', 0)

call s:hi('cStatement','violet',0,0)

hi! link Error ErrorMsg
hi! link TabLineFill TabLine
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineNC

" vim: set expandtab smarttab
