#!/usr/bin/env bash
vim -u NONE -i NONE -N -n -e -s -S $(cd $(dirname $0); pwd)/floating_apps/$@.vim
