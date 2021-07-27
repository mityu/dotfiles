let s:cpoptions_save = &cpoptions
set cpoptions&vim

import * as VimrcFuncs from $MYVIMRC

let s:Vimrc = {
      \'JoinPath': s:VimrcFuncs.JoinPath,
      \'Echomsg': s:VimrcFuncs.Echomsg,
      \'EchomsgError': s:VimrcFuncs.EchomsgError,
      \'Has': s:VimrcFuncs.Has,
      \}
let s:workplace = s:Vimrc.JoinPath(expand('$DOT_VIM'), 'workplace')
let s:available = isdirectory(s:workplace)

function! s:list_plugins() abort
  if !s:available | return [] | endif
  return map(filter(split(globpath(s:workplace, '*'), "\n"),
        \ 'isdirectory(v:val)'), 'fnamemodify(v:val, ":p:h:t")')
endfunction

function! vimrc#workingplugin#load(...) abort
  if !(s:available && a:0) | return | endif
  let rtp = split(&rtp, ',')
  let plugins = s:list_plugins()

  for plugin in a:000
    if index(plugins, plugin) == -1
      call s:Vimrc.EchomsgError('Failed to load: ' . plugin)
      continue
    endif
    let plugin_dir = s:Vimrc.JoinPath(s:workplace, plugin)
    call filter(rtp, 'fnamemodify(v:val, ":p:h:t") !=# "vim-" . plugin')
    call add(rtp, plugin_dir)
    for file_name in extend(
        \ split(glob(s:Vimrc.JoinPath(plugin_dir, 'plugin', '*.vim')), "\n"),
        \ split(glob(s:Vimrc.JoinPath(plugin_dir, 'after', 'plugin', '*.vim')), "\n")
        \)
      " TODO: Do this unlet with autocmd?
      execute 'unlet! g:loaded_' . fnamemodify(file_name, ':p:t:r')
    endfor
  endfor
  let &rtp = join(rtp, ',')
  runtime! plugin/**/*.vim
endfunction

function! vimrc#workingplugin#cd(has_bang, plugin) abort
  if !s:available | return | endif
  execute (a:has_bang ? 'lcd' : 'tcd') s:Vimrc.JoinPath(s:workplace, a:plugin)
endfunction

function! vimrc#workingplugin#clone(...) abort
  if !(s:available && executable('git') && a:0)
    return
  endif
  if !s:Vimrc.Has(a:1, '/')
    call s:Vimrc.EchomsgError(string(a:1) . ' is not a repository.')
    return
  endif
  let repository = printf('https://github.com/%s.git', a:1)
  let clone_to = ''
  if a:0 == 1
    let clone_to = split(a:1, '/')[1]
  else
    let clone_to = a:2
  endif
  if s:Vimrc.Has(s:list_plugins(), clone_to)
    call s:Vimrc.EchomsgError('Directory already exists: ' . clone_to)
    return
  endif
  let clone_to = s:Vimrc.JoinPath(s:workplace, clone_to)
  execute '!git clone' repository clone_to
endfunction

function! vimrc#workingplugin#new(...) abort
  if !s:available | return | endif
  if !exists('*mkdir')
    call s:Vimrc.EchomsgError(
          \ 'Built-in mkdir() function is not available.')
    return
  endif
  for plugin in a:000
    let base_dir = s:Vimrc.JoinPath(s:workplace, plugin)
    if isdirectory(base_dir)
      call s:Vimrc.EchomsgError('Plugin already exists: ' . base_dir)
      continue
    endif
    call mkdir(base_dir)
    call mkdir(s:Vimrc.JoinPath(base_dir, 'plugin'))
    call mkdir(s:Vimrc.JoinPath(base_dir, 'autoload'))
    call s:Vimrc.Echomsg('Created: ' . plugin)
  endfor
endfunction

function! vimrc#workingplugin#rm(...) abort "{{{
  if !s:available | return | endif

  let plugin_list = s:list_plugins()
  for plugin in a:000
    if !s:Vimrc.Has(plugin_list, plugin)
      call s:Vimrc.EchomsgError('Plugin does not exist: ' . plugin)
      continue
    endif
    call s:Vimrc.Echomsg(printf('Delete %s ? [y/n]', plugin))
    if VimrcFunc('GetcharString')() !~? 'y'
      call s:Vimrc.Echomsg('Canceled.')
      continue
    endif
    if delete(s:Vimrc.JoinPath(s:workplace, plugin), 'rf') != 0
      call s:Vimrc.EchomsgError('Failed to delete: ' . plugin)
    else
      call s:Vimrc.Echomsg('Succesfully deleted: ' . plugin)
    endif
  endfor
endfunction "}}}

function! vimrc#workingplugin#complete(arg_lead, cmd_line, cursor_pos) abort
  if !s:available | return [] | endif
  return map(filter(s:list_plugins(), 'v:val =~? a:arg_lead'),
        \ 'fnameescape(v:val)')
endfunction

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
