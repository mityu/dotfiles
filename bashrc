# If not running interactively, don't do anything
# [[ "$-" != *i* ]] && return

function bashrc_is_msys() {
	[[ $(uname -o) == "Msys" ]]
}

function bashrc_prepend_PATH() {
	if [[ $1 != "" && ! $PATH =~ "$1" ]]; then
		export PATH=$1:$PATH
	fi
}

function bashrc_has_cmd() {
	which $1 &> /dev/null
}

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

export LANG=en_US.UTF-8
bashrc_prepend_PATH "$(cd $(dirname $(readlink -f ${BASH_SOURCE[0]})); pwd)/bin"
bashrc_prepend_PATH "$HOME/.local/bin"
if bashrc_has_cmd cargo; then
	bashrc_prepend_PATH "$HOME/.cargo/bin"
fi
if bashrc_has_cmd go; then
	function bashrc_get_gobin() {
		local gobin
		gobin=$(go env GOBIN)
		gobin=${gobin:-$(go env GOPATH)/bin}
		if bashrc_is_msys; then
			gobin=$(cygpath -u $gobin)
		fi
		echo $gobin
	}
	bashrc_prepend_PATH $(bashrc_get_gobin)
fi

if bashrc_has_cmd vim && bashrc_is_msys && \
	[[ $(which vim) == "$(cygpath $USERPROFILE)"* ]]; then
	export PATH=$(echo $PATH | sed -E "s;$(dirname $(which vim))/?:;;"):$(dirname $(which vim))
fi


if ! bashrc_has_cmd sudoedit; then
	alias sudoedit='sudo -e'
fi


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

if bashrc_is_msys; then
	alias pbpaste='cat /dev/clipboard'
	alias pbcopy='cat > /dev/clipboard'
fi

function stdin() {
	local cmd stdin
	cmd="$1"
	shift
	while read -r stdin; do
		"$cmd" "$@" "$stdin"
	done
}

alias dotfiles=". $(which dotfiles)"

shopt -s nocaseglob
set -o vi
bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string ❯'
bind 'set vi-cmd-mode-string ❮'
bind 'set keymap vi-command'
bind 'k: history-search-backward'
bind 'j: history-search-forward'
bind 'set keymap vi-insert'
bind '\C-p: history-search-backward'
bind '\C-n: history-search-forward'
bind '\C-b: backward-char'
bind '\C-f: forward-char'
bind '\C-a: beggining-of-line'
bind '\C-e: end-of-line'
bind '\C-w: kill-word'

if bashrc_has_cmd fzf; then
	export FZF_DEFAULT_OPTS="--reverse --no-sort"

	bind -x '"\C-r": select-history'
	function select-history() {
		local cmd=$(history | awk '{$1=""; print substr($0, 2)}' | fzf --tac +m)
		if [[ $cmd != "" ]]; then
			READLINE_LINE=$cmd
			READLINE_POINT=${#cmd}
		fi
	}
fi

if bashrc_has_cmd vim; then
	export MANPAGER="vim -M +MANPAGER -"
	export EDITOR=vim
	export GIT_EDITOR=vim
fi

PROMPT_COMMAND=__bashrc_update_prompt

function __bashrc_update_prompt() {
	local exit_code=$?
	local gitbranch=$(which git &> /dev/null && git branch --show-current 2> /dev/null || echo '')
	local gray='\e[38;5;243m'
	local red='\e[0;31m'
	local green='\e[0;32m'
	local yellow='\e[0;33m'
	local purple='\e[0;35m'
	local reset='\e[m'
	PS1="\[\e]0;\w\a\]\n"
	if [[ $MSYSTEM != '' ]]; then
		PS1+="$purple$MSYSTEM$reset "
	fi
	PS1+="${purple}bash$reset "
	if [[ $exit_code == 0 ]]; then
		PS1+="$green#\$?$reset"
	else
		PS1+="$red#\$?$reset"
	fi
	PS1+=" $yellow\w$reset "
	if [[ $gitbranch != '' ]]; then
		PS1+="$gray$gitbranch$reset "
	fi
	PS1+='(no-async)'
	PS1+='\n '
}

# Don't put duplicate lines in the history.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups

# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'

# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
if [[ -f /etc/bash_completion ]]; then
	. /etc/bash_completion
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
