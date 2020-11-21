vim9script

var config: dict<dict<any>> = #{}
var linesCount: number
var tryToApply: bool
var justAfterApplying: bool

def IsCmdwin(): bool
  return getcmdwintype() !=# ''
enddef
def StrDivPos(str: string, pos: number): list<string>
  return [strpart(str, 0, pos),
        \ strpart(str, pos, strlen(str) - pos)]
enddef
def InitForBuffer(): void
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
  var global_configs = get(config, '_', {})->
        \filter({key, val -> !has_key(ft_configs, key)})

  return items(ft_configs) + items(global_configs)
enddef
def GetLineData(linenr: number): dict<any>
  var text: string = linenr != 0 ? getline(linenr) : ''
  var indentstr: string = matchstr(text, '^\s*')
  var indentdepth: number = strdisplaywidth(indentstr) / shiftwidth()
  return #{
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
      return v:true
    endif
  endfor
  for pattern in interruption.regexp
    if line =~# pattern
      return v:true
    endif
  endfor
  return v:false
enddef
def TryToApply()
  tryToApply = false

  # The following type specifier is necessary; vim9script cannot handle type
  # correctly yet.
  var nextline: dict<any> = GetLineData(nextnonblank(line('.') + 1))
  var prevline: dict<any> = GetLineData(prevnonblank(line('.') - 1))

  if nextline.indent_depth > prevline.indent_depth
    return
  endif

  var configs = GetConfig()
  for config in configs
    var pattern = config[0]
    var BlockPair: any = config[1].pair

    if prevline.trimed !~# '\v' .. pattern
      continue
    elseif nextline.indent_depth == prevline.indent_depth &&
            CheckInterruption(nextline.trimed, config[1].interruption)
      continue
    endif

    if type(BlockPair) == v:t_func
      BlockPair = call(BlockPair, [prevline.trimed])
    endif
    if type(BlockPair) == v:t_none
      # Cancel.
      continue
    endif

    var newline = prevline.indent_str .. BlockPair
    if nextline.text ==# newline
      continue
    endif
    if StrDivPos(getline('.'), col('.') - 1)[1] ==# BlockPair
      # If there is the `BlockPair` after the cursor, remove it to make it on
      # the new line.
      setline('.', GetIndentStr(prevline.indent_depth + 1))
      cursor(line('.'), strlen(getline('.')) + 1)
    endif
    append('.', newline)
    justAfterApplying = true
    break
  endfor
  UpdateContext()
enddef
def UpdateContext()
  if IsCmdwin()
    return
  endif
  linesCount = line('$')
enddef
def OnCursorMoved(): void
  if IsCmdwin()
    return
  endif
  justAfterApplying = false
  tryToApply = NeedTry() || tryToApply
  UpdateContext()
enddef
def OnTextChanged(): void
  if IsCmdwin()
    return
  endif
  if tryToApply
    TryToApply()
  endif
enddef
def OnInsertEnter(): void
  if IsCmdwin()
    return
  endif
  if NeedTry()
    TryToApply()
  endif
enddef
def OnInsertLeave(): void
  if IsCmdwin()
    return
  endif
  if justAfterApplying && trim(getline('.')) ==# ''
    delete _
  endif
  justAfterApplying = false
  tryToApply = false
enddef

export def vimrc#gyoza#enable()
  augroup gyoza
    autocmd!
    autocmd BufEnter * call InitForBuffer()
    autocmd CursorMoved,CursorMovedI * call OnCursorMoved()
    autocmd TextChangedI * call OnTextChanged()
    autocmd InsertEnter * call OnInsertEnter()
    autocmd InsertLeave * call OnInsertLeave()
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
  ref[pattern] = #{
    pair: pair,
    interruption: #{literal: literal, regexp: regexp}
  }

  return ft_config
enddef

def MergeRule(from: string, to: string)
  NewFiletypeRule(to)
  var additional: dict<any> = get(config, from, {})  # Workaround
  extend(config[to], additional, 'keep')
enddef

# Register rules
NewFiletypeRule('_')
  ->AddRule('\{$', '}', ['\=^}'])
NewFiletypeRule('c')
  ->AddRule('\{$', '}', ['\=^}',  '\=^%(public|private|protected)>\:'])
  ->AddRule('^%(typedef>\s+)?struct\s*\{\s*$', '};', ['\=^};'])
NewFiletypeRule('cpp')
  ->AddRule('^class>\s+\w+\s*\{$', '};', ['\=^};', '\=^%(public|private|protected)>\:'])
NewFiletypeRule('vim')
  ->AddRule('\{\s*$', '}', ['\=^\\\s*}'])
  ->AddRule('\[\s*$', ']', ['\=^\\\s*]'])
  ->AddRule('^\s*%(export\s)?\s*def!?\s+\S+(.*).*$', 'enddef')
  ->AddRule('^\s*function!?\s+\S+(.*).*$', 'endfunction')
  ->AddRule('^\s*if>', 'endif', ['else', '\=^elseif>'])
  ->AddRule('^\s*while>', 'endwhile')
  ->AddRule('^\s*for>', 'endfor')
  ->AddRule('^\s*try>', 'endtry', ['\=^catch>', 'finally'])
  ->AddRule('^\s*echohl\s+%(NONE)@!\S+$', 'echohl NONE')
  ->AddRule('^\s*augroup\s+%(END)@!\S+$', 'augroup END')
  ->AddRule('^\s*%(let|var|const|final)\s+\w+\s*\=\<\<\s*%(trim\s+)?\s*\w+$', {line -> matchstr(line, '\w\+$')})
NewFiletypeRule('vimspec')
  ->AddRule('^\s*%(Describe|Before|After|Context|It)', 'End')
NewFiletypeRule('sh')
  ->AddRule('%(^|;)\s*<do>', 'done')
  ->AddRule('^\s*if>', 'fi', ['\=^elif>', 'else'])
MergeRule('c', 'cpp')
MergeRule('vim', 'vimspec')
MergeRule('sh', 'zsh')
