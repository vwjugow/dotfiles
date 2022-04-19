#!/bin/bash
branch=$1
base_branch=$2

if [[ -z $base_branch ]]; then
    base_branch="master"
fi

repo_url=`git remote -v | grep push | grep origin | awk '{print $2}' | sed 's_:_/_'  | sed 's_git@_https://_' | sed 's_.git\s*$__'`
if [[ $repo_url = *"bitbucket"* ]]; then
    xc `g br`
    sensible-browser ${repo_url}/pull-requests/new &
else
    sensible-browser ${repo_url}/compare/${base_branch}...${branch} &
fi
