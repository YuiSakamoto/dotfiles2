-- 旧 init.vim からの移植 + LazyVim デフォルトの上書き
-- LazyVim デフォルトで既に有効なもの: number, cursorline, expandtab,
-- shiftwidth=2, tabstop=2, termguicolors, clipboard=unnamedplus, hlsearch

local opt = vim.opt

-- 旧設定では相対行番号を使っていなかったので無効化 (LazyVim は有効がデフォルト)
opt.relativenumber = false

-- 不可視文字の可視化 (タブを「▸-」で表示)
opt.list = true
opt.listchars = { tab = "▸-" }

-- カーソルの左右移動で行を跨げるようにする
opt.whichwrap = "b,s,h,l,<,>,[,],~"
