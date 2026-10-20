# This is based on the built-in fish_clipboard_paste, which is distributed under GPL-2.0 license.

function pbpaste
    if command -q pbpaste
        command pbpaste
    else if set -q WAYLAND_DISPLAY; and type -q wl-paste
        # TODO: Check whether we can connect to WAYLAND_DISPLAY.
        wl-paste -n
    else if set -q DISPLAY; and type -q xsel; and xsel -q >/dev/null
        xsel --clipboard
    else if set -q DISPLAY; and type -q xclip; and xclip -selection clipboard -o >/dev/null
        xclip -selection clipboard -o
    else if type -q powershell.exe
        powershell.exe Get-Clipboard
    else if test (uname -o) = Msys
        command cat /dev/clipboard
    else
        # Give up.
        echo 'No method found to get clipboard content' >&2
        return 1
    end
end
