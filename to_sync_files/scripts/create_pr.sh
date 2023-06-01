#!/bin/bash
branch=$1
base_branch=$2
BROWSER_BIN="open"

if [[ -z $base_branch ]]; then
    base_branch="master"
fi

repo_url=`git remote -v | grep push | grep origin | awk '{print $2}' | sed 's_:_/_'  | sed 's_git@_https://_' | sed 's_.git\s*$__'`
if [[ $repo_url = *"bitbucket"* ]]; then
    ${COPYFN} `g br`
    ${BROWSER_BIN} ${repo_url}/pull-requests/new &
else
    ${BROWSER_BIN} ${repo_url}/compare/${base_branch}...${branch} &
fi
