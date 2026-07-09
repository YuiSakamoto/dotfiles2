-- LazyVim デフォルトへの追加・上書き
return {
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
