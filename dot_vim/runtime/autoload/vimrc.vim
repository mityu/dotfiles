vim9script

import * as Vimrc from $MYVIMRC

final SLASH = Vimrc.Filesystem.slash
final NON_ESCAPED_SPACE = '\v%(%(\_^|[^\\])%(\\\\)*)@<=\s'

export def vimrc#delete_undofiles()
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

export def vimrc#clipbuffer(arg: string)
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
    :%delete _
    :1 put +
    :1 delete _
    setlocal nomodified
  endif
enddef

export def vimrc#set_digraph_for_japanese()
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

export def vimrc#list_tasks()
  var target = '%'
  if args =~# 'rf'
    target = '**/*.' .. expand('%:e')
  elseif args !=# ''
    target = args
  endif
  execute 'vimgrep /\C\v<(TODO|FIXME|XXX)>/' target
enddef

export def vimrc#git_init_repo(cmdarg: string)
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

export def vimrc#update_local_packages()
  if !executable('git')
    Vimrc.EchomsgError('No git')
    return
  endif
  var dirs: list<string>
  dirs = Vimrc.JoinPath($DOT_VIM, 'pack', 'local', 'start', '*', '.git')->glob(true, true)
  dirs += Vimrc.JoinPath($DOT_VIM, 'pack', 'local', 'opt', '*', '.git')->glob(true, true)
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
