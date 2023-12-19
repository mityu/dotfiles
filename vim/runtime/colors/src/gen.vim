" NOTE: This file must be placed at <runtimepath>/colors/<dir-name>/gen.vim
vim9script

final ColorsDir = fnamemodify(expand('<sfile>:h:h'), ':p')

var ColorsInfo: dict<string>  # Keys are: name, path and background
var HiList: list<list<string>>
var HiLinkList: list<list<string>>
var Scripts: list<list<string>>

final GROUP = 0
final FG    = 1
final BG    = 2
final GUI   = 3
final TERM  = 4

export def Init(srcpath: string, background: string)
  HiList = []
  HiLinkList = []
  Scripts = []

  var fname = fnamemodify(srcpath, ':t')
  ColorsInfo.name = fnamemodify(fname, ':r')
  ColorsInfo.path = ColorsDir .. fname
  ColorsInfo.background = background
enddef

export def Hi(g: string, fg: string, bg: string, gui: string = '', term: string = '')
  add(HiList, [g, fg, bg, gui, term])
enddef

export def HiLink(src: string, dest: string)
  add(HiLinkList, [src, dest])
enddef

export def Script(lines: list<string>)
  add(Scripts, lines)
enddef

export def Generate()
  # TODO: check ColorsInfo is not blank

  var lines: list<string>
  lines->add('" vim: set expandtab smarttab shiftwidth=2')
  lines->add('" Generated by gen.vim on ' .. strftime('%d %b %Y'))
  lines->add('')
  lines->add('set background=' .. ColorsInfo.background)
  lines->add('highlight clear')
  lines->add("if exists('g:syntax_on')")
  lines->add('  syntax reset')
  lines->add('endif')
  lines->add('let g:colors_name = ' .. fnamemodify(ColorsInfo.name, ':r')->string())
  lines->add('')
  lines->add('')
  lines->extend(GenerateHiCmd())
  lines->add('')
  lines->extend(GenerateHiLinkCmd())
  lines->add('')
  lines->extend(GenerateScriptsSection())

  writefile(lines, ColorsInfo.path)
enddef

# Generate highlight color declarations from HiList
def GenerateHiCmd(): list<string>
  # highlight <group> <guifg> <guibg> <ctermfg> <ctermbg> <gui> <cterm> <term>
  var hiList = deepcopy(HiList)
  var groupNameMaxLen = 0
  var guiMaxLen = 0
  var termMaxLen = 0

  for hi in hiList
    for i in [FG, BG, GUI, TERM]
      if hi[i] ==# ''
        hi[i] = 'NONE'
      endif
    endfor

    var l: number
    l = strlen(hi[GROUP])
    if l > groupNameMaxLen
      groupNameMaxLen = l
    endif

    l = strlen(hi[GUI])
    if l > guiMaxLen
      guiMaxLen = l
    endif

    l = strlen(hi[TERM])
    if l > termMaxLen
      termMaxLen = l
    endif
  endfor

  var cmds: list<string>
  var groupNameFormatter = '%-' .. groupNameMaxLen .. 's'
  var guiFormatter = '%-' .. guiMaxLen .. 's'
  var termFormatter = '%-' .. termMaxLen .. 's'
  for hi in hiList
    var cmd = ['highlight', printf(groupNameFormatter, hi[GROUP])]
    cmd->add('guifg=' .. printf('%-7s', hi[FG]))
    cmd->add('guibg=' .. printf('%-7s', hi[BG]))
    cmd->add(printf('%-12s', 'ctermfg=' .. GetCtermColor(hi[FG])))
    cmd->add(printf('%-12s', 'ctermbg=' .. GetCtermColor(hi[BG])))
    cmd->add('gui=' .. printf(guiFormatter, hi[GUI]))
    cmd->add('cterm=' .. printf(guiFormatter, hi[GUI]))
    cmd->add('term=' .. printf(termFormatter, hi[TERM]))

    cmds->add(cmd->join()->substitute('\s*$', '', ''))
  endfor

  return cmds
enddef

# Generate highlight color declarations from HiLinkList
def GenerateHiLinkCmd(): list<string>
  var fromMaxLen = 0
  for [from, _] in HiLinkList
    var l = strlen(from)
    if l > fromMaxLen
      fromMaxLen = l
    endif
  endfor

  var cmds: list<string>
  var formatter = '%-' .. fromMaxLen .. 's %s'
  for [from, to] in HiLinkList
    cmds->add('highlight! link ' .. printf(formatter, from, to))
  endfor

  return cmds
enddef

def GenerateScriptsSection(): list<string>
  var script = []
  for block in Scripts
    script->extend(block->flattennew())
    script->add('')
  endfor
  return script
enddef


# Color converter: gui colors -> cterm colors
var ConvertedColors: dict<string>
def GetCtermColor(color_code: string): string
  if tolower(color_code) == 'none'
    return 'NONE'
  endif

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
enddef


final t_Co = str2nr(&t_Co)
# These functions are based on thinca/vim-guicolorscheme. Thank you!
def Graynum(x: number): number
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
enddef
def Graylvl(n: number): number
  if t_Co == 88
    return get([0, 46, 92, 115, 139, 162, 185, 208, 231], n, 255)
  else
    return n == 0 ? 0 : 8 + (n * 10)
  endif
enddef
def Gray(n: number): number
  if t_Co == 88
    return n == 0 ? 16 : n == 9 ? 79 : 79 + n
  else
    return n == 0 ? 16 : n == 25 ? 231 : 231 + n
  endif
enddef
def RGBnum(x: number): number
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
enddef
def RGBlvl(n: number): number
  if t_Co == 88
    return get([0, 139, 205], n, 255)
  else
    return n == 0 ? 0 : 55 + (n * 40)
  endif
enddef
def RGB(r: number, g: number, b: number): number
  if t_Co == 88
    return 16 + (r * 16) + (g * 4) + b
  else
    return 16 + (r * 36) + (g * 6) + b
  endif
enddef
def Color(r: number, g: number, b: number): number
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
enddef

export def BlendColor(baseCode: string, overlayCode: string, alphaRate: float): string
  const base = ParseColorcode(baseCode)
  const overlay = ParseColorcode(overlayCode)

  if alphaRate < 0.0 || alphaRate > 1.0
    echoerr 'Alpha must be in [0.0, 1.0]:' alphaRate
    return ''
  endif

  const alpha = float2nr(round(255 * alphaRate))
  const factorBase = 255 - alpha
  const factorOverlay = alpha
  var blended: list<number> = []
  for i in range(3)
    const c = (base[i] * factorBase + overlay[i] * factorOverlay) / 255
    blended->add(c)
  endfor
  blended->map('float2nr(round(v:val))')
  return printf('#%02x%02x%02x', blended[0], blended[1], blended[2])
enddef

def ParseColorcode(code: string): list<number>
  if code !~# '^#[0-9a-f]\{6}'
    echoerr 'Invalid color code:' code
    return []
  endif
  return code[1 :]->split('..\zs')->mapnew('str2nr(v:val, 16)')
enddef
