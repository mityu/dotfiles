vim9script

var SnipList: dict<dict<list<string>>> = {}
final CursorPlaceholder = '<+CURSOR+>'

export def vimrc#pinsnip#expand(): string
  var comparison = trim(getline('.'))
  if comparison ==# ''
    Warning('Empty pattern')
    return ''
  endif
  var snip = copy(FindSnip(&filetype, comparison))
  if empty(snip)
    Error('Snippet not found: ' .. string(comparison))
    return ''
  endif

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

  return ''
enddef

def GetOneIndentString(): string
  if &l:expandtab || strdisplaywidth("\t") != shiftwidth()
    return repeat(' ', shiftwidth())
  endif
  return "\t"
enddef

def FindSnip(filetype: string, comparison: string): list<string>
  var snipdict = get(SnipList, filetype, {})
  if empty(snipdict)
    return []
  endif

  # Exact matching of dict-key
  if has_key(snipdict, comparison)
    return snipdict[comparison]
  endif

  final keys = keys(snipdict)
  final comparison_reg = '\V' .. comparison

  # Literal matching of dict-key
  {
    var candidates: list<string> =
          copy(keys)->filter((_, key) => (stridx(key, comparison) != -1))
    if !empty(candidates)
      return snipdict[candidates[0]]
    endif
  }

  # Fuzzy matching of dict-key
  {
    var candidates: list<string> =
            matchfuzzy(keys, comparison, {matchseq: true})
    if !empty(candidates)
      return snipdict[candidates[0]]
    endif
  }

  final snips = values(snipdict)

  # Literal matching of the first line of snippet
  {
    var idx: number = -1
    var candidate: list<string>
    for snip in snips
      var _ = stridx(snip[0], comparison)
      if _ == -1
        continue
      endif
      if _ < idx || idx < 0
        idx = _
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

def SnipFiletype(filetype: string): dict<list<string>>
  if !has_key(SnipList, filetype)
    SnipList[filetype] = {}
  endif
  return SnipList[filetype]
enddef
def AddSnip(
  snips: dict<list<string>>,
  name: string,
  snip: list<string>,
): dict<list<string>>
  snips[name] = snip
  return snips
enddef


SnipFiletype('go')
  ->AddSnip('ifnil', [
    'if err != nil {',
    "\tfmt.Println(err)",
    "}"
    ])
SnipFiletype('cpp')
  ->AddSnip('std::cout', ['std::cout << "<+CURSOR+>" << std::endl;'])
  ->AddSnip('std::cerr', ['std::cerr << "<+CURSOR+>" << std::endl;'])
  ->AddSnip('template', ['template <typename T>'])
SnipFiletype('vim')
  ->AddSnip('cpoptions', [
      'let s:cpoptions_save = &cpoptions',
      'set cpoptions&vim',
      '',
      '<+CURSOR+>',
      '',
      'let &cpoptions = s:cpoptions_save',
      'unlet s:cpoptions_save'
      ])
