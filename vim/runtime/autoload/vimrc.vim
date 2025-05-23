vim9script

import $MYVIMRC as Vimrc

final SLASH = Vimrc.Fs.slash
final NON_ESCAPED_SPACE = '\v%(%(\_^|[^\\])%(\\\\)*)@<=\s'

export def DeleteUndofiles()
  var undodir_save = &undodir
  var undofiles: list<string>
  try
    noautocmd set undodir-=.
    undofiles = globpath(&undodir, '*', true, true)
  finally
    &undodir = undodir_save
  endtry

  # Remove unreadable undofiles and them whose original files are still exists
  undofiles->filter((_, val): bool => filereadable(val))
    ->filter((_, val): bool => !fnamemodify(val, ':t')->tr('%', SLASH)->filereadable())

    if empty(undofiles)
      Vimrc.Echomsg('All undofiles are used. It''s already clean.')
      return
    endif

    echo join(undofiles, "\n") .. "\n"
    if !Vimrc.Ask('Delete the above unused undofiles?')
      Vimrc.Echomsg('Canceled.')
      return
    endif

    for file in undofiles
      if delete(file)
        Vimrc.Echomsg('Failed to delete: ' .. file)
      endif
    endfor
    Vimrc.Echomsg('Deleted.')
enddef

export def Clipbuffer(arg: string)
  var opener = strlen(arg) == 0 ? 'tabedit' : arg
  execute 'hide' opener 'clipboard://buffer'

  setbufvar(bufnr(), 'clipbuffer_bufhidden', &l:bufhidden)
  setlocal buftype=acwrite nomodified bufhidden=hide noswapfile

  ClipbufferCatchup()

  augroup vimrc_clipbuffer
    autocmd! * <buffer>
    autocmd BufWriteCmd <buffer> ++nested ClipbufferSet()
    autocmd BufWipeout  <buffer> ++nested
          \ setbufvar(bufnr(), '&bufhidden', b:clipbuffer_bufhidden)
    autocmd BufEnter <buffer> ++nested ClipbufferCatchup()
  augroup END
enddef

def ClipbufferSet()
  :%yank +
  setlocal nomodified
enddef

def ClipbufferCatchup()
  if !&modified
    try
      :%delete _
      :1 put +
      :1 delete _
      setlocal nomodified
    catch /^Vim\:E353\:/
      # Ignore "E353: Nothing in register +" error
    catch
      Vimrc.EchomsgError(v:throwpoint)
      Vimrc.EchomsgError(v:exception)
    endtry
  endif
enddef

export def SetDigraphForJapanese()
  digraph_set('((', '（')
  digraph_set('))', '）')
  digraph_set('{{', '『')
  digraph_set('}}', '』')
  digraph_set('[[', '「')
  digraph_set(']]', '」')
  digraph_set('  ', nr2char(12288))
  digraph_set('""', '”')
  digraph_set('!!', '！')
  digraph_set('??', '？')
  digraph_set('<<', '＜')
  digraph_set('>>', '＞')
  digraph_set(',,', '、')
  digraph_set('..', '。')
  digraph_set('--', 'ー')
enddef

export def ListTasks(args: string)
  var target = '%'
  if args =~# 'rf'
    target = '**/*.' .. expand('%:e')
  elseif args !=# ''
    target = args
  endif
  execute 'vimgrep /\C\v<(TODO|FIXME|XXX)>/' target
enddef

export def GitInitRepo(cmdarg: string)
  var d: string
  if cmdarg ==# ''
    d = getcwd(0)  # Refer the cwd of the current window.
  else
    d = expand(cmdarg)
    if !isdirectory(d)
      Vimrc.EchomsgError('Not a directory: ' .. cmdarg)
      return
    endif
  endif
  if isdirectory(fnamemodify(d, '%:p') .. '.git')
    Vimrc.Echo('Already a git repository: ' .. cmdarg)
    return
  endif

  var cmdbase = 'git -C ' .. shellescape(d) .. ' '
  var cmds = [
    cmdbase .. 'init',
    cmdbase .. 'branch -m main',
    cmdbase .. 'commit --allow-empty -m "Initial commit"'
  ]

  for cmd in cmds
    var m = system(cmd)
    if !!v:shell_error
      Vimrc.EchomsgError('Command Failed: The stdout message is:')
      Vimrc.EchomsgError(m)
      return
    endif
  endfor
  Vimrc.Echo('Initialized git repository: ' .. cmdarg)
enddef

export def UpdateLocalPackages()
  if !executable('git')
    Vimrc.EchomsgError('No git')
    return
  endif
  var packDir = Vimrc.Fs.JoinPath(Vimrc.Stdpath.cache, 'pack')
  var dirs: list<string>
  dirs = Vimrc.Fs.JoinPath(Vimrc.Stdpath.localpack, 'start', '*', '.git')->glob(true, true)
  dirs += Vimrc.Fs.JoinPath(Vimrc.Stdpath.localpack, 'opt', '*', '.git')->glob(true, true)
  var cmds: list<string>
  for dir in dirs
    cmds->add('git -C ' .. dir->fnamemodify(':h')->shellescape() .. ' pull')
  endfor

  var fname = tempname() .. '.sh'
  writefile(cmds, fname)
  term_start([&shell, fname], {
    term_name: 'Update Local Packages',
    exit_cb: (_, _) => delete(fname)
  })
enddef

export def DefineOpenCommand()
  var cmd = ''
  if has('mac')
    if executable('open')
      cmd = 'open'
    endif
  elseif has('win32') || has('win32unix') || (has('linux') && system('uname -r') =~? 'microsoft')
    if executable('explorer')
      cmd = 'explorer'
    endif
  elseif has('linux')
    if executable('xdg-open')
      cmd = 'xdg-open'
    endif
  endif

  if cmd ==# ''
    command! -bar -nargs=* -complete=dir SysOpen
          \ Vimrc.EchomsgWarning(':SysOpen command is not supported on this platform.')
  else
    execute 'command! -bar -nargs=+ -complete=dir SysOpen ' ..
      $'call system("{cmd} " .. shellescape(<q-args>))'
  endif
enddef

export def ShowHighlightGroup()
  var hlgroup = synIDattr(synID(line('.'), col('.'), 1), 'name')
  var groupChain: list<string> = []

  while hlgroup !=# ''
    groupChain->add(hlgroup)
    hlgroup = execute($'highlight {hlgroup}')->trim()->matchstr('\<links\s\+to\>\s\+\zs\w\+$')
  endwhile

  if empty(groupChain)
    echo 'No highlight groups'
    return
  endif

  for group in groupChain
    execute 'highlight' group
  endfor
enddef

def SearchMarker(marker: string, path: string, isDir: bool): string
  const d = isDir ? finddir(marker, path) : findfile(marker, path)
  if d ==# ''
    return ''
  elseif isDir
    return d->fnamemodify(':p:h:h')
  else
    return d->fnamemodify(':p:h')
  endif
enddef

export def SearchProjectRoot(path: string): string
  if path ==# ''
    return ''
  elseif !isabsolutepath(path)
    throw $'Path should be absolute: {path}'
  endif

  const rootMarkerDirs = [
    '.git',
    'autoload', 'plugin', 'denops',
  ]
  const rootMarkerFiles = [
    'go.mod',
    'compile_flags.txt', 'compile_commands.json', '.clang-format',
    'Cargo.toml',
    'dune-project',
    'deno.json', 'deno.jsonc', 'import_map.json',
  ]

  var root = ''
  const parent = path .. ';'
  for marker in rootMarkerDirs
    const d = SearchMarker(marker, parent, true)
    if strlen(d) > strlen(root)
      root = d
    endif
  endfor
  for marker in rootMarkerFiles
    const d = SearchMarker(marker, parent, false)
    if strlen(d) > strlen(root)
      root = d
    endif
  endfor
  return root
enddef

export def FindProjectRoot(pathGiven: string = '', silent: bool = false): string
  if pathGiven ==# ''
    const curbuf = expand('%:p')
    if curbuf =~# '^gin[^:]*://'
      return gin#util#worktree()
    elseif curbuf =~# '^fern://'
      const fern = fern#helper#new()
      if fern.sync.get_scheme() ==# 'file'
        return fern.sync.get_root_node()._path
      else
        return getcwd(winnr())
      endif
    else
      return SearchProjectRoot(curbuf) ?? getcwd(winnr())
    endif
  endif

  const path = pathGiven->expand()
  if !path->isdirectory()
    if !silent
      Vimrc.EchomsgError($'Directory not found: {path}')
    endif
    return ''
  endif

  return path
enddef

export def CdProjectRoot(cdcmd: string)
  const root = SearchProjectRoot(expand('%:p:h'))
  if root !=# ''
    execute cdcmd fnameescape(root)
  endif
enddef

def FindCommon(findfn: string, args: list<any>): string
  const file = call(findfn, args)
  if file ==# ''
    return ''
  endif
  return fnamemodify(file, ':p')
enddef

export def Findfile(name: string, ...args: list<any>): string
  return FindCommon('findfile', [name] + args)
enddef

export def Finddir(name: string, ...args: list<any>): string
  return FindCommon('finddir', [name] + args)
enddef
