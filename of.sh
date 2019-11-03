#!/bin/bash

#if [ $# != 1 ];
#then
#    echo "Usage: $0 \"Author Name\"";
#    exit 1;
#fi;

remote=$(git remote get-url origin)
#remote=$(git remote -v | cut -f 2 | cut -f 1-4 -d "." | cut -f 1 -d '(' | cut -f 1 -d ' ' | head -1)
for c in $(git log --oneline --author=".*Mateus.*" --since="9 days ago" | cut -f1 -d " ");
do
    i=0;
#    echo -e "\n\n################################################################################"
#    git log -n 1 --pretty="format:[%cD] %C(yellow)%s%Creset%n%b" "$c"
#    echo -e "################################################################################\n"
#    echo "Files:"
    for a in $(git diff-tree --no-commit-id --numstat -r "$c");
    do
        case "$i" in
            "0") i=1;;
#            "0") echo -en "(\033[38;1;32m+"; printf "%-3s" $a; echo -en "\033[38;1;0m,";i=1;;
            "1") i=2;;
#            "1") echo -en "\033[38;1;31m-"; printf "%-3s" $a; echo -en "\033[38;1;0m)";i=2;;
            "2") echo -e "$remote/blob/$c/$a";i=0;;
#            "2") echo -e " \033[4;1;22m$remote/blob/$c/$a\033[38;1;0m";i=0;;
        esac
    done;
done;
