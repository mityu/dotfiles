function vimrc#gyoza#load_rules(filetype) abort
  call gyoza#config#load_rules_for_filetype(a:filetype)
  call gyoza#builtin_rules#load_all_rules_for_filetype(a:filetype)
endfunction

function vimrc#gyoza#extend_rules(dst, src) abort
  let stack = gyoza#config#get_rules_for_filetype(a:dst)
  call vimrc#gyoza#load_rules(a:src)
  call stack.extend_rules(gyoza#config#get_rules_for_filetype(a:src))
endfunction
