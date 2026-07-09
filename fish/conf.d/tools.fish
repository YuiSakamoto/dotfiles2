# モダンCLIツールの初期化
# いずれも未導入環境ではスキップされる (エラーにしない)

# starship: プロンプト
if type -q starship
    starship init fish | source
end

# atuin: Ctrl+R 履歴検索 (上矢印の挙動は変えない)
if type -q atuin
    atuin init fish --disable-up-arrow | source
end

# zoxide: ディレクトリジャンプ (z コマンド)
if type -q zoxide
    zoxide init fish | source
end
