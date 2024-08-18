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
  dirs = Vimrc.Fs.JoinPath(packDir, 'local', 'start', '*', '.git')->glob(true, true)
  dirs += Vimrc.Fs.JoinPath(packDir, 'local', 'opt', '*', '.git')->glob(true, true)
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
    command! -bar -nargs=* -complete=dir Open
          \ Vimrc.EchomsgWarning(':Open command is not supported on this platform.')
  else
    execute 'command! -bar -nargs=+ -complete=dir Open ' ..
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

export def FindProjectRoot(path: string): string
  if path ==# ''
    return ''
  endif

  const rootMarkerDirs = [
    '.git',
    'autoload', 'plugin',
  ]
  const rootMarkerFiles = [
    'go.mod',
    'compile_flags.txt', 'compile_commands.json', '.clang-format',
    'Cargo.toml',
    'dune-project',
  ]

  var root = ''
  const parent = path .. ';'
  for marker in rootMarkerDirs
    const d = finddir(marker, parent)->fnamemodify(':h')
    if strlen(d) > strlen(root)
      root = d
    endif
  endfor
  for marker in rootMarkerFiles
    const d = findfile(marker, parent)->fnamemodify(':h')
    if strlen(d) > strlen(root)
      root = d
    endif
  endfor
  return root
enddef

export def CdProjectRoot(cdcmd: string)
  const root = FindProjectRoot(expand('%:p:h'))
  if root !=# ''
    execute cdcmd fnameescape(root)
  endif
enddef
