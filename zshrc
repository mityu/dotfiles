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
	[[ ! ("$(command -v $cmd)" == '' || $cmd == 'rm' || $cmd == 'exit') ]]
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

if [ -n "$VIM_TERMINAL" ]; then
	function drop() {
		echo "\e]51;[\"drop\", \"$(pwd)/$1\"]\x07"
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

	if [ ! -d "$DOTZSH/pure" ]; then
		git clone https://github.com/sindresorhus/pure $DOTZSH/pure
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

if [ -d "$DOTZSH/pure" ]; then
	autoload -U promptinit; promptinit
	zstyle ':prompt:pure:git:stash' show yes
	zstyle ':prompt:pure:path' color yellow
	zstyle ':prompt:pure:prompt:*' color default
	prompt pure

	# Show $? value with color (green=succeeded, red=failed)
	prompt_newline=$' %{%(?.%F{green}.%F{red})%}$?%f\n%{\r%}'
else
	PROMPT='%c $ '
	RPROMPT='[%~]'
fi

if [ -d "$DOTZSH/zsh-syntax-highlighting" ]; then
	source $DOTZSH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if zsh_has_cmd fzf; then
	export FZF_DEFAULT_COMMANDS="files -a \`pwd\`"
	export FZF_DEFAULT_OPTS="--reverse --no-sort"

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

function update-softwares() {
	local password=''
	echo -n "Password:"; read -s password;

	echo $password | update-vim.sh

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
