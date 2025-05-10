#!/usr/bin/env bash

set-config() {
	if git config get --global $1 &> /dev/null; then
		echo "Skipped '$1=$2': Already set to '$(git config get --global $1)'"
	else
		git config --global $*
		echo "Set $*"
	fi
}

set-config user.name mityu
set-config user.email mityu.mail@gmail.com
set-config color.ui true
set-config core.editor vim
set-config pull.rebase false
set-config commit.verbose true
set-config rebase.autoSquash true
set-config rebase.autoStash true
set-config fetch.prune true
set-config diff.algorithm histogram
set-config github.user mityu
