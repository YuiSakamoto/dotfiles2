local wezterm = require 'wezterm';

return {
  -- font = wezterm.font 'Fira Code',
  -- You can specify some parameters to influence the font selection;
  -- for example, this selects a Bold, Italic font variant.
  font = wezterm.font("JetBrains Mono", {weight = 'Bold'}),

  use_ime = true, -- wezは日本人じゃないのでこれがないとIME動かない
  font_size = 15.0,
  color_scheme = "Orangish (terminal.sexy)", -- 自分の好きなテーマ探す https://wezfurlong.org/wezterm/colorschemes/index.html
  hide_tab_bar_if_only_one_tab = true,
  adjust_window_size_when_changing_font_size = false,
  window_background_opacity = 0.8,
  text_background_opacity = 0.4,
  window_background_image = '/Users/yui_tang/Downloads/1500x500.jpeg',
  window_background_image_hsb = {
    -- Darken the background image by reducing it to 1/3rd
    brightness = 0.3,

    -- You can adjust the hue by scaling its value.
    -- a multiplier of 1.0 leaves the value unchanged.
    hue = 1.0,

    -- You can adjust the saturation also.
    saturation = 1.0,
  }
}

