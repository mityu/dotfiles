vim9script

var SnipList: dict<list<func(string): bool>> = {}
var FuzzySnipList: dict<list<list<string>>> = {}
final CursorPlaceholder = '<+CURSOR+>'

export def Expand(): string
  var comparison = trim(getline('.'))
  if comparison ==# ''
    Warning('Empty pattern')
    return ''
  endif

  for SnipFunc in get(SnipList, &filetype, [])
    if SnipFunc(comparison)
      return ''
    endif
  endfor

  Error('Snippet not found: ' .. string(comparison))
  return ''
enddef

def ApplySnip(snip: list<string>)
  final current_indent = getline('.')->matchstr('^\s*')
  snip->map((_: number, line: string) =>
          current_indent .. substitute(line, "^\t*\t", GetOneIndentString(), 'g'))
  add(snip, current_indent) # Add a new line if there's no `CursorPlaceholder`

  var cursor_line = -1
  var cursor_col = strlen(snip[-1])

  for line in snip
    var idx = stridx(line, CursorPlaceholder)
    cursor_line += 1
    if idx >= 0
      cursor_col = idx
      snip[cursor_line] =
          strpart(line, 0, idx) .. line[idx + strlen(CursorPlaceholder) :]
      remove(snip, -1) # Remove the new line; It's not needed.
      break
    endif
  endfor

  if mode() ==# 'i'
    cursor_col += 1
  endif
  append('.', snip)
  delete _
  cursor(line('.') + cursor_line, cursor_col)
enddef

def GetOneIndentString(): string
  if &l:expandtab || strdisplaywidth("\t") != shiftwidth()
    return repeat(' ', shiftwidth())
  endif
  return "\t"
enddef

def Error(msg: string)
  echohl ErrorMsg
  echomsg '[pinsnip] ' .. msg
  echohl NONE
enddef

def Warning(msg: string)
  echohl WarningMsg
  echomsg '[pinsnip] ' .. msg
  echohl NONE
enddef

def SnipFiletype(filetype: string): list<func(string): bool>
  if !has_key(SnipList, filetype)
    SnipList[filetype] = []
  endif
  return SnipList[filetype]
enddef

def AddSnip(
  snips: list<func(string): bool>,
  Snip: func(string): bool,
): list<func(string): bool>
  snips->add(Snip)
  return snips
enddef

def TrySnipFuzzy(comparison: string): bool
  var snip = FindSnipFuzzy(comparison)
  if empty(snip)
    return false
  endif
  ApplySnip(snip)
  return true
enddef

def FindSnipFuzzy(comparison: string): list<string>
  final snips = get(FuzzySnipList, &filetype, [])
  if empty(snips)
    return []
  endif

  # Literal matching of the first line of snippet
  {
    var idx: number = -1
    var candidate: list<string>
    for snip in snips
      var idx_ = stridx(snip[0], comparison)
      if idx_ == -1
        continue
      endif
      if idx_ < idx || idx < 0
        idx = idx_
        candidate = snip
      endif
    endfor
    if idx != -1
      return candidate
    endif
  }

  # Fuzzy matching of the first line of snippet
  {
    var snipmap: dict<list<string>>
    for snip in snips
      snipmap[snip[0]] = snip
    endfor
    var candidates: list<string> = keys(snipmap)
              ->matchfuzzy(comparison, {matchseq: true})
    if !empty(candidates)
      return snipmap[candidates[0]]
    endif
  }
  return []
enddef


SnipFiletype('go')
  ->AddSnip((comparison: string): bool => {
    var r = '^\v(}\s*else\s+)?if(\s*.{-};)?\s*%(e%[rr]\s*%(!=\s*nil\s*)?(\S+)?)'

    var m = matchlist(comparison, r)
    if empty(m)
      return false
    endif

    var [else_unit, initializer, kind] = m[1 : 3]
    var snip = [else_unit .. 'if' .. initializer .. ' err != nil {']
    if kind !=# ''
      var processes = [
        'return err',
        'fmt.Println(err)',
        'log.Fatal(err)',
        'panic(err)',
        't.Error(err)',
        't.Fatal(err)',
      ]
      for p in processes
        if stridx(tolower(p), kind) != -1
          snip->add("\t" .. p)
          break
        endif
      endfor
    endif
    if len(snip) == 1
      snip->add("\t<+CURSOR+>")
    endif
    snip->add('}')
    ApplySnip(snip)
    return true
  })
  ->AddSnip((line: string): bool => {
    var r = '^\v((\w|_)+)\s*:\=\s*func\((.{-})\)\s*(\S+|\(%(\s*\S+)+\s*\))?\s*\{\s*$'
    var m = matchlist(line, r)
    if empty(m)
      return false
    endif
    var funcName = m[1]
    var funcArgs = m[3]
    var funcRet  = m[4]
    var funcArgTypes = substitute(
      ',' .. funcArgs,
      '\v(%(\s*,\s*%(\w|_)+)+)\s+(\S+)\ze%(,|$)',
      (): string => (repeat([submatch(2)], count(submatch(1), ',')) + [''])->join(', '),
      'g')[: -3]

    var funcVarDecl = 'var ' .. funcName .. ' func(' .. funcArgTypes .. ')'
    if funcRet !=# ''
      funcVarDecl ..= ' ' .. funcRet
    endif

    var funcDecl = funcName .. ' = func(' .. funcArgs .. ')'
    if funcRet !=# ''
      funcDecl ..= ' ' .. funcRet
    endif
    funcDecl ..= ' {<+CURSOR+>'

    ApplySnip([funcVarDecl, funcDecl])
    return true
  })

SnipFiletype('cpp')->AddSnip(TrySnipFuzzy)
FuzzySnipList['cpp'] = [
  ['std::cout << "<+CURSOR+>" << std::endl;'],
  ['std::cerr << "<+CURSOR+>" << std::endl;'],
  ['template <typename T>'],
]

SnipFiletype('vim')
  ->AddSnip((comparison: string): bool => {
    var curidx = col('.') - 1 - (mode() ==# 'i' ? 1 : 0)
    if curidx < 0 || getline('.')[curidx] !=# '#'
      return false
    endif

    var fname = expand('%:p')
    var strridx = strridx(fname, 'autoload')
    if fnamemodify(fname, ':e') !=# 'vim' || strridx == -1
      return false
    endif

    var autoload_name =
      fnamemodify(fname, ':r')
      ->strpart(strridx + 9)  # Skip 'autoload/' or 'autoload\'
      ->split('[/\\]')
      ->join('#') .. '#'

    var snip =
      strpart(getline('.'), 0, curidx) ..
      autoload_name ..
      '<+CURSOR+>' ..
      getline('.')[curidx + 1 :]
    ApplySnip([snip])

    return true
  })
  ->AddSnip((comparison: string): bool => {
    var r = '^\v(leg%[acy]\s*)?(fu%[nction])(!?\s*.*$)'
    var m = matchlist(comparison, r)
    if empty(m)
      return false
    endif

    var fnlen = strlen(m[2])
    m[2] = 'function'
    var col = col('.') - (mode() ==# 'i' ? 1 : 0)
    if col >= (strlen(m[1]) + fnlen)
      col += strlen(m[2]) - fnlen
    endif
    var snip = join(m[1 :], '')
    snip = strpart(snip, 0, col) .. '<+CURSOR+>' .. snip[col :]
    ApplySnip([snip])

    return true
  })
  ->AddSnip(TrySnipFuzzy)
FuzzySnipList['vim'] = [
  [
    'let s:cpoptions_save = &cpoptions',
    'set cpoptions&vim',
    '',
    '<+CURSOR+>',
    '',
    'let &cpoptions = s:cpoptions_save',
    'unlet s:cpoptions_save'
  ]
]

SnipFiletype('rust')
  ->AddSnip((comparison: string): bool => {
    var curpos = getcurpos()
    var word = ''
    try
      normal! h
      word = expand('<cword>')
      if word !~? '^r\%[esult]$'
        return false
      endif
    finally
      setpos('.', curpos)
    endtry
    var cmd = repeat("\<C-h>", strchars(word)) .. 'Result<(), String>'
    feedkeys(cmd, 'ni')
    return true
  })

SnipFiletype('java')
  ->AddSnip((comparison: string): bool => {
    var r = '^\v%(public\s+)?class%(\s+\w+\s*\{)?$'
    if comparison !~# r
      return false
    endif

    var snip = 'public class %s {'
    var fname = expand('%:t:r')
    if fname ==# ''
      fname = '<+CURSOR+>'
    else
      snip ..= '<+CURSOR+>'
    endif
    snip = printf(snip, fname)
    ApplySnip([snip])

    return true
  })
  ->AddSnip(TrySnipFuzzy)

FuzzySnipList['java'] = [
  ['public static void main(String[] args) {<+CURSOR+>'],
]
