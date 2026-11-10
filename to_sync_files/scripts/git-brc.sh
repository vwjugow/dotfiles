#!/bin/bash
# git brc [regex]: check out a local branch.
# With regex: check out the most recently committed branch matching it (case-insensitive).
# Without: list branches by commit date and ask for a number.
# Branches named release_NNNN_* are never listed or matched.
branches=$(git for-each-ref --sort=-committerdate refs/heads/ \
    --format='%(refname:short)|%(committerdate:relative)|%(authorname)|%(worktreepath)' \
    | grep -vE '^release_[0-9]{4}_')

if [ -n "$1" ]; then
    matches=$(echo "$branches" | cut -d'|' -f1 | grep -iE -- "$1")
    if [ -z "$matches" ]; then
        echo "No branch matching '$1'"
        exit 1
    fi
    branch=$(echo "$matches" | head -n 1)
    if [ "$(echo "$matches" | wc -l)" -gt 1 ]; then
        echo "Multiple matches, using most recent:"
        echo "$matches" | sed 's/^/  /'
    fi
    git checkout "$branch"
    exit
fi

echo "$branches" | awk -F'|' 'BEGIN{Y="\033[33m";G="\033[32m";R="\033[31m";B="\033[34m";C="\033[36m";Z="\033[m"}
    {n=split($4,a,"/"); wt=(a[n]==""?"":B a[n] Z); print C NR ")" Z, Y $1 Z, "(" G $2 Z ")", R $3 Z, wt}'
printf "Select branch number: "
read -r num </dev/tty
branch=$(echo "$branches" | sed -n "${num}p" | cut -d'|' -f1)
if [ -n "$branch" ]; then
    git checkout "$branch"
else
    echo "Invalid selection"
fi
