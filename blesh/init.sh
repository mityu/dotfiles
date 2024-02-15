# vim: set tabstop=2 shiftwidth=2
# See also: https://github.com/akinomyoga/ble.sh/blob/master/blerc.template

bleopt editor=vim
bleopt exec_errexit_mark=


function blerc/hook-keymap-vi-load {
	bleopt keymap_vi_mode_string_nmap=$'\e[1m-- NORMAL --\e[m'
	ble-bind -m vi_imap --cursor 6
	ble-bind -m vi_nmap --cursor 2
	ble-bind -m vi_omap --cursor 2
	ble-bind -m vi_xmap --cursor 2
	ble-bind -m vi_cmap --cursor 2

	ble-bind -m vi_imap -f 'C-i' 'vi_imap/complete'
	ble-bind -m vi_imap -f 'TAB' 'vi_imap/complete'

	bleopt keymap_vi_mode_name_linewise='V-LINE'
	bleopt keymap_vi_mode_name_blockwise='V-BLOCK'
}
blehook/eval-after-load keymap_vi blerc/hook-keymap-vi-load

function blerc/hook-complete-load {
	ble-bind -m auto_complete -f 'C-i' auto_complete/insert
	ble-bind -m auto_complete -f 'TAB' auto_complete/insert
	ble-bind -m auto_complete -f 'C-e' auto_complete/cancel
}
blehook/eval-after-load complete blerc/hook-complete-load


ble-face syntax_error='fg=red'
ble-face command_builtin='fg=green'
ble-face command_alias='fg=green'
ble-face command_function='fg=green'
ble-face command_keyword='fg=cyan'
ble-face auto_complete='fg=gray'

ble-sabbrev g='git'
ble-sabbrev v='vim'
