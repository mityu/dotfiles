vim9script

let config: dict<dict<any>> = #{}
let linesCount: number
let tryToApply: bool

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
  let indent = getline(line)->matchstr('^\s*')->strdisplaywidth()
  return indent / shiftwidth()
enddef
def GetIndentStr(depth: number): string
  return repeat(GetOneIndent(), depth)
enddef
def GetConfig(): list<string>
  let ft_configs = get(config, &filetype, {})
  let global_configs = get(config, '_', {})->
        \filter({key, val -> !has_key(ft_configs, key)})

  return items(ft_configs) + items(global_configs)
enddef
def GetLineData(linenr: number): dict<any>
  let text: string = linenr ? getline(linenr) : ''
  let indentstr: string = matchstr(text, '^\s*')
  let indentdepth: number = strdisplaywidth(indentstr) / shiftwidth()
  return #{
    nr: linenr,
    text: text,
    indent_str: indentstr,
    indent_depth: indentdepth,
  }
enddef
def TryToApply()
  tryToApply = false

  # The following type specifier is necessary; vim9script cannot handle type
  # correctly yet.
  let nextline: dict<any> = GetLineData(nextnonblank(line('.') + 1))
  let prevline: dict<any> = GetLineData(prevnonblank(line('.') - 1))

  if nextline.indent_depth > prevline.indent_depth
    return
  endif

  let configs = GetConfig()
  for config in configs
    let pattern = config[0]
    let BlockPair: any = config[1].pair
    let interruption: list<string> = config[1].interruption

    if prevline.text !~# '\v' .. pattern
      continue
    elseif nextline.indent_depth == prevline.indent_depth
      let text = trim(nextline.text)
      let need_continue = false

      # NOTE: Can't use filter() here because multiple closure isn't supoprted yet.
      for interrupt in interruption
        if interrupt =~# '^\\='
          # Check by regexp
          if text =~# '\v' .. strpart(interrupt, 2)
            need_continue = true
            break
          endif
        else
          # Check by literal
          if text ==# interrupt
            need_continue = true
            break
          endif
        endif
      endfor

      if need_continue
        continue
      endif
    endif

    if type(BlockPair) == v:t_func
      # TODO: Change argument?
      BlockPair = call(BlockPair, [{'prev': prevline.text, 'current': getline('.'),
           \ 'next': nextline.text}])
    endif
    if type(BlockPair) == v:t_none
      # Cancel.
      continue
    endif

    let indent_depth = prevline.indent_depth
    let indent = prevline.indent_str
    let newline = indent .. BlockPair
    if nextline.text ==# newline
      continue
    endif
    let after_cursor = StrDivPos(getline('.'), col('.') - 1)[1]
    if mode() =~# '^i' && after_cursor !=# ''
      if after_cursor !=# BlockPair
        continue
      else
        setline('.', GetIndentStr(indent_depth + 1))
        cursor(line('.'), strlen(getline('.')) + 1)
      endif
    endif
    append('.', newline)
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
  if NeedTry()
    tryToApply = true
  endif
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
  tryToApply = false
enddef

export def vimrc#gyoza#enable()
  augroup gyoza
    autocmd!
    autocmd BufEnter * call InitForBuffer()
    autocmd CursorMoved,CursorMovedI * call OnCursorMoved()
    autocmd TextChanged,TextChangedI * call OnTextChanged()
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

  let ref = ft_config
  ref[pattern] = #{
    pair: pair,
    interruption: copy(interruption)->filter('v:val != ""')
  }

  return ft_config
enddef

def MergeRule(from: string, to: string)
  NewFiletypeRule(to)
  extend(config[to], get(config, from, {}), 'keep')
enddef

# Register rules
NewFiletypeRule('_')
  ->AddRule('\{\s*$', '}', ['\=^}'])
NewFiletypeRule('vim')
  ->AddRule('\{\s*$', '}', ['\=^\\\s*}'])
  ->AddRule('^\s*%(export\s)?\s*def!?\s+\S+(.*).*$', 'enddef')
  ->AddRule('^\s*function!?\s+\S+(.*).*$', 'endfunction')
  ->AddRule('^\s*if>', 'endif', ['else', 'elseif'])
  ->AddRule('^\s*while>', 'endwhile')
  ->AddRule('^\s*for>', 'endfor')
  ->AddRule('^\s*try>', 'endtry', ['\=^catch>', 'finally'])
  ->AddRule('^\s*echohl\s+%(NONE)@!\S+$', 'echohl NONE')
  ->AddRule('^\s*augroup\s+%(END)@!\S+$', 'augroup END')
NewFiletypeRule('vimspec')
  ->AddRule('^\s*%(Describe|Before|After|Context|It)', 'End')
NewFiletypeRule('sh')
  ->AddRule('%(^|;)\s*<do>', 'done')
  ->AddRule('^\s*if>', 'fi', ['\=^elif>', 'else'])
MergeRule('vim', 'vimspec')
MergeRule('sh', 'zsh')
