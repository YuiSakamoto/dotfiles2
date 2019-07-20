#!/bin/bash

DOT_FILES=( .gitconfig .gitignore .tmux.conf)

for file in ${DOT_FILES[@]}
do
    ln -s $HOME/dotfiles2/$file $HOME/$file
done
