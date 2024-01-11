vim9script

import './gen.vim' as Gen

Gen.Init(expand('<sfile>'), 'dark')

# Gen.Hi(<group>, <fg>, <bg>, [<gui>, [<term>]])
Gen.Hi('Normal', '#fff8dc', '#1f1f1f')
Gen.HiLink('ModeMsg', 'Normal')
Gen.HiLink('Terminal', 'Normal')

Gen.Hi('Comment', '#ffd700', '')
Gen.Hi('Todo', '#ff7f00', '')

Gen.Hi('Number', '#00fa9a', '', '')
Gen.HiLink('Constant', 'Number')
Gen.HiLink('Boolean', 'Number')
Gen.HiLink('Float', 'Number')
Gen.HiLink('Function', 'Number')
Gen.HiLink('Question', 'Number')

Gen.Hi('String', '#ffa500', '', '')
Gen.HiLink('Character', 'String')
Gen.HiLink('Title', 'String')

Gen.Hi('PreProc', '#b0c4de', '', '')
Gen.HiLink('Include', 'PreProc')
Gen.HiLink('Define', 'PreProc')
Gen.HiLink('Macro', 'PreProc')
Gen.HiLink('PreCondit', 'PreProc')
Gen.HiLink('helpNote', 'PreProc')

Gen.Hi('Type', '#ffff00', '', '')
Gen.HiLink('CursorLineNr', 'Type')
Gen.HiLink('WileMenu', 'Type')
Gen.HiLink('Identifier', 'Type')

Gen.Hi('Structure', '#ee82ee', '', '')
Gen.HiLink('StorageClass', 'Structure')
Gen.HiLink('cStatement', 'Structure')

Gen.Hi('Statement', '#00ffff', '', '')
Gen.HiLink('Conditional', 'Statement')
Gen.HiLink('Repeat', 'Statement')
Gen.HiLink('Label', 'Statement')
Gen.HiLink('Operator', 'Statement')
Gen.HiLink('Directory', 'Statement')

Gen.Hi('ErrorMsg', '#ffffff', '#ff0000', '')
Gen.HiLink('Error', 'ErrorMsg')
Gen.Hi('WarningMsg', '#ffffff', '#ff6347', '')

Gen.Hi('Cursor', '#1f1f1f', '#fff8dc', '')
Gen.Hi('CursorIM', '#1f1f1f', '#a020f0', '')

Gen.Hi('CursorLine', '', '#000000', '')
Gen.HiLink('CursorColumn', 'CursorLine')
Gen.HiLink('QuickFixLine', 'CursorLine')

Gen.Hi('LineNr', '#555555', '', '')
Gen.HiLink('NonText', 'LineNr')
Gen.HiLink('LineNrAbove', 'LineNr')
Gen.HiLink('LineNrBelow', 'LineNr')
Gen.HiLink('EndOfBuffer', 'Linenr')

Gen.Hi('Visual', 'NONE', '#666666', '')
Gen.HiLink('Search', 'Visual')
Gen.HiLink('IncSearch', 'Visual')
Gen.Hi('VisualNOS', '#000000', '', '')

Gen.Hi('Folded', '#bebebe', '#1f1f1f', '')
Gen.Hi('FoldColumn', '#666666', '#1f1f1f', '')
Gen.Hi('SignColumn', '', '#1f1f1f', '')

Gen.Hi('StatusLine', '#333333', '#ffa500', '')
Gen.Hi('StatusLineNC', '#333333', '#a79000', '')
Gen.HiLink('StatusLineTerm', 'StatusLine')
Gen.HiLink('StatusLineTermNC', 'StatusLineNC')

Gen.Hi('TabLine', '#333333', '#a0933d', '')
Gen.Hi('TabLineSel', '#1f1f1f', '#ffa000', '')
Gen.HiLink('TabLineFill', 'TabLine')

Gen.Hi('Pmenu', '#caca9d', '#493f2f', '')
Gen.Hi('PmenuSel', '#caca9d', '#706656', '')
Gen.Hi('PmenuSbar', '', '#82775a', '')
Gen.Hi('PmenuThumb', '', '#b6b689', '')

const DiffAddBg = Gen.BlendColor('#1f1f1f', '#75ff22', 0.15)
const DiffAddFg = Gen.BlendColor('#fff8dc', DiffAddBg, 0.08)
const DiffDeleteBg = Gen.BlendColor('#1f1f1f', '#ff4523', 0.2)
const DiffDeleteFg = Gen.BlendColor(DiffDeleteBg, '#ffffff', 0.1)
const DiffChangeBg = Gen.BlendColor('#1f1f1f', '#ffff00', 0.1)
const DiffTextBg = Gen.BlendColor(DiffChangeBg, '#ffff99', 0.1)
Gen.Hi('DiffAdd', DiffAddFg, DiffAddBg, '')
Gen.Hi('DiffDelete', DiffDeleteFg, DiffDeleteBg, '')
Gen.Hi('DiffChange', '', DiffChangeBg, '')
Gen.Hi('DiffText', '', DiffTextBg, '')

Gen.HiLink('Added', 'Identifier')
Gen.HiLink('Changed', 'PreProc')
Gen.HiLink('Removed', 'Special')

Gen.Hi('SpellBad', '', '#650000', '')
Gen.HiLink('SpellCap', 'SpellBad')
Gen.HiLink('SpellLocal', 'SpellBad')
Gen.HiLink('SpellRare', 'SpellBad')

Gen.Hi('Underlined', '', '', 'underline')
Gen.Hi('Ignore', 'NONE', '', '')
Gen.Hi('SpecialKey', '#bebebe', '', '')
Gen.Hi('VertSplit', '#fff8dc', '#fff8dc', '')
Gen.Hi('MatchParen', 'NONE', '#a020f0', '')
Gen.Hi('ColorColumn', '', '#40250a', '')

Gen.Hi('vimStringUrlGithub', '#b28214', '', '')  # Gen.BlendColor('#ffa500', '#003344', 0.3)

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

Gen.Generate()
