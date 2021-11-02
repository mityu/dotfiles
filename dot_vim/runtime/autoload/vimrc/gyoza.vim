vim9script
# TODO: Separate as a plugin when vim9script is fully implemented

var config: dict<dict<any>>
var bracketCompletefunc: dict<func(dict<any>, dict<any>): string>
var linesCount: number
var tryToApply: bool
var justAfterApplying: bool

def StrDivPos(str: string, pos: number): list<string>
  return [strpart(str, 0, pos), strpart(str, pos, strlen(str) - pos)]
enddef
def InitForBuffer()
  linesCount = line('$')
  tryToApply = false
enddef
def NeedTry(): bool
  return line('$') > linesCount
enddef
def GetOneIndent(): string
  if &l:expandtab || strdisplaywidth("\t") != shiftwidth()
    return repeat(' ', shiftwidth())
  else
    return "\t"
  endif
enddef
def GetIndentDepth(line: number): number
  var indent = getline(line)->matchstr('^\s*')->strdisplaywidth()
  return indent / shiftwidth()
enddef
def GetIndentStr(depth: number): string
  return repeat(GetOneIndent(), depth)
enddef
def GetConfig(): list<any>
  var ft_configs = get(config, &filetype, {})
  var global_configs =
        get(config, '_', {})->filter((key, val) => !has_key(ft_configs, key))

  return items(ft_configs) + items(global_configs)
enddef
def GetLineData(linenr: number): dict<any>
  var text: string = linenr != 0 ? getline(linenr) : ''
  var indentstr: string = matchstr(text, '^\s*')
  var indentdepth: number = strdisplaywidth(indentstr) / shiftwidth()
  return {
    nr: linenr,
    text: text,
    trimed: trim(text),
    indent_str: indentstr,
    indent_depth: indentdepth,
  }
enddef
def CheckInterruption(line: string, interruption: dict<list<string>>): bool # Better name
  for comparison in interruption.literal
    if line ==# comparison
      return true
    endif
  endfor
  for pattern in interruption.regexp
    if line =~# pattern
      return true
    endif
  endfor
  return false
enddef
def TryToApply()
  tryToApply = false

  var nextline = GetLineData(nextnonblank(line('.') + 1))
  var prevline = GetLineData(prevnonblank(line('.') - 1))

  if nextline.indent_depth > prevline.indent_depth
    return
  endif

  var blockPair: string

  if prevline.trimed[-1] ==# '{'
    if nextline.trimed[0] ==# '}' && nextline.indent_depth == prevline.indent_depth
      return
    endif

    var currentline = getline('.')->trim()
    if currentline[0] ==# '}'
      blockPair = currentline
    else
      if has_key(bracketCompletefunc, &filetype)
        blockPair = call(bracketCompletefunc[&filetype], [prevline, nextline])
      elseif has_key(bracketCompletefunc, '_')
        blockPair = call(bracketCompletefunc._, [prevline, nextline])
      endif
    endif

    if blockPair ==# ''  # Cancel
      return
    endif

    if nextline.indent_depth == prevline.indent_depth &&
        nextline.trimed ==# blockPair
      return
    endif
  else
    var configs = GetConfig()
    for config in configs
      var pattern = config[0]

      if prevline.trimed !~# '\v' .. pattern
        continue
      elseif nextline.indent_depth == prevline.indent_depth &&
              CheckInterruption(nextline.trimed, config[1].interruption)
        continue
      endif

      if type(config[1].pair) == v:t_func
        blockPair = call(config[1].pair, [prevline.trimed])
      else
        blockPair = config[1].pair
      endif

      if blockPair ==# ''  # Cancel
        continue
      endif

      if nextline.indent_depth == prevline.indent_depth &&
          nextline.trimed ==# blockPair
        return
      endif

      break
    endfor
  endif

  if blockPair ==# ''
    return
  endif

  if StrDivPos(getline('.'), col('.') - 1)[1] ==# blockPair
    # If there is the `blockPair` after the cursor, remove it to make it on
    # the new line.
    setline('.', GetIndentStr(prevline.indent_depth + 1))
    cursor(line('.'), strlen(getline('.')) + 1)
  endif
  append('.', prevline.indent_str .. blockPair)
  justAfterApplying = true

  UpdateContext()
enddef
def UpdateContext()
  linesCount = line('$')
enddef
def OnCursorMoved()
  justAfterApplying = false
  tryToApply = NeedTry() || tryToApply
  UpdateContext()
enddef
def OnTextChanged()
  if tryToApply
    TryToApply()
  endif
enddef
def OnInsertEnter()
  if NeedTry()
    TryToApply()
  endif
enddef
def OnInsertLeave()
  if justAfterApplying && trim(getline('.')) ==# ''
    delete _
  endif
  justAfterApplying = false
  tryToApply = false
enddef

def OnCmdwinEnter()
  # Do not use gyoza.vim in cmdwin
  augroup gyoza
    autocmd!
    autocmd CmdwinLeave * ++once vimrc#gyoza#enable()
  augroup END
enddef

export def vimrc#gyoza#enable()
  augroup gyoza
    autocmd!
    autocmd BufEnter * InitForBuffer()
    autocmd CursorMoved,CursorMovedI * OnCursorMoved()
    autocmd TextChangedI * OnTextChanged()
    autocmd InsertEnter * OnInsertEnter()
    autocmd InsertLeave * OnInsertLeave()
    autocmd CmdwinEnter * ++once OnCmdwinEnter()
  augroup END
enddef

export def vimrc#gyoza#disable()
  augroup gyoza
    autocmd!
  augroup END
enddef

def NewFiletypeRule(filetype: string): dict<any>
  if !has_key(config, filetype)
    config[filetype] = {}
  endif
  return config[filetype]
enddef
def AddRule(
    ft_config: dict<any>,
    pattern: string, # NOTE: This pattern is evaluated under very magic
    pair: any,
    interruption: list<string> = []): dict<any>

  var literal: list<string>
  var regexp: list<string>
  for interrupt in interruption
    if interrupt ==# ''
      continue
    elseif stridx(interrupt, '\=') == 0
      add(regexp, '\v' .. strpart(interrupt, 2))
    else
      add(literal, interrupt)
    endif
  endfor

  var ref = ft_config
  ref[pattern] = {
    pair: pair,
    interruption: {literal: literal, regexp: regexp}
  }

  return ft_config
enddef

def MergeRule(from: string, to: string)
  NewFiletypeRule(to)
  extend(config[to], get(config, from, {}), 'keep')
enddef

# Register rules
NewFiletypeRule('vim')
  ->AddRule('\[\s*$', (line: string): string => {
    var currentline = getline('.')->trim()
    if currentline[0] ==# ']'
      return currentline
    elseif getline(nextnonblank(line('.') + 1))->trim()[0] ==# ']'
      return ''
    endif
    return ']'
  })
  ->AddRule('^\s*%(export\s|legacy\s)?\s*def!?\s+\S+(.*).*$', 'enddef')
  ->AddRule('^\s*%(legacy\s)?\s*fu%[nction]!?\s+\S+(.*).*$', 'endfunction')
  ->AddRule('^\s*if>', 'endif', ['else', '\=^elseif>'])
  ->AddRule('^\s*while>', 'endwhile')
  ->AddRule('^\s*for>', 'endfor')
  ->AddRule('^\s*try>', 'endtry', ['\=^catch>', 'finally'])
  ->AddRule('^\s*echohl\s+%(NONE)@!\S+$', 'echohl NONE')
  ->AddRule('^\s*augroup\s+%(END)@!\S+$', 'augroup END')
  ->AddRule('^\s*%(let|var|const|final)\s+\w+\s*\=\<\<\s*%(trim\s+)?\s*\w+$', (line: string): string => matchstr(line, '\w\+$'))
NewFiletypeRule('vimspec')
  ->AddRule('^\s*%(Describe|Before|After|Context|It)>', 'End')
NewFiletypeRule('sh')
  ->AddRule('%(^|;)\s*<do>', 'done')
  ->AddRule('^\s*if>', 'fi', ['\=^elif>', 'else'])
NewFiletypeRule('go')
  ->AddRule('\v^%(var|const|import)\s*\($', ')')
# NewFiletypeRule('markdown')
#   ->AddRule('^```%(\s*\w+)?', '```')
# NewFiletypeRule('html')
#   ->AddRule('^\<\s*\w+[^>]*>', (line: string): string => ('</' .. matchstr(line, '^<\s*\zs\w\+\ze') .. '>')) # TODO: Improve

MergeRule('c', 'cpp')
MergeRule('vim', 'vimspec')
MergeRule('sh', 'zsh')


bracketCompletefunc['_'] = (prevline: dict<any>, nextline: dict<any>): string => '}'

bracketCompletefunc['c'] = (prevline: dict<any>, nextline: dict<any>): string => {
  if prevline.trimed =~# '\v^%(typedef\s+)?%(struct|enum)>'
    return '};'
  endif
  return '}'
}

bracketCompletefunc['cpp'] = (prevline: dict<any>, nextline: dict<any>): string => {
  var c_style_completion = call(bracketCompletefunc.c, [prevline, nextline])
  if c_style_completion !=# '' && c_style_completion !=# '}'
    return c_style_completion
  endif

  if prevline.trimed =~# '^class\>'
    if nextline.trimed =~# '\v^%(public|private|protected)>\:'
      return ''
    endif
    return '};'
  endif
  return '}'
}

final hasVim9contextPlugin = globpath(&rtp, 'autoload/vim9context.vim') !=# ''
bracketCompletefunc['vim'] = (prevline: dict<any>, nextline: dict<any>): string => {
  var isVim9script = false
  if hasVim9contextPlugin
    isVim9script = vim9context#get_context() == g:vim9context#CONTEXT_VIM9_SCRIPT
  endif

  if isVim9script
    return '}'
  endif
  return '\}'
}

bracketCompletefunc['vimspec'] = bracketCompletefunc['vim']

bracketCompletefunc['go'] = (prevline: dict<any>, nextline: dict<any>): string => {
  if prevline.trimed =~# '^select\>\s*{'
    if nextline.trimed =~# '\v^%(case\s*.*\:|default\:)'
      return ''
    endif
  elseif prevline.trimed =~# '\v^%(defer|go)\s+func\s*\([^)]{-}\)\s*\{'
    return '}()'
  endif
  return '}'
}
