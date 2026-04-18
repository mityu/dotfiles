" SetUndoFtplugin nunmap <CR>
" SetUndoFtplugin nunmap o
" SetUndoFtplugin nunmap q

nnoremap <buffer> <CR> <CR>
nnoremap <buffer> o <CR>zz<C-w>p
nnoremap <buffer> <silent> q <C-w>q
if getwininfo(win_getid())[0].quickfix
  nnoremap <buffer> <C-n> <Cmd>execute $'cnewer {v:count1}'<CR>
  nnoremap <buffer> <C-p> <Cmd>execute $'colder {v:count1}'<CR>
else
  nnoremap <buffer> <C-n> <Cmd>execute $'lnewer {v:count1}'<CR>
  nnoremap <buffer> <C-p> <Cmd>execute $'lolder {v:count1}'<CR>
endif
