-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local deficient = require("deficient")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors,
  })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then
      return
    end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err),
    })
    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "wezterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.floating,
  -- awful.layout.suit.tile.left,
  -- awful.layout.suit.tile.bottom,
  -- awful.layout.suit.tile.top,
  -- awful.layout.suit.fair,
  -- awful.layout.suit.fair.horizontal,
  -- awful.layout.suit.spiral,
  -- awful.layout.suit.spiral.dwindle,
  -- awful.layout.suit.max,
  -- awful.layout.suit.max.fullscreen,
  -- awful.layout.suit.magnifier,
  -- awful.layout.suit.corner.nw,
  -- awful.layout.suit.corner.ne,
  -- awful.layout.suit.corner.sw,
  -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
  {
    "hotkeys",
    function()
      hotkeys_popup.show_help(nil, awful.screen.focused())
    end,
  },
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  {
    "quit",
    function()
      awesome.quit()
    end,
  },
}

mymainmenu = awful.menu({
  items = {
    { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "open terminal", terminal },
  },
})

mylauncher = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = mymainmenu,
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}



-- {{{ Wibar
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
  awful.button({}, 1, function(t)
    t:view_only()
  end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({}, 4, function(t)
    awful.tag.viewnext(t.screen)
  end),
  awful.button({}, 5, function(t)
    awful.tag.viewprev(t.screen)
  end)
)

local tasklist_buttons = gears.table.join(
  awful.button({}, 1, function(c)
    if c == client.focus then
      c.minimized = true
    else
      c:emit_signal("request::activate", "tasklist", { raise = true })
    end
  end),
  awful.button({}, 3, function()
    awful.menu.client_list({ theme = { width = 250 } })
  end),
  awful.button({}, 4, function()
    awful.client.focus.byidx(1)
  end),
  awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
  end)
)

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local function add_tag(name, props)
  local tag = awful.tag.add(name, props)
  tag:connect_signal("property::selected", function(t)
    if not t.selected and #t:clients() == 0 then
      t:delete()
    end
  end)
  return tag
end

awful.screen.connect_for_each_screen(function(s)
  -- Wallpaper
  set_wallpaper(s)

  -- Each screen has its own tag table.
  awful.tag({ "1" }, s, awful.layout.layouts[1])

  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt()
  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.layout.inc(1)
    end),
    awful.button({}, 3, function()
      awful.layout.inc(-1)
    end),
    awful.button({}, 4, function()
      awful.layout.inc(1)
    end),
    awful.button({}, 5, function()
      awful.layout.inc(-1)
    end)
  ))
  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = taglist_buttons,
  })

  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist({
    screen = s,
    filter = awful.widget.tasklist.filter.currenttags,
    buttons = tasklist_buttons,
  })

  -- Create the wibox
  s.mywibox = awful.wibar({ height = beautiful.menu_height, position = "top", screen = s })
  local spacer = wibox.container.margin(nil, dpi(8), 0, 0, 0)

  -- Add widgets to the wibox
  s.mywibox:setup({
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      mylauncher,
      s.mytaglist,
      s.mypromptbox,
    },
    s.mytasklist, -- Middle widget
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      awful.widget.keyboardlayout(),
      spacer,
      wibox.widget.systray(),
      spacer,
      require("memory").widget(),
      spacer,
      require("battery").widget(),
      spacer,
      deficient.cpuinfo().widget,
      spacer,
      wibox.widget.textclock("%m/%d(%A) %R"),
      spacer,
      s.mylayoutbox,
    },
  })
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
  awful.button({}, 3, function()
    mymainmenu:toggle()
  end),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

local volume_widget = wibox {
  width = dpi(200),
  height = dpi(50),
  bg = "#000000",
  fg = "#444444",
  ontop = true,
  visible = false,
  type = 'popup_menu',
}

local volume_bar = wibox.widget {
  max_value = 100,
  value = 0,
  border_width = dpi(1),
  forced_height = dpi(10),
  forced_width = dpi(180),
  shape = gears.shape.rounded_bar,
  bar_shape = gears.shape.rounded_bar,
  widget = wibox.widget.progressbar,
  color = '#ddd7cc',
  background_color = '#444444',
  border_color = '#444444',
}

local volume_text = wibox.widget {
  text = 'Volume: ?',
  widget = wibox.widget.textbox,
}

volume_widget:setup {
  {
    {
      {
        volume_text,
        valign = 'center',
        halign = 'center',
        widget = wibox.container.place,
      },
      volume_bar,
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  },
  bg = '#ddd7cc',
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background,
  opacity = 0.9,
}

local volume_widget_timer = gears.timer {
    timeout = 2,
    autostart = false,
    single_shot = true,
    callback = function()
      volume_widget.visible = false
    end,
  }

local function show_volume()
  awful.spawn.easy_async_with_shell(
    'wpctl get-volume @DEFAULT_AUDIO_SINK@',
    function(stdout)
      if string.match(stdout, '%[MUTED]%s*$') then
        volume_bar.value = 0
        volume_text.text = 'Volume: Muted'
      else
        local volume = tonumber(string.match(stdout, '^Volume:%s*(%d+.%d+)')) * 100
        volume_bar.value = volume
        volume_text.text = string.format('Volume: %d%%', volume)
      end

      local screen = awful.screen.focused()
      volume_widget.screen = screen
      volume_widget.x = (screen.geometry.width - volume_widget.width) * 0.5
      volume_widget.y = (screen.geometry.height - volume_widget.height) * 0.5
      volume_widget.visible = true
      volume_widget_timer:again()
    end
  )
end

-- {{{ Key bindings
globalkeys = gears.table.join(
  awful.key(
    { modkey },
    "s",
    hotkeys_popup.show_help,
    { description = "show help", group = "awesome" }
  ),
  awful.key(
    { modkey },
    "Left",
    awful.tag.viewprev,
    { description = "view previous", group = "tag" }
  ),
  awful.key(
    { modkey },
    "Right",
    awful.tag.viewnext,
    { description = "view next", group = "tag" }
  ),
  awful.key(
    { modkey, "Shift" },
    "Tab",
    awful.tag.viewprev,
    { description = "view next", group = "tag" }
  ),
  awful.key(
    { modkey },
    "Tab",
    awful.tag.viewnext,
    { description = "view previous", group = "tag" }
  ),
  awful.key(
    { modkey },
    "Escape",
    awful.tag.history.restore,
    { description = "go back", group = "tag" }
  ),

  -- awful.key({ modkey }, "w", function()
  -- 	mymainmenu:show()
  -- end, { description = "show main menu", group = "awesome" }),

  -- Layout manipulation
  awful.key({ modkey, "Shift" }, "j", function()
    awful.client.swap.byidx(1)
  end, { description = "swap with next client by index", group = "client" }),

  awful.key({ modkey, "Shift" }, "k", function()
    awful.client.swap.byidx(-1)
  end, { description = "swap with previous client by index", group = "client" }),

  awful.key({ modkey, "Control" }, "j", function()
    awful.screen.focus_relative(1)
  end, { description = "focus the next screen", group = "screen" }),

  awful.key({ modkey, "Control" }, "k", function()
    awful.screen.focus_relative(-1)
  end, { description = "focus the previous screen", group = "screen" }),

  awful.key(
    { modkey },
    "u",
    awful.client.urgent.jumpto,
    { description = "jump to urgent client", group = "client" }
  ),

  awful.key({ modkey }, "Tab", function()
    awful.client.focus.history.previous()
    if client.focus then
      client.focus:raise()
    end
  end, { description = "go back", group = "client" }),

  -- Standard program
  awful.key({ modkey }, "Return", function()
    awful.spawn(terminal)
  end, { description = "open a terminal", group = "launcher" }),
  awful.key(
    { modkey, "Control" },
    "r",
    awesome.restart,
    { description = "reload awesome", group = "awesome" }
  ),
  awful.key(
    { modkey, "Shift" },
    "q",
    awesome.quit,
    { description = "quit awesome", group = "awesome" }
  ),

  -- awful.key({ modkey }, "l", function()
  --   awful.tag.incmwfact(0.05)
  -- end, { description = "increase master width factor", group = "layout" }),
  -- awful.key({ modkey }, "h", function()
  --   awful.tag.incmwfact(-0.05)
  -- end, { description = "decrease master width factor", group = "layout" }),
  awful.key({ modkey, "Shift" }, "h", function()
    awful.tag.incnmaster(1, nil, true)
  end, { description = "increase the number of master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "l", function()
    awful.tag.incnmaster(-1, nil, true)
  end, { description = "decrease the number of master clients", group = "layout" }),
  awful.key({ modkey, "Control" }, "h", function()
    awful.tag.incncol(1, nil, true)
  end, { description = "increase the number of columns", group = "layout" }),
  awful.key({ modkey, "Control" }, "l", function()
    awful.tag.incncol(-1, nil, true)
  end, { description = "decrease the number of columns", group = "layout" }),
  awful.key({ modkey }, "space", function()
    awful.layout.inc(1)
  end, { description = "select next", group = "layout" }),
  -- awful.key({ modkey, "Shift" }, "space", function()
  -- 	awful.layout.inc(-1)
  -- end, { description = "select previous", group = "layout" }),

  awful.key({ modkey, "Control" }, "n", function()
    local c = awful.client.restore()
    -- Focus restored client
    if c then
      c:emit_signal("request::activate", "key.unminimize", { raise = true })
    end
  end, { description = "restore minimized", group = "client" }),

  -- Prompt
  awful.key({ "Control" }, "space", function()
    awful.spawn("rofi -show combi")
  end, { description = "start rofi application launcher", group = "launcher" }),
  -- awful.key({ modkey }, "r", function()
  -- 	awful.spawn("rofi -show combi")
  -- end),

  awful.key({ modkey }, "x", function()
    awful.prompt.run({
      prompt = " Run Lua code: ",
      textbox = awful.screen.focused().mypromptbox.widget,
      exe_callback = awful.util.eval,
      history_path = awful.util.get_cache_dir() .. "/history_eval",
    })
  end, { description = "lua execute prompt", group = "awesome" }),
  -- Menubar
  -- awful.key({ modkey }, "p", function()
  -- 	menubar.show()
  -- end, { description = "show the menubar", group = "launcher" })

  awful.key({}, "XF86AudioRaiseVolume", function(_)
    awful.spawn.easy_async_with_shell(
      'wpctl get-volume @DEFAULT_AUDIO_SINK@',
      function(stdout)
        if not stdout then
          return
        end
        awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0")
        -- TODO: fix this; this is called asynchronously, therefore, this guard
        -- may not work when this is invoked so many times in short time.
        if tonumber(string.match(stdout, '^Volume:%s*(%d+.%d+)')) * 100 < 100 then
          awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+")
        end
        show_volume()
      end
    )
  end, { description = "increase audio volume", group = "audio" }),

  awful.key({}, "XF86AudioLowerVolume", function(_)
    awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0")
    awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-")
    show_volume()
  end, { description = "decrease audio volume", group = "audio" }),

  awful.key({}, "XF86AudioMute", function(_)
    awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
    show_volume()
  end, { description = "toggle muting audio", group = "audio" }),

  -- awful.key(
  -- 	{},
  -- 	"XF86AudioMicMute",
  -- 	function(_)
  -- 		awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
  -- 	end,
  -- 	{ description = "toggle muting mike", group = "audio" }
  -- ),

  awful.key({}, "XF86MonBrightnessUp", function(_)
    awful.spawn("brightnessctl set 5%+")
  end, { description = "increase display light", group = "backlight" }),

  awful.key({}, "XF86MonBrightnessDown", function(_)
    awful.spawn("brightnessctl set 5%-")
  end, { description = "increase display light", group = "backlight" })
)

for _, key in ipairs({ "j", "l" }) do
  local tb = awful.key(
    { modkey },
    key,
    function() awful.client.focus.byidx(1) end,
    { description = "focus next by index", group = "client" }
  )
  globalkeys = gears.table.join(globalkeys, tb)
end

for _, key in ipairs({ "k", "h" }) do
  local tb = awful.key(
    { modkey },
    key,
    function() awful.client.focus.byidx(-1) end,
    { description = "focus previous by index", group = "client" }
  )
  globalkeys = gears.table.join(globalkeys, tb)
end

clientkeys = gears.table.join(
  awful.key({ modkey }, "f", function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
  end, { description = "toggle fullscreen", group = "client" }),
  awful.key({ modkey, "Shift" }, "c", function(c)
    c:kill()
  end, { description = "close", group = "client" }),
  -- awful.key(
  -- 	{ modkey, "Control" },
  -- 	"space",
  -- 	awful.client.floating.toggle,
  -- 	{ description = "toggle floating", group = "client" }
  -- ),
  awful.key({ modkey, "Control" }, "Return", function(c)
    c:swap(awful.client.getmaster())
  end, { description = "move to master", group = "client" }),
  awful.key({ modkey }, "o", function(c)
    c:move_to_screen()
  end, { description = "move to screen", group = "client" }),
  -- awful.key({ modkey }, "t", function(c)
  -- 	c.ontop = not c.ontop
  -- end, { description = "toggle keep on top", group = "client" }),
  awful.key({ modkey }, "n", function(c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
  end, { description = "minimize", group = "client" }),
  awful.key({ modkey }, "m", function(c)
    c.maximized = not c.maximized
    c:raise()
  end, { description = "(un)maximize", group = "client" }),
  awful.key({ modkey, "Control" }, "m", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
  end, { description = "(un)maximize vertically", group = "client" }),
  awful.key({ modkey, "Shift" }, "m", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
  end, { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = gears.table.join(
    globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9, function()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if not tag then
        tag = add_tag(tostring(i), {
          screen = screen,
          index = i,
          layout = awful.layout.layouts[1],
        })
      end
      tag:view_only()
    end, { description = "view tag #" .. i, group = "tag" }),
    -- Toggle tag display.
    -- awful.key({ modkey, "Control" }, "#" .. i + 9, function()
    --   local screen = awful.screen.focused()
    --   local tag = screen.tags[i]
    --   if tag then
    --     awful.tag.viewtoggle(tag)
    --   end
    -- end, { description = "toggle tag #" .. i, group = "tag" }),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if not tag then
          tag = add_tag(tostring(i), {
            screen = awful.screen.focused(),
            index = i,
            layout = awful.layout.layouts[1],
          })
        end
        client.focus:move_to_tag(tag)
        tag:view_only()
      end
    end, { description = "move focused client to tag #" .. i, group = "tag" })
    -- Toggle tag on focused client.
    -- awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
    --   if client.focus then
    --     local tag = client.focus.screen.tags[i]
    --     if tag then
    --       client.focus:toggle_tag(tag)
    --     end
    --   end
    -- end, { description = "toggle focused client on tag #" .. i, group = "tag" })
  )
end

clientbuttons = gears.table.join(
  awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
  end),
  awful.button({ modkey }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.move(c)
  end),
  awful.button({ modkey }, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.resize(c)
  end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    },
  },

  -- Workaround: Firefox opens a new wrong sized window when its maximized on
  -- startup.  In order to fix that, hook the new window creation by firefox
  -- and re-maximize the window.
  {
    rule = { class = "firefox" },
    properties = {},
    callback = function(c)
      if c.maximized == true then
        c.maximized = false
        c.maximized = true
      end
    end
  },

  -- Floating clients.
  {
    rule_any = {
      instance = {
        "DTA", -- Firefox addon DownThemAll.
        "copyq", -- Includes session name in class.
        "pinentry",
        "rofi",
      },
      class = {
        "Arandr",
        "Blueman-manager",
        "Gpick",
        "Kruler",
        "MessageWin", -- kalarm.
        "Sxiv",
        "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
        "Wpa_gui",
        "veromix",
        "xtightvncviewer",
      },

      -- Note that the name property shown in xprop might be set slightly after creation of the client
      -- and the name shown there might not match defined rules here.
      name = {
        "Event Tester", -- xev.
      },
      role = {
        "AlarmWindow", -- Thunderbird's calendar.
        "ConfigManager", -- Thunderbird's about:config.
        "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
      },
    },
    properties = { floating = true },
  },

  -- Add titlebars to normal clients and dialogs
  {
    rule_any = { type = { "normal", "dialog" } },
    properties = { titlebars_enabled = true },
  },

  -- Set Firefox to always map on the tag named "2" on screen 1.
  -- { rule = { class = "Firefox" },
  --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  -- if not awesome.startup then awful.client.setslave(c) end

  c.shape = gears.shape.rounded_rect

  if
    awesome.startup
    and not c.size_hints.user_position
    and not c.size_hints.program_position
  then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- buttons for the titlebar
  local size = {}
  size.titlebar = dpi(25)
  size.button = size.titlebar * 0.6
  size.spacer = size.button * 0.2

  local function create_circle_button(size, color, callback, overlay_drawer)
    local color_unfocused = "#777777"

    local overlay_mark = wibox.widget({
      widget = wibox.widget.base.make_widget,
      fit = function(_, _, width, height)
        return width, height
      end,
      draw = function(_, _, cr, width, height)
        overlay_drawer(cr, size, width, height)
      end,
    })
    overlay_mark:set_visible(false)

    local button = wibox.widget({
      {
        overlay_mark,
        widget = wibox.container.place,
        valign = "center",
        halign = "center",
        opacity = 0.5,
      },
      widget = wibox.container.background,
      bg = color,
      shape = gears.shape.circle,
      forced_width = size,
    })

    button:connect_signal("button::press", callback)

    container = wibox.widget({
      button,
      left = size / 2,
      -- right = size / 2,
      widget = wibox.container.margin,
    })

    local function update(is_focused)
      if is_focused then
        button.bg = color
      else
        button.bg = color_unfocused
      end
    end

    client.connect_signal("focus", function(cl)
      if cl == c then
        update(true)
      end
    end)
    client.connect_signal("unfocus", function(cl)
      if cl == c then
        update(false)
      end
    end)
    button:connect_signal("mouse::enter", function()
      overlay_mark:set_visible(true)
    end)
    button:connect_signal("mouse::leave", function()
      overlay_mark:set_visible(false)
    end)

    return container
  end

  local buttons = gears.table.join(
    awful.button({}, 1, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      awful.mouse.client.move(c)
    end),
    awful.button({}, 3, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      awful.mouse.client.resize(c)
    end)
  )

  local close_button = create_circle_button(
    size.button,
    "#fc474a",
    function(_, _, _, button)
      if button == 1 then
        c:kill()
      end
    end,
    function(cr, size, width, height)
      cr:set_source_rgb(0, 0, 0)
      cr:set_line_width(2)

      local weight = math.sqrt(2) * 0.5 * 0.65
      local topleft = {
        x = (width - size * weight) * 0.5 * 1.05,
        y = (height - size * weight) * 0.5 * 1.05,
      }
      local bottomright = {
        x = topleft.x + size * weight,
        y = topleft.y + size * weight,
      }
      cr:move_to(topleft.x, topleft.y)
      cr:line_to(bottomright.x, bottomright.y)

      cr:stroke()

      cr:move_to(topleft.x, bottomright.y)
      cr:line_to(bottomright.x, topleft.y)
      cr:stroke()
    end
  )

  --[[
	local minimize_button = create_circle_button(
		size.button,
		"#fdb136",
		function(_, _, _, button)
			if button == 1 then
				c.minimized = not c.minimized
			end
		end,
		function(cr, size, width, height)
			cr:set_source_rgb(0, 0, 0)
			cr:set_line_width(2)

			local x = (width - size * 0.6) * 0.5
			local y = height * 0.5
			cr:move_to(x, y)
			cr:line_to(width - x, y)
			cr:stroke()
		end
	)
]]

  local maximize_button = create_circle_button(
    size.button,
    "#19c43d",
    function(_, _, _, button)
      if button == 1 then
        c.maximized = not c.maximized
      end
    end,
    function(cr, size, width, height)
      local function draw_triangle(a, b, c)
        cr:move_to(a.x, a.y)
        cr:line_to(b.x, b.y)
        cr:line_to(c.x, c.y)
        cr:line_to(a.x, a.y)
        cr:fill()
      end
      cr:set_source_rgb(0, 0, 0)

      local weight = math.sqrt(2) * 0.5 * 0.65
      local topleft = {
        x = (width - size * weight) * 0.5 * 0.97,
        y = (height - size * weight) * 0.5 * 0.97,
      }
      local bottomright = {
        x = width - topleft.x,
        y = height - topleft.y,
      }

      local triangle_size = size * 0.41
      draw_triangle(
        topleft,
        { x = topleft.x + triangle_size, y = topleft.y },
        { x = topleft.x, y = topleft.y + triangle_size }
      )
      draw_triangle(
        bottomright,
        { x = bottomright.x - triangle_size, y = bottomright.y },
        { x = bottomright.x, y = bottomright.y - triangle_size }
      )
    end
  )

  local spacer = wibox.container.margin(nil, size.spacer, size.spacer, 0, 0)

  awful.titlebar(c, { size = size.titlebar }):setup({
    { -- Left
      -- spacer,
      close_button,
      -- minimize_button,
      maximize_button,
      spacer,
      awful.titlebar.widget.iconwidget(c),
      -- awful.titlebar.widget.ontopbutton(c),
      -- awful.titlebar.widget.stickybutton(c),
      -- awful.titlebar.widget.floatingbutton(c),

      layout = wibox.layout.fixed.horizontal(),
    },
    { -- Middle
      { -- Title
        align = "center",
        widget = awful.titlebar.widget.titlewidget(c),
      },
      buttons = buttons,
      layout = wibox.layout.flex.horizontal,
    },
    { -- Right
      -- awful.titlebar.widget.iconwidget(c),
      -- buttons = buttons,
      layout = wibox.layout.fixed.horizontal,
    },
    layout = wibox.layout.align.horizontal,
  })
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
  c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
end)
-- }}}
