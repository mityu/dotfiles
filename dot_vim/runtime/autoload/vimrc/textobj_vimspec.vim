vim9script noclear

if has('patch-8.2.4019')
  import "./textobj_vim.vim" as Vim
else
  import * as Vim from "./textobj_vim.vim"
endif

final BLOCK_BEGIN = '\v\c^\s*<%(Describe|Before|After|Context|It)>'
final BLOCK_END = '\v\c^\s*<End>'

def vimrc#textobj_vimspec#select(object_type: string): any
  var GetRange: func(string, string): list<number>
  if object_type ==# 'a'
    GetRange = function('Vim.GetRangeA')
  else
    GetRange = function('Vim.GetRangeI')
  endif

  var range = GetRange(Vim.FUNCTION_BEGIN, Vim.FUNCTION_END)
  if range == Vim.RANGE_NOT_FOUND
    range = GetRange(BLOCK_BEGIN, BLOCK_END)
    if range == Vim.RANGE_NOT_FOUND
      return 0
    endif
  endif
  return Vim.ConvertRangeToSelection(range)
enddef
