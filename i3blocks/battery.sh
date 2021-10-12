#!/usr/bin/env bash

set -euCo pipefail

function online_icon() {
  [[ $# -eq 0 ]] && return 1
  local -ar icons=('' '' '' '' '')
  local index
  index=$(expr $1 % ${#icons[@]})
  echo ${icons[${index}]}
}

function echo_battery() {
  [[ $# -eq 1 ]] \
    && echo -e "\"full_text\": \"$1 \"" \
    || echo -e "\"full_text\": \"$1 \", \"color\": \"$2\""
}

function get_battery() {
  [[ -e '/sys/class/power_supply/BAT1/capacity' ]] \
    && cat '/sys/class/power_supply/BAT1/capacity' \
    || echo 0
}

function online() {
  [[ -e '/sys/class/power_supply/BAT1/status' && \
    $(cat /sys/class/power_supply/BAT1/status) == 'Charging' ]] \
    && return 0
  return 1
}

function main() {
  local -Ar \
    high=( ['value']=79 ['icon']='' ['color']='#fff8dc') \
    middle=( ['icon']='' ['color']='#fff8dc') \
    low=( ['value']=31 ['icon']='' ['color']='#ff0000')

  local online_icon='' cnt=0
  while sleep 1; do
    cnt=$(expr ${cnt} + 1)

    if online; then
      online_icon=$(online_icon ${cnt})
    else
      [[ -z ${online_icon} && $(expr ${cnt} % 60) -ne 1 ]] \
        && continue
      online_icon=''
    fi

    local battery
    battery=$(get_battery)
    if [[ ${battery} -eq 0 ]]; then
      echo_battery "${online_icon}" "#22ff22"
    elif [[ ${battery} -gt ${high['value']} ]];then
      echo_battery \
        "${online_icon:-${high['icon']}} ${battery}%" ${high['color']}
    elif [[ ${battery} -lt ${low['value']} ]];then
      echo_battery \
        "${online_icon:-${low['icon']}} ${battery}%" ${low['color']}
    else
      echo_battery \
        "${online_icon:-${middle['icon']}} ${battery}%" ${middle['color']}
    fi
  done
}

main
