if [ -f ~/.envrc ]; then
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
		export $(eval echo ${path_expr})
	done
fi

if [ -n "$VIM_TERMINAL" ] && [ -n "$VIM_SERVERNAME" ]; then
	function mvim(){
		$VIMBINARY --servername $VIM_SERVERNAME --remote-tab-wait $@
	}
else
	function mvim(){
		$VIMBINARY $@
	}
fi

#alias mvim=$VIMBINARY
alias vim='mvim'
alias winecmd='wine cmd /k "C:\setenv"'
alias pip3upgrade='pip3 list --outdated --format=legacy | awk '"'"'{print $1}'"'"' | xargs pip3 install -U'

autoload -U compinit
compinit
#PROMPT='%m:%c %n$ '
PROMPT='%c $ '
RPROMPT='[%~]'

# The file to save history
export HISTFILE=${HOME}/.zhistory
# How many does zsh record history to memory.
export HISTSIZE=1000
# How many does zsh record history to a history file.
export SAVEHIST=100000
# Remove history duplicates
setopt hist_ignore_dups
setopt hist_ignore_all_dups
# historyを共有
setopt share_history
# Do not record `history`
setopt hist_no_store
# Enable completion
setopt menu_complete
