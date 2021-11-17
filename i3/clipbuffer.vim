if !executable('i3-msg')
  cquit!
endif

" FIXME: I don't know why but after executing `i3-msg floating enable`, the
" 'lines' and 'columns' options are reset.
" set lines=24 columns=90
silent call system('i3-msg floating enable')
set lines=24 columns=90
silent call system('i3-msg move position center')
autocmd VimEnter * ++once ClipBuffer edit
