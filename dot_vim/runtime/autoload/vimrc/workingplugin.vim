let s:cpoptions_save = &cpoptions
set cpoptions&vim

let s:JoinPath = VimrcFunc('join_path')
let s:Has = VimrcFunc('has')
let s:workplace = s:JoinPath(expand('$DOT_VIM'), 'workplace')
let s:available = isdirectory(s:workplace)
let s:message = {
      \ 'echomsg': VimrcFunc('echomsg'),
      \ 'echomsg_error': VimrcFunc('echomsg_error'),
      \ }

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
      call s:message.echomsg_error('Failed to load: ' . plugin)
      continue
    endif
    let plugin_dir = s:JoinPath(s:workplace, plugin)
    call filter(rtp, 'fnamemodify(v:val, ":p:h:t") !=# "vim-" . plugin')
    call add(rtp, plugin_dir)
    for file_name in extend(
        \ split(glob(s:JoinPath(plugin_dir, 'plugin', '*.vim')), "\n"),
        \ split(glob(s:JoinPath(plugin_dir, 'after', 'plugin', '*.vim')), "\n")
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
  execute (a:has_bang ? 'lcd' : 'tcd') s:JoinPath(s:workplace, a:plugin)
endfunction

function! vimrc#workingplugin#clone(...) abort
  if !(s:available && executable('git') && a:0)
    return
  endif
  if !s:Has(a:1, '/')
    call s:message.echomsg_error(string(a:1) . ' is not a repository.')
    return
  endif
  let repository = printf('https://github.com/%s.git', a:1)
  let clone_to = ''
  if a:0 == 1
    let clone_to = split(a:1, '/')[1]
  else
    let clone_to = a:2
  endif
  if s:Has(s:list_plugins(), clone_to)
    call s:message.echomsg_error('Directory already exists: ' . clone_to)
    return
  endif
  let clone_to = s:JoinPath(s:workplace, clone_to)
  execute '!git clone' repository clone_to
endfunction

function! vimrc#workingplugin#new(...) abort
  if !s:available | return | endif
  if !exists('*mkdir')
    call s:message.echomsg_error(
          \ 'Built-in mkdir() function is not available.')
    return
  endif
  for plugin in a:000
    let base_dir = s:JoinPath(s:workplace, plugin)
    if isdirectory(base_dir)
      call s:message.echomsg_error('Plugin already exists: ' . base_dir)
      continue
    endif
    call mkdir(base_dir)
    call mkdir(s:JoinPath(base_dir, 'plugin'))
    call mkdir(s:JoinPath(base_dir, 'autoload'))
    call s:message.echomsg('Created: ' . plugin)
  endfor
endfunction

function! vimrc#workingplugin#rm(...) abort "{{{
  if !s:available | return | endif

  let plugin_list = s:list_plugins()
  for plugin in a:000
    if !s:Has(plugin_list, plugin)
      call s:message.echomsg_error('Plugin does not exist: ' . plugin)
      continue
    endif
    call s:message.echomsg(printf('Delete %s ? [y/n]', plugin))
    if s:getchar_string() !~? 'y'
      call s:message.echomsg('Canceled.')
      continue
    endif
    if delete(s:JoinPath(s:workplace, plugin), 'rf') != 0
      call s:message.echomsg_error('Failed to delete: ' . plugin)
    else
      call s:message.echomsg('Succesfully deleted: ' . plugin)
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
