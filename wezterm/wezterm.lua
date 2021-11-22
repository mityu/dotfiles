local wezterm = require('wezterm');

local font_size
if wezterm.target_triple == 'x86_64-apple-darwin' then
    font_size = 14  -- TODO: Specify good size
else
    font_size = 14
end

return {
    font = wezterm.font('Cica'),
    font_size = font_size,
    colors = {
        background = '#1f1f1f',
        foreground = '#eaeaea',

        selection_bg = '#666666',

        cursor_fg = '#1f1f1f',
        cursor_bg = '#fff8dc',
        cursor_border = '#fff8dc',

        ansi = {'#000000', '#d54e53', '#b9ca4a', '#e6c547', '#7aa6da', '#c397d8', '#70c0ba', '#eaeaea'},
        brights = {'#666666', '#ff3334', '#9ec400', '#e7c547', '#7aa6da', '#b77ee0', '#54ced6', '#ffffff'}
    },

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
