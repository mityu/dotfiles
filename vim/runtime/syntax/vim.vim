" Highlight GitHub URL in plugin declarations.
syntax match vimStringUrlGithub +['"]\zshttps://github.com/+ containedin=vimString
highlight default link vimStringUrlGithub vimString
