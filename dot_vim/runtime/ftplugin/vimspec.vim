" The below is already set by textobj-function
" SetUndoFtplugin unlet! b:textobj_function_select
let b:textobj_function_select = function('vimrc#textobj_vimspec#select')

def CommandAbbrev(command: string): string
  if getline('.')[: col('.') - 1]->trim() ==# command
    return toupper(command[0]) .. command[1 :]
  else
    return command
  endif
enddef

inoreabbrev <expr> <buffer> describe CommandAbbrev('describe')
inoreabbrev <expr> <buffer> context CommandAbbrev('context')
inoreabbrev <expr> <buffer> before CommandAbbrev('before')
inoreabbrev <expr> <buffer> after CommandAbbrev('after')
inoreabbrev <expr> <buffer> it CommandAbbrev('it')
inoreabbrev <expr> <buffer> assert CommandAbbrev('assert')
inoreabbrev <expr> <buffer> throws CommandAbbrev('throws')
inoreabbrev <expr> <buffer> fail CommandAbbrev('fail')
inoreabbrev <expr> <buffer> skip CommandAbbrev('skip')

def AssertCommandAbbrev(command: string, abbrev: string): string
  if getline('.')[: col('.') - 1] =~? '\v^\s*Assert\s+' .. command .. '$'
    return abbrev
  else
    return command
  endif
enddef

inoreabbrev <expr> <buffer> true AssertCommandAbbrev('true', 'True')
inoreabbrev <expr> <buffer> false AssertCommandAbbrev('false', 'False')
inoreabbrev <expr> <buffer> truthy AssertCommandAbbrev('truthy', 'Truthy')
inoreabbrev <expr> <buffer> falsy AssertCommandAbbrev('falsy', 'Falsy')
inoreabbrev <expr> <buffer> compare AssertCommandAbbrev('compare', 'Compare')
inoreabbrev <expr> <buffer> equals AssertCommandAbbrev('equals', 'Equals')
inoreabbrev <expr> <buffer> notequals AssertCommandAbbrev('notequals', 'NotEquals')
inoreabbrev <expr> <buffer> same AssertCommandAbbrev('same', 'Same')
inoreabbrev <expr> <buffer> notsame AssertCommandAbbrev('notsame', 'NotSame')
inoreabbrev <expr> <buffer> match AssertCommandAbbrev('match', 'Match')
inoreabbrev <expr> <buffer> notmatch AssertCommandAbbrev('notmatch', 'NotMatch')
inoreabbrev <expr> <buffer> isnumber AssertCommandAbbrev('isnumber', 'IsNumber')
inoreabbrev <expr> <buffer> isnotnumber AssertCommandAbbrev('isnotnumber', 'IsNotNumber')
inoreabbrev <expr> <buffer> isstring AssertCommandAbbrev('isstring', 'IsString')
inoreabbrev <expr> <buffer> isnotstring AssertCommandAbbrev('isnotstring', 'IsNotString')
inoreabbrev <expr> <buffer> isfunction AssertCommandAbbrev('isfunction', 'IsFunction')
inoreabbrev <expr> <buffer> isnotfunction AssertCommandAbbrev('isnotfunction', 'IsNotFunction')
inoreabbrev <expr> <buffer> islist AssertCommandAbbrev('islist', 'IsList')
inoreabbrev <expr> <buffer> isnotlist AssertCommandAbbrev('isnotlist', 'IsNotList')
inoreabbrev <expr> <buffer> isdictionary AssertCommandAbbrev('isdictionary', 'IsDictionary')
inoreabbrev <expr> <buffer> isnotdictionary AssertCommandAbbrev('isnotdictionary', 'IsNotDictionary')
inoreabbrev <expr> <buffer> isfloat AssertCommandAbbrev('isfloat', 'IsFloat')
inoreabbrev <expr> <buffer> isnotfloat AssertCommandAbbrev('isnotfloat', 'IsNotFloat')
inoreabbrev <expr> <buffer> isbool AssertCommandAbbrev('isbool', 'IsBool')
inoreabbrev <expr> <buffer> isnotbool AssertCommandAbbrev('isnotbool', 'IsNotBool')
inoreabbrev <expr> <buffer> isnone AssertCommandAbbrev('isnone', 'IsNone')
inoreabbrev <expr> <buffer> isnotnone AssertCommandAbbrev('isnotnone', 'IsNotNone')
inoreabbrev <expr> <buffer> isjob AssertCommandAbbrev('isjob', 'IsJob')
inoreabbrev <expr> <buffer> isnotjob AssertCommandAbbrev('isnotjob', 'IsNotJob')
inoreabbrev <expr> <buffer> ischannel AssertCommandAbbrev('ischannel', 'IsChannel')
inoreabbrev <expr> <buffer> isnotchannel AssertCommandAbbrev('isnotchannel', 'IsNotChannel')
inoreabbrev <expr> <buffer> typeof AssertCommandAbbrev('typeof', 'TypeOf')
inoreabbrev <expr> <buffer> lengthof AssertCommandAbbrev('lengthof', 'LengthOf')
inoreabbrev <expr> <buffer> keyexists AssertCommandAbbrev('keyexists', 'KeyExists')
inoreabbrev <expr> <buffer> keynotexists AssertCommandAbbrev('keynotexists', 'KeyNotExists')
inoreabbrev <expr> <buffer> haskey AssertCommandAbbrev('haskey', 'HasKey')
inoreabbrev <expr> <buffer> exists AssertCommandAbbrev('exists', 'Exists')
inoreabbrev <expr> <buffer> cmdexists AssertCommandAbbrev('cmdexists', 'CmdExists')
inoreabbrev <expr> <buffer> empty AssertCommandAbbrev('empty', 'Empty')
inoreabbrev <expr> <buffer> notempty AssertCommandAbbrev('notempty', 'NotEmpty')

def ExpectCommandAbbrev(command: string, abbrev: string): string
  if getline('.')[: col('.') - 1] =~? '\v^\s*Expect\s+' .. abbrev .. '$'
    return abbrev
  else
    return command
  endif
enddef

inoreabbrev <expr> <buffer> tobefalsy ExpectCommandAbbrev('tobefalsy', 'ToBeFalsy')
inoreabbrev <expr> <buffer> tobegreaterthan ExpectCommandAbbrev('tobegreaterthan', 'ToBeGreaterThan')
inoreabbrev <expr> <buffer> tobegreaterthanorequal ExpectCommandAbbrev('tobegreaterthanorequal', 'ToBeGreaterThanOrEqual')
inoreabbrev <expr> <buffer> tobelessthan ExpectCommandAbbrev('tobelessthan', 'ToBeLessThan')
inoreabbrev <expr> <buffer> tobelessthanorequal ExpectCommandAbbrev('tobelessthanorequal', 'ToBeLessThanOrEqual')
inoreabbrev <expr> <buffer> toequal ExpectCommandAbbrev('toequal', 'ToEqual')
inoreabbrev <expr> <buffer> tobesame ExpectCommandAbbrev('tobesame', 'ToBeSame')
inoreabbrev <expr> <buffer> tomatch ExpectCommandAbbrev('tomatch', 'ToMatch')
inoreabbrev <expr> <buffer> tobenumber ExpectCommandAbbrev('tobenumber', 'ToBeNumber')
inoreabbrev <expr> <buffer> tobestring ExpectCommandAbbrev('tobestring', 'ToBeString')
inoreabbrev <expr> <buffer> tobefunc ExpectCommandAbbrev('tobefunc', 'ToBeFunc')
inoreabbrev <expr> <buffer> tobelist ExpectCommandAbbrev('tobelist', 'ToBeList')
inoreabbrev <expr> <buffer> tobedict ExpectCommandAbbrev('tobedict', 'ToBeDict')
inoreabbrev <expr> <buffer> tobefloat ExpectCommandAbbrev('tobefloat', 'ToBeFloat')
inoreabbrev <expr> <buffer> toexist ExpectCommandAbbrev('toexist', 'ToExist')
inoreabbrev <expr> <buffer> tobeempty ExpectCommandAbbrev('tobeempty', 'ToBeEmpty')
inoreabbrev <expr> <buffer> tohavelength ExpectCommandAbbrev('tohavelength', 'ToHaveLength')
inoreabbrev <expr> <buffer> tohavekey ExpectCommandAbbrev('tohavekey', 'ToHaveKey')
