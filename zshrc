# Set environmental variables (Only when outside of vim.)
if ! [ -n "$VIM_TERMINAL" ] && [ -f ~/.envrc ]; then
	cat ~/.envrc | while read path_expr
	do
		# Ignore blank line.
		if [ -z ${path_expr} ]; then
			continue
		fi

		# Ignore comment.
		if [ ${path_expr:0:1} = "#" ]; then
			continue
		fi
		eval 'export' $path_expr
	done
fi
export PATH=$(cd $(dirname $(readlink ${(%):-%N})); pwd)/bin:$PATH
export LANG=en_US.UTF-8

function zsh_has_cmd() {
	which $1 &> /dev/null
}

if zsh_has_cmd vim; then
	() {
		local thisfile
		thisfile=$1
		thisfile=${$(readlink $thisfile):-$thisfile}
		eval 'alias vi="vim -u' $(dirname $thisfile)'/dot_vim/vimrc_stable"'
	} ${(%):-%N}
	export MANPAGER="vim -M +MANPAGER -"
	export EDITOR=vim
	export GIT_EDITOR=vim
fi

alias zenn='deno run -A npm:zenn-cli@latest'

if ! zsh_has_cmd sudoedit; then
	alias sudoedit='sudo -e'
fi

if ! zsh_has_cmd pbpaste && zsh_has_cmd xsel; then
	# xsel -p?
	alias pbpaste='xsel -b'
fi

if ! zsh_has_cmd pbcopy && zsh_has_cmd xsel; then
	alias pbcopy='xsel -bi'
fi

zsh_has_cmd bat && alias cat='bat --style plain --theme ansi'

if zsh_has_cmd exa; then
	function ls() {
		if [ -t 1 ]; then
			# When output is terminal.
			exa --group-directories-first --icons $*
		else
			command ls $*
		fi
	}
fi

alias dotfiles=". $(cd $(dirname $(readlink ${(%):-%N})); pwd)/bin/dotfiles"

zsh_has_cmd opam && eval $(opam env)

# Enable smart completion
autoload -Uz compinit
compinit

# The file to save history
export HISTFILE=${HOME}/.zhistory
# How many zsh records history to memory.
export HISTSIZE=1000
# How many zsh records history to the history file.
export SAVEHIST=100000
# Remove history duplicates
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt share_history
# Do not record `history` to command history
setopt hist_no_store
# Enable completion
setopt menu_complete

zshaddhistory() {
	local line cmd
	line=${1%%$'\n'}
	# Skip environmental variable assignments
	while true; do
		cmd=${line%% *}
		line=${line#* }
		if [[ ${cmd%%=*} == $cmd && ${cmd#*=} == $cmd ]]; then
			break
		fi
	done
	[[ (! ("$(command -v $cmd)" == '' || $cmd == 'rm' || $cmd == 'exit')) || -x $cmd ]]
}


bindkey -d # Reset keybinds
bindkey -v # Use vi like keybinds

bindkey '^p' up-line-or-search
bindkey '^n' down-line-or-search
bindkey '^f' forward-char
bindkey '^b' backward-char
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# textobjects
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
	for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
		bindkey -M $m $c select-bracketed
	done
done
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
	for c in {a,i}{\',\",\`}; do
		bindkey -M $m $c select-quoted
	done
done

# operator-surround
autoload -Uz surround
zle -N delete-surround surround
zle -N change-surround surround
zle -N add-surround surround
bindkey -M vicmd 'mr' change-surround
bindkey -M vicmd 'md' delete-surround
bindkey -M vicmd 'ma' add-surround
bindkey -M visual 'mr' change-surround
bindkey -M visual 'md' delete-surround
bindkey -M visual 'ma' add-surround

# Prompt
setopt prompt_subst
typeset zshrc_prompt_keymap
zshrc_prompt_precmd() {
	PROMPT="$(zshrc_build_prompt)"

	if zsh_has_cmd async; then
		async_stop_worker zshrc_prompt_async_worker
		async_start_worker zshrc_prompt_async_worker -n
		async_register_callback \
			zshrc_prompt_async_worker zshrc_prompt_async_callback
		async_job zshrc_prompt_async_worker zshrc_prompt_async_prompt
	fi
}

zshrc_build_prompt() {
	local yellow='%F{yellow}'
	local green='%F{green}'
	local red='%F{red}'
	local gray='%F{242}'
	local cyan='%F{cyan}'
	local magenta='%F{218}'
	local purple='%F{177}'
	local reset='%f'

	local build_full=${1-false}
	local ps1='\n'

	ps1+='${zshrc_prompt_keymap}'

	# Show Linux distribution on WSL2
	if [[ $(uname) == "Linux" && $(uname -r) == *"microsoft"* ]]; then
		local distrib='Unknown'
		if [ -f '/etc/arch-release' ]; then
			distrib='Arch'
		fi
		ps1+="${purple}${distrib}${reset} "
	fi

	# Exit code
	ps1+='%{%(?.%F{green}.%F{red})%}#$?%f '
	ps1+="$yellow%~$reset "

	# Git status
	if git rev-parse 2> /dev/null; then
		# When inside git repository.
		ps1+="$gray$(git branch --show-current)$reset"
		if $build_full; then
			if zshrc_prompt_git_dirty; then
				# There're modified files or untracked files
				ps1+="$magenta*$reset"
			fi
			# TODO: Fetch/push
			if git rev-list --walk-reflogs --count refs/stash &> /dev/null; then
				ps1+=" $cyan≡$reset"
			fi
		fi
		ps1+=' '
	fi

	if ! zsh_has_cmd async; then
		ps1+='(no-async)'
	fi

	ps1+=$'\n'
	if [[ $(id -u) == 0 ]]; then
		ps1+='# '
	else
		ps1+='$ '
	fi

	echo $ps1
}

zshrc_prompt_async_prompt() {
	zshrc_build_prompt true  # Generate prompt with full information
}

zshrc_prompt_async_callback() {
	PROMPT="$3"
	zle reset-prompt
}

zshrc_prompt_git_dirty() {
	setopt localoptions noshwordsplit

	# Prevent e.g. `git status` from refreshing the index as a side effect.
	# Ref: https://github.com/sindresorhus/pure
	export GIT_OPTIONAL_LOCKS=0
	test -n "$(git status --porcelain --untracked-files=normal --no-renames)"
}

function zle-line-pre-redraw zle-keymap-select zle-line-init {
	if [[ $REGION_ACTIVE != 0 ]]; then
		zshrc_prompt_keymap='%F{red} VISUAL %f'
	else
		case $KEYMAP in
			vicmd)
				zshrc_prompt_keymap='%F{green} NORMAL %f'
				;;
			main|viins)
				zshrc_prompt_keymap='%F{cyan} INSERT %f'
				;;
		esac
	fi
	zle reset-prompt
}

# Show the number of background jobs
RPROMPT='%(1j.[%j].)'

zle -N zle-line-init
zle -N zle-keymap-select
zle -N zle-line-pre-redraw
autoload -Uz add-zsh-hook
add-zsh-hook precmd zshrc_prompt_precmd


if [ -n "$VIM_TERMINAL" ]; then
	function drop() {
		echo "\e]51;[\"drop\", \"$(pwd)/$1\"]\x07"
	}

	function synccwd() {
		local cwd
		echo "\e]51;[\"call\", \"Tapi_getcwd\", []]\x07"
		read cwd
		cd "$cwd"
	}
fi

# WSL2
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
	LOCAL_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
	export DISPLAY=$LOCAL_IP:0
	if [ -n "$APPDATA" ]; then
		export SUMATRAPDF=$(dirname $APPDATA)/Local/SumatraPDF/SumatraPDF.exe
	else
		echo "\033[41m\$APPDATA is empty\033[m"
	fi
	cd ~
	function open() {
		cmd.exe /c start $(wslpath -w $1)
	}
fi

# Plugins
DOTZSH=$HOME/.zsh

function install_zsh_plugins() {
	if ! zsh_has_cmd git ; then
		echo -e '\033[41mgit command not found\033[m'
		return 1
	fi
	if [ ! -d "$DOTZSH/zsh-syntax-highlighting" ]; then
		git clone https://github.com/zsh-users/zsh-syntax-highlighting \
			$DOTZSH/zsh-syntax-highlighting
	fi

	if [ ! -d "$DOTZSH/zsh-async"]; then
		git clone https://github.com/mafredri/zsh-async $DOTZSH/zsh-async
	fi
}

function update-zsh-plugins() {
	local dir
	for dir in $(find $DOTZSH/* -maxdepth 0 -type d); do
		echo -e '\033[1mChecking updates: '$(basename $dir)'\033[m'
		git -C $dir pull
	done
}

if [ ! -d "$DOTZSH" ]; then
	printf "Install plugins? [y/N]: "
	if read -q; then
		mkdir -p $DOTZSH
		install_zsh_plugins
	fi
fi

# Add plugin directories to fpath (&runtimepath like variable)
function() {
	local dir
	for dir in $(find $DOTZSH/* -maxdepth 0 -type d); do
		fpath+=$dir
	done
}

# if [ -d "$DOTZSH/pure" ]; then
# 	autoload -U promptinit; promptinit
# 	zstyle ':prompt:pure:git:stash' show yes
# 	zstyle ':prompt:pure:path' color yellow
# 	zstyle ':prompt:pure:prompt:*' color default
# 	prompt pure
# 
# 	# Show $? value with color (green=succeeded, red=failed)
# 	prompt_newline=$' %{%(?.%F{green}.%F{red})%}$?%f\n%{\r%}'
# fi

[ -d "$DOTZSH/zsh-async" ] && autoload -Uz async && async

if [ -d "$DOTZSH/zsh-syntax-highlighting" ]; then
	source $DOTZSH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if zsh_has_cmd fzf; then
	export FZF_DEFAULT_COMMANDS="files -a \`pwd\`"
	export FZF_DEFAULT_OPTS="--reverse --no-sort --no-separator"

	function select-history(){
		local bufsave
		bufsave=$BUFFER
		BUFFER=$(history -n 1 | fzf --tac +m)
		if ! [ -n "$BUFFER" ]; then
			BUFFER=$bufsave
		fi
		CURSOR=$#BUFFER
		zle redisplay
	}
	zle -N select-history
	bindkey '^r' select-history
fi

function update-vim-plugins() {
	echo 'Updating vim plugins'
	vim -u ~/.vim/vimrc --noplugins -n -N -e -s -S <(cat <<- EOF
	function UpdatePlugins()
		PackInit
		if !exists("*minpac#init()")
			call setline(1, split(execute("message"), "\n"))
			call append("$", "Failed to load minpac")
			%print
			cquit!
		endif
		let g:minpac#opt.status_auto = v:false
		call minpac#update("", {"do": "call PostUpdatePlugins()"})
	endfunction
	function PostUpdatePlugins()
		let bufnr = bufnr("%")
		call minpac#status()
		let lines = getline(1, "$")
		wincmd p
		setlocal modifiable
		call append("$", lines)
		setlocal nomodified
		%print
		quitall!
	endfunction
	autocmd VimEnter * ++once call UpdatePlugins()
	EOF
	)
}

function update-softwares() {
	local password=''
	echo -n "Password:"; read -s password;

	echo $password | update-vim

	if zsh_has_cmd brew; then
		brew upgrade
		brew cleanup
		if [[ "$(uname)" == "Darwin" ]]; then
			brew upgrade --cask
		fi
	fi
	if zsh_has_cmd pacman; then
		if zsh_has_cmd yay; then
			# Prefer using yay to pacman
			echo $password | yay -Syyu --noconfirm --sudoflags -S
		else
			echo $password | sudo -S pacman -Syyu --noconfirm
		fi
	fi
	if zsh_has_cmd go; then
		pushd ~
		local gobin=$(go env GOBIN)
		local gobin=${gobin:-$(go env GOPATH)/bin}
		print -rl ${gobin}/*(*) | while read file; do
			local pkg="$(go version -m "${file}" | head -n2 | tail -n1 | awk '{print $2}')"
			go install "${pkg}@latest"
		done
		popd
	fi
	if zsh_has_cmd opam; then
		opam update && opam upgrade --yes
	fi
	if zsh_has_cmd pip3; then
		pip3 list --outdated --format json | \
			python3 -c "import sys; import json; list(map(lambda x: print(x['name']), json.loads(sys.stdin.read())))" | \
			xargs pip3 install -U
	fi
	update-zsh-plugins
	update-vim-plugins
}

function gitinit() {
	if ! [ -d "./.git" ]; then
		git init
		git branch -m main
		git commit --allow-empty -m "Initial commit"
	fi
}

function CAPSLOCK() {
	if zsh_has_cmd xdotool; then
		xdotool key Caps_Lock
	else
		echo "\033[41m\xdotool not found\033[m"
	fi
}

function stdin() {
	local cmd stdin
	cmd="$1"
	shift
	while read -r stdin; do
		"$cmd" "$@" "$stdin"
	done
}
