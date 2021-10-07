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
        bright = {'#666666', '#ff3334', '#9ec400', '#e7c547', '#7aa6da', '#b77ee0', '#54ced6', '#ffffff'}
    },

    disable_default_key_bindings = true,
}