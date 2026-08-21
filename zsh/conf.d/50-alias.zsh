# alias 定義。fish/conf.d/alias.fish から移植。

# --- ls (eza) ---
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --git'
  alias ll='eza -l --icons --git'
  alias la='eza -la --icons --git'
  alias lt='eza --tree --level=2 --icons'
fi

# --- editor ---
alias vi='nvim'
alias v='nvim'

# --- git ---
alias g='git'
alias gi='git'
alias gs='git status -s -b'
alias gst='git status -s -b'
alias gc='git commit'
alias gci='git commit -a'
alias gd='git diff'

# --- container ---
alias d='docker'
# Docker Desktop には v1 の docker-compose バイナリが同梱されないため v2 を使う
alias dc='docker compose'

# --- kubernetes ---
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kcx='kubectx'

# --- cloud / infra ---
alias gcl='gcloud'
alias tf='terraform'

# --- tmux ---
alias tm='tmux'
alias tma='tmux attach'
alias tma0='tmux attach -t 0'
alias tma1='tmux attach -t 1'
alias tma2='tmux attach -t 2'
alias tml='tmux list-sessions'
alias tpt='tmux_pane_title'

# --- misc ---
alias less='less -r'
alias du='du -h'
alias df='df -h'
# --max-depth は GNU 拡張。macOS の BSD du では動かないので -d を使う
alias duh='du -h -d 1 ./'
alias ij='open -b com.jetbrains.intellij'
alias cl='claude'
