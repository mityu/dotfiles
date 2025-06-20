function dotfiles-path() {
	local thisfile=$(whence -v $0 | awk '{print $NF}')
	echo $(cd $(dirname $(realpath $thisfile)); pwd)
}

function gobin-path() {
	echo ${$(go env GOBIN):-$(go env GOPATH)/bin}
}

# Set environmental variables (Only when outside of vim.)
if ! [ -n "$VIM_TERMINAL" ] && [ -f ~/.envrc ]; then
	source ~/.envrc
fi
export LANG=en_US.UTF-8

function zshrc_in_git_repo() {
	git rev-parse 2> /dev/null
}

function zshrc_has_cmd() {
	which $1 &> /dev/null
}

function zshrc_ask_yesno() {
	echo -n "$1 [y/N]: "
	read -q
}

function zshrc_prepend_PATH() {
	if [[ $1 != "" && ! $PATH =~ "$1" ]]; then
		export PATH=$1:$PATH
	fi
}

zshrc_prepend_PATH $HOME/.local/bin
zshrc_prepend_PATH $(dotfiles-path)/bin
zshrc_has_cmd go && zshrc_prepend_PATH $(gobin-path)
zshrc_has_cmd cargo && zshrc_prepend_PATH $HOME/.cargo/bin

if zshrc_has_cmd vim; then
	alias vi="vim -u $(dotfiles-path)/vim/vimrc_stable"
	alias vim-stable='vi'
	alias profile-vimrc="vim --cmd 'source $(dotfiles-path)/vim/misc/profile_vimrc.vim'"
	export MANPAGER='vim -M +MANPAGER -'
	export EDITOR=vim
	export GIT_EDITOR=vim
fi

alias zenn='deno run -A npm:zenn-cli@latest'
alias zenn-update='deno cache --reload npm:zenn-cli@latest'

if ! zshrc_has_cmd sudoedit; then
	alias sudoedit='sudo -e'
fi

if ! zshrc_has_cmd pbpaste && zshrc_has_cmd xsel; then
	# xsel -p?
	alias pbpaste='xsel -b'
fi

if ! zshrc_has_cmd pbcopy && zshrc_has_cmd xsel; then
	alias pbcopy='xsel -bi'
fi

zshrc_has_cmd bat && alias cat='bat --style plain --theme ansi'

if zshrc_has_cmd eza; then
	function ls() {
		if [ -t 1 ]; then
			# When output is terminal.
			eza --group-directories-first --icons $*
		else
			command ls $*
		fi
	}
fi

alias dotfiles=". $(dotfiles-path)/bin/dotfiles"
alias update-softwares="update-zsh-plugins; $(dotfiles-path)/bin/update-softwares"

zshrc_has_cmd opam && eval $(opam env)

if zshrc_has_cmd xcrun && zshrc_has_cmd brew; then
	__zshrc_brew_prefix=$(brew --prefix)
	export SDKROOT=$(xcrun --show-sdk-path)
	export CPATH=$CPATH:$SDKROOT/usr/include
	export LIBRARY_PATH=$LIBRARY_PATH:$SDKROOT/usr/lib
	# TODO: How can I set framework search path?
	if [ -d "$__zshrc_brew_prefix/opt/llvm" ]; then
		export PATH=$(brew --prefix)/opt/llvm/bin:$PATH
	fi
	if [ -d "$__zshrc_brew_prefix/opt/gcc" ]; then
		zshrc_prepend_PATH "$__zshrc_brew_prefix/opt/gcc/bin"
		zshrc_prepend_PATH "$(dotfiles-path)/opt/gcc/bin"
	fi
fi

# Enable smart completion
autoload -Uz compinit
compinit

export CLICOLOR=auto
function() {
	local -a color_config=(
		gx ex fx dx cx ah ad ac ag ac ad
	)
	export LSCOLORS="${(j..)color_config}"
}

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
typeset -A zshrc_prompt_git_info=(
	branch ''
	dirty ''
	stash ''
	push_pull ''
)
typeset -A zshrc_prompt_colors=(
	yellow '%{%F{yellow}%}'
	green  '%{%F{green}%}'
	red    '%{%F{red}%}'
	gray   '%{%F{242}%}'
	cyan   '%{%F{cyan}%}'
	pink   '%{%F{218}%}'
	purple '%{%F{177}%}'
	reset  '%{%f%}'
)
readonly zshrc_prompt_colors

function zshrc_init_prompt() {
	PROMPT="$(zshrc_build_prompt)"

	# Show the number of background jobs
	RPROMPT='%(1j.[%j].)'

	zle -N zle-line-init
	zle -N zle-keymap-select
	zle -N zle-line-pre-redraw
	autoload -Uz add-zsh-hook
	add-zsh-hook precmd zshrc_prompt_precmd
}

function zshrc_build_prompt() {
	local ps1

	ps1+='${zshrc_prompt_keymap}'

	# Show hostname on SSH
	if [[ -n "$SSH_CONNECTION" ]]; then
		ps1+="${zshrc_prompt_colors[purple]}SSH:${HOSTNAME}${zshrc_prompt_colors[reset]} "
	fi

	# Show Linux distribution on WSL2
	if [[ $(uname) == "Linux" && $(uname -r) == *"microsoft"* ]]; then
		local distrib='Unknown'
		if [ -f '/etc/arch-release' ]; then
			distrib='Arch'
		elif [ -f '/etc/lsb-release' ]; then
			local id="$(cat /etc/lsb-release | grep DISTRIB_ID | sed 's/^DISTRIB_ID=//')"
			if [[ $id == Ubuntu ]]; then
				distrib='Ubuntu'
			fi
		fi
		ps1+="${zshrc_prompt_colors[purple]}${distrib}${zshrc_prompt_colors[reset]} "
	fi

	# Exit code
	ps1+="%{%(?.${zshrc_prompt_colors[green]}.${zshrc_prompt_colors[red]})%}"
	ps1+='#$?'
	ps1+="${zshrc_prompt_colors[reset]} "

	# Current working directory
	ps1+="${zshrc_prompt_colors[yellow]}%~${zshrc_prompt_colors[reset]} "

	# Git status
	ps1+='${zshrc_prompt_git_info[branch]}${zshrc_prompt_git_info[dirty]} '
	ps1+='${zshrc_prompt_git_info[stash]} ${zshrc_prompt_git_info[push_pull]}'

	if ! zshrc_has_cmd async; then
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

function zshrc_prompt_precmd() {
	local has_async=false
	zshrc_has_cmd async && has_async=true

	if $has_async; then
		async_stop_worker zshrc_prompt_async_worker
		async_start_worker zshrc_prompt_async_worker -n
		async_register_callback \
			zshrc_prompt_async_worker zshrc_prompt_async_callback
	fi

	for key in ${(k)zshrc_prompt_git_info}; do
		zshrc_prompt_git_info[${key}]=''
	done

	if zshrc_in_git_repo; then
		zshrc_prompt_git_info[branch]="${zshrc_prompt_colors[gray]}$(git branch --show-current)${zshrc_prompt_colors[reset]}"
		if $has_async; then
			async_job zshrc_prompt_async_worker zshrc_prompt_git_dirty
			async_job zshrc_prompt_async_worker zshrc_prompt_git_stash
			async_job zshrc_prompt_async_worker zshrc_prompt_git_push_pull

			# FIXME: In git repository the prompt text will redrawn on these job
			# callback, but it throws away the last line of output.  As a workaround
			# for it, output a newline here.
			printf '\n'
		fi
	fi
}

function zshrc_prompt_git_dirty() {
	setopt localoptions noshwordsplit

	# Prevent e.g. `git status` from refreshing the index as a side effect.
	# Ref: https://github.com/sindresorhus/pure
	export GIT_OPTIONAL_LOCKS=0
	if [ -n "$(git status --porcelain --untracked-files=normal --no-renames)" ]; then
		echo "${zshrc_prompt_colors[pink]}*${zshrc_prompt_colors[reset]}"
	fi
}

function zshrc_prompt_git_stash() {
	if git rev-list --walk-reflogs --count refs/stash &> /dev/null; then
		echo "${zshrc_prompt_colors[cyan]}≡${zshrc_prompt_colors[reset]}"
	fi
}

# This code is based on pure.zsh. Thanks!
# https://github.com/sindresorhus/pure/blob/2f13dea466466dde1ba844ba5211e7556f4ae2db/pure.zsh#L317
function zshrc_prompt_git_fetch() {
	setopt localoptions noshwordsplit

	local only_upstream=${1:-0}

	# Sets `GIT_TERMINAL_PROMPT=0` to disable authentication prompt for Git fetch (Git 2.3+).
	export GIT_TERMINAL_PROMPT=0
	# Set SSH `BachMode` to disable all interactive SSH password prompting.
	export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-"ssh"} -o BatchMode=yes"

	# If gpg-agent is set to handle SSH keys for `git fetch`, make
	# sure it doesn't corrupt the parent TTY.
	# Setting an empty GPG_TTY forces pinentry-curses to close immediately rather
	# than stall indefinitely waiting for user input.
	export GPG_TTY=

	local -a remote
	if ((only_upstream)); then
		local ref
		ref=$(command git symbolic-ref -q HEAD)
		# Set remote to only fetch information for the current branch.
		remote=($(command git for-each-ref --format='%(upstream:remotename) %(refname)' $ref))
		if [[ -z $remote[1] ]]; then
			# No remote specified for this branch, skip fetch.
			return 97
		fi
	fi

	# Default return code, which indicates Git fetch failure.
	local fail_code=99

	# Guard against all forms of password prompts. By setting the shell into
	# MONITOR mode we can notice when a child process prompts for user input
	# because it will be suspended. Since we are inside an async worker, we
	# have no way of transmitting the password and the only option is to
	# kill it. If we don't do it this way, the process will corrupt with the
	# async worker.
	setopt localtraps monitor

	# Make sure local HUP trap is unset to allow for signal propagation when
	# the async worker is flushed.
	trap - HUP

	trap '
		# Unset trap to prevent infinite loop
		trap - CHLD
		if [[ $jobstates = suspended* ]]; then
			# Set fail code to password prompt and kill the fetch.
			fail_code=98
			kill %%
		fi
	' CHLD

	# Do git fetch and avoid fetching tags or
	# submodules to speed up the process.
	command git -c gc.auto=0 fetch \
		--quiet \
		--no-tags \
		--recurse-submodules=no \
		$remote &>/dev/null &
	wait $! || return $fail_code

	unsetopt monitor
}

function zshrc_prompt_git_push_pull() {
	setopt localoptions noshwordsplit
	if [[ "$(git remote)" == "" ]]; then
		echo '(no-remote)'
		return 0
	fi

	zshrc_prompt_git_fetch
	case $? in
		0)
			local arrows
			local -a output
			output=$(git rev-list --left-right --count HEAD...@'{u}')
			(( output[(w)2] > 0)) && arrows+='⇣'
			(( output[(w)1] > 0)) && arrows+='⇡'
			echo "${zshrc_prompt_colors[cyan]}$arrows${zshrc_prompt_colors[reset]}"
			;;
		97)
			echo '(no-remote)'
			;;
		99|98)  # git fetch failed
			echo "${zshrc_prompt_colors[red]}x${zshrc_prompt_colors[reset]}"
			;;
		*) echo '(err)' ;;  # Do nothing
	esac
}

function zshrc_prompt_vim_mode() {
	if [[ $REGION_ACTIVE != 0 ]]; then
		local modestr='UNKNOWN'
		if [[ $REGION_ACTIVE == 1 ]]; then
			modestr='VISUAL'
		elif [[ $REGION_ACTIVE == 2 ]]; then
			modestr='V-LINE'
		fi
		zshrc_prompt_keymap="${zshrc_prompt_colors[red]} ${modestr} ${zshrc_prompt_colors[reset]}"
	else
		case $KEYMAP in
			vicmd)
				zshrc_prompt_keymap="${zshrc_prompt_colors[green]} NORMAL ${zshrc_prompt_colors[reset]}"
				;;
			main|viins)
				zshrc_prompt_keymap="${zshrc_prompt_colors[cyan]} INSERT ${zshrc_prompt_colors[reset]}"
				;;
		esac
	fi
}

function zshrc_prompt_async_callback() {
	local job=$1
	case $job in
		zshrc_prompt_git_*)
			zshrc_prompt_git_info[${job##zshrc_prompt_git_}]="$3"
			;;
		*)
			return
			;;
	esac
	(( $6 )) || zle .reset-prompt
}

# Handles mode changes between insert mode and normal mode
function zle-keymap-select zle-line-init {
	local keymap_save="$zshrc_prompt_keymap"
	zshrc_prompt_vim_mode
	[[ "$keymap_save" != "$zshrc_prompt_keymap" ]] && zle .reset-prompt
}

# Handles mode changes between normal mode and visual mode
function zle-line-pre-redraw {
	local keymap_save="$zshrc_prompt_keymap"
	zshrc_prompt_vim_mode
	[[ "$keymap_save" != "$zshrc_prompt_keymap" ]] && zle .reset-prompt

	# A hack to enable zsh-syntax-highlighting. (but dirty...)
	zshrc_has_cmd	_zsh_highlight__zle-line-pre-redraw && _zsh_highlight__zle-line-pre-redraw
}

if [ -n "$VIM_TERMINAL" ]; then
	function drop() {
		echo "\e]51;[\"call\", \"Tapi_drop\", [\"$(pwd)\", \"$1\"]]\x07"
	}

	function synccwd() {
		local cwd
		echo "\e]51;[\"call\", \"Tapi_getcwd\", []]\x07"
		read cwd
		cd "$cwd"
	}
fi

# WSL2
if [[ $(uname) == "Linux" && $(uname -r) == *"microsoft"* ]]; then
	function open() {
		cmd.exe /c start $(wslpath -w $1)
	}
	cd ~
fi

# Plugins
DOTZSH=$HOME/.zsh

function install_zsh_plugins() {
	if ! zshrc_has_cmd git ; then
		echo -e '\033[41mgit command not found\033[m'
		return 1
	fi
	if [ ! -d "$DOTZSH/zsh-syntax-highlighting" ]; then
		git clone https://github.com/zsh-users/zsh-syntax-highlighting \
			$DOTZSH/zsh-syntax-highlighting
	fi

	if [ ! -d "$DOTZSH/zsh-async" ]; then
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
	if zshrc_ask_yesno "Install plugins?"; then
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

[ -d "$DOTZSH/zsh-async" ] && source $DOTZSH/zsh-async/async.zsh && async
zshrc_init_prompt  # Must build PROMPT string after "async" library is loaded.

if [ -d "$DOTZSH/zsh-syntax-highlighting" ]; then
	source $DOTZSH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if zshrc_has_cmd fzf; then
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

function gitinit() {
	if zshrc_in_git_repo; then
		zshrc_ask_yesno 'In a git repository. continue?' || return 1
	fi
	git init --initial-branch main
	git commit --allow-empty -m "Initial commit"
}

function CAPSLOCK() {
	if zshrc_has_cmd xdotool; then
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
