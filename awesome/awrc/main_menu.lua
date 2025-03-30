local awful = require("awful")

local function show_hotkey_help()
  require("awful.hotkeys_popup").show_help(nil, nil)
end

local function make_menu()
  local awesome_menu = {
    { "hotkeys", show_hotkey_help },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end, },
  }

  -- TODO: Add reboot, logout, lock, shutdown
  local system_menu = {}

  return awful.menu({
    items = {
      { "awesome", awesome_menu },
      { "wezterm", "wezterm" },
      { "firefox", "firefox" },
      { "system", system_menu },
    }
  })
end

return {
  make = make_menu
}
