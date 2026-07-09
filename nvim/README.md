# nvim

LazyVim ベースの Neovim 設定 (2026-07 に dein.vim + init.vim から移行)。

- プラグイン管理: lazy.nvim (初回起動時に自動ブートストラップ)
- ベース: [LazyVim](https://www.lazyvim.org/) — LSP / Treesitter / telescope / gitsigns / which-key 同梱
- 旧設定からの移植: tabstop=2, `;`↔`:` スワップ, listchars, whichwrap (lua/config/ 参照)
- WSL: クリップボード連携には win32yank.exe が必要 (install/common-post.sh が導入)

## 初回セットアップ

nvim を起動するだけ。lazy.nvim が自動導入され、プラグインが同期される。
`:LazyHealth` で状態確認。
