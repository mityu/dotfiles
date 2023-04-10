local wezterm = require('wezterm');

local isWindows = string.find(wezterm.target_triple, 'windows', 0, 1)
local isMac = string.find(wezterm.target_triple, 'apple-darwin', 0, 1)

local colors = {
    background = '#1f1f1f',
    foreground = '#eaeaea',

    selection_bg = '#666666',

    cursor_fg = '#1f1f1f',
    cursor_bg = '#fff8dc',
    cursor_border = '#fff8dc',

    ansi = {'#000000', '#d54e53', '#b9ca4a', '#e6c547', '#7aa6da', '#c397d8', '#70c0ba', '#eaeaea'},
    brights = {'#666666', '#ff3334', '#9ec400', '#e7c547', '#7aa6da', '#b77ee0', '#54ced6', '#ffffff'}
}

wezterm.on("update-right-status", function(window, pane)
  local bat = ""
  local bat_color = colors.foreground
  for _, b in ipairs(wezterm.battery_info()) do
    if b.state_of_charge == 0 then
        bat = ''
    elseif b.state_of_charge <= 0.2 then
        bat = ''
    elseif b.state_of_charge <= 0.5 then
        bat = ''
    elseif b.state_of_charge <= 0.8 then
        bat = ''
    else
        bat = ''
    end
    bat = bat .. '  ' .. string.format("%0.f%%", b.state_of_charge * 100)

    if b.state == "Charging" then
        bat_color = "Green"
    elseif b.state_of_charge <= 0.3 then
        bat_color = "Red"
    end
  end

  window:set_right_status(wezterm.format({
      {Foreground = {Color = bat_color}},
      {Text = bat},
      {Foreground = {Color = colors.foreground}},
      {Text = "  " .. wezterm.strftime("%b %-d (%a) %H:%M ")}
  }));
end)

local MODKEY = 'SUPER'
if isWindows then
  MODKEY = 'ALT'
end

local config = {
    use_fancy_tab_bar = false,
    show_update_window = false,
    adjust_window_size_when_changing_font_size = false,
    exit_behavior = "Close",
    font = wezterm.font('Cica'),
    font_size = 14,
    colors = colors,

    disable_default_key_bindings = true,
    leader = {key = 'p', mods = MODKEY},
    keys = {
        {key = 't', mods = MODKEY, action = wezterm.action{SpawnTab="CurrentPaneDomain"}},
        {key = 'n', mods = MODKEY, action = "SpawnWindow"},
        {key = 'w', mods = MODKEY, action = wezterm.action{CloseCurrentTab={confirm=true}}},
        {key = 'Tab', mods = 'CTRL', action = wezterm.action{ActivateTabRelative = 1}},
        {key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action{ActivateTabRelative = -1}},
        {key = 'f', mods = MODKEY, action = wezterm.action{Search = {CaseInSensitiveString = ''}}},
        {key = 'v', mods = MODKEY, action = wezterm.action{PasteFrom = "Clipboard"}},
        {key = 'c', mods = MODKEY, action = wezterm.action{CopyTo = "Clipboard"}},
        -- {key = 'c', mods = MODKEY, action = wezterm.action{CompleteSelection = "Clipboard"}},
        {key = 's', mods = 'LEADER', action = wezterm.action{SplitHorizontal = {domain = "CurrentPaneDomain"}}},
        {key = 'v', mods = 'LEADER', action = wezterm.action{SplitVertical = {domain = "CurrentPaneDomain"}}},
        {key = 'q', mods = 'LEADER', action = wezterm.action{CloseCurrentPane={confirm=true}}},
        {key = 'h', mods = 'LEADER', action = wezterm.action{ActivatePaneDirection = "Left"}},
        {key = 'j', mods = 'LEADER', action = wezterm.action{ActivatePaneDirection = "Down"}},
        {key = 'k', mods = 'LEADER', action = wezterm.action{ActivatePaneDirection = "Up"}},
        {key = 'l', mods = 'LEADER', action = wezterm.action{ActivatePaneDirection = "Right"}},
        {key = 'H', mods = 'LEADER', action = wezterm.action{AdjustPaneSize = {"Left", 1}}},
        {key = 'J', mods = 'LEADER', action = wezterm.action{AdjustPaneSize = {"Down", 1}}},
        {key = 'K', mods = 'LEADER', action = wezterm.action{AdjustPaneSize = {"Up", 1}}},
        {key = 'L', mods = 'LEADER', action = wezterm.action{AdjustPaneSize = {"Right", 1}}},
        {key = 'Escape', mods = 'LEADER', action = "Nop"},

        {key = 'x', mods = MODKEY, action = "ActivateCopyMode"},
        {key = 'z', mods = MODKEY, action = "TogglePaneZoomState"},
        {key = 'q', mods = 'CTRL', action = wezterm.action{SendString = '\x11'}},
    },
    window_padding = {
      top = 0,
      bottom = 0,
      right = 0,
      left = 0
    }
}

if isWindows then
    config.font_size = 13
    config.initial_cols = 170
    config.initial_rows = 40
    config.default_prog = {'cmd.exe', '/k', '%USERPROFILE%\\dotfiles\\batfiles\\setenv.bat'}
elseif isMac then
    config.initial_cols = 206
    config.initial_rows = 58
end

return config
