# vim: filetype=bash tabstop=2
# If not running interactively, don't do anything
# [[ "$-" != *i* ]] && return

# If bash is running interactively, launch ble.sh
if [[ $- == *i* ]] && [[ -f "$HOME/.local/share/blesh/ble.sh" ]] && \
	[[ -z ${NO_BLE:-} ]] && [[ $(uname -o) != "Msys" ]]; then
	source "$HOME/.local/share/blesh/ble.sh" --noattach
elif tput -T xterm longname &> /dev/null; then
	# Fix cursor shape (it's maybe different when bash is launched via "no-ble-bash")
	printf "\e[2 q"
fi

function dotfiles-path() {
	echo $(cd $(dirname $(readlink -f ${BASH_SOURCE[0]})); pwd)
}

function bashrc_is_msys() {
	[[ $(uname -o) == "Msys" ]]
}

function bashrc_in_vim_terminal() {
	[[ "$VIM_TERMINAL" != "" ]]
}

function bashrc_in_neovim_terminal() {
	[[ "$NVIM" != "" ]]
}

function bashrc_XDG_CONFIG_HOME() {
	echo ${XDG_CONFIG_HOME:-$HOME/.config}
}

function bashrc_XDG_CACHE_HOME() {
	echo ${XDG_CACHE_HOME:-$HOME/.cache}
}

function bashrc_has_cmd() {
	type $1 &> /dev/null
}

function bashrc_print_error() {
	printf "\033[41m$@\033[m\n"
}

function bashrc_ask_yesno() {
	echo -n "$1 [y/N]: "
	read -q
}

__bashrc_dotfiles_path=`dotfiles-path`

# Set environmental variables (Only when outside of Vim.)
if ! (bashrc_in_vim_terminal || bashrc_in_neovim_terminal) && [[ -f ~/.envrc ]]; then
	source ~/.envrc
fi

# Environmental variables
if shopt -q login_shell; then
	function bashrc_prepend_PATH() {
		if [[ $1 != "" && ! $PATH =~ "$1" ]]; then
			export PATH=$1:$PATH
		fi
	}

	export LANG=en_US.UTF-8
	export CLICOLOR=auto
	export LSCOLORS=gxexfxdxcxahadacagacad
	bashrc_prepend_PATH "$__bashrc_dotfiles_path/bin"
	bashrc_prepend_PATH "$HOME/.local/bin"
	bashrc_prepend_PATH "$HOME/.nodebrew/current/bin"

	# if bashrc_has_cmd cargo; then
	# 	bashrc_prepend_PATH "$HOME/.cargo/bin"
	# fi
	if [[ -f "$HOME/.cargo/env" ]]; then
		. "$HOME/.cargo/env"
	fi

	if bashrc_has_cmd go; then
		function __bashrc_get_gobin() {
			local gobin
			gobin=$(go env GOBIN)
			gobin=${gobin:-$(go env GOPATH)/bin}
			if bashrc_is_msys; then
				gobin=$(cygpath -u $gobin)
			fi
			echo $gobin
		}
		bashrc_prepend_PATH $(__bashrc_get_gobin)
	fi

	bashrc_has_cmd ros && bashrc_prepend_PATH "$HOME/.roswell/bin"
	bashrc_has_cmd opam && eval $(opam env)

	if bashrc_has_cmd xcrun && bashrc_has_cmd brew; then
		__bashrc_brew_prefix=$(brew --prefix)
		export SDKROOT=$(xcrun --show-sdk-path)
		export CPATH=$CPATH:$SDKROOT/usr/include
		export LIBRARY_PATH=$LIBRARY_PATH:$SDKROOT/usr/lib
		export DYLD_FRAMEWORK_PATH=$DYLD_FRAMEWORK_PATH:$SDKROOT/System/Library/Frameworks
		if [[ -d "$__bashrc_brew_prefix/opt/llvm" ]]; then
			export PATH=$__bashrc_brew_prefix/opt/llvm/bin:$PATH
		fi
		if [[ -d "$__bashrc_brew_prefix/opt/gcc" ]]; then
			alias gcc="$(ls $__bashrc_brew_prefix/bin | grep '^gcc-\d\+')"
			alias g++="$(ls $__bashrc_brew_prefix/bin | grep '^g++-\d\+')"
		fi
	fi
fi


shopt -s nocaseglob
set -o vi
if ! type ble &> /dev/null; then
	bind 'set show-mode-in-prompt on'
	bind 'set vi-ins-mode-string -'
	bind 'set vi-cmd-mode-string :'
	bind 'set keymap vi-command'
	bind 'k: history-search-backward'
	bind 'j: history-search-forward'
	bind 'set keymap vi-insert'
	bind '\C-p: history-search-backward'
	bind '\C-n: history-search-forward'
	bind '\C-b: backward-char'
	bind '\C-f: forward-char'
	bind '\C-a: beginning-of-line'
	bind '\C-e: end-of-line'
	bind '\C-w: kill-word'
fi


alias dotfiles=". $(which dotfiles)"
alias update-softwares=". $(which update-softwares)"
alias zenn='deno run --unstable-fs -A npm:zenn-cli@latest'
alias zenn-update='deno cache --reload npm:zenn-cli@latest'
alias no-ble-bash='NO_BLE=true exec bash'
alias themis-nvim='THEMIS_VIM=nvim themis'

bashrc_has_cmd bat && alias cat='bat --style plain --theme ansi'
bashrc_has_cmd sudoedit || alias sudoedit='sudo -e'

if bashrc_is_msys; then
	alias pbpaste='command cat /dev/clipboard'
	alias pbcopy='command cat > /dev/clipboard'
elif bashrc_has_cmd xsel; then
	# xsel -p?
	bashrc_has_cmd pbpaste || alias pbpaste='xsel -b'
	bashrc_has_cmd pbcopy || alias pbcopy='xsel -bi'
fi

if bashrc_has_cmd rlwrap; then
	bashrc_has_cmd ocaml && alias ocaml='rlwrap ocaml'
fi

if bashrc_has_cmd eza; then
	function ls() {
		if [[ -t 1 ]]; then
			# When output is terminal.
			eza --group-directories-first --icons $*
		else
			command ls $*
		fi
	}
fi

if bashrc_has_cmd vim; then
	alias vi="vim -u $__bashrc_dotfiles_path/vim/vimrc_stable"
	alias vim-stable='vi'
	alias profile-vimrc="vim --cmd 'source $__bashrc_dotfiles_path/vim/misc/profile_vimrc.vim'"
	export MANPAGER='vim -M +MANPAGER -'
	export EDITOR=vim
	export GIT_EDITOR=vim

	if bashrc_is_msys && [[ $(which vim) == "$(cygpath $USERPROFILE)"* ]]; then
		export PATH=$(echo $PATH | sed -E "s;$(dirname $(which vim))/?:;;"):$(dirname $(which vim))
	fi
fi

function gitinit() {
	if git rev-parse 2> /dev/null; then
		bashrc_ask_yesno 'In a git repository. continue?' || return 1
	fi
	git init --initial-branch main
	git commit --allow-empty -m "Initial commit"
}

function CAPSLOCK() {
	if bashrc_has_cmd xdotool; then
		xdotool key Caps_Lock
	else
		bashrc_print_error 'xdotool not found.'
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

if bashrc_in_vim_terminal; then
	function drop() {
		printf "\e]51;[\"call\", \"Tapi_drop\", [\"$(pwd)\", \"$1\"]]\x07"
	}

	function synccwd() {
		local cwd
		printf "\e]51;[\"call\", \"Tapi_getcwd\", []]\x07"
		read cwd
		cd "$cwd"
	}

	function clear-vimenv() {
		export VIM= VIMRUNTIME=
	}

	if bashrc_has_cmd nvim; then
		alias nvim='VIM= VIMRUNTIME= nvim'
	fi
fi

if bashrc_has_cmd sk; then
	export SKIM_DEFAULT_OPTIONS='--reverse --no-sort'

	bind -x '"\C-r": select-history'
	function select-history() {
		local cmd=$(history | awk '{$1=""; print substr($0, 2)}' | sk --tac --no-multi)
		if [[ $cmd != "" ]]; then
			READLINE_LINE=$cmd
			READLINE_POINT=${#cmd}
		fi
	}

	function cd() {
		if [[ $@ != '' ]]; then
			command cd "$@"
			return $?
		fi
		local directories=(
			`dotfiles-path`
			`bashrc_XDG_CONFIG_HOME`
			`bashrc_XDG_CACHE_HOME`
			"$HOME/dev"
		)
		local cmd="find ${directories[@]} -type d -not -path '*/\.git/*'"
		local path=$(sk --no-multi -c "$cmd")
		if [[ $path != "" ]]; then
			command cd $path
		fi
	}
elif bashrc_has_cmd fzf; then
	export FZF_DEFAULT_OPTS="--reverse --no-sort"

	bind -x '"\C-r": select-history'
	function select-history() {
		local cmd=$(history | awk '{$1=""; print substr($0, 2)}' | fzf --tac --no-multi)
		if [[ $cmd != "" ]]; then
			READLINE_LINE=$cmd
			READLINE_POINT=${#cmd}
		fi
	}
fi

# Plugins
bashrc_plugin_dir=`bashrc_XDG_CACHE_HOME`/bash

function install-bash-plugins() {
	local blesh_repo_dir=$bashrc_plugin_dir/ble.sh
	if [[ ! -d $blesh_repo_dir ]]; then
		git clone --recursive https://github.com/akinomyoga/ble.sh.git \
			$blesh_repo_dir
		# Build ble.sh and install to ~/.local/share/blesh
		make -C $blesh_repo_dir && make -C $blesh_repo_dir install
	fi

	local gitstatus_repo_dir=$bashrc_plugin_dir/gitstatus
	git clone https://github.com/romkatv/gitstatus $gitstatus_repo_dir
	$gitstatus_repo_dir/build -w
}

function update-bash-plugins() {
	local blesh_bin="$HOME/.local/share/blesh/ble.sh"
	if [[ ${BLE_VERSION-} ]]; then
		ble-update
	elif [[ -f $blesh_bin ]]; then
		bash $blesh_bin --update
	fi

	if [[ -d $bashrc_plugin_dir/gitstatus ]]; then
		pushd $bashrc_plugin_dir/gitstatus
		local hash=$(git rev-parse HEAD)
		git pull
		if [[ $hash != $(git rev-parse HEAD) ]]; then
			./build -w
		fi
		popd
	fi
}

if [[ ! -d $bashrc_plugin_dir ]]; then
	echo 'Start installing bash plugins.'
	mkdir -p $bashrc_plugin_dir
	install-bash-plugins
fi

if [[ -f $bashrc_plugin_dir/gitstatus/gitstatus.plugin.sh ]]; then
	source $bashrc_plugin_dir/gitstatus/gitstatus.plugin.sh
	gitstatus_stop && gitstatus_start
fi

PROMPT_COMMAND=__bashrc_update_prompt

declare -A __bashrc_prompt_colors=(
	[gray]='\e[38;5;243m'
	[red]='\e[0;31m'
	[pink]='\e[38;5;218m'
	[green]='\e[0;32m'
	[yellow]='\e[0;33m'
	[purple]='\e[0;35m'
	[cyan]='\e[0;36m'
)
if ! tput -T xterm-256color longname &> /dev/null; then
	__bashrc_prompt_colors[gray]='\e[0;37m'
	__bashrc_prompt_colors[pink]='\e[0;31m'
fi

function __bashrc_update_prompt() {
	local exit_code=$?
	local reset='\e[m'

	PS1="\[\e]0;\w\a\]\n"
	if [[ $MSYSTEM != '' ]]; then
		PS1+="${__bashrc_prompt_colors[purple]}$MSYSTEM$reset "
	fi
	PS1+="${__bashrc_prompt_colors[purple]}bash$reset "
	if [[ $exit_code == 0 ]]; then
		PS1+="${__bashrc_prompt_colors[green]}#\$?$reset"
	else
		PS1+="${__bashrc_prompt_colors[red]}#\$?$reset"
	fi
	PS1+=" ${__bashrc_prompt_colors[yellow]}\w$reset "
	if type gitstatus_query &> /dev/null && gitstatus_query && \
		[[ "$VCS_STATUS_RESULT" == ok-sync ]]; then
		local branch=$VCS_STATUS_LOCAL_BRANCH
		[[ -z $branch ]] && branch="@$VCS_STATUS_COMMIT"
		local dirty
		(( dirty = VCS_STATUS_NUM_STAGED + VCS_STATUS_NUM_UNSTAGED + VCS_STATUS_NUM_UNTRACKED ))

		PS1+=" ${__bashrc_prompt_colors[gray]}$branch$reset"
		(( dirty )) && PS1+="${__bashrc_prompt_colors[pink]}*$reset"
		(( VCS_STATUS_COMMITS_AHEAD )) && PS1+="${__bashrc_prompt_colors[cyan]}⇡$VCS_STATUS_COMMITS_AHEAD$reset"
		(( VCS_STATUS_COMMITS_BEHIND )) && PS1+="${__bashrc_prompt_colors[cyan]}⇣$VCS_STATUS_COMMITS_BEHIND$reset"
		(( VCS_STATUS_STASHES )) && PS1+="${__bashrc_prompt_colors[cyan]}≡$reset"
		if [[ -n ${VCS_STATUS_REMOTE_NAME:-} ]]; then
			PS1+="${__bashrc_prompt_colors[gray]} → $VCS_STATUS_REMOTE_NAME"
			[[ -n ${VCS_STATUS_REMOTE_BRANCH:-} ]] && PS1+="/$VCS_STATUS_REMOTE_BRANCH"
			PS1+="$reset"
		fi
	else
		local branch=$(git branch --show-current 2> /dev/null || echo '')
		[[ -n $branch ]] && PS1+=" ${__bashrc_prompt_colors[gray]}$branch$reset (no-status)"
	fi
	PS1+='\n'
	[[ $(id -u) == 0 ]] && PS1+='# ' || PS1+='$ '
	return $exit_code
}

# Don't put duplicate lines in the history.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}erasedups:ignorespace

# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'

# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
if [[ -f /etc/bash_completion ]]; then
	. /etc/bash_completion
fi

if bashrc_has_cmd brew; then
	__bashrc_brew_prefix=$(brew --prefix)
	if [[ -f $__bashrc_brew_prefix/etc/bash_completion ]]; then
		. $__bashrc_brew_prefix/etc/bash_completion
	fi
	if [[ -d "$__bashrc_brew_prefix/etc/bash_completion.d" ]]; then
		for f in $__bashrc_brew_prefix/etc/bash_completion.d/*; do
			. $f
		done
	fi
fi

# Whenever displaying the prompt, write the previous line to disk
# export PROMPT_COMMAND="history -a"

# Aliases
#
# Some people use a different file for aliases
# if [ -f "${HOME}/.bash_aliases" ]; then
#   source "${HOME}/.bash_aliases"
# fi
#
# Default to human readable figures
# alias df='df -h'
# alias du='du -h'

[[ ${BLE_VERSION-} ]] && ble-attach || true  # Do not leave error exit status.
