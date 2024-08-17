vim9script noclear

import "./textobj_vim.vim" as Vim

final BLOCK_BEGIN = '\v\c^\s*<%(Describe|Before|After|Context|It)>'
final BLOCK_END = '\v\c^\s*<End>'

export def Select(object_type: string): any
  var GetRange: Vim.GetRangeFn
  if object_type ==# 'a'
    GetRange = Vim.GetRangeA
  else
    GetRange = Vim.GetRangeI
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
