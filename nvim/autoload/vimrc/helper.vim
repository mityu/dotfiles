function vimrc#helper#get_project_root_from_fern_buffer() abort
  const fern = fern#helper#new()
  if fern.sync.get_scheme() ==# 'file'
    return fern.sync.get_root_node()._path
  else
    return getcwd(winnr())
  endif
endfunction

function vimrc#helper#statusline_git_branch_by_gin() abort
  const branch = gin#component#branch#unicode()
  if branch ==# ''
    return 'no-git'
  endif
  return branch .. gin#component#traffic#unicode()
endfunction

function vimrc#helper#statusline_filename_label(bufnr) abort
  const buftype = getbufvar(a:bufnr, '&buftype')
  const bufname = bufname(a:bufnr)
  if buftype ==# 'help'
    return fnamemodify(bufname, ':t')
  elseif buftype ==# 'quickfix'
    return '[quickfix]'
  elseif getbufvar(a:bufnr, '&previewwindow')
    return '[preview]'
  elseif buftype ==# 'terminal'
    return 'terminal:' .. bufname
  elseif buftype ==# 'prompt'
    return '[prompt]'
  else
    return (buftype ==# 'nofile' ? ' *NoFile* ' : '') ..
        \ (bufname ==# '' ? '[NoName]' : pathshorten(fnamemodify(bufname, ':.')))
  endif
endfunction
