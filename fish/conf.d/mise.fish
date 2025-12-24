# mise activation for fish shell
# - interactive のときだけ初期化（git hook 等の非対話シェルを軽くする）
if status is-interactive
    if type -q mise
        mise activate fish | source
    end
end
