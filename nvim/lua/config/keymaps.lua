-- 旧 init.vim からの移植: ノーマルモードで ; と : を入れ替え
vim.keymap.set("n", ";", ":", { desc = "コマンドライン (: の入れ替え)" })
vim.keymap.set("n", ":", ";", { desc = "f/t の繰り返し (; の入れ替え)" })
