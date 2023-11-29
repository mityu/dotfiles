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

  for SnipFunc in get(SnipList, &filetype, []) + get(SnipList, '_', [])
    if SnipFunc(comparison)
      return ''
    endif
  endfor

  Error('Snippet not found: ' .. string(comparison))
  return ''
enddef

def ApplySnip(snip_arg: list<string>)
  final current_indent = getline('.')->matchstr('^\s*')
  var snip = copy(snip_arg)
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

def MergeSnip(snips: list<func(string): bool>, ftSrc: string): list<func(string): bool>
  snips->extend(SnipFiletype(ftSrc))
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


# Returns getline('.')->trimleft()->split_at_cursor_pos()
# Note that this function must be called in insert mode.
def GetlineDividedByCursor(): list<string>
  var col = col('.') - 1
  var line = getline('.')
  var div = [strpart(line, 0, col), line[col :]]
  div[0] = trim(div[0], " \t", 1)
  return div
enddef


SnipFiletype('go')
  ->AddSnip((comparison: string): bool => {
    const r = '^\v(}\s*else\s+)?if(\s*.{-};)?\s*%(e%[rr]\s*%(!=\s*nil\s*)?(\S+)?)'

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
      snip->add("\t" .. CursorPlaceholder)
    endif
    snip->add('}')
    ApplySnip(snip)
    return true
  })
  ->AddSnip((line: string): bool => {
    const r = '^\v((\w|_)+)\s*:\=\s*func\((.{-})\)\s*(\S+|\(%(\s*\S+)+\s*\))?\s*\{\s*$'
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
    funcDecl ..= ' {' .. CursorPlaceholder

    ApplySnip([funcVarDecl, funcDecl])
    return true
  })

SnipFiletype('c')
  ->AddSnip((comparison: string): bool => {
    # for (type i; until|  =>  for (type i; i < until; ++i) {
    var matches = matchlist(
      comparison,
      '\v^for\s*\((%(\w+\s*)*)(\w+)\s*;\s*(\w+)%(\s*\))?$'
    )
    if empty(matches)
      return false
    endif
    var [type, varName, until] = matches[1 : 3]
    var snip = printf(
      'for (%s %s = 0; %s < %s; ++%s) {' .. CursorPlaceholder,
      trim(type), varName, varName, until, varName
    )
    ApplySnip([snip])
    return true
  })
  ->AddSnip((comparison: string): bool => {
    var matches = matchlist(
      comparison,
      '^\vfor\s*\(\s*([^;]+\s*)%(;\s*([^;]+)\s*)?%(;\s*([^;]+\s*))?(\)(\s*[{;])?)?$'
    )
    if empty(matches)
      return false
    endif

    var [initializer, expr, iterator, suffix] = matches[1 : 4]
    var varName = matchstr(initializer, '^\v%(\w+\s+)*\zs\w+\ze%(\s*\=\s*\S+)?$')
    if expr ==# ''
      expr = $'{varName} < {CursorPlaceholder}'
    elseif !(expr =~# '\s' || expr =~# '[<>=]')
      expr = printf('%s < %s', varName, expr)
    endif
    if iterator ==# ''
      iterator = '++' .. varName
    endif
    if suffix ==# ''
      suffix = ') {'
    endif

    var snip = printf('for (%s; %s; %s%s', initializer, expr, iterator, suffix)
    if stridx(snip, CursorPlaceholder) == -1
      snip ..= CursorPlaceholder
    endif
    ApplySnip([snip])
    return true
  })
  ->AddSnip((comparison: string): bool => {
    var fname = bufname('%')->fnamemodify(':t')
    if fname ==# '' || fnamemodify(fname, ':e') !~? '^h'
      # No filename or non header file.  Do not apply.
      return false
    endif
    var guardian = fname->toupper()->tr('.-', '__') .. '_'  # Include guard
    var snip = [
      $'#ifndef {guardian}',
      $'#define {guardian}',
      '',
      CursorPlaceholder,
      '',
      $'#endif  // {guardian}'
    ]
    if stridx(snip[0], comparison) == -1
      return false
    endif
    ApplySnip(snip)
    return true
  })
  ->AddSnip((comparison: string): bool => {
    # Complete closing #endif for current #if, #ifdef, or #ifndef.
    if comparison !~# '\v^#\s*if%(n?def)?>'
      return false
    endif
    var padding = matchstr(comparison, '\v^#\zs\s*\zeif%(n?def)?')
    var [pre, suf] = GetlineDividedByCursor()
    var snip = [
      $'{pre}{CursorPlaceholder}{suf}',
      $'#{padding}endif',
    ]
    ApplySnip(snip)
    return true
  })
  ->AddSnip((comparison: string): bool => {
    # This snippet works like a template; apply this only when the cursor line
    # is modified.
    if !(prevnonblank(line('.') - 1) == 0 && nextnonblank(line('.') + 1) == 0)
      return false
    endif
    var snip = [
      '#include <stdio.h>',
      '',
      'int main(void) {',
      "\tputs(\"Hello\");" .. CursorPlaceholder,
      '}'
    ]

    if stridx(snip[0], comparison) == -1
      return false
    endif
    ApplySnip(snip)
    return true
  })

SnipFiletype('cpp')
  ->AddSnip((comparison: string): bool => {
    # This snippet works like a template; apply this only when the cursor line
    # is modified.
    if !(prevnonblank(line('.') - 1) == 0 && nextnonblank(line('.') + 1) == 0)
      return false
    endif
    var snip = [
      '#include <iostream>',
      '',
      'int main() {',
      "\tstd::cout << \"Hello" .. CursorPlaceholder .. '" << std::endl;',
      '}'
    ]

    if stridx(snip[0], comparison) == -1
      return false
    endif
    ApplySnip(snip)
    return true
  })
  ->AddSnip((comparison: string): bool => {
    # std::vec -> std::vector<>, vec -> std::vector<>, e.g.
    const types = ['vector', 'pair', 'set', 'map']
    var [pre, suf] = GetlineDividedByCursor()
    var target = matchstr(pre, '\w\+$')
    if target ==# ''
      return false
    endif

    var completion = ''
    for t in types
      if stridx(t, target) == 0
        completion = t
        break
      endif
    endfor
    if completion ==# ''
      return false
    endif

    pre = pre[: -(strlen(target) + 1)]  # std::vec -> std::
    if pre[-2 :] !=# '::'  # Only check for '::' to accept 'foolib::vector' like STL.
      pre ..= 'std::'
    endif
    ApplySnip([$'{pre}{completion}<{CursorPlaceholder}>{suf}'])
    return true
  })
  ->AddSnip((comarison: string): bool => {
    # Insert '::' after certan namespaces e.g.
    # 'std' -> 'std::', 'stdstring' -> 'std::string'
    const regex = '\v^(.*<%(std|boost))%(::)@<!(\w*)$'
    var [pre, suf] = GetlineDividedByCursor()
    if pre !~# regex
      return false
    endif
    pre = substitute(pre, regex, '\1::\2', '')
    ApplySnip([pre .. CursorPlaceholder .. suf])
    return true
  })
SnipFiletype('cpp')->MergeSnip('c')->AddSnip(TrySnipFuzzy)
FuzzySnipList['cpp'] = [
  [$'std::cout << "{CursorPlaceholder}" << std::endl;'],
  [$'std::cerr << "{CursorPlaceholder}" << std::endl;'],
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
      substitute(strpart(getline('.'), 0, curidx), '^\s*', '', '') ..
      autoload_name ..
      CursorPlaceholder ..
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
    snip = strpart(snip, 0, col) .. CursorPlaceholder .. snip[col :]
    ApplySnip([snip])

    return true
  })
  ->AddSnip(TrySnipFuzzy)
FuzzySnipList['vim'] = [
  [
    'let s:cpoptions_save = &cpoptions',
    'set cpoptions&vim',
    '',
    CursorPlaceholder,
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
      fname = CursorPlaceholder
    else
      snip ..= CursorPlaceholder
    endif
    snip = printf(snip, fname)
    ApplySnip([snip])

    return true
  })
  ->AddSnip(TrySnipFuzzy)

FuzzySnipList['java'] = [
  ['public static void main(String[] args) {' .. CursorPlaceholder],
]

SnipFiletype('help')
  ->AddSnip((_: string): bool => {
    # Add modeline text when there's no modeline and cursor is at the EOF.
    const lastline = line('$')
    const no_modeline =
      (getline(1, &modelines) + getline(lastline - &modelines, lastline))
      ->filter((_: number, line: string): bool => line =~? '\v^\s*%(vim?|ex):')
      ->empty()
    if !no_modeline
      return false
    elseif !getline('.', '$')->filter('trim(v:val) ==# ""')->empty()
      # Not at the tail of file.
      return false
    endif
    ApplySnip(['vim:tw=78:fo=tcq2mM:ts=8:ft=help:norl' .. CursorPlaceholder])
    return true
  })
  ->AddSnip((_: string): bool => {
    if getline('.') !~# '^[-=]*$'
      return false
    endif
    const c = getline('.')[0]
    ApplySnip([repeat(c, &l:textwidth) .. CursorPlaceholder])
    return true
  })

SnipFiletype('_')
  ->AddSnip((_: string): bool => {
    # foo()>|bar => foo(bar)
    var linestr = getline('.')
    var pre_cursor = substitute(strpart(linestr, 0, col('.') - 1), '^\s*', '', '')
    var reg_wrapper = '\%(^\|\s\)\zs[^([:space:]]*(\ze)>$'
    var wrapper = matchstr(pre_cursor, reg_wrapper)
    if wrapper ==# ''
      return false
    endif
    var firstcol = col('.')
    search('[^([:space:]]\+(\?', 'e', line('.'))
    if strpart(linestr, col('.') - 1, 1) ==# '('
      normal! %
    endif
    var lastcol = col('.')
    var target = strpart(linestr, firstcol - 1, lastcol - firstcol + 1)
    var pre_wrapper =
          strpart(pre_cursor, 0, strlen(pre_cursor) - strlen(wrapper) - strlen(')>'))
    var snip =
          pre_wrapper .. wrapper .. target .. ')' .. CursorPlaceholder .. linestr[lastcol :]
    # Restore cursor position in order to make cursor position be restored
    # properly after undo.
    cursor(line('.'), firstcol)
    ApplySnip([snip])

    return true
  })
