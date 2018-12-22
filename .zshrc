if [ -f ~/.envrc ]; then
	cat ~/.envrc | while read path_expr
	do
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

# 履歴ファイルの保存先
export HISTFILE=${HOME}/.zhistory
# メモリに保存される履歴の件数
export HISTSIZE=1000
# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000
# 重複を記録しない
setopt hist_ignore_dups
# historyを共有
setopt share_history
# 履歴に追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups
# historyコマンドは履歴に登録しない
setopt hist_no_store
setopt menu_complete
