vim9script

final SLASH = fnamemodify(getcwd(), ':p')[-1 :]
final NON_ESCAPED_SPACE = '\v%(%(\_^|[^\\])%(\\\\)*)@<=\s'

export def vimrc#delete_undofiles()
  final Echomsg = VimrcFunc('echomsg')
  var undodir_save = &undodir
  var undofiles: list<string>
  try
    noautocmd set undodir-=.
    undofiles = globpath(&undodir, '*', true, true)
  finally
    &undodir = undodir_save
  endtry

  # Remove unreadable undofiles and them whose original files are still exists
  undofiles->filter((_, val) => filereadable(val))
    ->filter((_, val) => (!fnamemodify(val, ':t')->tr('%', SLASH)->filereadable()))

    if empty(undofiles)
      Echomsg('All undofiles are used. It''s already clean.')
      return
    endif

    echo join(undofiles, "\n") .. "\n"
    if !VimrcFunc('ask')('Delete the above unused undofiles?')
      Echomsg('Canceled.')
      return
    endif

    for file in undofiles
      if delete(file)
        Echomsg('Failed to delete: ' .. file)
      endif
    endfor
    Echomsg('Deleted.')
enddef

var PathComplete: dict<any> = {target_path: '', completions: []}
export def vimrc#pathComplete(findstart: bool, base: string): any
  if findstart
    var line = getline('.')[: col('.') - 1]
    if line ==# ''
      PathComplete.target_path = ''
    else
      PathComplete.target_path = split(line, NON_ESCAPED_SPACE)[-1]
    endif
    var completions = VimrcFunc('glob')(PathComplete.target_path .. '*')
    var files: list<dict<string>> = []
    var dirs: list<dict<string>> = []
    for path in completions
      var completion = fnamemodify(path, ':t')
      if filereadable(path)
        add(files, {word: completion, menu: '[file]'})
      else
        add(dirs, {word: completion .. SLASH, menu: '[dir]'})
      endif
    endfor
    sort(dirs)
    sort(files)
    PathComplete->remove('completions') # To avoid E1121 error in the next line.
    PathComplete.completions = dirs + files

    return col('.') - fnamemodify(PathComplete.target_path, ':t')->strlen() - 1
  endif

  return PathComplete.completions
enddef

export def vimrc#clipbuffer(arg: string)
  var opener = strlen(arg) == 0 ? 'tabedit' : arg
  execute 'hide' opener 'clipboard://buffer'

  setbufvar(bufnr(), 'clipbuffer_bufhidden', &l:bufhidden)
  setlocal buftype=acwrite nomodified bufhidden=hide noswapfile

  augroup vimrc_clipbuffer
    autocmd! * <buffer>
    autocmd BufWriteCmd <buffer> ++nested ClipbufferSet()
    autocmd BufWipeout  <buffer> ++nested
          \ setbufvar(bufnr(), '&bufhidden', b:clipbuffer_bufhidden)
  augroup END
enddef

def ClipbufferSet()
  setreg('*', getline(1, '$')->join("\<CR>"))
  deletebufline(bufnr(), 1, '$')
  setlocal nomodified
enddef
