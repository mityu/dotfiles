#!/usr/bin/env bash

exit_status=0

set-config() {
	local overwrite=false
	if [[ "$1" == '-f' ]]; then
		overwrite=true
		shift
	fi

	if ! $overwrite && git config get --global $1 &> /dev/null; then
		echo "Skipped '$1=$2': Already set to '$(git config get --global $1)'"
	else
		if git config --global "$1" "$2"; then
			echo "Set $*"
		else
			echo "Failed to set alias: $*"
			exit_status=1
		fi
	fi
}

set-config user.name mityu
set-config user.email mityu.mail@gmail.com
set-config color.ui true
set-config core.editor vim
set-config pull.rebase false
set-config push.followTags true
set-config commit.verbose true
set-config rebase.autoSquash true
set-config rebase.autoStash true
set-config fetch.prune true
set-config diff.algorithm histogram
set-config github.user mityu
set-config ghq.root ~/dev
set-config -f alias.vim '!vim --cmd "autocmd User DenopsPluginPost:gin ++once call feedkeys(\"\<Cmd>GinStatus\<CR>\", \"n\")"'

exit $exit_status
