#!/bin/bash

DOT_FILES=(.gitconfig .gitignore .tmux.conf)

for file in ${DOT_FILES[@]}; do
  ln -s $(
    cd $(dirname $0) || exit
    pwd
  )/$file $HOME/$file
done

DOT_FILES_TO_CONFIG_DIR=(fish nvim karabiner wezterm starship.toml)

if [[ ! -d ~/.config ]]; then
  mkdir ~/.config
fi

for file in ${DOT_FILES_TO_CONFIG_DIR[@]}; do
  ln -s $(
    cd $(dirname $0) || exit
    pwd
  )/$file $HOME/.config/$file
done

BIN_FILES=(ssm)

for file in ${BIN_FILES[@]}; do
  sudo ln -s $(
    cd $(dirname $0) || exit
    pwd
  )/bin/$file /usr/local/bin/$file
  chmod 755 /usr/local/bin/$file
done
