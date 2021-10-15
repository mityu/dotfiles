#!/usr/bin/env bash

set -euCo pipefail

function is_charging() {
  if [[ -e '/sys/class/power_supply/BAT1/status' && \
    $(cat /sys/class/power_supply/BAT1/status) == 'Charging' ]]; then
    return 0
  fi
  return 1
}

function get_battery_rest() {
  if [[ -e '/sys/class/power_supply/BAT1/capacity' ]]; then
    cat '/sys/class/power_supply/BAT1/capacity'
    return 0
  fi
  echo 0
}

function main() {
    local icon_color=''
    local icon='Err'
    local rest=$(get_battery_rest)

    if [[ ${rest} -eq 0 ]]; then
        icon=''
    elif [[ ${rest} -lt 21 ]]; then
        icon=''
    elif [[ ${rest} -lt 51 ]]; then
        icon=''
    elif [[ ${rest} -lt 81 ]]; then
        icon=''
    else
        icon=''
    fi

    if is_charging; then
        icon_color='#00ff00'
    elif [[ ${rest} -lt 31 ]]; then
        icon_color='#ff3334'
    fi

    local battery_status="${icon} ${rest}%"
    if [[ -z "${icon_color}" ]]; then
        echo -e "\"full_text\": \"${battery_status}\""
    else
        echo -e "\"full_text\": \"${battery_status}\", \"color\": \"${icon_color}\""
    fi
}

while sleep 1; do
  main
done
