local wezterm = require('wezterm');

local font_size
if wezterm.target_triple == 'x86_64-apple-darwin' then
    font_size = 14  -- TODO: Specify good size
else
    font_size = 14
end

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

return {
    show_update_window = false,
    adjust_window_size_when_changing_font_size = false,
    exit_behavior = "Close",
    font = wezterm.font('Cica'),
    font_size = font_size,
    colors = colors,

    disable_default_key_bindings = true,
    leader = {key = 'p', mods = 'SUPER'},
    keys = {
        {key = 't', mods = 'SUPER', action = wezterm.action{SpawnTab="CurrentPaneDomain"}},
        {key = 'w', mods = 'SUPER', action = wezterm.action{CloseCurrentTab={confirm=true}}},
        {key = 'Tab', mods = 'CTRL', action = wezterm.action{ActivateTabRelative = 1}},
        {key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action{ActivateTabRelative = -1}},
        {key = 'f', mods = 'SUPER', action = wezterm.action{Search = {CaseInSensitiveString = ''}}},
        {key = 'v', mods = 'SUPER', action = wezterm.action{PasteFrom = "Clipboard"}},
        {key = 'c', mods = 'SUPER', action = wezterm.action{CopyTo = "Clipboard"}},
        -- {key = 'c', mods = 'SUPER', action = wezterm.action{CompleteSelection = "Clipboard"}},
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

        {key = 'x', mods = 'SUPER', action = "ActivateCopyMode"},
        {key = 'z', mods = 'SUPER', action = "TogglePaneZoomState"},
    }
}
