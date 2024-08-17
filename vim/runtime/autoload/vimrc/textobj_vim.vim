vim9script noclear

export final FUNCTION_BEGIN = '\v\C^\s*%(export\s+|legacy\s+)?%(fu%[nction]|def)>'
export final FUNCTION_END = '\v\C^\s*end%(f%[unction]|def)>'
export final RANGE_NOT_FOUND = [0, 0]
export type GetRangeFn = func(string, string): list<number>

export def Select(object_type: string): any
  var range: list<number>
  if object_type ==# 'a'
    range = GetRangeA(FUNCTION_BEGIN, FUNCTION_END)
  else
    range = GetRangeI(FUNCTION_BEGIN, FUNCTION_END)
  endif

  if range == RANGE_NOT_FOUND
    return 0
  endif
  return ConvertRangeToSelection(range)
enddef

export def ConvertRangeToSelection(range: list<number>): list<any>
  cursor(range[0], 0)
  normal! 0
  var b = getpos('.')

  cursor(range[1], 0)
  normal! $
  var e = getpos('.')

  return ['V', b, e]
enddef

export def GetRangeA(begin: string, end: string): list<number>
  if getline('.') !~# end
    if searchpair(begin, '', end, 'W') <= 0
      # It seems that the cursor is not on any function.
      return RANGE_NOT_FOUND
    endif
  endif

  var end_line = line('.')

  normal! 0
  if searchpair(begin, '', end, 'bW') <= 0
    # Found the end, but did not found the begin
    return RANGE_NOT_FOUND
  endif
  return [line('.'), end_line]
enddef

export def GetRangeI(begin: string, end: string): list<number>
  var range = GetRangeA(begin, end)
  if range == RANGE_NOT_FOUND
    return RANGE_NOT_FOUND
  endif

  if range[1] - range[0] <= 1
    return RANGE_NOT_FOUND
  endif

  return [range[0] + 1, range[1] - 1]
enddef
