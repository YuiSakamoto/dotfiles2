# fish 全体設定
# プロンプト(starship)・履歴(atuin)・ジャンプ(zoxide)の初期化は tools.fish 参照

# ghq リポジトリ選択 (Ctrl+G) のセレクタ
set -gx GHQ_SELECTOR fzf

# secrets は ~/.config/fish/conf.d/secrets.fish に置く (git 追跡外)

# Claude Code Hooks: Obsidian保存先
set -gx CLAUDE_OBSIDIAN_VAULT "$HOME/src/github.com/YuiSakamoto/obsidian/private/Claude Code"
