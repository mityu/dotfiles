vim9script

import $MYVIMRC as Vimrc

def NewInstance(name: string): dict<any>
  var path = Vimrc.JoinPath(Vimrc.CacheDir, name)
  if !isdirectory(path)
    mkdir(path, 'p')
  endif
  return {save_dir_: path}
enddef

def ListFiles(self: dict<any>): list<string>
  return Vimrc.Glob(Vimrc.JoinPath(self.save_dir_, '*.*'))
         ->map((_: number, val: string): string => fnamemodify(val, ':p:t'))
enddef

def CreateNewNote(self: dict<any>, filename_specified: string = '')
  var filename: string
  if filename_specified ==# ''
    filename = Vimrc.Input('Name: ')
    if filename ==# ''
      Vimrc.Echo('Canceled.')
      return
    endif
  else
    filename = filename_specified
  endif
  if Vimrc.HasInDict(self, 'ExpandFilename')
    filename = call(self.ExpandFilename, [filename])
  endif
  var filepath = Vimrc.JoinPath(self.save_dir_, filename)
  execute 'edit' fnameescape(filepath)
enddef

def OpenNote(self: dict<any>)
  vimrc#files#start(self.save_dir_)
enddef

def DeleteNote(self: dict<any>, ...notes: list<string>)
  files = self->ListFiles()
  for target in notes
    if !Vimrc.HasInList(files, target)
      Vimrc.EchomsgError('File does not exist: ' .. target)
      continue
    endif
    Vimrc.EchoQuestion(printf('Delete %s ?', target))
    if getcharstr() !~? 'y'
      Vimrc.Echomsg('Canceled')
      continue
    endif
    if delete(Vimrc.JoinPath(self.save_dir_, target)) == 0
      Vimrc.Echomsg('Successfully deleted: ' .. target)
    else
      Vimrc.Echomsg('Failed to delete: ' .. target)
    endif
  endfor
enddef

def GetCompletion(self: dict<any>, arg_lead: string): list<string>
  return self->ListFiles()
             ->filter((_: number, val: string): bool => val =~? arg_lead)
             ->map((_: number, val: string): string => fnameescape(val))
enddef

var MemoList: dict<any> = NewInstance('memo')
var OtameshiList: dict<any> = NewInstance('otameshi')

def MemoExpandFilename(name_arg: string): string
  var name = name_arg
  if !Vimrc.HasInString(name, '.')
    name ..= '.md'
  endif
  name = strftime('%Y-%m-%d-%H-%M-') .. name
  return name
enddef
MemoList.ExpandFilename = MemoExpandFilename

def OtameshiExpandFilename(name: string): string
  if Vimrc.HasInString(name, '.')
    return name
  endif
  var extension = Vimrc.Input('Extension? (Empty will be non-extension file): ')
  if extension ==# ''
    return name
  endif
  return name .. '.' .. extension
enddef
OtameshiList.ExpandFilename = OtameshiExpandFilename

export def Memo_new(filename: string)
  MemoList->CreateNewNote(filename)
enddef

export def Otameshi_new(filename: string)
  OtameshiList->CreateNewNote(filename)
enddef

export def Memo_delete(files: list<string>)
  MemoList->DeleteNote(files)
enddef

export def Otameshi_delete(files: list<string>)
  OtamemshiList->DeleteNote(files)
enddef

export def Memo_list()
  MemoList->OpenNote()
enddef

export def Otameshi_list()
  OtameshiList->OpenNote()
enddef

export def Memo_complete(
  arg_lead: string,
  command_line: string,
  cursor_pos: number): list<string>
  return MemoList->GetCompletion(arg_lead)
enddef

export def Otameshi_complete(
  arg_lead: string,
  command_line: string,
  cursor_pos: number): list<string>
  return OtameshiList->GetCompletion(arg_lead)
enddef
