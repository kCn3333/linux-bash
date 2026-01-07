# ~/.bashrc 

# ─────────────────────────────────────
# interactive shell guard
# ─────────────────────────────────────
[[ $- != *i* ]] && return

# ─────────────────────────────────────
# history
# ─────────────────────────────────────
HISTCONTROL=ignoreboth
HISTSIZE=2000
HISTFILESIZE=4000
HISTTIMEFORMAT="%Y-%m-%d %T "
shopt -s histappend checkwinsize

# ─────────────────────────────────────
# colors & tools
# ─────────────────────────────────────
export CLICOLOR=1
export EDITOR=nvim

# ─────────────────────────────────────
# shell behavior
# ─────────────────────────────────────
set -o notify          # bg jobs report immediately
set -o noclobber       # > won't overwrite files
shopt -s cdspell       # small typos in cd
shopt -s autocd        # cd without 'cd'

# ─────────────────────────────────────
# less pager
# ─────────────────────────────────────
export LESS='-R --mouse'
export LESSHISTFILE=-

# ─────────────────────────────────────
# XDG base dirs
# ─────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# ─────────────────────────────────────
# ls / grep colors
# ─────────────────────────────────────
if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
    alias grep='grep --color=auto'
fi

# ─────────────────────────────────────
# modern ls (eza)
# ─────────────────────────────────────
if command -v eza >/dev/null 2>&1; then
    alias ls='eza -a --group-directories-first --icons --color=always'
    alias la='eza -al --group-directories-first --icons --color=always'
    alias lt='eza -T -a --group-directories-first --icons --color=always'
fi

# ─────────────────────────────────────
# aliases
# ─────────────────────────────────────
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias mkdir='mkdir -p'

# ─────────────────────────────────────
# completion
# ─────────────────────────────────────
if ! shopt -oq posix; then
  for f in /usr/share/bash-completion/bash_completion /etc/bash_completion; do
    [[ -r $f ]] && source "$f" && break
  done
fi

# ─────────────────────────────────────
# starship
# ─────────────────────────────────────
eval "$(starship init bash)"

# ─────────────────────────────────────
# local aliases
# ─────────────────────────────────────
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
