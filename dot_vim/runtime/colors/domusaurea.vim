" Last Change: 21-Dec-2020.
" Author: mityu
" This colorscheme is based on billw
vim9script

set background=dark
highlight clear
if exists('g:syntax_on')
  syntax reset
endif

final ColorsName = expand('<sfile>:t:r')
g:colors_name = ColorsName

final Palette = {
      black:             '#000000',
      white:             '#ffffff',
      yellow:            '#ffff00',
      darkred:           '#650000',
      red:               '#ff0000',
      tomato:            '#ff6347',
      orange:            '#ffa500',
      vividorange:       '#ff7f00',
      darkorange:        '#5c4709',
      deeplydarkorange:  '#322705',
      cornsilk:          '#fff8dc',
      gray:              '#bebebe',
      lightgray:         '#555555',
      darkgray:          '#333333',
      blackgray:         '#1f1f1f',
      lightlightgray:    '#666666',
      gold:              '#ffd700',
      cyan:              '#00ffff',
      deeplydarkblue:    '#002a40',
      mediumspringgreen: '#00fa9a',
      purple:            '#a020f0',
      violet:            '#ee82ee',
      lightsteelblue:    '#b0c4de',
      russet:            '#8b8b00',
      paneldarkorange:   '#493f2f',
      panelorange:       '#706656',
      panellightorange:  '#caca9d',
      sbarorange:        '#82775a',
      thumborange:       '#b6b689',
      NONE:              'NONE'
}

var GuiRunning = has('gui_running') || &termguicolors

def GetColor(name: string): string # {{{
  return name ==# 'NONE' ? 'NONE' : GetRawColor(Palette[name])
enddef # }}}

if GuiRunning
  g:terminal_ansi_colors = [
        '#000000',
        '#d54e53',
        '#b9ca4a',
        '#e6c547',
        '#7aa6da',
        '#c397d8',
        '#70c0ba',
        '#eaeaea',
        '#666666',
        '#ff3334',
        '#9ec400',
        '#e7c547',
        '#7aa6da',
        '#b77ee0',
        '#54ced6',
        '#ffffff',
  ]
endif

if GuiRunning
  def GetRawColor(code: string): string # {{{
    return code
  enddef # }}}
else
  var ConvertedColors = {}
  def GetRawColor(color_code: string): string # {{{
    var colorcode = color_code[1 :]
    if !has_key(ConvertedColors, colorcode)
      var code = str2nr(colorcode, 16)
      var color = {r: 0, g: 0, b: 0}
      for kind in ['b', 'g', 'r']
        color[kind] = code % 256
        code = code / 256
      endfor
      ConvertedColors[colorcode] = Color(color.r, color.g, color.b)->string()
    endif
    return ConvertedColors[colorcode]
  enddef # }}}


  final t_Co = str2nr(&t_Co)
  # These functions are based on thinca/vim-guicolorscheme. Thank you!
  def Graynum(x: number): number # {{{
    if t_Co == 88
      return [22, 68, 102, 126, 149, 172, 195, 218, 242, x]->sort('n')->index(x)
    else
      if x < 14
        return 0
      else
        var n = (x - 8) / 10
        var m = (x - 8) % 10
        return m < 5 ? n : n + 1
      endif
    endif
  enddef # }}}
  def Graylvl(n: number): number # {{{
    if t_Co == 88
      return get([0, 46, 92, 115, 139, 162, 185, 208, 231], n, 255)
    else
      return n == 0 ? 0 : 8 + (n * 10)
    endif
  enddef # }}}
  def Gray(n: number): number # {{{
    if t_Co == 88
      return n == 0 ? 16 : n == 9 ? 79 : 79 + n
    else
      return n == 0 ? 16 : n == 25 ? 231 : 231 + n
    endif
  enddef # }}}
  def RGBnum(x: number): number # {{{
    if t_Co == 88
      return [68, 171, 229, x]->sort('n')->index(x)
    else
      if x < 75
        return 0
      else
        var n = (x - 55) / 40
        var m = (x - 55) % 40
        return m < 20 ? n : n + 1
      endif
    endif
  enddef # }}}
  def RGBlvl(n: number): number # {{{
    if t_Co == 88
      return get([0, 139, 205], n, 255)
    else
      return n == 0 ? 0 : 55 + (n * 40)
    endif
  enddef # }}}
  def RGB(r: number, g: number, b: number): number # {{{
    if t_Co == 88
      return 16 + (r * 16) + (g * 4) + b
    else
      return 16 + (r * 36) + (g * 6) + b
    endif
  enddef # }}}
  def Color(r: number, g: number, b: number): number # {{{
    # get the closest Gray
    var gx = Graynum(r)
    var gy = Graynum(g)
    var gz = Graynum(b)

    # get the closest color
    var x = RGBnum(r)
    var y = RGBnum(g)
    var z = RGBnum(b)

    var level = (r * r) + (g * g) + (b * b)
    if gx == gy && gy == gz
      # there are two possibilities
      var dgr = Graylvl(gx)
      var dgg = Graylvl(gy)
      var dgb = Graylvl(gz)
      var dgrey = (dgr * dgr) + (dgg * dgg) + (dgb * dgb) - level

      var dr = RGBlvl(gx)
      var dg = RGBlvl(gy)
      var db = RGBlvl(gz)
      var drgb = (dr * dr) + (dg * dg) + (db * db) - level

      if dgrey < drgb
        # use the Gray
        return Gray(gx)
      else
        # use the color
        return RGB(x, y, z)
      endif
    else
      # only one possibility
      return RGB(x, y, z)
    endif
  enddef # }}}
endif

def Hi(group: string, fg: string, bg: string, attr: string) # {{{
  var has_fg = fg !=# ''
  var has_bg = bg !=# ''
  var has_attr = attr !=# ''

  if has_fg && !has_key(Palette, fg)
    Echoerr(printf('color: %s does not exists. (specified in %s)',
                  \ fg, group))
    return
  endif
  if has_bg && !has_key(Palette, bg)
    Echoerr(printf('color: %s does not exists. (specified in %s)',
                  \ bg, group))
    return
  endif

  var color_fg = has_fg ? fg : 'NONE'
  var color_bg = has_bg ? bg : 'NONE'
  var cmd_attr = has_attr ? attr : 'NONE'

  var type = GuiRunning ? 'gui' : 'cterm'
  var cmd_fg = printf('%sfg=%s', type, GetColor(color_fg))
  var cmd_bg = printf('%sbg=%s', type, GetColor(color_bg))

  if GuiRunning && &termguicolors
    type = 'cterm'
  endif
  cmd_attr = printf('%s=%s', type, cmd_attr)
  execute 'highlight' group cmd_fg cmd_bg cmd_attr
enddef # }}}
def Echoerr(msg: string) # {{{
  echohl Error
  echomsg printf('[%s] %s', ColorsName, msg)
  echohl None
enddef # }}}


# highlight statements
Hi('Normal', 'cornsilk', 'blackgray', '')
Hi('Comment', 'gold', '', '')
Hi('Constant', 'mediumspringgreen', '', '')
Hi('String', 'orange', '', '')
Hi('Character', 'orange', '', '')
Hi('Number', 'mediumspringgreen', '', '')
Hi('Boolean', 'mediumspringgreen', '', '')
Hi('Float', 'mediumspringgreen', '', '')

Hi('Statement', 'cyan', '', '')
Hi('Conditional', 'cyan', '', '')
Hi('Repeat', 'cyan', '', '')
Hi('Label', 'cyan', '', '')
Hi('Operator', 'cyan', '', '')

Hi('PreProc', 'lightsteelblue', '', '')
Hi('Include', 'lightsteelblue', '', '')
Hi('Define', 'lightsteelblue', '', '')
Hi('Macro', 'lightsteelblue', '', '')
Hi('PreCondit', 'lightsteelblue', '', '')

Hi('Type', 'yellow', '', '')
Hi('StorageClass', 'violet', '', '')
Hi('Structure', 'violet', '', '')

Hi('Identifier', 'yellow', '', '')
Hi('Function', 'mediumspringgreen', '', '')

Hi('ErrorMsg', 'white', 'red', '')
Hi('WarningMsg', 'white', 'tomato', '')

Hi('Cursor', 'blackgray', 'cornsilk', '')
Hi('CursorIM', 'blackgray', 'purple', '')
Hi('CursorLine', '', 'black', '')
Hi('CursorColumn', '', 'black', '')

Hi('LineNr', 'lightgray', '', '')
Hi('CursorLineNr', 'yellow', '', '')

Hi('Search', 'NONE', 'lightlightgray', '')
Hi('Visual', 'NONE', 'lightlightgray', '')
Hi('VisualNOS', 'black', '', '')
Hi('Title', 'orange', '', '')
Hi('Folded', 'gray', 'blackgray', '')
Hi('FoldColumn', 'lightlightgray', 'blackgray', '')
Hi('SignColumn', '', 'blackgray', '')

Hi('StatusLine', 'darkgray', 'orange', '')
Hi('StatusLineNC', 'darkgray', 'russet', '')
Hi('TabLine', 'black', 'russet', '')
Hi('TabLineSel', 'black', 'orange', '')

Hi('Underlined', '', '', 'underline')
Hi('Ignore', 'NONE', '', '')
Hi('SpecialKey', 'gray', '', '')

Hi('Directory', 'cyan', '', '')
Hi('Question', 'mediumspringgreen', '', '')
Hi('VertSplit', 'cornsilk', 'cornsilk', '')
Hi('MatchParen', 'NONE', 'purple', '')

Hi('WileMenu', '', 'yellow', '')
Hi('Pmenu', 'panellightorange', 'paneldarkorange', '')
Hi('PmenuSel', 'panellightorange', 'panelorange', '')
Hi('PmenuSbar', '', 'sbarorange', '')
Hi('PmenuThumb', '', 'thumborange', '')


Hi('DiffAdd', '', 'deeplydarkorange', '')
Hi('DiffDelete', 'deeplydarkblue', 'deeplydarkblue', '')
Hi('DiffChange', '', 'deeplydarkorange', '')
Hi('DiffText', '', 'darkorange', '')

# TODO: Specify good colors.
Hi('SpellBad', '', 'darkred', '')
Hi('SpellCap', '', 'darkred', '')
Hi('SpellLocal', '', 'darkred', '')
Hi('SpellRare', '', 'darkred', '')

Hi('cStatement', 'violet', '', '')


highlight StatuslineNC guibg=#a79000
highlight CursorLineNr guibg=#393939 guifg=#ffff00
highlight Tabline guibg=#a0933d guifg=#333333
highlight TablineSel guibg=#ffa000 guifg=#1f1f1f

highlight! link Error ErrorMsg
highlight! link TabLineFill TabLine
highlight! link StatusLineTerm StatusLine
highlight! link StatusLineTermNC StatusLineNC
highlight! link QuickFixLine CursorLine

augroup domusaurea
  autocmd!
  execute 'autocmd OptionSet termguicolors ++nested colorscheme' ColorsName
  autocmd ColorSchemePre * ++once autocmd! domusaurea OptionSet
augroup END

# Plugins
g:cursorword_highlight = 0
highlight CursorWord0 term=underline cterm=underline gui=underline
highlight CursorWord1 term=underline cterm=underline gui=underline ctermbg=NONE guibg=NONE

# vim: set expandtab smarttab shiftwidth=2
