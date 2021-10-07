# -*- coding: utf-8 -*-

import re
from xkeysnail.transform import *

# define timeout for multipurpose_modmap
define_timeout(1)

# [Global modemap] Change modifier keys as in xmodmap
define_modmap({
    Key.CAPSLOCK: Key.LEFT_CTRL
})


# [Multipurpose modmap] Give a key two meanings. A normal key when pressed and
# released, and a modifier key when held down with another key. See Xcape,
# Carabiner and caps2esc for ideas and concept.
define_multipurpose_modmap(
    # Enter is enter when pressed and released. Control when held down.
    {Key.ENTER: [Key.ENTER, Key.RIGHT_CTRL]}

    # Capslock is escape when pressed and released. Control when held down.
    # {Key.CAPSLOCK: [Key.ESC, Key.LEFT_CTRL]
    # To use this example, you can't remap capslock with define_modmap.
)

# [Conditional multipurpose modmap] Multipurpose modmap in certain conditions,
# such as for a particular device.
# define_conditional_multipurpose_modmap(lambda wm_class, device_name: device_name.startswith("Microsoft"), {
#    # Left shift is open paren when pressed and released.
#    # Left shift when held down.
#    Key.LEFT_SHIFT: [Key.KPLEFTPAREN, Key.LEFT_SHIFT],
# 
#    # Right shift is close paren when pressed and released.
#    # Right shift when held down.
#    Key.RIGHT_SHIFT: [Key.KPRIGHTPAREN, Key.RIGHT_SHIFT]
# })


# Keybindings for Web browsers
define_keymap(re.compile("Firefox|Google-chrome|Chromium|Vivaldi", re.IGNORECASE), {
    K("Super-t"): K("C-t"),
    K("Super-n"): K("C-n"),
    K("Super-Shift-n"): K("C-Shift-n"),
    K("Super-w"): K("C-w"),
    K("Super-Shift-w"): K("C-Shift-w"),
    K("Super-r"): K("C-r"),
    # K("Super-l"): K("C-l"),
    K("Super-f"): K("C-f"),
    K("Super-d"): K("C-d"),
    # very naive "Edit in editor" feature (just an example)
    K("C-o"): [K("C-a"), K("C-c"), launch(["gedit"]), sleep(0.5), K("C-v")],
}, "WebBrowser")

macLikeExceptions = ("URxvt", "org.wezfurlong.wezterm", "Alacritty", "Gvim")
# macOS-like keybindings in many place
define_keymap(lambda wm_class: wm_class not in macLikeExceptions, {
    # Cursor
    K("C-b"): with_mark(K("left")),
    K("C-f"): with_mark(K("right")),
    K("C-p"): with_mark(K("up")),
    K("C-n"): with_mark(K("down")),
    K("C-h"): with_mark(K("backspace")),
    # Beginning/End of line
    K("C-a"): with_mark(K("home")),
    K("C-e"): with_mark(K("end")),
    # Newline
    K("C-m"): K("enter"),
    K("C-j"): K("enter"),
    K("C-o"): [K("enter"), K("left")],
    # Delete
    K("C-d"): [K("delete"), set_mark(False)],

    # Copy and paste
    K("Super-c"): K("C-c"),
    K("Super-v"): K("C-v"),
}, "macOS-like keys")
