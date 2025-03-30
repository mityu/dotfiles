local wibox = require("wibox")
local gears = require("gears")

local function create_circle_button(size, current_client, color, callback, overlay_drawer)
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
    if cl == current_client then
      update(true)
    end
  end)
  client.connect_signal("unfocus", function(cl)
    if cl == current_client then
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

local function create_close_button(size, current_client)
  local callback = function(_, _, _, button)
    if button == 1 then
      current_client:kill()
    end
  end

  local overlay_drawer = function(cr, size, width, height)
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

  return create_circle_button(size.button, current_client, "#fc474a", callback, overlay_drawer)
end

--[[
  local minimize_button = create_circle_button(
    size.button,
    "#fdb136",
    function(_, _, _, button)
      if button == 1 then
        current_client.minimized = not current_client.minimized
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

local function create_maximize_button(size, current_client)
  local callback = function(_, _, _, button)
    if button == 1 then
      current_client.maximized = not current_client.maximized
    end
  end

  local overlay_drawer = function(cr, size, width, height)
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

  return create_circle_button(size.button, current_client, "#19c43d", callback, overlay_drawer)
end

local function create_spacer(size)
  return wibox.container.margin(nil, size.spacer, size.spacer, 0, 0)
end

return {
  create = function(size, current_client)
    return {
      spacer = create_spacer(size),
      maximize = create_maximize_button(size, current_client),
      close = create_close_button(size, current_client),
      -- minimize = create_minimize_button(size, current_client),
    }
  end,
}
