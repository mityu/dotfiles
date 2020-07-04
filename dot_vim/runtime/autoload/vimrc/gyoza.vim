vim9script

let config: dict<dict<any>> = {}
let linesCount: number
let tryToApply: bool

" Workaround: vim9script cannnot handle script variables properly yet.
def GetConfigRef(): dict<dict<any>>
  let ref: dict<dict<any>> = config
  return ref
enddef
def IsCmdwin(): bool
  return getcmdwintype() !=# ''
enddef
def StrDivPos(str: string, pos: number): list<string>
  return [strpart(str, 0, pos),
        \ strpart(str, pos, strlen(str) - pos)]
enddef
def InitForBuffer(): void
  linesCount = line('$')
  tryToApply = v:false
enddef
def NeedTry(): bool
  " TODO: This is experimental.
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
def GetConfig(): list<any> " TODO: Don't use any
  let ref = GetConfigRef() # Workaround
  let ft_configs = get(ref, &filetype, {})
  let global_configs = get(ref, '_', {})->
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
  tryToApply = v:false

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
      let need_continue = v:false

      # NOTE: Can't use filter() here because multiple closure isn't supoprted yet.
      for interrupt in interruption
        if interrupt =~# '^\\='
          # Check by regexp
          if text =~# '\v' .. strpart(interrupt, 2)
            need_continue = v:true
            break
          endif
        else
          # Check by literal
          if text ==# interrupt
            need_continue = v:true
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
      " Cancel.
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
    tryToApply = v:true
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
  tryToApply = v:false
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

def NewFiletypeRule(filetype: string)
  if !has_key(config, filetype)
    let ref = GetConfigRef() # Workaround
    ref[filetype] = {}
  endif
enddef
def AddRule(
    filetype: string,
    pattern: string, # NOTE: This pattern is evaluated under very magic
    pair: any,
    interruption: list<string>)
  NewFiletypeRule(filetype)

  let ref = GetConfigRef()[filetype] # Workaround
  ref[pattern] = #{
    pair: pair,
    interruption: copy(interruption)->filter('v:val != ""')
  }
enddef

def MergeRule(from: string, to: string)
  NewFiletypeRule(to)
  let ref = GetConfigRef() # Workaround
  extend(ref[to], get(ref, from, {}), 'keep')
enddef

" Register rules
AddRule('_', '\{\s*$', '}', ['\=^}'])
AddRule('vim', '\{\s*$', '}', ['\=^\\\s*}'])
AddRule('vim', '^\s*%(export\s)?\s*def!?\s+\S+(.*).*$', 'enddef', [])
AddRule('vim', '^\s*function!?\s+\S+(.*).*$', 'endfunction', [])
AddRule('vim', '^\s*if>', 'endif', ['else', 'elseif'])
AddRule('vim', '^\s*while>', 'endwhile', [])
AddRule('vim', '^\s*for>', 'endfor', [])
AddRule('vim', '^\s*try>', 'endtry', ['\=^catch>', 'finally'])
AddRule('vim', '^\s*echohl\s+%(NONE)@!\S+$', 'echohl NONE', [])
AddRule('vim', '^\s*augroup\s+%(END)@!\S+$', 'augroup END', [])
AddRule('vimspec', '^\s*%(Describe|Before|After|Context|It)', 'End', [])
AddRule('sh', '%(^|;)\s*<do>', 'done', [])
AddRule('sh', '^\s*if>', 'fi', ['\=^elif>', 'else'])
MergeRule('vim', 'vimspec')
MergeRule('sh', 'zsh')
