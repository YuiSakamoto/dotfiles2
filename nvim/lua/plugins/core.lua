-- LazyVim デフォルトへの追加・上書き
return {
  -- 配色: ターミナル (ghostty/config) と揃える。
  -- nvim は truecolor で自前の色を出すため、端末の ANSI パレットは効かない。
  -- そこで on_colors で同じ置き換えを入れる。
  --
  -- 赤緑色覚特性では diff の赤(削除)と緑(追加)や、エラー(赤)と成功(緑)が
  -- 同系に潰れる。カラーユニバーサルデザインの考え方に従い
  --   赤 → 朱色 (vermillion, 橙寄り)   緑 → 青緑 (bluish green, teal)
  -- に置き換える。赤緑の識別が落ちても青-黄軸の差は保たれるため色相で分かれ、
  -- さらに明度も離してあるので色相が完全に潰れても明暗で区別できる。
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "storm",
      on_colors = function(c)
        c.bg = "#16171f"
        c.bg_dark = "#101119"
        c.fg = "#cbd5ee"
        c.comment = "#7480a5" -- 既定はコントラストが足りず読みづらい
        c.red = "#ff5f45"
        c.green = "#00d7a3"
        c.yellow = "#ffd75f"
        c.blue = "#4d9dff"
        c.magenta = "#ef8fc9"
        c.cyan = "#5fe3ff"
        c.orange = "#ff8a70"
        c.error = "#ff5f45"
        c.warning = "#ffd75f"
        c.info = "#4d9dff"
        c.hint = "#5fe3ff"
        -- gitsigns / diff view も同じ2色に寄せる
        c.git.add = "#00d7a3"
        c.git.change = "#ffd75f"
        c.git.delete = "#ff5f45"
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight-storm" },
  },

  -- Treesitter: 普段使う言語を最初から入れておく
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash", "fish", "lua", "vim",
        "typescript", "tsx", "javascript", "json",
        "go", "python", "rust",
        "yaml", "toml", "markdown", "markdown_inline",
        "dockerfile", "terraform", "hcl",
      },
    },
  },
}
