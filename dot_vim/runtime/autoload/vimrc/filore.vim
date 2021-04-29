"Plugin Name: filore.vim
"Author: mityu
"Last Change: 29-Apr-2021.

let s:cpoptions_save = &cpoptions
set cpoptions&vim

let s:NULL = 0
let s:TRUE = 1
let s:FALSE = !s:TRUE
let s:t_string = type('')
let s:t_dict = type({})
let s:prompt_lines_count = 0

" Utility
let s:notify = {}
function! s:notify.notify(msg,hl_group,cmd) abort "{{{
  execute 'echohl' a:hl_group
  execute a:cmd string('[filore] ' . a:msg)
  echohl None
endfunction "}}}
function! s:notify.error(msg) abort "{{{
  call self.notify(a:msg,'Error','echomsg')
endfunction "}}}
function! s:notify.warning(msg) abort "{{{
  call self.notify(a:msg,'Warning','echomsg')
endfunction "}}}

let s:filesystem = {}
function! s:filesystem.name(path) abort "{{{
  if isdirectory(a:path)
    return fnamemodify(a:path,':p:h:t')
  else
    return fnamemodify(a:path,':p:t')
  endif
endfunction "}}}
function! s:filesystem.base(path) abort "{{{
  if isdirectory(a:path)
    return fnamemodify(a:path,':p:h:h')
  else
    return fnamemodify(a:path,':p:h')
  endif
endfunction "}}}
function! s:filesystem.abs(path) abort "{{{
  return fnamemodify(a:path,':p')
endfunction "}}}

function! s:list_files(dir_path) abort "{{{
  let show_hidden = s:win_get_reference_of_current_items().show_hidden_files
  let dir_path = escape(a:dir_path,',')
  let raw_file_list = []
  let dirs = [] | let files = []
  if show_hidden
    call extend(raw_file_list,globpath(dir_path,'.*',s:FALSE,s:TRUE))
    call filter(raw_file_list,'!s:has_item([".",".."],fnamemodify(v:val,":t"))')
  endif
  call extend(raw_file_list, globpath(dir_path, '*', s:FALSE, s:TRUE))
  for _ in raw_file_list
    if isdirectory(_)
      call add(dirs, _)
    elseif filereadable(_)
      call add(files, _)
    endif
  endfor
  return [dirs, files]
endfunction "}}}
function! s:remove_item(list,item) abort "{{{
  let index = index(a:list,a:item)
  if index != -1
    return remove(a:list,index)
  endif
  return ''
endfunction "}}}
function! s:has_item(list,item) abort "{{{
  return index(a:list,a:item) != -1
endfunction "}}}
function! s:extend_pos(list,item,...) "{{{
  " NOTE:
  " - Use builtin function when change 'a:list' in order to apply
  "   changes to the entitiy of reference.
  " - 'index' is used same as 'insert()'
  let index = exists('a:1') ? a:1 : 0
  if index < 0 | let index = s:mod(index,len(a:list)) | endif
  let list = deepcopy(a:list)
  call remove(a:list, 0, -1) " Remove everything to prepare for changes.
  if index == 0
    call extend(a:list, a:item + list)
  elseif index >= len(list)
    call extend(a:list, list + a:item)
  else
    call extend(a:list, list[:index-1] + a:item + list[index:])
  endif
  return a:list
endfunction "}}}
function! s:mod(n,law) abort "{{{
  if a:n >= 0
    return a:n % a:law
  else
    return a:n + (-a:n/a:law + ((-a:n%a:law) ? 1 : 0)) * a:law
  endif
endfunction "}}}
function! s:isdirectory(item) abort "{{{
  if type(a:item) == s:t_dict
    return a:item.isdirectory
  elseif type(a:item) == s:t_string
    return isdirectory(a:item)
  else
    call s:notify.warning('Unknown argument type: ' . type(a:item))
    return s:FALSE
  endif
endfunction "}}}
function! s:escape_regpat(pat) abort "{{{
  return escape(a:pat,'.~/\^$[]:+*')
endfunction "}}}
function! s:is_cmdwin() abort "{{{
  return getcmdwintype() !=# ''
endfunction "}}}
function! s:path_slash() abort "{{{
  " Get path separator from directory's full-path.
  return fnamemodify(getcwd(), ':p')[-1:]
endfunction "}}}

" Main
function! vimrc#filore#start(...) abort "{{{
  if s:is_cmdwin()
    call s:notify.error('filore cannot be used in command-line window')
    return
  endif
  let current_directory = get(a:000, 0, '')->expand()
  if current_directory !=# '' && isdirectory(current_directory)
    " Do nothing.
  elseif expand('%') !=# '' && &buftype ==# '' && &buflisted
    let current_directory = fnamemodify(expand('%'),':p:h')
  else
    let current_directory = getcwd()
  endif
  call s:win_new(current_directory)
  call s:history_register(current_directory)
endfunction "}}}
function! s:filore_define_plugin_mappings() abort "{{{
  let maps = [
      \ ['exit', 'win_close()'],
      \ ['enter-directory', 'browse_enter_directory_under_cursor()'],
      \ ['leave-directory', 'browse_leave_directory()'],
      \ ['toggle-directory-folding', 'browse_toggle_directory_folding_under_cursor()'],
      \ ['toggle-show-hidden-files', 'browse_toggle_show_hidden_files()'],
      \ ['loop-cursor-up', 'filore_loop_cursor(-v:count1)'],
      \ ['loop-cursor-down', 'filore_loop_cursor(v:count1)'],
      \ ['open-file', 'browse_open_file_under_cursor()'],
      \ ['start-history', 'history_start_select()'],
      \ ['filter-files', 'browse_filter_files()']
      \ ]
      " \ ['', ''],
  call map(maps,{key, val ->
        \ printf(
        \ 'nnoremap <silent><buffer> <Plug>(filore-%s) ' .
        \ ':<C-u>call <SID>%s<CR>',
        \ val[0], val[1])})
  execute join(maps,"\n")
endfunction "}}}
function! s:filore_loop_cursor(movement) abort "{{{
  let move_to = line('.') - s:prompt_lines_count + a:movement - 1
  let law = line('$') - s:prompt_lines_count
  let move_to = s:mod(move_to,law) + 1 + s:prompt_lines_count
  call cursor(move_to,col('%'))
endfunction "}}}

" Window
if !exists('s:filore_list')
  let s:filore_list = {}
endif
if !exists('s:cursorpos')
  let s:cursorpos = {}
endif
function! s:win_new(current_directory) abort "{{{
  let alter_bufnr = bufnr('%')
  call s:win_open_new()
  let items = s:win_get_reference_of_current_items()
  let items.current_directory = a:current_directory
  let items.file_list = []
  let items.show_hidden_files = s:FALSE
  let items.alter_bufnr = alter_bufnr
  let items.unfolded_directories = []
  call s:browse_fresh_display()
endfunction "}}}
function! s:win_fork(bufnr_from) abort "{{{
  " NOTE: Use builtin function when change 'items' in order to apply
  " changes to the entitiy of reference.
  call s:win_open_new()
  let items = s:win_get_reference_of_current_items()
  call filter(items,'0') " Remove everything to prepare for initializing.
  call extend(items, deepcopy(s:win_get_reference_of_items(a:bufnr_from)))
  call s:browse_fresh_display()
endfunction "}}}
function! s:win_open_new() abort "{{{
  let new_name = s:win_get_available_name()
  execute 'keepjumps silent edit' new_name
  call s:filore_define_plugin_mappings()

  if !has_key(s:filore_list, new_name)
    let s:filore_list[new_name] = {
          \ 'items': {},
          \ 'bufnr': s:NULL,
          \ }
  endif
  let s:filore_list[new_name].bufnr = bufnr('%')

  augroup filore_window
    autocmd! * <buffer>
    autocmd BufHidden,BufWipeOut <buffer> call s:win_BufHidden()
    autocmd BufWinEnter <buffer> call s:win_BufWinEnter()
    autocmd WinEnter <buffer> call s:win_WinEnter()
    autocmd BufEnter <buffer> call s:win_BufEnter()
    autocmd BufEnter <buffer> call s:browse_color()
    autocmd ColorScheme <buffer> call s:browse_color()
  augroup END

  setlocal nobuflisted noswapfile noundofile filetype=filore
  setlocal nomodified nomodifiable

  call s:browse_color()
endfunction "}}}
function! s:win_get_available_name() abort "{{{
  let name_base = 'filore://file-browser:'
  let subscript = 1
  while s:TRUE
    let new_name = name_base . string(subscript)
    if !has_key(s:filore_list, new_name)
      return new_name
    elseif s:filore_list[new_name].bufnr == s:NULL
      augroup filore_window
        execute printf('autocmd! BufWinEnter <buffer=%d>',
              \ bufnr(s:escape_regpat(new_name)))
      augroup END
      return new_name
    endif
    let subscript += 1
  endwhile
endfunction "}}}
function! s:win_close() abort "{{{
  let alter_bufnr = s:win_get_reference_of_current_items().alter_bufnr
  if has_key(s:filore_list, bufname(alter_bufnr)) ||
        \ !bufexists(alter_bufnr) ||
        \ alter_bufnr == s:NULL
    enew
  else
    execute 'keepjumps silent buffer' alter_bufnr
  endif
endfunction "}}}
function! s:win_get_reference_of_current_items() abort "{{{
  return s:win_get_reference_of_items(bufnr('%'))
endfunction "}}}
function! s:win_get_reference_of_items(bufnr) abort "{{{
  let buffer_name = bufname(a:bufnr)
  if !has_key(s:filore_list,buffer_name)
    call s:notify.error('items is not in s:filore_list: ' . buffer_name)
    return {}
  endif
  return s:filore_list[buffer_name].items
endfunction "}}}
function! s:win_BufHidden() abort "{{{
  let s:filore_list[expand('<afile>')].bufnr = s:NULL
  let items = s:win_get_reference_of_current_items()
  let items.alter_bufnr = s:NULL
endfunction "}}}
function! s:win_BufWipeout() abort "{{{
  " NOTE: expand('<abuf>') : Wiped out buffer's name
  call remove(s:filore_list,expand('<abuf>'))
endfunction "}}}
function! s:win_BufWinEnter() abort "{{{
  " NOTE:
  "  bufnr('%') : New buffer's name
  "  bufnr('#') : Previous buffer's name
  let s:filore_list[expand('%')].bufnr = bufnr('%')
  let items = s:win_get_reference_of_current_items()
  let items.alter_bufnr = bufnr('#')
endfunction "}}}
function! s:win_BufEnter() abort "{{{
  if len(win_findbuf(bufnr('%'))) > 1
    call s:win_fork(bufnr('%'))
  endif
endfunction "}}}
function! s:win_WinEnter() abort "{{{
  if has_key(s:filore_list, bufname('%')) && len(win_findbuf(bufnr('%'))) > 1
    call s:win_fork(bufnr('%'))
  endif
endfunction "}}}
function! s:win_call_buffer_modify_function(func_name,args) abort "{{{
  let bufnr = bufnr('%')
  call setbufvar(bufnr,'&modifiable',1)
  silent call call(a:func_name,[bufnr] + a:args)
  call setbufvar(bufnr,'&modified',0)
  call setbufvar(bufnr,'&modifiable',0)
endfunction "}}}
function! s:win_setline(lnum,text) abort "{{{
  call s:win_call_buffer_modify_function('setbufline',[a:lnum,a:text])
endfunction "}}}
function! s:win_append(lnum,expr) abort "{{{
  call s:win_call_buffer_modify_function('appendbufline',[a:lnum,a:expr])
endfunction "}}}
function! s:win_deleteline(first,...) abort "{{{
  call s:win_call_buffer_modify_function('deletebufline',[a:first] + a:000)
endfunction "}}}

" Browse
function! s:browse_fresh_current_directory_info() abort "{{{
  let items = s:win_get_reference_of_current_items()
  let items.file_list = s:browse_list_files(
        \ items.current_directory, s:NULL) " 'depth' starts with 0.
endfunction "}}}
function! s:browse_list_files(parent_dirctory, depth) abort "{{{
  return s:browse_fill_nested_file_info(s:browse_list_file_info(
        \ a:parent_dirctory, a:depth))
endfunction "}}}
function! s:browse_list_file_info(parent_dirctory,depth) abort "{{{
  let [dirs,files] = s:list_files(a:parent_dirctory)
  let Convert_to_info = {file_name, isdirectory ->
        \ {
        \   'abs': s:filesystem.abs(file_name),
        \   'filename': s:filesystem.name(file_name),
        \   'depth': a:depth,
        \   'isdirectory': isdirectory,
        \ }} " 'depth' starts with 0
  call map(dirs,'Convert_to_info(v:val,s:TRUE)')
  call map(files,'Convert_to_info(v:val,s:FALSE)')

  return dirs + files
endfunction "}}}
function! s:browse_fill_nested_file_info(file_list) abort "{{{
  let file_list = a:file_list
  let unfolded_directories =
        \ s:win_get_reference_of_current_items().unfolded_directories
  let size = len(file_list)
  let index = -1

  while s:TRUE
    let index += 1
    if index == size
      break
    endif
    if !s:isdirectory(file_list[index])
      if file_list[index].depth == s:NULL
        break
      endif
      continue
    endif
    if s:has_item(unfolded_directories, file_list[index].abs)
      call s:extend_pos(file_list,
            \ s:browse_list_file_info(file_list[index].abs,
            \   file_list[index].depth + 1),
            \ index+1)
      let size = len(file_list)
    endif
  endwhile

  return file_list
endfunction "}}}
function! s:browse_get_display_text(file_info) abort "{{{
  let items = s:win_get_reference_of_current_items()
  let text = repeat(' ', a:file_info.depth * 2) " Make indent
  let text .= '|'
  if s:isdirectory(a:file_info)
    if s:has_item(items.unfolded_directories, a:file_info.abs)
      " The directory is opened.
      let text .= '-'
    else
      let text .= '+'
    endif
  else
    let text .= ' '
  endif
  let text .= ' '
  let text .= a:file_info.filename

  return text
endfunction "}}}
function! s:browse_get_index_from_lnum(lnum) abort "{{{
  return a:lnum - 1 - s:prompt_lines_count
endfunction "}}}
function! s:browse_get_lnum_from_index(index) abort "{{{
  return a:index + 1 + s:prompt_lines_count
endfunction "}}}
function! s:browse_fresh_display() abort "{{{
  let curpos_save = getpos('.')
  call s:browse_fresh_current_directory_info()
  let file_list = deepcopy(s:win_get_reference_of_current_items().file_list)
  call s:win_deleteline(1, '$')

  if empty(file_list)
    call s:win_setline(1 + s:prompt_lines_count, '(No Item)')
    call cursor(line('$'), 0)
    return
  endif

  call map(file_list,'s:browse_get_display_text(v:val)')
  call s:win_setline(1 + s:prompt_lines_count, file_list)
  call setpos('.', curpos_save)
endfunction "}}}
function! s:browse_unfold_directory_under_cursor() abort "{{{
  let items = s:win_get_reference_of_current_items()
  let lnum = line('.')
  let index = s:browse_get_index_from_lnum(lnum)
  let file_info = copy(items.file_list[index])

  call add(items.unfolded_directories, file_info.abs)
  call s:win_setline(lnum, s:browse_get_display_text(file_info))

  let child_file_list = s:browse_list_files(file_info.abs, file_info.depth + 1)
  if empty(child_file_list) | return | endif

  call s:extend_pos(items.file_list, child_file_list, index + 1)
  call s:win_append(lnum, map(deepcopy(child_file_list),
        \ 's:browse_get_display_text(v:val)'))
endfunction "}}}
function! s:browse_fold_directory_under_cursor() abort "{{{
  let items = s:win_get_reference_of_current_items()
  let lnum = line('.')
  let index = s:browse_get_index_from_lnum(lnum)
  let file_info = items.file_list[index]

  call s:remove_item(items.unfolded_directories, file_info.abs)
  call s:win_setline(lnum, s:browse_get_display_text(file_info))

  let file_list = items.file_list
  let child_start = index + 1
  let child_end = child_start
  let child_depth = file_info.depth + 1
  let file_list_size = len(file_list)

  while s:TRUE
    if child_end == file_list_size
      let child_end -= 1
      break
    endif
    if file_list[child_end].depth < child_depth
      let child_end -= 1
      break
    endif
    let child_end += 1
  endwhile
  if (child_start - 1) == child_end
    " The parent directory is empty.
    return
  endif
  call remove(file_list, child_start, child_end)
  call s:win_deleteline(s:browse_get_lnum_from_index(child_start),
        \ s:browse_get_lnum_from_index(child_end))
endfunction "}}}
function! s:browse_toggle_directory_folding_under_cursor() abort "{{{
  let items = s:win_get_reference_of_current_items()
  let file_info = items.file_list[s:browse_get_index_from_lnum(line('.'))]
  if !s:isdirectory(file_info) | return | endif
  if s:has_item(items.unfolded_directories, file_info.abs)
    " The directory is unfolded.
    call s:browse_fold_directory_under_cursor()
  else
    call s:browse_unfold_directory_under_cursor()
  endif
endfunction "}}}
function! s:browse_store_cursor_position_in_cache() abort "{{{
  let s:cursorpos[s:win_get_reference_of_current_items().current_directory]
        \ = line('.')
endfunction "}}}
function! s:browse_restore_cursor_position_with_cache() abort "{{{
  let cwd = s:win_get_reference_of_current_items().current_directory
  if !has_key(s:cursorpos, cwd)
    let s:cursorpos[cwd] = 1 + s:prompt_lines_count
  endif
  call cursor(s:cursorpos[cwd], 0)
endfunction "}}}
function! s:browse_enter_directory_under_cursor() abort "{{{
  call s:browse_store_cursor_position_in_cache()
  let items = s:win_get_reference_of_current_items()
  let file_info = items.file_list[s:browse_get_index_from_lnum(line('.'))]

  if !s:isdirectory(file_info) | return | endif

  let items.current_directory = file_info.abs
  call s:browse_fresh_display()
  call s:browse_restore_cursor_position_with_cache()
  call s:history_register(items.current_directory)
endfunction "}}}
function! s:browse_leave_directory() abort "{{{
  call s:browse_store_cursor_position_in_cache()
  let items = s:win_get_reference_of_current_items()
  let items.current_directory = s:filesystem.base(items.current_directory)
  call s:browse_fresh_display()
  call s:browse_restore_cursor_position_with_cache()
  call s:history_register(items.current_directory)
endfunction "}}}
function! s:browse_toggle_show_hidden_files() abort "{{{
  let items = s:win_get_reference_of_current_items()
  let flag_save = items.show_hidden_files
  let file_info_save = copy(items.file_list[
        \ s:browse_get_index_from_lnum(line('.'))])
  let items.show_hidden_files = !items.show_hidden_files
  call s:browse_fresh_display()

  " Change cursor position with file info only when switch to show hidden files.
  if flag_save | return | endif
  let size = len(items.file_list)
  let index = 0
  while items.file_list[index].abs !=# file_info_save.abs
    let index += 1
    if size == index | break | endif
  endwhile

  " 'index' is same to 'size' when the file wasn't found.
  if index != size
    call cursor(s:browse_get_lnum_from_index(index), 0)
  endif
endfunction "}}}
function! s:browse_open_file_under_cursor() abort "{{{
  let file_info = s:win_get_reference_of_current_items().file_list[
        \ s:browse_get_index_from_lnum(line('.'))]
  if s:isdirectory(file_info) | return | endif
  execute 'edit' fnameescape(fnamemodify(file_info.abs, ':~:.'))
endfunction "}}}
function! s:browse_color() abort "{{{
  let node_directory = '\(\_^\(\s\s\)*\)\@<=|[+-]\s\@='
  let node_file = '\(\_^\(\s\s\)*\)\@<=|\(\s\s\)\@='
  let SyntaxMatch = {hlgroup, pat ->
        \ execute(printf('syntax match %s /%s/', hlgroup, pat))}
  let HighlightLink = {hlgroup, link_to ->
        \ hlexists(hlgroup) ? 0 :
        \ execute(printf('highlight link %s %s', hlgroup, link_to))}

  syntax clear
  call HighlightLink('filoreBrowseNode', 'Title')
  call HighlightLink('filoreBrowseDirectory', 'Directory')
  call HighlightLink('filoreBrowseNoItem', 'Comment')
  call SyntaxMatch('filoreBrowseNode', node_directory)
  call SyntaxMatch('filoreBrowseNode', node_file)
  call SyntaxMatch('filoreBrowseDirectory',
        \ printf('\(%s\)\@<=.\+$', node_directory))
  call SyntaxMatch('filoreBrowseNoItem',
        \ printf('\%%%dl\_^(No\sItem)$', 1 + s:prompt_lines_count))
endfunction "}}}

function! s:browse_filter_files() abort
  let cwd_strlen = s:win_get_reference_of_current_items().current_directory
        \->strlen() + 1
  let files = s:win_get_reference_of_current_items().file_list
        \->mapnew({idx, item -> #{word: item.abs[cwd_strlen :], user_data: idx}})
  call gram#select({
        \ 'name': 'Move to file',
        \ 'items': files,
        \ 'callback': {item -> cursor(s:browse_get_lnum_from_index(item.user_data), 0)},
        \ })
endfunction
" History
function! s:history_register(path) abort "{{{
  call s:remove_item(s:history, a:path)
  call insert(s:history, a:path)
endfunction "}}}
function! s:history_start_select() abort "{{{
  let s:gram.items = s:history
  call gram#select(s:gram)
endfunction "}}}
if !exists('s:gram')
  let s:gram = {'name': 'filore-history'}
  function! s:gram.callback(selected_item) abort
    let items = s:win_get_reference_of_current_items()
    let items.current_directory = a:selected_item.word
    call s:browse_fresh_display()
  endfunction
endif
if !exists('s:history')
  let s:history = []
endif

" Command-line and command-line window
function! s:cmdline_current_bufnr() abort "{{{
  return s:is_cmdwin() ? bufnr('#') : bufnr('%')
endfunction "}}}
function! s:cmdline_is_current_filore() abort "{{{
  return has_key(s:filore_list, bufname(s:cmdline_current_bufnr()))
endfunction "}}}

" User utility
function! vimrc#filore#smart_map(on_directory, on_file) abort "{{{
  if s:isdirectory(s:win_get_reference_of_current_items().file_list[
        \ s:browse_get_index_from_lnum(line('.'))])
    return a:on_directory
  else
    return a:on_file
  endif
endfunction "}}}
function! vimrc#filore#get_current_directory_path() abort "{{{
  let dir = s:win_get_reference_of_items(
        \ s:cmdline_current_bufnr()).current_directory
  let dir = fnamemodify(dir, ':p')

  " Relate to current directory.
  let modified = fnamemodify(dir, ':.')
  if dir !=# modified
    return '.' . s:path_slash() . modified
  endif

  " Relate to $HOME.
  let modified = fnamemodify(dir, ':~')
  if dir !=# modified
    return modified
  endif

  return dir
endfunction "}}}
function! vimrc#filore#get_file_path_of_under_cursor() abort "{{{
  if s:is_cmdwin()
    if getcmdtype() ==# '='
      let winid = str2nr(win_execute(win_getid(),
            \ 'echo win_getid(winnr("#"))'))
    else
      let winid = win_getid(winnr('#'))
    endif
    let lnum = line('.', winid)
    if lnum < (1 + s:prompt_lines_count) || lnum > line('$', winid)
      return ''
    endif
    return s:win_get_reference_of_items(winbufnr(winid)).file_list[
          \ s:browse_get_index_from_lnum(lnum)].abs
  else
    return vimrc#filore#get_file_path_of_line(line('.'))
  endif
  return ''
endfunction "}}}
function! vimrc#filore#get_file_path_of_line(lnum) abort "{{{
  if !s:cmdline_is_current_filore()
    return ''
  endif
  if a:lnum < (1 + s:prompt_lines_count) || a:lnum > line('$')
    return ''
  endif
  return s:win_get_reference_of_current_items().file_list[
        \ s:browse_get_index_from_lnum(a:lnum)].abs
endfunction "}}}

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
