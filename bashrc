# If not running interactively, don't do anything
# [[ "$-" != *i* ]] && return

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

if which fzf &> /dev/null; then
    export FZF_DEFAULT_OPTS="--reverse --no-sort"

    # FIXME: It seems that fzf doesn't work on MSYS2 bash on Vim's terminal.
    if [[ $VIM_TERMINAL == "" || $MSYSTEM == '' ]]; then
        bind -x '"\C-r": select-history'
    fi
    function select-history() {
        local cmd=$(history | awk '{$1=""; print substr($0, 2)}' | fzf --tac +m)
        if [[ $cmd != "" ]]; then
            READLINE_LINE=$cmd
            READLINE_POINT=${#cmd}
        fi
    }
fi

PROMPT_COMMAND=__bashrc_update_prompt

function __bashrc_update_prompt() {
    local exit_code=$?
    local gitbranch=$(which git &> /dev/null && git branch --show-current 2> /dev/null || echo '')
    local gray='\e[38;5;243m\]'
    local red='\e[0;31m\]'
    local green='\e[0;32m\]'
    local yellow='\e[0;33m\]'
    local purple='\e[0;35m\]'
    local reset='\e[m\]'
    PS1="\[\e]0;\w\a\]\n"
    if [[ $MSYSTEM != '' ]]; then
        PS1+="$purple$MSYSTEM$reset "
    fi
    PS1+="$yellow\W$reset "
    if [[ $gitbranch != '' ]]; then
        PS1+="$gray$gitbranch$reset "
    fi
    if [[ $exit_code == 0 ]]; then
        PS1+="$green\$?$reset"
    else
        PS1+="$red\$?$reset"
    fi
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
