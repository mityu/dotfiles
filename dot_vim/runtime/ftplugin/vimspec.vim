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

iabbrev <expr> <buffer> describe CommandAbbrev('describe')
iabbrev <expr> <buffer> context CommandAbbrev('context')
iabbrev <expr> <buffer> before CommandAbbrev('before')
iabbrev <expr> <buffer> after CommandAbbrev('after')
iabbrev <expr> <buffer> it CommandAbbrev('it')
iabbrev <expr> <buffer> assert CommandAbbrev('assert')
iabbrev <expr> <buffer> throws CommandAbbrev('throws')
iabbrev <expr> <buffer> fail CommandAbbrev('fail')
iabbrev <expr> <buffer> skip CommandAbbrev('skip')

def AssertCommandAbbrev(command: string, abbrev: string): string
  if getline('.')[: col('.') - 1] =~? '\v^\s*Assert\s+' .. command .. '$'
    return abbrev
  else
    return command
  endif
enddef

iabbrev <expr> <buffer> true AssertCommandAbbrev('true', 'True')
iabbrev <expr> <buffer> false AssertCommandAbbrev('false', 'False')
iabbrev <expr> <buffer> truthy AssertCommandAbbrev('truthy', 'Truthy')
iabbrev <expr> <buffer> falsy AssertCommandAbbrev('falsy', 'Falsy')
iabbrev <expr> <buffer> compare AssertCommandAbbrev('compare', 'Compare')
iabbrev <expr> <buffer> equals AssertCommandAbbrev('equals', 'Equals')
iabbrev <expr> <buffer> notequals AssertCommandAbbrev('notequals', 'NotEquals')
iabbrev <expr> <buffer> same AssertCommandAbbrev('same', 'Same')
iabbrev <expr> <buffer> notsame AssertCommandAbbrev('notsame', 'NotSame')
iabbrev <expr> <buffer> match AssertCommandAbbrev('match', 'Match')
iabbrev <expr> <buffer> notmatch AssertCommandAbbrev('notmatch', 'NotMatch')
iabbrev <expr> <buffer> isnumber AssertCommandAbbrev('isnumber', 'IsNumber')
iabbrev <expr> <buffer> isnotnumber AssertCommandAbbrev('isnotnumber', 'IsNotNumber')
iabbrev <expr> <buffer> isstring AssertCommandAbbrev('isstring', 'IsString')
iabbrev <expr> <buffer> isnotstring AssertCommandAbbrev('isnotstring', 'IsNotString')
iabbrev <expr> <buffer> isfunction AssertCommandAbbrev('isfunction', 'IsFunction')
iabbrev <expr> <buffer> isnotfunction AssertCommandAbbrev('isnotfunction', 'IsNotFunction')
iabbrev <expr> <buffer> islist AssertCommandAbbrev('islist', 'IsList')
iabbrev <expr> <buffer> isnotlist AssertCommandAbbrev('isnotlist', 'IsNotList')
iabbrev <expr> <buffer> isdictionary AssertCommandAbbrev('isdictionary', 'IsDictionary')
iabbrev <expr> <buffer> isnotdictionary AssertCommandAbbrev('isnotdictionary', 'IsNotDictionary')
iabbrev <expr> <buffer> isfloat AssertCommandAbbrev('isfloat', 'IsFloat')
iabbrev <expr> <buffer> isnotfloat AssertCommandAbbrev('isnotfloat', 'IsNotFloat')
iabbrev <expr> <buffer> isbool AssertCommandAbbrev('isbool', 'IsBool')
iabbrev <expr> <buffer> isnotbool AssertCommandAbbrev('isnotbool', 'IsNotBool')
iabbrev <expr> <buffer> isnone AssertCommandAbbrev('isnone', 'IsNone')
iabbrev <expr> <buffer> isnotnone AssertCommandAbbrev('isnotnone', 'IsNotNone')
iabbrev <expr> <buffer> isjob AssertCommandAbbrev('isjob', 'IsJob')
iabbrev <expr> <buffer> isnotjob AssertCommandAbbrev('isnotjob', 'IsNotJob')
iabbrev <expr> <buffer> ischannel AssertCommandAbbrev('ischannel', 'IsChannel')
iabbrev <expr> <buffer> isnotchannel AssertCommandAbbrev('isnotchannel', 'IsNotChannel')
iabbrev <expr> <buffer> typeof AssertCommandAbbrev('typeof', 'TypeOf')
iabbrev <expr> <buffer> lengthof AssertCommandAbbrev('lengthof', 'LengthOf')
iabbrev <expr> <buffer> keyexists AssertCommandAbbrev('keyexists', 'KeyExists')
iabbrev <expr> <buffer> keynotexists AssertCommandAbbrev('keynotexists', 'KeyNotExists')
iabbrev <expr> <buffer> haskey AssertCommandAbbrev('haskey', 'HasKey')
iabbrev <expr> <buffer> exists AssertCommandAbbrev('exists', 'Exists')
iabbrev <expr> <buffer> cmdexists AssertCommandAbbrev('cmdexists', 'CmdExists')
iabbrev <expr> <buffer> empty AssertCommandAbbrev('empty', 'Empty')
iabbrev <expr> <buffer> notempty AssertCommandAbbrev('notempty', 'NotEmpty')

def ExpectCommandAbbrev(command: string, abbrev: string): string
  if getline('.')[: col('.') - 1] =~? '\v^\s*Expect\s+' .. abbrev .. '$'
    return abbrev
  else
    return command
  endif
enddef

iabbrev <expr> <buffer> tobefalsy ExpectCommandAbbrev('tobefalsy', 'ToBeFalsy')
iabbrev <expr> <buffer> tobegreaterthan ExpectCommandAbbrev('tobegreaterthan', 'ToBeGreaterThan')
iabbrev <expr> <buffer> tobegreaterthanorequal ExpectCommandAbbrev('tobegreaterthanorequal', 'ToBeGreaterThanOrEqual')
iabbrev <expr> <buffer> tobelessthan ExpectCommandAbbrev('tobelessthan', 'ToBeLessThan')
iabbrev <expr> <buffer> tobelessthanorequal ExpectCommandAbbrev('tobelessthanorequal', 'ToBeLessThanOrEqual')
iabbrev <expr> <buffer> toequal ExpectCommandAbbrev('toequal', 'ToEqual')
iabbrev <expr> <buffer> tobesame ExpectCommandAbbrev('tobesame', 'ToBeSame')
iabbrev <expr> <buffer> tomatch ExpectCommandAbbrev('tomatch', 'ToMatch')
iabbrev <expr> <buffer> tobenumber ExpectCommandAbbrev('tobenumber', 'ToBeNumber')
iabbrev <expr> <buffer> tobestring ExpectCommandAbbrev('tobestring', 'ToBeString')
iabbrev <expr> <buffer> tobefunc ExpectCommandAbbrev('tobefunc', 'ToBeFunc')
iabbrev <expr> <buffer> tobelist ExpectCommandAbbrev('tobelist', 'ToBeList')
iabbrev <expr> <buffer> tobedict ExpectCommandAbbrev('tobedict', 'ToBeDict')
iabbrev <expr> <buffer> tobefloat ExpectCommandAbbrev('tobefloat', 'ToBeFloat')
iabbrev <expr> <buffer> toexist ExpectCommandAbbrev('toexist', 'ToExist')
iabbrev <expr> <buffer> tobeempty ExpectCommandAbbrev('tobeempty', 'ToBeEmpty')
iabbrev <expr> <buffer> tohavelength ExpectCommandAbbrev('tohavelength', 'ToHaveLength')
iabbrev <expr> <buffer> tohavekey ExpectCommandAbbrev('tohavekey', 'ToHaveKey')
