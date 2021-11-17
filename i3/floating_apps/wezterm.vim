if !executable('wezterm')
  cquit!
endif
try
  source ~/.config/i3/floating_app.vim
  if !OpenFloatingApp('wezterm')
    cquit!
  endif
finally
  quitall!
endtry
