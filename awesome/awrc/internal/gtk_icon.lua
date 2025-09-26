-- A internal module for loading GTK icons

local gears = require("gears")
local lgi = require("lgi")
local cairo = lgi.cairo
local rsvg = lgi.Rsvg
local gtk = lgi.Gtk
local theme = gtk.IconTheme.get_default()

local function get_icon_path(name)
  local info = theme:lookup_icon(name, 64, { gtk.IconLookupFlags.LOOKUP_FORCE_SVG })
  if not info then
    return nil
  end
  return info:get_filename()
end

local function get_resized_icon_surface(path, width)
  local svg = rsvg.Handle.new_from_file(path)

  local size = svg:get_dimensions()
  local scale = width / size.width
  local height = size.height * scale

  local surface = cairo.ImageSurface(cairo.Format.ARGB32, width, height)
  local cr = cairo.Context(surface)
  cr:set_antialias(cairo.Antialias.BEST)
  cr:scale(scale, scale)
  svg:render_cairo(cr)

  return surface
end

local function load(name, options)
  local options = options or {}

  local path = get_icon_path(name)
  if not path then
    return nil
  end

  local icon = options.width ~= nil and get_resized_icon_surface(path, options.width)
    or gears.surface.load(path)

  if options.color ~= nil then
    icon = gears.color.recolor_image(icon, options.color)
  end
  return icon
end

return {
  load = load,
}
