#!/bin/bash

DOT_FILES=( .gitconfig .gitignore .tmux.conf)

for file in ${DOT_FILES[@]}
do
    ln -s $(cd $(dirname $0);pwd)/$file $HOME/$file
done

DOT_FILES_TO_CONFIG_DIR=( fish nvim karabiner)

if [[ ! -d ~/.config ]]; then
  mkdir ~/.config
fi

for file in ${DOT_FILES_TO_CONFIG_DIR[@]}
do
    ln -s $(cd $(dirname $0);pwd)/$file $HOME/.config/$file
done
