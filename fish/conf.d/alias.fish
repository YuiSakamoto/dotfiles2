alias d='docker'
alias gcl='gcloud'
alias less='less -r'

# kubernetes
alias k='kubectl'
alias kg="kubectl get"
alias kd="kubectl describe"
alias kcx='kubectx'

# nvim
alias vi='nvim'
alias v='vi'

# tmux
alias tm='tmux'
alias tma='tmux attach'
alias tma0='tmux attach -t 0'
alias tma1='tmux attach -t 1'
alias tma2='tmux attach -t 2'
alias tml='tmux list-sessions'
alias tpt='tmux_pane_title'

# git
alias g='git'
alias gi='git'
alias gs='git status -s -b'
alias gst='git status -s -b'
alias gc='git commit'
alias gci='git commit -a'
alias gd='git diff'

# Docker
alias d='docker'
alias dc='docker-compose'

# du/df
alias du="du -h"
alias df="df -h"
alias duh="du -h ./ --max-depth=1"

# terraform
alias tf="terraform"

# claude
alias cl='claude'

# モダンCLI (未導入なら素の ls 等のまま)
if type -q eza
    alias ls='eza --icons'
    alias ll='eza -l --icons --git'
    alias la='eza -la --icons --git'
    alias lt='eza --tree --icons --level=2'
end
if type -q lazygit
    alias lg='lazygit'
end
