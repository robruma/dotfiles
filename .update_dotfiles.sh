#!/bin/bash
# Setting COMMENT with a default value
# This will use all arguments to the script as the commit message
COMMENT=${@:-"Updating dotfiles"}

# What branch are we using?
BRANCH=$(git symbolic-ref -q HEAD)
BRANCH=${BRANCH##refs/heads/}
BRANCH=${BRANCH:-HEAD}

# Conditionally run git commands to properly update all submodules within this repo
git fetch
if [[ -n $(git status --porcelain) ]] || [[ $(git diff --exit-code --quiet origin/${BRANCH}) ]]; then
  git pull origin ${BRANCH} 
  git submodule init 
  git submodule foreach --recursive git pull origin ${BRANCH}
  git commit -a -m "${COMMENT}"
  git push origin ${BRANCH}
  git submodule update
else
  echo "Nothing to update"
fi
