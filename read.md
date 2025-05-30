# Configure .zshrc
cat > ~/.zshrc << 'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    extract
    docker
    colored-man-pages
    command-not-found
    history
    cp
)

source $ZSH/oh-my-zsh.sh

# 实用的别名配置
alias ll='ls -lh'
alias la='ls -lah'
alias l='ls -CF'
alias pc='proxychains4'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias md='mkdir -p'
alias rd='rmdir'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# 历史命令配置
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt HIST_REDUCE_BLANKS

# 补全配置
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' rehash true
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'

# 按键绑定
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^U' backward-kill-line
bindkey '^K' kill-line
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# 目录跳转配置
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# 开启命令纠错提示
setopt CORRECT
setopt CORRECT_ALL

# 设置默认编辑器
export EDITOR='vim'
export VISUAL='vim'

# 设置语言环境
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
