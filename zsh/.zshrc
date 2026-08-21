# dotfiles2 .zshrc
#
# 対話シェルの入口。実体は conf.d/*.zsh に分割してあり、ここは番号順に
# source するだけに留める (fish の conf.d と同じ構成)。
#
# 読み込み順には意味がある:
#   00 基本オプション → 10 補完(compinit) → 20 プラグイン(sheldon)
#   → 30 ツール init → 40 キーバインド → 50 alias
# 特に fzf-tab は compinit の後でないと機能しないため 10 → 20 の順は動かせない。
#
# 起動プロファイルを見たいとき: ZSH_PROFILE=1 zsh -i -c exit

if [[ -n "${ZSH_PROFILE:-}" ]]; then
  zmodload zsh/zprof
fi

for _conf in "${ZDOTDIR:-$HOME/.config/zsh}"/conf.d/*.zsh(N); do
  source "$_conf"
done
unset _conf

if [[ -n "${ZSH_PROFILE:-}" ]]; then
  zprof
fi
