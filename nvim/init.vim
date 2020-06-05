set number                      "行番号を表示
set autoindent                  "改行時に自動でインデントする
set tabstop=2                   "タブを何文字の空白に変換するか
set shiftwidth=2                "自動インデント時に入力する空白の数
set expandtab                   "タブ入力を空白に変換
set clipboard=unnamed           "yank した文字列をクリップボードにコピー
set hls                         "検索した文字をハイライトする
set termguicolors               "TrueColor対応"
set list listchars=tab:\▸\-     " 不可視文字を可視化(タブが「▸-」と表示される)
set whichwrap=b,s,h,l,<,>,[,],~ " カーソルの左右移動で行末から次の行の行頭への移動が可能になる
set cursorline                  " カーソルラインをハイライト"

" Swap : and ; when normal mode
nnoremap ; :
nnoremap : ;

"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" プラグインが実際にインストールされるディレクトリ
let s:dein_dir = expand('~/.cache/dein')
" dein.vim 本体
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
" dein.vim がなければ github から落としてくる
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

" Required:
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  call dein#load_toml('~/.config/nvim/dein.toml', {'lazy': 0})
  call dein#load_toml('~/.config/nvim/dein_lazy.toml', {'lazy': 1})

  " Let dein manage dein
  " Required:
  call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here like this:
  "call dein#add('Shougo/neosnippet.vim')
  "call dein#add('Shougo/neosnippet-snippets')

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------

autocmd VimEnter * NERDTree "Open nerdtree automatically
autocmd BufWritePre * :%s/\s\+$//e "Delete space in the end of line
let g:airline_theme='powerlineish'  " airline_themeの設定
let g:indentLine_char = '¦'         " display indent line
let g:terraform_fmt_on_save = 1     " checking terraform format when save
