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
}

