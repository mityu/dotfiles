"Last Change: 24-Mar-2019.
"Author: mityu
"This colorscheme based on billw

set background=dark
highlight clear
if exists('syntax_on')|syntax reset|endif

let s:colors_name=expand('<sfile>:t:r')
let g:colors_name=s:colors_name

if !exists('s:TYPE_NUM')|let s:TYPE_NUM=type(0)|execute 'lockvar s:TYPE_NUM'|endif

let s:palette={
            \'black': [0,'black'],
            \'white': [255,'white'],
            \'yellow': [226,'yellow'],
            \'darkred': [52,'#650000'],
            \'red': [196,'red'],
            \'tomato': [9,'tomato'],
            \'orange': [214,'orange'],
            \'vividorange': [208,'#ff7f00'],
            \'dullorange': [214,'#ff9932'],
            \'tenderorange': [214,'orange1'],
            \'darkorange': [100,'#5c4709'],
            \'deeplydarkorange': [94,'#322705'],
            \'tan': [214,'#ffa54f'],
            \'cornsilk': [230,'cornsilk'],
            \'gray': [238,'gray'],
            \'lightgray': [240,'#555555'],
            \'darkgray': [238, '#333333'],
            \'blackgray': [234,'#1f1f1f'],
            \'lightlightgray': [240,'#666666'],
            \'gold': [178,'gold'],
            \'cyan': [14,'cyan'],
            \'darkcyan': [67,'darkcyan'],
            \'deeplydarkblue': [17,'#002a40'],
            \'mediumspringgreen': [48,'mediumspringgreen'],
            \'green': [28, '#006519'],
            \'darkgreen': [28,'#00320c'],
            \'purple': [129,'purple'],
            \'violet': [207,'violet'],
            \'lightsteelblue': [103,'lightsteelblue'],
            \'russet': [142,'yellow4'],
            \'NONE': ['NONE','NONE']
            \}

let s:gui_running=has('gui_running')

function! s:hi(group,fg,bg,attr) "{{{
    let has_fg=type(a:fg)!=s:TYPE_NUM
    let has_bg=type(a:bg)!=s:TYPE_NUM
    let has_attr=type(a:attr)!=s:TYPE_NUM

    if has_fg&&!has_key(s:palette,a:fg)
        call s:echoerr(printf('color: %s does not exists. (specificated in %s, %sfg)',
                    \a:fg,a:group,s:gui_running? 'gui': 'cterm'))
        return
    endif
    if has_bg&&!has_key(s:palette,a:bg)
        call s:echoerr(printf('color: %s does not exists. (specificated in %s, %sbg)',
                    \a:bg,a:group,s:gui_running? 'gui': 'cterm'))
        return
    endif

    if s:gui_running
        let fg=has_fg? 'guifg=' . s:palette[a:fg][1]: ''
        let bg=has_bg? 'guibg=' . s:palette[a:bg][1]: ''
        let attr=has_attr? 'gui=' . a:attr : ''
    else
        let fg=has_fg? 'ctermfg=' . s:palette[a:fg][0]: ''
        let bg=has_bg? 'ctermbg=' . s:palette[a:bg][0]: ''
        let attr=has_attr? 'cterm=' . a:attr : ''
    endif
    execute 'silent highlight' a:group fg bg attr
endfunction "}}}
function! s:echoerr(msg) "{{{
    echohl Error
    echom printf('[%s] %s',s:colors_name,a:msg)
    echohl None
endfunction "}}}


call s:hi('Normal','cornsilk','blackgray',0)
call s:hi('Comment','gold',0,0)
call s:hi('Constant','mediumspringgreen',0,0)
call s:hi('String','orange',0,0)
call s:hi('Character','orange',0,0)
call s:hi('Number','mediumspringgreen',0,0)
call s:hi('Boolean','mediumspringgreen',0,0)
call s:hi('Float','mediumspringgreen',0,0)

call s:hi('Statement','cyan',0,0)
call s:hi('Conditional','cyan',0,0)
call s:hi('Repeat','cyan',0,0)
call s:hi('Label','cyan',0,0)
call s:hi('Operator','cyan',0,0)

call s:hi('PreProc','lightsteelblue',0,0)
call s:hi('Include','lightsteelblue',0,0)
call s:hi('Define','lightsteelblue',0,0)
call s:hi('Macro','lightsteelblue',0,0)
call s:hi('PreCondit','lightsteelblue',0,0)

call s:hi('Type','yellow',0,0)
call s:hi('StorageClass','violet',0,0)
call s:hi('Structure','violet',0,0)

call s:hi('Identifier','yellow',0,0)
call s:hi('Function','mediumspringgreen',0,0)

call s:hi('ErrorMsg','white','red',0)
call s:hi('WarningMsg','white','tomato',0)

call s:hi('Cursor',0,'cornsilk',0)
call s:hi('CursorIM',0,'purple',0)
call s:hi('CursorLine',0,'black','NONE')
call s:hi('CursorColumn',0,'black',0)

call s:hi('LineNr','lightgray',0,0)
call s:hi('CursorLineNr','yellow',0,0)

call s:hi('Search','NONE','lightlightgray',0)
call s:hi('Visual','NONE','lightlightgray',0)
call s:hi('VisualNOS','black',0,0)
call s:hi('Title','orange',0,0)
call s:hi('Folded','gray','blackgray',0)
call s:hi('FoldColumn','lightlightgray','blackgray',0)
call s:hi('SignColumn',0,'blackgray',0)

call s:hi('StatusLine','tenderorange',0,0)
call s:hi('StatusLineNC','russet',0,0)
call s:hi('TabLine','black','russet',0)
call s:hi('TabLineSel','black','tenderorange',0)

call s:hi('Underlined',0,0,'underline')
call s:hi('Ignore',0,0,0)
call s:hi('SpecialKey','gray',0,0)

call s:hi('Directory','cyan',0,0)
call s:hi('Question','mediumspringgreen',0,0)
call s:hi('VertSplit','cornsilk','cornsilk',0)
call s:hi('MatchParen','NONE','purple',0)

call s:hi('WileMenu',0,'yellow',0)
call s:hi('Pmenu','cornsilk','vividorange',0)
call s:hi('PmenuSel','cornsilk','tenderorange',0)
call s:hi('PmenuSbar',0,'white',0)
call s:hi('PmenuThumb',0,'gray',0)

" Experiment
"call s:hi('Pmenu','cornsilk','darkorange',0)
"call s:hi('PmenuSel','cornsilk','deeplydarkorange',0)
"call s:hi('PmenuSbar',0,'darkgray',0)
"call s:hi('PmenuThumb',0,'gray',0)


call s:hi('DiffAdd', 0, 'deeplydarkorange', 0)
call s:hi('DiffDelete', 'deeplydarkblue', 'deeplydarkblue', 0)
call s:hi('DiffChange', 0, 'deeplydarkorange', 0)
call s:hi('DiffText', 0, 'darkorange', 0)

call s:hi('cStatement','violet',0,0)

hi! link Error ErrorMsg
hi! link TabLineFill TabLine
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineNC

" vim: set expandtab smarttab
