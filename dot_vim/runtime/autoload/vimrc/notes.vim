execute 'import * as Vimrc from' string($MYVIMRC)

let s:notes = {'save_dir_': ''}
function! s:notes.instance(path) abort
  let new_obj = deepcopy(self)
  let new_obj.save_dir_ = a:path
  return new_obj
endfunction
function! s:notes.list_files() abort
  return map(s:Vimrc.Glob(s:Vimrc.JoinPath(self.save_dir_, '*.*')),
       \ 'fnamemodify(v:val, ":p:t")')
endfunction
function! s:notes.new(opener) abort
  let name = s:Vimrc.Input('Name: ')
  if name ==# ''
    call Echo('Canceled.')
    return
  endif
  if s:Vimrc.Has(self, 'expand_filename')
    let name = self.expand_filename(name)
  endif
  let filepath = s:Vimrc.JoinPath(self.save_dir_, name)
  execute (a:opener ==# '' ? 'edit' : a:opener) fnameescape(filepath)
endfunction
function! s:notes.list() abort
  call vimrc#files#start(self.save_dir_)
endfunction
function! s:notes.delete(...) abort
  let files = self.list_files()
  for target in a:000
    if !s:Vimrc.Has(files, target)
      call EchomsgError('File does not exists: ' .. target)
      continue
    endif
    call s:Vimrc.Echomsg(printf('Delete %s ? [y/n]', target))
    if s:Vimrc.GetcharString() !~? 'y'
      call s:Vimrc.Echomsg('Canceled.')
      continue
    endif
    if delete(s:Vimrc.JoinPath(self.save_dir_, target)) == 0
      call s:Vimrc.Echomsg('Successfully deleted: ' .target)
    else
      call s:Vimrc.Echomsg('Failed to delete: ' .target)
    endif
  endfor
endfunction
function! s:notes.get_save_dir() abort
  return self.save_dir_
endfunction
function! s:notes.get_completion(arg_lead) abort
  return map(filter(self.list_files(), 'v:val =~? a:arg_lead'),
       \ 'fnameescape(v:val)')
endfunction
" Define :Memo* :Otameshi*
for s:type_ in ['memo', 'otameshi']
  let s:{s:type_} = s:notes.instance(s:Vimrc.JoinPath(
     \ s:Vimrc.CacheDir, s:type_))
  if !isdirectory(s:{s:type_}.get_save_dir())
    call mkdir(s:{s:type_}.get_save_dir(), 'p')
  endif
  if isdirectory(s:{s:type_}.get_save_dir())
    let s:com_prefix_ = toupper(s:type_[0]) .. s:type_[1:]
    execute printf('command! -bar -nargs=* %sNew call s:%s.new(<q-args>)',
         \ s:com_prefix_, s:type_)
    execute printf('command! -bar -nargs=+ -complete=customlist,Vimrc%sComplete %sDelete call s:%s.delete(<f-args>)',
         \ s:com_prefix_, s:com_prefix_, s:type_)
    execute printf('command! -bar %sList call s:%s.list()',
         \ s:com_prefix_, s:type_)
    unlet s:com_prefix_
  endif
endfor | unlet s:type_

function! s:memo.expand_filename(name) abort
  let name = a:name
  if !s:Vimrc.Has(name, '.')
    " Add .md extension only when use didn't specificate extension.
    let name ..= '.md'
  endif
  let name = strftime('%Y-%m-%d %H:%M ') .. name
  return name
endfunction
function! s:otameshi.expand_filename(name) abort
  if s:Vimrc.Has(a:name, '.') " Filename already s:Vimrc.has an extension.
    return a:name
  endif
  let extension = s:Vimrc.Input('Extension? (Empty will be non-extension file):')
  if extension ==# ''
    return a:name
  else
    return a:name .. '.' .. extension
  endif
endfunction
function! VimrcMemoComplete(arg_lead, cmd_line, cur_pos) abort
  return s:memo.get_completion(a:arg_lead)
endfunction
function! VimrcOtameshiComplete(arg_lead, cmd_line, cur_pos) abort
  return s:otameshi.get_completion(a:arg_lead)
endfunction
