local awful = require("awful")
local gears = require("gears")

-- Make all of the corners of awesome-wm menus be rounded.
awful.menu.new = (function()
  local new = awful.menu.new
  return function(args, parent)
    local widget = new(args, parent)
    widget.wibox.shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, 5)
    end
    return widget
  end
end)()
