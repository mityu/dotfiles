function vimrc#fall#stdpath(kind) abort
  if a:kind ==# 'dotfiles'
    return luaeval('require("vimrc.helper").stdpath("dotfiles")')
  elseif a:kind ==# 'localpack'
    return expand('~/dev/vim')  " TODO: improve
  elseif a:kind ==# 'packpath'
    return luaeval('require("lazy.core.config").defaults.root')
  endif

  throw $'Unknown kind: {a:kind}'
endfunction

function vimrc#fall#findProjectRoot(path) abort
  return luaeval($'require("vimrc").find_project_root("{a:path}")')
endfunction
