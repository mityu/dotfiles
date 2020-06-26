vim9script

" gyoza
" TODO: Fix configFuncs
let configFuncs: dict<dict<any>> = {'c': {}, 'vim': {}, 'sh': {}}
function configFuncs.get_indent(line) abort
  return matchstr(a:line, '^\s*')
endfunction
function configFuncs.c.brace(lines) abort
  let indent = configFuncs.get_indent(a:lines.prev)

  if a:lines.next =~# '\v^' .. indent .. '}.*;'
    return v:null
  endif

  if a:lines.prev =~# '\v<%(struct|class|enum|union)>'
    if a:lines.next =~# '\v<%(public|protected|private)>:'
      return v:null
    endif
    return '};'
  elseif a:lines.prev =~# '\v^\s*if>'
    if a:lines.next =~# '\v^' .. indent .. '%(}\s*)?<else>'
      return v:null
    endif
  elseif a:lines.prev =~# '\v^\s*switch>'
    if a:lines.next =~# '\v^\s*\S+:'
      return v:null
    endif
  endif

  return '}'
endfunction
function configFuncs.vim.endif(lines) abort
  let indent = configFuncs.get_indent(a:lines.prev)
  if a:lines.next =~# '\v^' .. indent .. 'else%[if]'
    return v:null
  endif
  return 'endif'
endfunction
function configFuncs.vim.endtry(lines) abort
  let indent = configFuncs.get_indent(a:lines.prev)
  if a:lines.next =~# '\v^' .. indent .. '%(catch|finally)'
    return v:null
  endif
  return 'endtry'
endfunction
function configFuncs.sh.fi(lines) abort
  let indent = configFuncs.get_indent(a:lines.prev)
  if a:lines.next =~# '\v^' .. indent .. '%(elif|else)'
    return v:null
  endif
  return 'fi'
endfunction

" NOTE: Keys are evaluated under very magic.
let config = {
     \ '_': {
     \   '\{\s*$': '}',
     \ },
     \ 'c': {
     \   '\{\s*$': configFuncs.c.brace,
     \ },
     \ 'cpp': {},
     \ 'sh': {
     \   '%(^|;)\s*<do>': 'done',
     \   '^\s*if>': configFuncs.sh.fi,
     \ },
     \ 'zsh': {},
     \ 'vim': {
     \   '\{\s*$': v:null,
     \   '^\s*\{\s*$': '}',
     \   '^\s*%(export\s)?\s*def!?\s+\S+(.*).*$': 'enddef',
     \   '^\s*function!?\s+\S+(.*).*$': 'endfunction',
     \   '^\s*if>': configFuncs.vim.endif,
     \   '^\s*while>': 'endwhile',
     \   '^\s*for>': 'endfor',
     \   '^\s*try>': configFuncs.vim.endtry,
     \   '^\s*echohl\s+%(NONE)@!\S+$': 'echohl NONE',
     \   '^\s*augroup\s+%(END)@!\S+$': 'augroup END',
     \ },
     \ 'vimspec': {
     \   '^\s*%(Describe|Before|After|Context|It)': 'End',
     \ },
     \ }
extend(config.cpp, config.c)
extend(config.vimspec, config.vim)
extend(config.zsh, config.sh)

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
  let ft_configs = get(config, &filetype, {})
  let global_configs = get(config, '_', {})->
        \filter({key, val -> !has_key(ft_configs, key)})

  return items(ft_configs) + items(global_configs)
enddef
export def vimrc#gyoza#getConfig(): list<any>
  return GetConfig()
enddef
def TryToApply()
  tryToApply = v:false
  let nextlinenr = nextnonblank(line('.') + 1)
  if GetIndentDepth(nextlinenr) >
       \ GetIndentDepth(line('.') - 1)
    return
  endif
  let prev_line = getline(line('.') - 1)
  let configs = GetConfig()
  for config in configs
    let pattern = config[0]
    let Block_end: any = config[1]
    if prev_line !~# '\v' .. pattern
      continue
    endif
    if type(Block_end) == v:t_func
      Block_end = call(Block_end, [{'prev': prev_line, 'current': getline('.'),
           \ 'next': getline(nextlinenr)}])
    endif
    if type(Block_end) == v:t_none
      " Cancel.
      continue
    endif
    let indent_depth = GetIndentDepth(line('.') - 1)
    let indent =  GetIndentStr(indent_depth)
    let newline = indent .. Block_end
    if getline(nextlinenr) ==# newline
      continue
    endif
    let after_cursor = StrDivPos(getline('.'), col('.') - 1)[1]
    if mode() =~# '^i' && after_cursor !=# ''
      if after_cursor !=# Block_end
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
