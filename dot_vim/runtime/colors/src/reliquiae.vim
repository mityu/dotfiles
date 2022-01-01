vim9script

import * as Gen from './gen.vim'


Gen.Init(expand('<sfile>'), 'dark')

# Gen.Hi(<group>, <fg>, <bg>, [<gui>, [<term>]])
# Gen.Hi('Normal', '#d6d1b0', '#1B1D1E')
Gen.Hi('Normal', '#d6d1b0', '#232526')
Gen.HiLink('NonText', 'Normal')
Gen.Hi('ModeMsg', '#E6DB74', '')

Gen.Hi('Comment', '#908a7c', '')
Gen.Hi('Todo', '#ff6347', '')

Gen.Hi('Number', '#a6e22e', '')
Gen.HiLink('Constant', 'Number')
Gen.HiLink('Boolean', 'Number')
Gen.HiLink('Float', 'Number')

Gen.Hi('Function', '#A6E22E', '')
Gen.Hi('Question', '#66D9EF', '')

Gen.Hi('String', '#eee58c', '')
Gen.HiLink('Title', 'String')
Gen.HiLink('CursorLineNr', 'String')
Gen.HiLink('helpExample', 'String')
Gen.Hi('Character', '#E6DB74', '', '')

Gen.Hi('PreProc', '#C4BE89', '', '')
Gen.HiLink('Include', 'PreProc')
Gen.HiLink('Macro', 'PreProc')
Gen.HiLink('PreCondit', 'PreProc')
Gen.Hi('Define', '#66D9EF', '', '')

Gen.Hi('Type', '#66D9EF', '', '')
Gen.HiLink('Identifier', 'Type')

Gen.Hi('WildMenu', '#66D9EF', '#000000')

Gen.Hi('Structure', '#bdb76d', '', '')
Gen.Hi('StorageClass', '#FD971F', '', '')

Gen.Hi('Statement', '#fd971f', '', '')
Gen.HiLink('Conditional', 'Statement')
Gen.HiLink('Repeat', 'Statement')
Gen.HiLink('Operator', 'Statement')
Gen.HiLink('Keyword', 'Statement')
Gen.HiLink('Exception', 'Statement')
Gen.HiLink('helpOption', 'Statement')
Gen.HiLink('helpHyperTextJump', 'Statement')

Gen.Hi('Label', '#E6DB74', '')
Gen.Hi('Directory', '#A6E22E', '')
# Gen.HiLink('Operator', 'Statement')

Gen.HiLink('ErrorMsg', 'Todo')
# Gen.Hi('Error', '#E6DB74', '#1E0010')
Gen.HiLink('Error', 'ErrorMsg')
Gen.Hi('WarningMsg', '#ffffff', '#333333')

Gen.Hi('Cursor', '#000000', '#F8F8F0', '')
Gen.Hi('CursorIM', '#000000', '#a020f0', '')

Gen.Hi('CursorLine', '', '#293739', '')
Gen.HiLink('CursorColumn', 'CursorLine')

Gen.Hi('LineNr', '#465457', '#232526')
Gen.HiLink('LineNrAbove', 'LineNr')
Gen.HiLink('LineNrBelow', 'LineNr')
Gen.HiLink('EndOfBuffer', 'Linenr')

Gen.Hi('Visual', 'NONE', '#4d3d30', '')
Gen.HiLink('Search', 'Visual')
Gen.HiLink('IncSearch', 'Visual')
Gen.HiLink('QuickFixLine', 'Search')
Gen.Hi('VisualNOS', '#403D3D', '', '')

Gen.Hi('Folded', '#465457', '#000000')
Gen.Hi('FoldColumn', '#465457', '#000000')
Gen.Hi('SignColumn', '#A6E22E', '#232526')

Gen.Hi('StatusLine', '#b9b9b9', '#4c4a4a', '')
Gen.Hi('StatusLineNC', '#909090', '#313030', '')
Gen.HiLink('StatusLineTerm', 'StatusLine')
Gen.HiLink('StatusLineTermNC', 'StatusLineNC')
Gen.HiLink('TabLine', 'StatusLineNC')
Gen.HiLink('TabLineSel', 'StatusLine')
Gen.Hi('TabLineFill', '#1B1D1E', '#1B1D1E')

Gen.Hi('Pmenu', '#909090', '#232526', '')
Gen.Hi('PmenuSel', '#909090', '#131515', '')
Gen.Hi('PmenuSbar', '', '#080808', '')
Gen.Hi('PmenuThumb', '#66D9EF', '#ffffff', '')

Gen.Hi('DiffAdd', '', '#13354A', '')
Gen.Hi('DiffDelete', '#960050', '#1E0010', '')
Gen.Hi('DiffChange', '#89807D', '#4C4745', '')
Gen.Hi('DiffText', '', '#4C4745', '')
Gen.Hi('DiffText', '', '#5c4709', '')

Gen.Hi('SpellBad', '', '#650000', '')
Gen.HiLink('SpellCap', 'SpellBad')
Gen.HiLink('SpellLocal', 'SpellBad')
Gen.HiLink('SpellRare', 'SpellBad')

Gen.Hi('Underlined', '', '', 'underline')
Gen.Hi('Ignore', 'NONE', '', '')
Gen.Hi('SpecialKey', '#465457', '', '')
Gen.Hi('VertSplit', '#4c4a4a', '#444444', '')
Gen.Hi('MatchParen', '#000000', '#FD971F', '')

Gen.Hi('Typedef', '#66d9ef', '')
Gen.Hi('Tag', '#F92672', '')
Gen.Hi('SpecialChar', '#F92672', '')
Gen.Hi('SpecialComment', '#7E8E91', '')
Gen.Hi('Delimiter', '#f5deb3', '')
Gen.Hi('Debug', '#BCA3A3', '')
Gen.Hi('ColorColumn', '', '#232526')

var script =<< END
let g:terminal_ansi_colors = [
\      '#000000',
\      '#d54e53',
\      '#b9ca4a',
\      '#e6c547',
\      '#7aa6da',
\      '#c397d8',
\      '#70c0ba',
\      '#eaeaea',
\      '#666666',
\      '#ff3334',
\      '#9ec400',
\      '#e7c547',
\      '#7aa6da',
\      '#b77ee0',
\      '#54ced6',
\      '#ffffff',
\ ]
END
Gen.Script(script)

var acknowledgements =<< END
" Acknowledgements: This colorscheme is based on molokai.vim.
" Copyright (c) 2011 Tomas Restrepo
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.
END
Gen.Script(acknowledgements)

Gen.Generate()

# hi NonText         term=bold  gui=bold guifg=#465457
# hi MoreMsg         term=bold  gui=bold guifg=#E6DB74
# hi SpellBad        term=reverse  gui=undercurl guisp=#FF0000
# hi SpellCap        term=reverse  gui=undercurl guisp=#7070F0
# hi SpellRare       term=reverse cterm=reverse gui=undercurl guisp=#FFFFFF
# hi SpellLocal      term=underline  gui=undercurl guisp=#70F0F0
# hi ToolbarLine     term=underline  guibg=Grey50
# hi ToolbarButton   cterm=bold   gui=bold guifg=Black guibg=LightGrey
# hi Special         term=bold  gui=italic guifg=#66D9EF guibg=bg
