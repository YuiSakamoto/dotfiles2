# 対話シェルを herdr に常駐させる（意識せず常に herdr の中にいる状態にする）。
# cmux 内でも herdr に入る。そのために cmux 側の Ctrl+T バインドは
# コメントアウト済み（cmux/cmux.json）で、Ctrl+T はペイン内の herdr が受ける。
# 番号が 05 なのは、herdr に入るケースで sheldon/atuin の init を待たせないため。
# herdr ペイン内で開かれる zsh は（下のガードで素通りして）通常どおり全 init を行う。
#
# exec ではなく通常起動にしている理由（変えると事故る）:
# - herdr が起動に失敗しても素の zsh にフォールバックする
#   （exec だと新しい端末がすべて即閉じし、復旧手段を失う）
# - デタッチ（prefix q）後もウィンドウが閉じず、残りの init が走った
#   素の zsh に戻ってくる
#
# ガード（消すと壊れる）:
# - -t 0/-t 1: TTY が無い「対話フラグ付き」起動（エディタや script の zsh -i 等）で
#   乗っ取らない
# - HERDR_PANE_ID / HERDR_ENV: herdr がペイン内シェルに立てる変数（実機で確認済み）。
#   無限ネスト防止の本丸。二重にしているのは片方が将来消えても保つため
# - TMUX / SSH_CONNECTION: tmux 内・SSH 先では従来どおり素の zsh
# - HERDR_AUTO=0: 一時的に素の zsh が欲しいときの脱出ハッチ（HERDR_AUTO=0 zsh）
#
# 増殖しない根拠: herdr は client-server 型で、この起動は「常駐セッションへの
# アタッチ1クライアント」にしかならない。複数ウィンドウから開くと同一セッションの
# ミラー表示になるだけで、シェルもエージェントも増えない（tmux の多重アタッチと同じ）。
if [[ -o interactive ]] && [[ -t 0 && -t 1 ]] \
  && (( $+commands[herdr] )) \
  && [[ -z $HERDR_PANE_ID && -z $HERDR_ENV && -z $TMUX && -z $SSH_CONNECTION ]] \
  && [[ ${HERDR_AUTO:-1} != 0 ]]; then
  herdr
  # ここに来るのは herdr を抜けたとき（デタッチ・終了・起動失敗）。
  # そのまま .zshrc の続きが走り、通常の zsh として使える。
fi
