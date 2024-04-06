vim9script

import $MYVIMRC as V

const themis = V.Pacpack.GetPlugin('vim-themis')
if themis == null_object
  finish
endif

execute $'source {themis.path}/indent/vimspec.vim'

if exists('*g:GetVimspecIndent')
  setlocal indentexpr=g:GetVimspecIndent('dist#vimindent#Expr()')
endif
