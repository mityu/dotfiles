local awful = require("awful")
local wibox = require("wibox")

local function to_GB(kb_size)
  return kb_size / (1024.0 * 1024.0)
end

local function get_meminfo(info_string)
  local meminfo = {
    total = nil,
    free = nil,
    available = nil,
  }
  for entry, size in string.gmatch(info_string, "([a-zA-Z()]+):%s*(%d+)%s+[kK][bB]") do
    local size_gb = to_GB(tonumber(size))
    if entry == "MemTotal" then
      meminfo.total = size_gb
    elseif entry == "MemFree" then
      meminfo.free = size_gb
    elseif entry == "MemAvailable" then
      meminfo.available = size_gb
    end
  end
  return meminfo
end

local function widget()
  return awful.widget.watch(
    "cat /proc/meminfo",
    3,
    function(widget, stdout, _, _, exitcode)
      if exitcode ~= 0 then
        widget:set_markup('<span color="#ff0000">Error</span>')
        return
      end
      widget:set_text("getting...")

      local meminfo = get_meminfo(stdout)
      widget:set_text(tostring(meminfo.total))
      meminfo.used = meminfo.total - meminfo.available
      widget:set_text(string.format("%.1fG/%.1fG", meminfo.used, meminfo.total))
    end
  )
end

return {
  widget = widget,
}
