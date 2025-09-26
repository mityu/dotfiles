local wezterm = require('wezterm');

local isWindows = string.find(wezterm.target_triple, 'windows', 0, 1)
local isMac = string.find(wezterm.target_triple, 'apple-darwin', 0, 1)
local isLinux = not (isWindows or isMac)

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

wezterm.on("gui-startup", function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

wezterm.on("update-right-status", function(window, pane)
  local bat = ""
  local bat_color = colors.foreground
  for _, b in ipairs(wezterm.battery_info()) do
    if b.state_of_charge == 0 then
      bat = wezterm.nerdfonts.fa_battery_empty
    elseif b.state_of_charge <= 0.2 then
      bat = wezterm.nerdfonts.fa_battery_quarter
    elseif b.state_of_charge <= 0.5 then
      bat = wezterm.nerdfonts.fa_battery_half
    elseif b.state_of_charge <= 0.8 then
      bat = wezterm.nerdfonts.fa_battery_three_quarters
    else
      bat = wezterm.nerdfonts.fa_battery_full
    end
    bat = bat .. '  ' .. string.format("%0.f%%", b.state_of_charge * 100)

    if b.state == "Charging" then
      bat_color = "#44dd44"
    elseif b.state_of_charge <= 0.2 then
      bat_color = "#ff6000"
    end
  end

  window:set_right_status(wezterm.format({
    {Foreground = {Color = bat_color}},
    {Text = bat},
    {Foreground = {Color = colors.foreground}},
    {Text = "  " .. wezterm.strftime("%b %-d (%a) %H:%M ")},
  }));
end)

local MODKEY = 'SUPER'
if isWindows then
  MODKEY = 'ALT'
end

local config = {
  front_end = 'WebGpu',
  use_fancy_tab_bar = false,
  adjust_window_size_when_changing_font_size = false,
  exit_behavior = "Close",
  font = wezterm.font_with_fallback({
    { family = 'Cica' },
    { family = 'Cica', assume_emoji_presentation = true },
    { family = 'HackGen Console NF', scale = 13 / 14 },
    { family = 'HackGen Console NF', scale = 13 / 14, assume_emoji_presentation = true },
  }),
  font_size = 14,
  colors = colors,
  macos_forward_to_ime_modifier_mask = "SHIFT|CTRL",

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
    {key = 's', mods = 'LEADER', action = wezterm.action{SplitVertical = {domain = "CurrentPaneDomain"}}},
    {key = 'v', mods = 'LEADER', action = wezterm.action{SplitHorizontal = {domain = "CurrentPaneDomain"}}},
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

    {key = '+', mods = MODKEY, action = wezterm.action.IncreaseFontSize},
    {key = '-', mods = MODKEY, action = wezterm.action.DecreaseFontSize},
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
  config.default_prog = {
    "C:/msys64/msys2_shell.cmd", "-mingw64",
    "-defterm", "-no-start", "-use-full-path"
  }
elseif isMac then
  config.default_prog = {
    "/usr/bin/env",
    ("PATH=%s/.nix-profile/bin:/opt/homebrew/bin"):format(wezterm.home_dir),
    "fish",
    "-l",
  }
  config.initial_cols = 110
  config.initial_rows = 35
elseif isLinux then
  config.initial_cols = 130
  config.initial_rows = 40
end

return config
