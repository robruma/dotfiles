#!/bin/bash
# Setting COMMENT with a default value
# This will use all arguments to the script as the commit message
COMMENT=${@:-"Updating dotfiles"}

# Conditionally run git commands to properly update all submodules within this repo
git fetch
if [[ -n $(git status --porcelain) ]] || [[ $(git diff --exit-code --quiet origin/master) ]]; then
  git pull origin master 
  git submodule init 
  git submodule foreach --recursive git pull origin master
  git commit -a -m "${COMMENT}"
  git push origin master
  git submodule update
else
  echo "Nothing to update"
fi
