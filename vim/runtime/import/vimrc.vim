vim9script

export const IsWindows = has('win32')
export const IsWinUnix = has('win32unix')
export const IsLinux = has('linux')
export const IsMac = has('mac')
export const IsUnix = IsLinux || IsMac
export const IsWSL = IsLinux && getftype('/proc/sys/fs/binfmt_misc/WSLInterop') !=# ''

export class Fs
  static const slash = IsWindows ? '\\' : '/'
  static const pathSeparator = IsWindows ? ':' : ';'
  static const rcfilePrefix = IsWindows ? '_' : '.'

  static def Rc(fname: string): string
    return rcfilePrefix .. fname
  enddef

  static def JoinPath(...elems: list<any>): string
    return join(elems, slash)
  enddef
endclass

export class Stdpath
  static const cache = (IsWindows ? '~\.cache\vim' : '~/.cache/vim')->expand()
  static const dotvim = $MYVIMRC->fnamemodify(':h')
  static const dotfiles = $MYVIMRC->fnamemodify(':h:h')
  static const localpack = Fs.JoinPath(expand('~'), 'dev', 'vim')
endclass

def GetMsgString(msg: string): string
  return '[vimrc] ' .. msg
enddef

def EchomsgWithColor(msg: string, hl_group: string)
  execute 'echohl' hl_group
  echomsg GetMsgString(msg)
  echohl NONE
enddef

export def Echomsg(msg: string)
  EchomsgWithColor(msg, 'NONE')
enddef

export def EchomsgError(msg: string)
  EchomsgWithColor(msg, 'Error')
enddef

export def EchomsgWarning(msg: string)
  EchomsgWithColor(msg, 'WarningMsg')
enddef

export def Echo(msg: string)
  echo GetMsgString(msg)
enddef

export def EchoQuestion(question: string)
  echon GetMsgString(question) .. ' '
  echohl Question
  echon '[Y/N]'
  echohl NONE
  echon "\n"
enddef

export def Ask(question: string): bool
  EchoQuestion(question)
  return getcharstr() =~? 'y'
enddef

export def Mkdir(dir: string, ...opt: list<any>): bool
  if isdirectory(dir)
    return true
  endif
  return !!call('mkdir', [dir] + opt)
enddef

export def Input(prompt: string, ...opt: list<any>): string
  try
    return call('input', [prompt] + opt)
  catch /\C^Vim:Interrupt$/
    return ''
  endtry
  return ''
enddef

export def ReplaceTermcodes(key: string): string
  return key->substitute(
    '<[^<>]\+>', (m: list<string>): string => eval($'"\{m[0]}"'), 'g')
enddef

export def SetUndoFtplugin(config: string)
  const restorer = 'execute ' .. string(config)
  if exists('b:undo_ftplugin')
    b:undo_ftplugin = restorer .. '|' .. b:undo_ftplugin
  else
    setbufvar('%', 'undo_ftplugin', restorer)
  endif
enddef

export def FindGitRoot(targetGiven: string = null_string): string
  const target: string = resolve(targetGiven ?? bufname('%')->fnamemodify(':p'))
  const gitDir: string = finddir('.git', target .. ';')
  if gitDir ==# ''
    return ''
  endif
  return fnamemodify(gitDir, ':p:h:h')
enddef
