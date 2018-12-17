" Author: mityu
" Last Change: 17-Dec-2018.
" vim: foldmethod=marker
"{{{
if has('vim_starting')
	set encoding=utf-8
	scriptencoding utf-8

	if has('multi_lang')
		if has('menu')
			set langmenu=ja.utf-8
		endif
	endif

	let s:Windows = has('win32')
	let s:Unix = !s:Windows
	lockvar s:Windows
	lockvar s:Unix
endif
"}}}
func! s:SID() "{{{
	return matchstr(expand('<sfile>'), '\zs<SNR>\d\+_\zeSID$')
endfunc "}}}
func! VimrcSID() "{{{
	return s:SID()
endfunc "}}}

" Startup contig{{{
if has('vim_starting')
	" s:vimrc{{{
	let s:vimrc = {}
	let s:vimrc.filesystem = {}

	if s:Windows
		let $DOT_VIM = '~\vimfiles'
		let s:vimrc.filesystem.slash = '\'
		let s:vimrc.filesystem.path_separator = ';'
		let s:vimrc.filesystem.rcfile_prefix = '_'
	else
		let $DOT_VIM = '~/.vim'
		let s:vimrc.filesystem.slash = '/'
		let s:vimrc.filesystem.path_separator = ':'
		let s:vimrc.filesystem.rcfile_prefix = '.'
	endif
	"}}}

	"disable default plugins
	let g:loaded_2html_plugin=1
	let g:loaded_getscriptPlugin=1
	let g:loaded_gzip=1
	let g:loaded_zipPlugin=1
	let g:loaded_tarPlugin=1
	let g:loaded_vimballPlugin=1
	let g:loaded_netrwPlugin=1
endif
func! s:rc(fname) abort "{{{
	return s:vimrc.filesystem.rcfile_prefix . a:fname
endfunc "}}}
func! s:filename(path) abort "{{{
	return join(a:path,s:vimrc.filesystem.slash)
endfunc "}}}
" Set environment variables on gVim.{{{
let s:_envrc = expand('~/') . s:rc('envrc')
if has('gui_running')&&filereadable(s:_envrc)
	silent call execute(join(map(readfile(s:_envrc),'"let " . v:val'),"\n"))
endif | unlet s:_envrc
"}}}
"}}}
" Initialize autocmd{{{
let s:_augroups = readfile(expand('<sfile>'))
let s:_pattern = '^\s*aug\%[roup]\s\+\zs\S\+\ze\s*'
call filter(s:_augroups,'v:val=~#s:_pattern')
call map(s:_augroups,'matchstr(v:val,s:_pattern)')
call uniq(sort(filter(s:_augroups,'v:val!~#"END"')))
for s:_augroup in s:_augroups
	exec 'augroup' s:_augroup
		au!
	exec 'augroup END'
endfor | unlet s:_augroups s:_pattern
 "}}}
" Setting "{{{1
syntax on
colorscheme domusaurea

set number
set whichwrap=b,s,[,],<,>
set wrap
set smartindent autoindent
set noequalalways
set scrolloff=1
set colorcolumn=100
set cursorline cursorcolumn

set tabstop=4
set shiftwidth=4

set hls
set display=lastline
set pumheight=10

set noundofile nobackup noswapfile
set autoread
set incsearch ignorecase
set showmatch matchtime=1
set laststatus=2

set cmdheight=2 cmdwinheight=10
set wildmenu
set history=100

set keywordprg=:help
set shortmess& shortmess+=Ic
set helplang=ja
set foldmethod=marker
set hidden
"set breakindent

"set virtualedit& virtualedit+=block
set virtualedit=block
set complete=.,i,d,w,b,u

set noimdisable

if has('kaoriya')
	set fileencodings=guess,utf-8
else
	set fileencodings=utf-8
endif
if s:Unix
	set path& path+=/usr/local/include
endif
if executable('ag')
	let &grepprg='ag --vimgrep'
	let &grepformat='%f:%l:%c:%m'
endif

filetype plugin indent on

augroup vimrc_filetype
	au filetype * if !exists('b:did_ftplugin') |
				\ let &l:commentstring=' ' . &l:commentstring |
				\ endif
augroup END
"}}}
" Mapping{{{
nnoremap ; :
nnoremap : ;
vnoremap ; :
vnoremap : ;
map <C-j> <ESC>
map! <C-j> <ESC>
onoremap <C-j> <ESC>
nnoremap j gj
nnoremap k gk
nnoremap <CR> o<ESC>
nnoremap <S-CR> O<ESC>
nnoremap Y y$
nnoremap <ESC><ESC> :<C-u>nohls<CR>
nnoremap <silent> <C-w>s :<C-u>belowright wincmd s<CR>
nnoremap <silent> <C-w>v :<C-u>belowright wincmd v<CR>
noremap <C-a> ^
noremap <C-e> $
noremap - <C-x>
noremap + <C-a>

for [s:lhs,s:rhs] in [[';',':'],[':',';'],['<ESC>','N']]
	execute printf('tnoremap <C-w>%s <C-w>%s',s:lhs,s:rhs)
endfor | unlet s:lhs s:rhs
tmap <C-w><C-j> <C-w><ESC>
tmap <C-j> <C-w><ESC>

func! s:_prefix(kind) abort "{{{
	return '<Plug>(vimrc-' . a:kind . '-prefix)'
endfunc "}}}
func! s:_toCommand(list) abort "{{{
	return join(a:list,' ')
endfunc "}}}
" for Loop Mapping.{{{
func! s:_loop_define(config) abort
	let id = 'loop-' . a:config.id
	let prefix = s:prefix(id)
	let enter_with = a:config.enter_with
	let mode = get(a:config,'mode','n')
	exec printf('%snoremap <silent> %s :call <SID>map_when_leave_loop()<CR>',
				\prefix,mode,id)
	if has_key(a:config,'follow_key')
		let keys = map(split(a:config.follow_key,'\zs'),'[v:val,v:val]')
	else
		let keys = a:config.map
	endif
	let plug_map = {}
	call map(['prefix','main','do'],{->[
				\execute('let plug_map[v:val]=printf("<Plug>(%s-%s)",prefix,v:val)'),
				\v:val][-1]})

	for [lhs,rhs] in keys
		let com = []
		call add(com,[mode . 'noremap',
					\plug_map.do . lhs,
					\enter_with . rhs])
		call add(com,[mode . 'map',
					\enter_with . rhs,
					\plug_map.main . lhs])
		call add(com,[mode . 'map',
					\plug_map.main . lhs,
					\plug_map.do . lhs . plug_map.prefix
					\])
		call add(com,[mode . 'map',
					\plug_map.prefix . lhs,
					\plug_map.main . lhs)
		execute join(map(com,'join(v:val," ")'),"\n")
	endfor
endfunc
func! s:map_when_leave_loop() abort
	if getchar(1)!=0
		call feedkeys(nr2char(getchar()))
	endif
endfunc

"Window management
call s:_loop_define({
			\'id': 'WinChange',
			\'enter_with': '<C-w>',
			\'follow_key': 'hjkl'
			\})
call s:_loop_define({
			\'id': 'WinMove',
			\'enter_with': '<C-w>',
			\'follow_key': 'HJKL'
			\})
call s:_loop_define({
			\'id': 'WinResize',
			\'enter_with': '<C-w>',
			\'follow_key': '<>-+'
			\})
"tab move
call s:_loop_define({
			\'id': 'TabChange',
			\'enter_with': 'g',
			\'map': [['h','T'],['l','t']]
			\})
delfunc s:_loop_define
 "}}}
" for Command.{{{
let s:_prefix = s:_prefix('command')
execute s:_toCommand(['nnoremap',s:_prefix,'<Nop>'])
execute printf('nnoremap %sev :<C-u>edit $MYVIMRC<CR>',s:_prefix)
execute printf('nnoremap %ssv :<C-u>source $MYVIMRC<CR>',s:_prefix)
 "}}}
" for Operator{{{
let s:_prefix = s:prefix('operator')
execute s:_toCommand(['nnoremap',s:_prefix,'<Nop>'])
execute s:_toCommand(['nnoremap',',',s:_prefix])
let s:_map = []
call add(s:_map,['y','<Plug>(operator-stay-cursor-yank)'])
call add(s:_map,['J','<Plug>(jplus)'])
call add(s:_map,[s:_prefix . 'sa','<Plug>(operator-surround-append)'])
call add(s:_map,[s:_prefix . 'sd','<Plug>(operator-surround-delete)'])
call add(s:_map,[s:_prefix . 'sc','<Plug>(operator-surround-replace)'])
call add(s:_map,[s:_prefix . 'r','<Plug>(operator-replace)'])
call add(s:_map,[s:_prefix . 'sy','<Plug>(operator-swap-marking)'])
call add(s:_map,[s:_prefix . 'sp','<Plug>(operator-swap)'])
call add(s:_map,[s:_prefix . 'J','<Plug>(jplus-getchar-with-space)'])
call add(s:_map,[s:_prefix . 'ct','<Plug>(operator-toggle-comment-wrap)'])
for s:_ in s:_map
	execute s:_toCommand(add(['map'],s:_))
endfor | unlet s:_ s:_map
"}}}
" for Text Object.{{{
let s:_map = []
call add(s:_map,['ov','ab','<Plug>(textobj-multiblock-a)'])
call add(s:_map,['ov','ib','<Plug>(textobj-multiblock-i)'])
call add(s:_map,['ov','af','<Plug>(textobj-between-a)'])
call add(s:_map,['ov','if','<Plug>(textobj-between-i)'])
"call add(s:_map,['n','_t','<Plug>(sonictemplate)'])
for [s:_modes,s:_lhs,s:_rhs] in s:_map
	let s:_com = 'map ' . s:_lhs . ' ' . s:_rhs
	for s:_mode in split(s:_modes,'\zs')
		execute s:_mode . s:_com
	endfor
endfor | unlet s:_mode s:_com s:_modes s:_lhs s:_rhs s:_map
"}}}
unlet s:prefix
delfunc s:_prefix
delfunc s:_toCommand

func! s:plugin_mapping() abort "{{{
	let maps = []
	let prefix = s:prefix('operator')

	" Operator
	call add(maps,['','sa','<Plug>(operator-surround-append)'])
	call add(maps,['','sd','<Plug>(operator-surround-delete)'])
	call add(maps,['','sc','<Plug>(operator-surround-replace)'])
	call add(maps,['','r' ,'<Plug>(operator-replace)'])
	call add(maps,['','sy','<Plug>(operator-swap-marking)'])
	call add(maps,['','sp','<Plug>(operator-swap)'])
	call add(maps,['','J' ,'<Plug>(jplus-getchar-with-space)'])
	call add(maps,['','ct','<Plug>(operator-toggle-comment-wrap)'])
	call map(maps,{list -> [list[0], prefix . list[1], list[2]]})

	call add(maps,['','y','<Plug>(operator-stay-cursor-yank)'])
	call add(maps,['','J','<Plug>(jplus)'])

	" Text Object
	call add(maps,['ov','ab','<Plug>(textobj-multiblock-a)'])
	call add(maps,['ov','ib','<Plug>(textobj-multiblock-i)'])
	call add(maps,['ov','af','<Plug>(textobj-between-a)'])
	call add(maps,['ov','if','<Plug>(textobj-between-i)'])
	" call add(maps,['n','t','<Plug>(sonictemplate)'])

	for [modes,lhs,rhs] in maps
		let modes = (modes !=# '') ? split(modes,'\zs') : ['']
		for mode in modes
			if maparg(rhs,mode) ==# '' | continue | endif
			execute mode . 'map' lhs rhs
		endfor
	endfor
endfunc "}}}
augroup vimrc_plugin_settings
	au User vimrc_initialize call s:plugin_mappings()
augroup END

func! s:shift_ten_key(enablize) abort "{{{
	let ten_key_pair = [
				\['1','!'],
				\['2','"'],
				\['3','#'],
				\['4','$'],
				\['5','%'],
				\['6','&'],
				\['7',"'"],
				\['8','('],
				\['9',')'],
				\]
	if a:enablize
		for [key1,key2] in ten_key_pair
			execute 'inoremap' key1 key2
			execute 'inoremap' key2 key1
		endfor
	else
		for [key1,key2] in s:ten_key_pair
			execute 'silent! iunmap' key1
			execute 'silent! iunmap' key2
		endfor
	endif
endfunc "}}}
com! -bar EnableShiftTenKey call s:shift_ten_key(1)
com! -bar DisableShiftTenKey call s:shift_ten_key(0)
if has('vim_starting') | EnableShiftTenKey | endif

augroup vimrc_cmdwin
	au CmdWinEnter * nnoremap <buffer> <CR> <CR>
augroup END
"}}}
" Command {{{
com! -bar CdCurrent cd %:p:h
com! -bar LcdCurrent lcd %:p:h
com! -nargs=1 -complete=file Rename file <args>|call delete(expand('#'))
com! -bar Scratch new|setl buftype=nofile nobuflisted noswapfile
com! CopyToClipboard let @*=@"
com! ClearMessage execute repeat("echom ''\n",201)
com! Helptags helptags ALL

com! -bang -nargs=+ -complete=command Filter call s:filter(<bang>0,<f-args>)
func! Filter(pat,com) abort "{{{
	let output = split(execute(a:com),"\n")
	call filter(output,'v:val=~?a:pat')
	return output
endfunc "}}}
func! s:filter(bang,pat,com) abort "{{{
	let output = join(Filter(a:pat,a:com),"\n")
	if a:bang
		echom output
	else
		echo output
	endif
endfunc "}}}

if has('mac')&&executable('open')
	com! -bar -nargs=+ -complete=dir Open silent !open <args>
endif
"}}}
" Plugin{{{
" minpac{{{
com! PackInit   source $MYVIMRC|call s:pack_init()
com! PackUpdate source $MYVIMRC|call s:pack_update()
com! PackClean  source $MYVIMRC|call s:pack_clean()
func! s:pack_register() abort "{{{
	call minpac#add('k-takata/minpac',{'type': 'opt'})

	call minpac#add('vim-scripts/autodate.vim')
	call minpac#add('thinca/vim-quickrun')
	call minpac#add('thinca/vim-prettyprint')
	call minpac#add('thinca/vim-partedit')
	call minpac#add('tyru/capture.vim')
	call minpac#add('osyo-manga/vim-jplus')
	call minpac#add('kana/vim-textobj-user')
	call minpac#add('osyo-manga/vim-textobj-multiblock')
	call minpac#add('thinca/vim-textobj-between')
	call minpac#add('kana/vim-operator-user')
	call minpac#add('kana/vim-operator-replace')
	call minpac#add('osyo-manga/vim-operator-swap')
	call minpac#add('osyo-manga/vim-operator-stay-cursor')
	call minpac#add('rhysd/vim-operator-surround')
	"call minpac#add('thinca/vim-operator-sequence')
	call minpac#add('kana/vim-gf-user')
	call minpac#add('sgur/vim-gf-autoload')
	call minpac#add('kana/vim-altr')
	call minpac#add('itchyny/vim-cursorword')
	call minpac#add('mattn/sonictemplate-vim')
	call minpac#add('w0rp/ale')
	"call minpac#add('rhysd/tmpwin.vim')
	call minpac#add('vim-jp/vital.vim')
	call minpac#add('vim-jp/vimdoc-ja')
	call minpac#add('tyru/open-browser.vim')
	call minpac#add('sgur/vim-operator-openbrowser')

	call minpac#add('kannokanno/previm',{'type': 'opt'})
endfunc "}}}
func! s:pack_init() abort "{{{
	try
		packadd minpac
	catch /^Vim\%((\a\+)\)\=:E919/
		"Download minpac...
		let minpac_path=s:vim_home() . '/pack/minpac/opt/minpac'
		echo 'Downloading minpac...'
		call system('git clone https://github.com/k-takata/minpac.git ' .
					\minpac_path)
		packadd minpac
	catch
		echoerr v:exception
		return 0
	endtry

	call minpac#init()
	call s:pack_register()

	return 1
endfunc "}}}
func! s:pack_update() abort "{{{
	if s:pack_init() | call minpac#update() | endif
endfunc "}}}
func! s:pack_clean() abort "{{{
	if s:pack_init() | call minpac#clean() | endif
endfunc "}}}
"}}}
" Setting{{{
" ale{{{
"let g:ale
"}}}
" thinca/quickrun{{{
let g:quickrun_config={}
let g:quickrun_config._={
	\	'outputter/message': 1,
	\	'outputter/message/log': 1,
	\	'outputter/buffer/close_on_empty': 1,
	\	'runner': 'job',
	\}
let g:quickrun_config.cpp={
	\	'cmdopt' : '-std=c++17'
	\}
" TODO: Improve. (Support windows, etc)
let g:quickrun_config['cpp/sfml']={
	\	'type' : 'cpp',
	\	'cmdopt' : '-std=c++17 -lsfml-audio -lsfml-graphics -lsfml-network -lsfml-system -lsfml-window',
	\}
let g:quickrun_config.objc={
	\	'command' : 'cc',
	\	'exec' : ['%c %s -o %s:p:r -framework Foundation', '%s:p:r %a', 'rm -f %s:p:r'],
	\	'tempfile' : '%{tempname()}.m',
	\}
let g:quickrun_config.applescript={
	\	'command' : 'osascript',
	\	'exec' : '%c %s:p',
	\	'tempfile' : '%{tempname()}.applescript',
	\}
let g:quickrun_config.swift={
	\	'command' : 'swift',
	\	'exec' : '%c %s%p',
	\	'tempfile' : '%{tempname()}.swift',
	\}
nnoremap <expr> <C-c> quickrun#is_running() ?
			\ ':<C-u>call quickrun#sweep_sessions()<CR>' :
			\ '<C-c>'
augroup vimrc_filetype
	au FileType quickrun nnoremap <silent> <buffer> q :<C-u>q<CR>
augroup END
 "}}}
" rhysd/vim-operator-surround{{{
let g:operator#surround#ignore_space = 0
let g:operator#surrounde#blocks = {}
"}}}
" mattn/sonictemplate{{{
let g:sonictemplate_key='<Plug>(nop-sonictemplate)'
let g:sonictemplate_intelligent_key='<Plug>(nop-sonictemplate-intelligent)'
let g:sonictemplate_postfix_key='<Plug>(nop-sonictemplate-postfix)'
if has('mac')
	let g:sonictemplate_vim_template_dir=[expand('~/.vim/_vim_cache/sonictemplates')]
endif "}}}
" w0rp/ale{{{
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_enter = 0
 "}}}
"}}}
"}}}
" Utility{{{
" tabpage_cd{{{
augroup vimrc_tabpage_cd
	au TabEnter * let t:vimrc_cwd = getcwd(-1)
	au TabLeave * if exists('t:vimrc_cwd') | execute 'cd' t:vimrc_cwd | endif
augroup END
 "}}}
" showmode{{{
augroup vimrc_showmode
	au ColorScheme * call s:showmode_init()
	au User vimrc_initialize call s:showmode_init()
	au WinEnter,BufWinEnter * call s:showmode_update()
augroup END
func! Vimrc_showmode_filename() abort "{{{
	if &l:buftype==#'help'
		return expand('%:t')
	elseif &l:buftype==#'[quickfix]'
		return '[quickfix]'
	elseif &previewwindow
		return '[preview]'
	elseif &l:buftype==#'terminal'
		return 'terminal:' . expand('%')
	elseif &l:buftype==#'prompt'
		return '[prompt]'
	elseif expand('%')!=#''
		return pathshorten(expand('%:.'))
	elseif &l:buftype==#'nofile'
		return '[draft]'
	else
		return '[No name]'
	endif
endfunc "}}}
func! Vimrc_showmode() abort "{{{
	call s:showmode_highlight()
	let l:map={
		\'n': 'NORMAL',
		\'i': 'INSERT',
		\'R': 'REPLACE',
		\'v': 'VISUAL',
		\'V': 'V-LINE',
		\"\<C-v>": 'V-BLOCK',
		\'c': 'COMMAND',
		\'ce': 'EX-COM',
		\'s': 'SELECT',
		\'S': 'S-LINE',
		\"\<C-s>": 'S-BLOCK',
		\'t': 'T-INSERT',
		\'no': 'OPERATOR',
		\'niI': 'N-INSERT',
		\'niR': 'N-REPLACE',
		\'niV': 'N-V-REPLACE',
		\}
	return get(l:map,mode(),'UNKNOWN')
endfunc "}}}
func! s:showmode_init() abort "{{{
	let colors={
		\'normal': [['22','148'],['#005f00','#afdf00']],
		\'insert': [['23','117'],['#005f5f','#87dfff']],
		\'visual': [['88','208'],['#870000','#ff8700']],
		\'replace': [['231','160'],['#ffffff','#df0000']],
		\}
	for mode in keys(colors)
		execute printf('hi VimrcShowMode_%s ctermfg=%s ctermbg=%s guifg=%s guibg=%s',
					\mode,
					\colors[mode][0][0],
					\colors[mode][0][1],
					\colors[mode][1][0],
					\colors[mode][1][1])
	endfor
endfunc "}}}
func! s:showmode_highlight_type() abort "{{{
	return get({
			\'n': 'normal',
			\'c': 'normal',
			\'niI': 'normal',
			\'niR': 'normal',
			\'niV': 'normal',
			\'ce': 'normal',
			\'s': 'normal',
			\'S': 'normal',
			\"\<C-s>": 'normal',
			\'no': 'normal',
			\'i': 'insert',
			\'t': 'insert',
			\'R': 'replace',
			\'v': 'visual',
			\'V': 'visual',
			\"\<C-v>": 'visual',
			\},
		\mode(),'normal')
endfunc "}}}
func! s:showmode_highlight() abort "{{{
	let type=s:showmode_highlight_type()
	execute 'hi link VimrcShowMode VimrcShowMode_' . type
endfunc "}}}
func! s:showmode_update() abort "{{{
	call s:showmode_highlight()
	let line=[s:showmode_statusline(0),s:showmode_statusline(1)]
	let w=winnr()
	for n in range(1,winnr('$'))
		call setwinvar(n,'&statusline', line[n==w])
	endfor
endfunc "}}}
func! s:showmode_statusline(active) abort "{{{
	let line='[%{&ft==#""?"No ft":&ft}][#%{bufnr("%")}] %{Vimrc_showmode_filename()}%<%=[%{pathshorten(getcwd())}]'
	let info='%m'
	if a:active
		if &buftype!=#'terminal'&&!&l:ma
			let info='%#StatusLine#' . info
		else
			let info='%#StatusLine#' . info . '%#VimrcShowMode# %{Vimrc_showmode_mode()} %#StatusLine#'
		endif
	else
		let info='%#StatusLineNC#' . info
	endif
	return info . line
endfunc "}}}
 "}}}
" tabline{{{
let &tabline=printf('%!%stabline',s:SID())
func! s:tabline() abort "{{{
	let tabline='%#TabLine#'
	let t=tabpagenr()

	for n in range(1,tabpagenr('$'))
		let tabline .= '%' . n . 'T'
		let info=' ' . s:generate_tabinfo(n) . ' '
		if t==n
			let tabline .= '%#TabLineSel# %999Xx%X' . info . '%#TabLine#'
		else
			let tabline .= info
		endif
		let tabline .= '%T|'
	endfor
	let tabline .= '%>%=%{Vimrc_showmode_filename()} [%{pathshorten(getcwd())}]'

	return tabline
endfunc "}}}
func! s:buffer_name(bufnr) abort "{{{
	let l:buftype=getbufvar(a:bufnr,'&buftype')
	if l:buftype==#'help'
		return fnamemodify(bufname(a:bufnr),':t')
	elseif l:buftype==#'[quickfix]'
		return '[quickfix]'
	elseif &previewwindow
		return '[preview]'
	elseif l:buftype==#'terminal'
		return '[terminal]'
	elseif l:buftype==#'prompt'
		return '[prompt]'
	elseif bufname(a:bufnr)!=#''
		return pathshorten(fnamemodify(bufname(a:bufnr),':.'))
	elseif l:buftype==#'nofile'
		return '[draft]'
	else
		return '[No name]'
	endif
endfunc "}}}
func! s:generate_tabinfo(tabnr) abort "{{{
	let l:tablist=tabpagebuflist(a:tabnr)
	let l:info=''
	let l:info .= len(filter(copy(l:tablist),'getbufvar(v:val,"&mod")'))? '[+]': ''
	let l:info .= '[' . tabpagewinnr(a:tabnr,'$') . ']'
	let l:info .= s:buffer_name(tabpagebuflist(a:tabnr)[tabpagewinnr(a:tabnr)-1])
	return l:info
endfunc "}}}
"}}}
" :terminal{{{
augroup vimrc_terminal
	au TerminalOpen * call s:terminal_open()
augroup END
func! s:terminal_open() abort
	setlocal nonumber
endfunc
"}}}
"}}}
"
" lvimrc{{{
let s:_lvimrc = s:rc('lvimrc')
if filereadable(expand('~/' . s:_lvimrc))
	exec 'com! LocalVimrc e ~/' . s:_lvimrc
	exec 'source ~/' . s:_lvimrc
endif | unlet s:_lvimrc
" }}}
" gvimrc{{{
if has('gui_running')
	set guioptions& guioptions-=e guioptions-=T
	set guioptions-=R guioptions-=r guioptions-=L guioptions-=l
	set mouse=a
	set nomousefocus
	set mousehide
	set lines=999
	set columns=9999

	if has('win32')
		set guifont=MS_Gothic:h10:cSHIFTJIS
		set linespace=1
		"一部のUCS文字の幅を自動計測して決める
		if has('kaoriya')
			set ambiwidth=auto
		endif

		set columns=120
	elseif has('mac')
		set guifont=Osaka-Mono:h14
		"set columns=120
	elseif has('xfontset')
		"for unix (use xfontset)
		set guifont=a14,r14,k14
	endif

	if has('multi_byte_ime') || has('xim')
		set iminsert=0 imsearch=0
		augroup vimrc_iminsert
			au InsertLeave * set iminsert=0
		augroup END
	endif
endif
 "}}}

"Initialize when load this file.{{{
if has('vim_starting') "{{{
	augroup vimrc_initialize
		au VimEnter * doau User vimrc_initialize
	augroup END
else
	doau User vimrc_initialize
endif "}}}
 "}}}
