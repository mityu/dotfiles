vim9script

import autoload $VIMRUNTIME .. '/autoload/dist/vimindent.vim'
import $MYVIMRC as V

const themis = V.Pacpack.GetPlugin('vim-themis')
if themis == null_object
  finish
endif

execute $'source {themis.path}/indent/vimspec.vim'

if exists('*g:GetVimspecIndent')
  const vimIndentexpr = get(vimindent.Expr, 'name') .. '()'
  &l:indentexpr = $'g:GetVimspecIndent({vimIndentexpr->string()})'
endif
