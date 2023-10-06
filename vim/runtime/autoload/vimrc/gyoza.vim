vim9script
# TODO: Separate as a plugin when vim9script is fully implemented

class Rule
  this.pattern: string
  this.pair: any
  this.cancel_if_on_next_literal: list<string>
  this.cancel_if_on_next_regexp: list<string>

  def new(pattern: string, pair: any, cancel_literal: list<string>, cancel_regexp: list<string>)
    this.pattern = pattern
    this.pair = pair
    this.cancel_if_on_next_literal = cancel_literal
    this.cancel_if_on_next_regexp = cancel_regexp
  enddef
endclass

class Config
  this.config: dict<Rule>

  def new()
    this.config = {}
  enddef

  # TODO: Use 'Config' instead of 'any' in return type
  def AddRule(pattern: string, pair: any, cancel_if_on_next: list<string> = []): any
    var literal: list<string>
    var regexp: list<string>
    for canceler in cancel_if_on_next
      if canceler ==# ''
        continue
      elseif stridx(canceler, '\=') == 0
        if strlen(canceler) == 2
          # TODO: Error?
          continue
        endif
        add(regexp, '\v' .. strpart(canceler, 2))
      else
        add(literal, canceler)
      endif
    endfor
    this.config[pattern] = Rule.new(pattern, pair, literal, regexp)
    return this
  enddef

  def ExtendRule(rules: dict<Rule>)
    this.config->extend(rules, 'keep')
  enddef
endclass

var newlineRules: dict<Config>

var linesCount: number
var tryToApply: bool

final RuleApplyFailed = 0
final RuleAppled      = 1
final RuleUnnecessary = 2

def NewFiletypeRule(filetype: string): Config
  if !has_key(newlineRules, filetype)
    newlineRules[filetype] = Config.new()
  endif
  return newlineRules[filetype]
enddef


def StrDivPos(str: string, pos: number): list<string>
  return [strpart(str, 0, pos), str[pos :]]
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

def GetNewlineRules(): list<Rule>
  var ft_config_dict = {}
  if has_key(newlineRules, &filetype)
    ft_config_dict = newlineRules[&filetype].config
  endif

  var global_config_dict = {}
  if has_key(newlineRules, '_')
    global_config_dict =
      newlineRules._.config->filter((key, val) => !has_key(ft_config_dict, key))
  endif

  return ft_config_dict->values() + global_config_dict->values()
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

def CheckCancelIfOnNext(line: string, rule: Rule): bool
  for comparison in rule.cancel_if_on_next_literal
    if line ==# comparison
      return true
    endif
  endfor
  for pattern in rule.cancel_if_on_next_regexp
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

  var rules = GetNewlineRules()
  for rule in rules
    if prevline.trimed !~# '\v' .. rule.pattern
      continue
    endif

    var status = RuleApplyFailed
    if type(rule.pair) == v:t_func
      status = call(rule.pair, [prevline, nextline])
    else
      status = CompleteClosingBlock(prevline, nextline, rule.pair, rule)
    endif
    if status != RuleApplyFailed
      if status == RuleAppled
        SetUpCurlineRemoval()
        UpdateContext()
      endif
      return
    endif
  endfor
enddef

# TODO: Use 'Rule' instead of 'any' when null_object implemented
def CompleteClosingBlock(
    prevline: dict<any>, nextline: dict<any>, pair: string, rule: any = null): number
  var curpos_save = getcurpos()
  var curline_save = getline('.')
  var RestoreBuffer = () => {
    setline('.', curline_save)
    setpos('.', curpos_save)
  }

  setline('.', pair)
  try
    normal! ==
  catch
    RestoreBuffer()
    Error(v:throwpoint)
    Error(v:exception)
    return RuleApplyFailed
  endtry

  var indent_depth = GetIndentDepth(line('.'))
  if nextline.indent_depth > indent_depth ||
      (nextline.indent_depth == indent_depth &&
        ((!!rule && CheckCancelIfOnNext(nextline.trimed, rule)) ||
          stridx(nextline.trimed, pair) == 0))
    RestoreBuffer()
    return RuleUnnecessary
  endif

  var [cur_before, cur_after] = StrDivPos(curline_save, curpos_save[2] - 1)
  var curlinenr = line('.')
  if stridx(cur_after->trim(), pair) == 0
    append(curlinenr - 1, cur_before)
    cursor(curlinenr, len(cur_before) + 1)
  else
    append(curlinenr - 1, curline_save)
    setpos('.', curpos_save)
  endif

  # Manipulate undo sequence
  #   The desired undo sequences are:
  # Case1. Leave insert mode just after inserting newline
  #   1       ->      2
  #
  #   {               {
  #   }
  # Case2. Insert some text after inserting newline
  #   1       ->      2       ->      3
  #
  #   {               {               {
  #     aaa           }
  #   }
  #
  # So, breaking undo sequences here won't satisfy the case1.  We have to
  # break undo sequences only when we observe buffer modifications.  The
  # following autocmds do this.
  #   Note that we give up to break undo sequences when cursor is moved
  # because it is hard to restore the buffer state correctly.
  #
  # Technical Notes:
  #   TextChangedI event is fired after CursorMovedI event, so we cannot
  # figure out the first CursorMovedI event is triggered by modifying text or
  # just by cursor moves.  Only after the second CursorMovedI event we are
  # able to know the first CursorMovedI event is not followed by TextChangedI
  # event.
  UndoManipulatorFunc = function(ManipulateUndoSequence, [line('.')])
  augroup gyoza-undo-sequence
    autocmd!
    autocmd TextChangedI * ++once timer_start(0, UndoManipulatorFunc)
    autocmd CursorMovedI * ++once
        \ autocmd gyoza-undo-sequence CursorMovedI * ++once
        \   CleanManipulateUndoAutocommands()
    autocmd InsertLeave * ++once CleanManipulateUndoAutocommands()
  augroup END

  return RuleAppled
enddef

var UndoManipulatorFunc: func(number): void
def ManipulateUndoSequence(precurlinenr: number, _: number)
  CleanManipulateUndoAutocommands()
  var curlinenr = line('.')
  if curlinenr < precurlinenr
    return
  endif

  var lines = getline(precurlinenr, curlinenr)
  var curpos = getcurpos()
  try
    deletebufline('%', precurlinenr, curlinenr)
    execute "normal! i\<C-g>ua\<C-h>\<ESC>"
  catch
    Error(v:throwpoint)
    Error(v:exception)
  finally
    if len(lines) >= 2
      append(precurlinenr - 1, lines[: -2])
    endif
    RestoreCursorLineText(lines[-1], curpos)
  endtry
enddef

def RestoreCursorLineText(text: string, curpos: list<number>)
  # Similar to append(curpos[1] - 1, text), but does not break the start of
  # insert. This difference appears when 'backspace' option contains 'start.'
  var SID = expand("<SID>")
  var move_to_prevline_cmd = printf(
    "\<Cmd>call cursor(%d, %d)\<CR>",
    curpos[1] - 1,
    col([curpos[1] - 1, '$']))
  var restore_text_cmd = printf(
    "\<Cmd>call %sMayCompleteCursorLineText(%s)\<CR>", SID, string(text))
  var restore_curpos_cmd = printf(
    "\<Cmd>call setpos('.', %s)\<CR>", curpos)
  var maincmd = ''
  maincmd ..= "\<Cmd>let b:gyoza_ei_save = &eventignore\<CR>"
  maincmd ..= "\<Cmd>set eventignore=all\<CR>"
  maincmd ..= move_to_prevline_cmd
  maincmd ..= "\<CR>\<C-g>Ua\<C-h>\<ESC>A" .. restore_text_cmd
  maincmd ..= restore_curpos_cmd
  maincmd ..= "\<Cmd>let &eventignore = b:gyoza_ei_save\<CR>"
  maincmd ..= "\<Cmd>unlet b:gyoza_ei_save\<CR>"
  maincmd ..= "\<Cmd>call " .. SID .. "UpdateContext()\<CR>"
  feedkeys(maincmd, 'nti')
enddef

def MayCompleteCursorLineText(text: string)
  var indentlen = getline('.')->strlen()
  if strlen(text) > indentlen
    feedkeys(text[indentlen :], 'nti')
  endif
enddef

def CleanManipulateUndoAutocommands()
  autocmd! gyoza-undo-sequence
enddef

def SetUpCurlineRemoval()
  augroup gyoza-curline-removal
    autocmd!
    autocmd InsertLeave * ++once {
      if getline('.') =~# '^\s*$'
        delete _
      endif
      if exists('#gyoza-curline-removal#CursorMovedI')
        autocmd! gyoza-curline-removal CursorMovedI *
      endif
    }
    autocmd CursorMovedI * ++once
          \ autocmd! gyoza-curline-removal InsertLeave *
  augroup END
enddef

def UpdateContext()
  linesCount = line('$')
enddef

def OnCursorMoved()
  tryToApply = (NeedTry() || tryToApply) && mode() ==# 'i'
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
  tryToApply = false
enddef

def OnCmdwinEnter()
  # Do not use gyoza.vim in cmdwin
  augroup gyoza
    autocmd!
    autocmd CmdwinLeave * ++once Enable()
  augroup END
enddef

def Error(msg: string)
  echohl ErrorMsg
  echomsg '[gyoza]' msg
  echohl NONE
enddef

export def Enable()
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

export def Disable()
  augroup gyoza
    autocmd!
  augroup END
enddef

def MergeRule(from: string, to: string)
  if has_key(newlineRules, from)
    NewFiletypeRule(to)
    newlineRules[to].ExtendRule(newlineRules[from].config)
  endif
enddef

def ReplaceLine(nr: number, text: string)
  # Revert <CR> input, setline(), and then separate undo sequences.
  var curpos = getcurpos()
  var curline = getline('.')
  try
    delete _
    setline(nr, text)
    execute "normal! i\<C-g>ua\<C-h>\<ESC>"
  catch
    Error(v:throwpoint)
    Error(v:exception)
  finally
    append(curpos[1] - 1, curline)
    setpos('.', curpos)
  endtry
enddef
# Register rules
if globpath(&rtp, 'autoload/vim9context.vim') ==# ''
  def IsInVim9script(): bool
    return false
  enddef
else
  def IsInVim9script(): bool
    return vim9context#get_context() == g:vim9context#CONTEXT_VIM9_SCRIPT
  enddef
endif
NewFiletypeRule('vim')
  .AddRule('\[\s*$', (prev: dict<any>, next: dict<any>): number => {
    var prefix = IsInVim9script() ? '' : '\'
    var closer = prefix .. ']'
    var currentline = getline('.')->trim()
    if currentline[0] ==# ']'
      closer = prefix .. currentline
      setline('.', closer)
      cursor(line('.'), 1)
    endif
    return CompleteClosingBlock(prev, next, closer)
  })
  .AddRule('^\s*%(export\s|legacy\s)?\s*def!?\s+\S+(.*).*$', 'enddef')
  .AddRule('^\s*%(legacy\s)?\s*fu%[nction]!?\s+\S+(.*).*$',
      (prev: dict<any>, next: dict<any>): number => {
        var r = '^\v(.{-})(fu%[nction])(.*)$'
        var m = matchlist(prev.text, r)
        if m[2] !=# 'function'
          m[2] = 'function'
          ReplaceLine(prev.nr, join(m[1 :], ''))
        endif
        return CompleteClosingBlock(prev, next, 'endfunction')
      })
  .AddRule('^\s*%(%(export\s+)?abstruct\s+)?class>', 'endclass')
  .AddRule('^\s*%(export\s+)?interface>', 'endinterface')
  .AddRule('^\s*if>', 'endif', ['else', '\=^elseif>'])
  .AddRule('^\s*while>', 'endwhile')
  .AddRule('^\s*for>', 'endfor')
  .AddRule('^\s*try>', 'endtry', ['\=^catch>', 'finally'])
  .AddRule('^\s*echohl\s+%(NONE)@!\S+$', 'echohl NONE', ['\=^ec%[homsg]>', '\=^echon>', '\=^echoe%[rr]>', '\=^echoc%[onsole]'])
  .AddRule('^\s*augroup\s+%(END)@!\S+$', 'augroup END')
  .AddRule('^\s*%(let|var|const|final)\s+\w+\s*\=\<\<\s*%(%(trim|eval)\s+)*\s*\w+$',
      (prev: dict<any>, next: dict<any>): number => {
        var curpos = getcurpos()
        try
          cursor(next.nr, 0)
          if synIDattr(synID(line('.'), col('.'), 1), 'name') ==# 'vimLetHereDoc'
            return RuleUnnecessary
          endif
        finally
          setpos('.', curpos)
        endtry
        var closer = matchstr(prev.trimed, '\w\+\ze\s*$')
        return CompleteClosingBlock(prev, next, closer)
      })
NewFiletypeRule('vimspec')
  .AddRule('^\s*%(Describe|Before|After|Context|It)>', 'End')
NewFiletypeRule('sh')
  .AddRule('%(^|;)\s*<do>', 'done')
  .AddRule('^\s*if>', 'fi', ['\=^elif>', 'else'])
NewFiletypeRule('go')
  .AddRule('^%(var|const|import)\s*\($', ')')
NewFiletypeRule('python')
  .AddRule(
    '^%(def|for|while|if|elif|else)>.*[^:]\s*$',
    (prev: dict<any>, next: dict<any>): number => {
      ReplaceLine(prev.nr, prev.text .. ':')
      return RuleAppled
  })

# NewFiletypeRule('markdown')
#   ->AddRule('^```%(\s*\w+)?', '```')
# NewFiletypeRule('html')
#   ->AddRule('^\<\s*\w+[^>]*>', (line: string): string => ('</' .. matchstr(line, '^<\s*\zs\w\+\ze') .. '>')) # TODO: Improve


def GenericBracketCompletor(prevline: dict<any>, nextline: dict<any>): number
  var curline = getline('.')->StrDivPos(col('.') - 1)
  var closer = '}'
  var trimed = curline[1]->trim()
  if trimed !=# ''
    if stridx(',)]', trimed[0]) != -1
      closer = '}' .. curline[1]
      setline('.', curline[0] .. closer)
      cursor(line('.'), strlen(curline[0]))
    elseif trimed[0] ==# '}'
      closer = curline[1]
    endif
  endif
  return CompleteClosingBlock(prevline, nextline, closer)
enddef

NewFiletypeRule('_')
  .AddRule('\{$', GenericBracketCompletor)

NewFiletypeRule('c')
  .AddRule(
    '^%(%(typedef\s+)?%(struct|enum)|class)>.*\{$',
    '};',
    ['\=^%(public|private|protected)>\:'])
  .AddRule(
    '^switch\s*\(.*\)\s*\{$',
    '}',
    ['\=^%(case\s*.*\:|default\:)'])

NewFiletypeRule('go')
  .AddRule(
    '^%(select>|switch\s*\S*\s*)\s*\{$',
    '}',
    ['\=^%(case\s*.*\:|default\:)'])
  .AddRule(
    '^%(defer|go)\s+func\s*\([^)]{-}\)\s*\{$',
    '}()',
    ['\=\m^}\s*('])

NewFiletypeRule('rust')
  .AddRule(
    '^%(%(let|return)>|\w+\s*\=.*<%(match|if|loop)>).*\{$',
    '};')

NewFiletypeRule('tex')
  .AddRule(
    '^\\begin\{\w+\*?}',
    (prev: dict<any>, next: dict<any>): number => {
      var groupname = matchstr(prev.trimed, '\v^\\begin\{\zs\w+\*?\ze}')
      var closer = '\end{' .. groupname .. '}'
      return CompleteClosingBlock(prev, next, closer)
    }
  )

MergeRule('c', 'cpp')
MergeRule('vim', 'vimspec')
MergeRule('sh', 'zsh')
MergeRule('sh', 'bash')
