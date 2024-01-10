" Highlight exprs in string interpolation.
" https://github.com/thinca/config/blob/231dc076c5b22e5f8d6756ed6e6d584c02bb7125/dotfiles/dot.vim/pack/personal/start/default/after/syntax/vim.vim#L3C1-L9C61
syntax region vimString start=+$'+ end=+'+ oneline
      \ contains=vimStringInterpolationBrace,vimStringInterpolationExpr
syntax region vimString start=+$"+ end=+"+ oneline
      \ contains=@vimStringGroup,vimStringInterpolationBrace,vimStringInterpolationExpr
syntax region vimStringInterpolationExpr start=+{+ end="}" keepend oneline
      \ contains=vimFuncVar,vimIsCommand,vimOper,vimNotation,vimOperParen,vimString,vimVar
syntax match vimStringInterpolationBrace "{{"
syntax match vimStringInterpolationBrace "}}"
highlight default link vimStringInterpolationBrace vimEscape

" Highlight GitHub URL in plugin declarations.
syntax match vimStringUrlGithub +['"]\zshttps://github.com/+ containedin=vimString
highlight default link vimStringUrlGithub vimString
