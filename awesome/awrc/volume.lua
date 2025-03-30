local dpi = require("beautiful.xresources").apply_dpi
local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")

local function get_icons(width)
  local lgi = require("lgi")
  local cairo = lgi.cairo
  local rsvg = lgi.Rsvg
  local gtk = lgi.Gtk
  local theme = gtk.IconTheme.get_default()

  local get_icon_surface = function(name, width)
    local flags = gtk.IconLookupFlags
    local info = theme:lookup_icon(name, 64, { flags.LOOKUP_FORCE_SVG })
    if not info then
      return nil
    end

    local svg = rsvg.Handle.new_from_file(info:get_filename())

    local size = svg:get_dimensions()
    local scale = width / size.width
    local height = size.height * scale

    local surface = cairo.ImageSurface(cairo.Format.ARGB32, width, height)
    local cr = cairo.Context(surface)
    cr:set_antialias(cairo.Antialias.BEST)
    cr:scale(scale, scale)
    svg:render_cairo(cr)

    -- Change icon color
    return gears.color.recolor_image(surface, "#444444")
  end

  local icons = {}
  for _, type in pairs({ "high", "medium", "low", "muted" }) do
    icons[type] = get_icon_surface(string.format("audio-volume-%s", type), width)
  end

  return icons
end

local function new_volume_panel()
  local icons = get_icons(dpi(80))
  local colors = {
    black = "#444444",
    white = "#ddd7cc",
  }

  local M = {}

  M._autolock = require("awrc.internal.autolock").new()

  M.run_if_free = function(self, fn)
    self._autolock:run_if_free(fn)
  end

  M.unlock = function(self)
    self._autolock:unlock()
  end

  M._bar = wibox.widget {
    max_value = 100,
    value = 0,
    border_width = dpi(1),
    forced_height = dpi(10),
    forced_width = dpi(180),
    shape = gears.shape.rounded_bar,
    bar_shape = gears.shape.rounded_bar,
    widget = wibox.widget.progressbar,
    color = colors.white,
    background_color = colors.black,
    border_color = colors.black,
  }

  M._text = wibox.widget {
    text = 'Volume: ?',
    font = beautiful.font,
    widget = wibox.widget.textbox,
  }

  M._icon = wibox.widget {
    image = icons.medium,
    resize = true,
    forced_width = dpi(100),
    forced_height = dpi(100),
    widget = wibox.widget.imagebox,
  }

  M._display = wibox.widget({
    {
      {
        {
          M._icon,
          valign = 'center',
          halign = 'center',
          widget = wibox.container.place,
        },
        {
          M._text,
          valign = 'center',
          halign = 'center',
          widget = wibox.container.place,
        },
        M._bar,
        layout = wibox.layout.fixed.vertical,
      },
      widget = wibox.container.place,
    },
    widget = wibox.container.background,
  })

  M._panel = awful.popup {
    bg = colors.white,
    fg = colors.black,
    border_width = dpi(10),
    border_color = colors.white,
    shape = gears.shape.rounded_rect,
    ontop = true,
    visible = false,
    type = 'popup_menu',
    opacity = 0.9,
    placement = awful.placement.centered,
    input_passthrough = true,
    widget = M._display,
  }

  M._timer = gears.timer {
    timeout = 2,
    autostart = false,
    single_shot = true,
    callback = function()
      M._panel.visible = false
    end,
  }

  M.set_volume = function(self, volume)
    self._bar.value = volume
    self._text.text = string.format('Volume: %d%%', volume)

    if volume == 0 then
      self._icon.image = icons.muted
    elseif volume < (100 / 3) then
      self._icon.image = icons.low
    elseif volume < (100 / 3 * 2) then
      self._icon.image = icons.medium
    else
      self._icon.image = icons.high
    end
  end

  M.set_mute = function(self, muted)
    self:set_volume(0)
    self._text.text = 'Volume: Muted'
  end

  M.show = function(self)
    local callback = function(stdout)
      if string.match(stdout, '%[MUTED]%s*$') then
        self:set_mute(true)
      else
        local volume = tonumber(string.match(stdout, '^Volume:%s*(%d+.%d+)')) * 100
        self:set_volume(volume)
      end

      local screen = awful.screen.focused()
      self._panel.screen = screen
      self._panel.visible = true
      self._timer:again()

      self:unlock()
    end

    awful.spawn.easy_async(
      'wpctl get-volume @DEFAULT_AUDIO_SINK@',
      callback
    )
  end

  return M
end

local volume_panel = new_volume_panel()

local function raise_volume()
  volume_panel:run_if_free(function()
    awful.spawn.easy_async(
      'wpctl get-volume @DEFAULT_AUDIO_SINK@',
      function(stdout)
        if not stdout then
          return
        end
        awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0")

        local volume = tonumber(string.match(stdout, '^Volume:%s*(%d+.%d+)'))
        if volume < 1.0 then
          local delta = math.min(1.0 - volume, 0.05)
          awful.spawn(string.format("wpctl set-volume @DEFAULT_AUDIO_SINK@ %f+", delta))
        end
        volume_panel:show()
      end
    )
  end)
end

local function lower_volume()
  volume_panel:run_if_free(function()
    awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0")
    awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-")
    volume_panel:show()
  end)
end

local function toggle_mute()
  volume_panel:run_if_free(function()
    awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
    volume_panel:show()
  end)
end

return {
  raise_volume = raise_volume,
  lower_volume = lower_volume,
  toggle_mute = toggle_mute,
}
