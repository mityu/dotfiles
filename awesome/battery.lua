local awful = require("awful")
local wibox = require("wibox")

local function is_charging()
  local ok, lines = pcall(io.lines, "/sys/class/power_supply/BAT1/status")
  if ok then
    for line in lines do
      return line == "Charging"
    end
  else
    return false
  end
end

local function get_battery_icon(percentage)
  if percentage == 0 then
    return ""
  elseif percentage <= 20 then
    return ""
  elseif percentage <= 50 then
    return ""
  elseif percentage <= 80 then
    return ""
  else
    return ""
  end
end

local function get_battery_color(is_charging, percentage)
  if is_charging then
    return "#00ff00"
  elseif percentage <= 30 then
    return "#ff6000"
  else
    return nil
  end
end

local function widget()
  return awful.widget.watch(
    "cat /sys/class/power_supply/BAT1/capacity",
    1,
    function(widget, stdout, _, _, exitcode)
      if exitcode ~= 0 then
        widget:set_markup('<span color="#ff0000">Error</span>')
        return
      end

      local percentage = tonumber(stdout)
      local icon = get_battery_icon(percentage)
      local color = get_battery_color(is_charging(), percentage)
      local text = string.format("%s  %d%%", icon, percentage)
      if color == nil then
        widget:set_text(text)
      else
        widget:set_markup(string.format('<span color="%s">%s</span>', color, text))
      end
    end
  )
end

return {
  widget = widget,
}
