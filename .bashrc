# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Kolory
LBLUE='\033[38;5;110m'  # Błękitny
LGREEN='\033[38;5;120m' # Jasnozielony
YELLOW='\033[38;5;214m' # Pomarańczowy
CYAN='\033[38;5;117m'   # Cyjan
RESET='\033[0m'         # Reset kolorów


# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

#ssh agent
#eval "$(ssh-agent -s)"
#ssh-add ~/.ssh/id_rsa

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=4000
HISTTIMEFORMAT="%Y%m%d %T "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias sudo='sudo '
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias nmap="grc nmap"
alias cat="batcat"
alias la="eza -la --group-directories-first --icons --color-scale-mode=gradient --color=always"
alias ls="eza -a --group-directories-first --icons --color-scale-mode=gradient --color=always"
alias lt="eza -T -a --group-directories-first --icons --color-scale-mode=gradient --color=always" 

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

eval "$(starship init bash)"

alias i="sudo apt install"
alias pogoda="curl https://wttr.in/Krakow?0"
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 "
alias update="sudo nala update && sudo nala upgrade -y"
alias statuswatch="watch -c SYSTEMD_COLORS=1 systemctl status"
alias ekran="sudo systemctl restart gdm3"
alias camera="nohup /home/kcn/script/podglad_z_kamery/start_mpv.sh > output.log 2>&1 &"


apt() { 
  command nala "$@"
}
sudo() {
  if [ "$1" = "apt" ]; then
    shift
    command sudo nala "$@"
  else
    command sudo "$@"
  fi
}

#eval "$(fzf --bash)"

#============================================================================================
# 🔍 system info
UPTIME=$(uptime -p)
CPU_LOAD=$(awk -v cores=$(nproc) '{printf "%.1f%%", ($1 / cores) * 100}' /proc/loadavg)
MEMORY_TOTAL_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEMORY_AVAILABLE_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
MEMORY_TOTAL_GB=$(awk "BEGIN {printf \"%.2f\", $MEMORY_TOTAL_KB/1024/1024}")
MEMORY_AVAILABLE_GB=$(awk "BEGIN {printf \"%.2f\", $MEMORY_AVAILABLE_KB/1024/1024}")
MEMORY_USED_GB=$(awk "BEGIN {printf \"%.2f\", $MEMORY_TOTAL_GB - $MEMORY_AVAILABLE_GB}")
MEMORY_PERCENT=$(awk "BEGIN {printf \"%.0f%%\", ($MEMORY_USED_GB/$MEMORY_TOTAL_GB)*100}")
DISK_ROOT=$(df -h / | awk 'NR==2 {printf "%s / %s (%s)", $3, $2, $5}' | sed 's/G/GB/g')
DISK_BACKUP=$(df -h /media/kcn/backup | awk 'NR==2 {printf "%s / %s (%s)", $3, $2, $5}' | sed 's/G/GB/g')
DISK_ARCHIWUM=$(df -h /media/kcn/archiwum | awk 'NR==2 {printf "%s / %s (%s)", $3, $2, $5}' | sed 's/G/GB/g')
DISK_MEDIA=$(df -h /media/kcn/media | awk 'NR==2 {printf "%s / %s (%s)", $3, $2, $5}' | sed 's/G/GB/g')
CPU_TEMP=$(sensors | grep 'Package id 0:' | awk '{print $4}' 2>/dev/null)
LAST_UPDATE=$(grep -i "start-date" /var/log/apt/history.log* | tail -n 1 | awk '{print $2, $3, $4}')
USER_NAME=$(whoami | tr 'a-z' 'A-Z')


# 🔥 Check CPU temp sensor
if [ -z "$CPU_TEMP" ]; then
    CPU_TEMP="Brak danych"
fi

# 🌐 Get IP address
IP_ADDR=$(hostname -I | awk '{print $1}')

# 🚀 ASCII Banner
# echo "";
# echo "";
# echo ":::    ::: ::::::::  ::::    :::      ::::::::  :::::::::  :::     :::";
# echo ":+:   :+: :+:    :+: :+:+:   :+:     :+:    :+: :+:    :+: :+:     :+:";
# echo "+:+  +:+  +:+        :+:+:+  +:+     +:+        +:+    +:+ +:+     +:+";
# echo "+#++:++   +#+        +#+ +:+ +#+     +#++:++#++ +#++:++#:  +#+     +:+";
# echo "+#+  +#+  +#+        +#+  +#+#+#            +#+ +#+    +#+  +#+   +#+ ";
# echo "#+#   #+# #+#    #+# #+#   #+#+#     #+#    #+# #+#    #+#   #+#+#+#  ";
# echo "###    ### ########  ###    ####      ########  ###    ###     ###    ";
echo -e "${CYAN}"
echo -e "      Witaj na serwerze: ${GREEN}[ $USER_NAME ]${CYAN}"
echo -e "${RESET}"

# 📊 Show system info
echo -e "         ${LBLUE}📅 Uptime:        ${LGREEN}$UPTIME${RESET}"
echo -e "         ${LBLUE}🔄 Update:        ${LGREEN}${LAST_UPDATE:-Brak danych}${RESET}"
echo -e "         ${LBLUE}🚀 CPU:           ${LGREEN}$CPU_LOAD% ( ${CPU_TEMP})${RESET}"
echo -e "         ${LBLUE}💾 RAM:           ${LGREEN}${MEMORY_USED_GB}GB / ${MEMORY_TOTAL_GB}GB (${MEMORY_PERCENT})${RESET}"
echo -e "         ${LBLUE}📂 HDD /:         ${LGREEN}$DISK_ROOT${RESET}"
echo -e "                 📂 Backup:        ${LGREEN}$DISK_BACKUP${RESET}"
echo -e "                 📂 Archiwum:      ${LGREEN}$DISK_ARCHIWUM${RESET}"
echo -e "                 📂 Media:         ${LGREEN}$DISK_MEDIA${RESET}"
#echo -e "${LBLUE}🌐 Adres IP:      ${LGREEN}$IP_ADDR${RESET}"
echo ""

#echo ":: Serwer uptime: $(uptime -p)"
#=========================================================================================

# SSH agent
#if [ -z "$SSH_AUTH_SOCK" ]; then
#  eval $(ssh-agent -s)
#fi
