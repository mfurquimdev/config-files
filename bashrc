# System-wide .bashrc file for interactive bash(1) shells.
if [ -z "$PS1" ]; then
   return
fi

# Make bash check its window size after a process completes
shopt -s histappend
shopt -s checkwinsize
bind 'set show-all-if-ambiguous off'
bind 'set completion-ignore-case on'

[ -r "/etc/bashrc_$TERM_PROGRAM" ] && . "/etc/bashrc_$TERM_PROGRAM"


alias j="vim ~/Documents/journal/\"\$(date '+Week %W-%Y').md\""

alias gl='git log --oneline'
alias ga='git add'
alias gs='git status'
alias gc='git commit'
alias gd='git diff'
alias gp='git push'
alias gk='git checkout'
alias gb='git branch'

alias drm='docker ps -aq | xargs docker stop | xargs docker rm'

alias mv='mv -v'
alias rm='rm -v'
alias cp='cp -v'

alias ls='lsd -F --icon never --color always --group-dirs first'
alias l='lsd -F --icon never --color always --group-dirs first -lht'
alias tree='tree -FC'
alias grep='grep --colour'

function sg() {
  email=$(git config --global user.email)
  if [ "$email" == "furquim.axs@gmail.com" ]; then
    echo "C1299428 Mateus Medeiros Furquim Mendonca"
    echo "c1299428@interno.bb.com.br"
    git config --global user.name "C1299428 Mateus Medeiros Furquim Mendonca"
    git config --global user.email "c1299428@interno.bb.com.br"
  else
    echo "Mateus Furquim"
    echo "furquim.axs@gmail.com"
    git config --global user.name "Mateus Furquim"
    git config --global user.email "furquim.axs@gmail.com"
  fi
}


function p() {

  for f in *; do
    if [ -f "$f" ]; then
      echo -e "\033[38;1;32m$f\033[38;1;0m";
      cat "$f";
      echo "";
    fi;
  done;
}

function t() {
    echo -e "\033[0;1;34m"$(basename $(pwd))"\033[0;1;0m";
    printf '\xe2\x94\x94 ';
    ls $(pwd)
    for d in *; do
        if [ -d "$d" ]; then
            if [ ! -z "$(ls -A $d)" ]; then
                echo -e "  \033[0;1;31m$(basename $(pwd))/$d\033[0;1;0m"
                printf '  \xe2\x94\x94 ';
                ls "$d";
                for dd in $d/*; do
                    if [ -d "$dd" ]; then
                        if [ ! -z "$(ls -A $dd)" ]; then
                            echo -e "    \033[0;1;35m/$dd\033[0;1;0m"
                            printf '    \xe2\x94\x94 ';
                            ls "$dd";
                        fi;
                    fi;
                done;
            fi;
        fi;
    done;
}

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
# export HISTCONTROL=ignoredups
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
export HISTCONTROL=erasedups


trap 'tput sgr0' DEBUG

ESC=$(printf "\e")
F_RED="$ESC[38;5;1m"
F_GREEN="$ESC[38;5;2m"

err=0
err_color=$F_GREEN

function parse_git_branch() {
   git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

PS1=''

function prompt_right() {
   echo -e "\033[38;5;8m$(date '+%a, %b %d - %H:%M:%S')\033[0m"
}

function prompt_left() {
#   if [[ $err -eq 0 ]]; then
#       printf '\xE2\x9c\x93 '
#   else
#       printf '\xE2\x9C\x97 '
#   fi
   echo -e "\u\033[0;1;37m@\033[0;1;37m\h\033[38;5;7m\033[72;1;34m [\$(basename \$(dirname \$(pwd)))/\$(basename \$(pwd))]\033[38;5;3m$(parse_git_branch)\033[0;1;0m"
#   echo -e "\033[38;5;7m\033[72;1;34m[\w]\033[38;5;3m$(parse_git_branch) $err_color"
}

function prompt() {
   if [[ $? == 0 ]]; then
      err=0
      err_color=$F_GREEN
   else
      err=1
      err_color=$F_RED
   fi
   compensate=12
   PS1=$(printf "%*s\r%s\n\$ " "$(($(tput cols)+${compensate}))" "$(prompt_right)" "$(echo -n $err_color)$(prompt_left)")
   # Force prompt to write history after every command.
   # http://superuser.com/questions/20900/bash-history-loss
   history -a; history -c; history -r
}

PROMPT_COMMAND=prompt

#proxy="http://localhost:3128"
#proxy="http://localhost:40080"
proxy="http://c1299428:14183947@localhost:40080"

git_proxy() {
    var="$1"
    if [ "$var" = true ]; then
        git config --global http.proxy "$proxy"
        git config --global https.proxy "$proxy"
    else
        git config --global http.proxy ""
        git config --global https.proxy ""
    fi
    echo "git http.proxy=$(git config --global --get http.proxy)"
    echo "git https.proxy=$(git config --global --get https.proxy)"
}

proxy() {
    var=$1
    if [ "$var" = true ]; then
        export http_proxy="$proxy"
        export https_proxy="$proxy"
        export all_proxy="$proxy"
        export no_proxy="*.local, 169.254/16, *.bb.com.br, *.labbs.com.br, *.bancodobrasil.com.br"
    else
        unset http_proxy
        unset https_proxy
        unset all_proxy
        unset no_proxy
    fi
    echo -e "\$http_proxy="$http_proxy
    echo -e "\$https_proxy="$https_proxy
    echo -e "\$all_proxy="$all_proxy
    echo -e "\$no_proxy="$no_proxy
}

all_proxies() {
    git_proxy "$1"
    proxy "$1"
    echo -n ""
}

bb() {
    all_proxies true
    /usr/sbin/scselect "BB"
}

au() {
    all_proxies false
    /usr/sbin/scselect "Automatic"
}
