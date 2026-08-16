# This is based on the built-in fish_clipboard_paste, which is distributed under GPL-2.0 license.

function pbpaste
    set -l data
    if command -q pbpaste
        set data (command pbpaste 2>/dev/null | string collect -N)
    else if set -q WAYLAND_DISPLAY; and type -q wl-paste
        # TODO: Check whether we can connect to WAYLAND_DISPLAY.
        set data (wl-paste -n 2>/dev/null | string collect -N)
    else if set -q DISPLAY; and type -q xsel; and xsel -q >/dev/null
        set data (xsel --clipboard | string collect -N)
    else if set -q DISPLAY; and type -q xclip; and xclip -selection clipboard -o >/dev/null
        set data (xclip -selection clipboard -o 2>/dev/null | string collect -N)
    else if type -q powershell.exe
        set data (powershell.exe Get-Clipboard | string trim -r -c \r | string collect -N)
    else if test (uname -o) = Msys
        command cat /dev/clipboard
    end

    # Issue 6254: Handle zero-length clipboard content
    if not string length -q -- "$data"
        return 1
    end

    if not isatty stdout
        # If we're redirected, just write the data *as-is*.
        printf %s $data
        return
    end

    __fish_paste $data
end
