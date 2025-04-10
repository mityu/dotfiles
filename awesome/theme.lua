---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local getfont = function(name, size) return name .. ' ' .. dpi(size) end

local theme = {}

theme.font = getfont("noto", 12)

theme.editor_font = getfont("Cica", 13)
theme.editor_bg = "#1f1f1f"
theme.editor_fg = "#fff8dc"

theme.bg_normal = "#22222290"
theme.bg_focus = "#eeeeeee0"
theme.bg_urgent = "#ff0000"
theme.bg_minimize = "#444444"
theme.bg_systray = theme.bg_normal

theme.fg_normal = "#fff8f0"
theme.fg_focus = "#1f1f1f"
theme.fg_urgent = "#ffffff"
theme.fg_minimize = "#ffffff"

theme.useless_gap = dpi(2)
theme.border_width = dpi(0)
theme.border_normal = "#000000"
theme.border_focus = "#535d6c"
theme.border_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"
theme.titlebar_bg_focus = "#eeeeeef0"
theme.titlebar_bg_normal = "#999999f0"
theme.hotkeys_font = getfont("Cica", 14)
theme.hotkeys_bg = theme.editor_bg
theme.hotkeys_description_font = theme.editor_font
theme.hotkeys_fg = theme.editor_fg
theme.hotkeys_modifiers_fg = theme.editor_fg
theme.prompt_font = theme.editor_font
theme.prompt_bg = theme.editor_bg
theme.prompt_fg = theme.editor_fg
-- theme.tooltip_font = getfont("noto", 12)
-- theme.tooltip_opacity = 0.9

-- Generate taglist squares:
local taglist_square_size = dpi(4)
theme.taglist_squares_sel =
  theme_assets.taglist_squares_sel(taglist_square_size, theme.fg_normal)
theme.taglist_squares_unsel =
  theme_assets.taglist_squares_unsel(taglist_square_size, theme.fg_normal)

-- Variables set for theming notifications:
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]
theme.notification_font = getfont("noto", 13)
theme.notification_shape = gears.shape.rounded_rect
theme.notification_fg = "#1f1f1f"
theme.notification_bg = "#eeeeee"
theme.notification_opacity = 80
theme.notification_margin = dpi(25)

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
-- theme.menu_font = theme.font
theme.menu_submenu = '>'
-- theme.menu_submenu = '❯'
theme.menu_height = dpi(32)
theme.menu_width = dpi(150)
theme.menu_bg_normal = '#dbe3e6'
theme.menu_bg_focus = '#2b63dd'
theme.menu_fg_normal = '#1f1f1f'
theme.menu_fg_focus = '#ffffff'

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = themes_path .. "default/titlebar/close_normal.png"
theme.titlebar_close_button_focus = themes_path .. "default/titlebar/close_focus.png"
-- theme.titlebar_close_button_focus = require('gears').surface.load_from_shape(dpi(20), dpi(20), require('gears').shape.circle, '#ff0000')

theme.titlebar_minimize_button_normal = themes_path
  .. "default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus = themes_path
  .. "default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = themes_path
  .. "default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = themes_path
  .. "default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path
  .. "default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = themes_path
  .. "default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path
  .. "default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = themes_path
  .. "default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path
  .. "default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = themes_path
  .. "default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path
  .. "default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = themes_path
  .. "default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path
  .. "default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = themes_path
  .. "default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path
  .. "default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = themes_path
  .. "default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themes_path
  .. "default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = themes_path
  .. "default/titlebar/maximized_focus_active.png"

theme.wallpaper = gfs.get_configuration_dir() .. "wallpaper/Arisu.png"

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path .. "default/layouts/fairhw.png"
theme.layout_fairv = themes_path .. "default/layouts/fairvw.png"
theme.layout_floating = themes_path .. "default/layouts/floatingw.png"
theme.layout_magnifier = themes_path .. "default/layouts/magnifierw.png"
theme.layout_max = themes_path .. "default/layouts/maxw.png"
theme.layout_fullscreen = themes_path .. "default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path .. "default/layouts/tilebottomw.png"
theme.layout_tileleft = themes_path .. "default/layouts/tileleftw.png"
theme.layout_tile = themes_path .. "default/layouts/tilew.png"
theme.layout_tiletop = themes_path .. "default/layouts/tiletopw.png"
theme.layout_spiral = themes_path .. "default/layouts/spiralw.png"
theme.layout_dwindle = themes_path .. "default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path .. "default/layouts/cornernww.png"
theme.layout_cornerne = themes_path .. "default/layouts/cornernew.png"
theme.layout_cornersw = themes_path .. "default/layouts/cornersww.png"
theme.layout_cornerse = themes_path .. "default/layouts/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon =
  theme_assets.awesome_icon(theme.menu_height, theme.fg_focus, theme.bg_focus)


-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
