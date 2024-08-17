" Highlight GitHub URL in plugin declarations.
syntax match vimStringUrlGithub +['"]\zshttps://github.com/+ containedin=vimString
highlight default link vimStringUrlGithub vimString

" From thinca/config repository.  Thank you!
" https://github.com/thinca/config/blob/a5ef2e1b3239dc4b73dfa5b3e9f630a5e0f7f254/dotfiles/dot.vim/pack/personal/start/default/after/syntax/vim.vim#L1
syntax region vimSet matchgroup=vimCommand start="\<Set\>" skip="\%(\\\\\)*\\." end="$" end="|" matchgroup=vimNotation end="<[cC][rR]>" keepend oneline contains=vimSetEqual,vimOption,vimErrSetting,vimComment,vim9Comment,vimSetString,vimSetMod
