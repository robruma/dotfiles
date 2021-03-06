#!/bin/bash
# Setting COMMENT with a default value
# Use all arguments to this script as the commit message
COMMENT=${@:-"Updating dotfiles"}

# Which branch are we using?
BRANCH=$(git symbolic-ref -q HEAD)
BRANCH=${BRANCH##refs/heads/}
BRANCH=${BRANCH:-HEAD}

# Fetch changes then check remote and local status to conditionally update all submodules
git fetch
if ! git diff --submodule=diff --exit-code --quiet origin/${BRANCH} || [[ $(git submodule update --recursive --remote > /dev/null 2>&1; git submodule status --recursive) =~ ^+.* ]] || [[ -n $(git status --porcelain) ]]; then
  git pull origin ${BRANCH}
  git submodule init
  git submodule foreach --recursive "git pull origin ${BRANCH}"
  git submodule foreach --recursive "git submodule update --init"
  git commit -a -m "${COMMENT}"
  git push origin ${BRANCH}
  git submodule update
else
  echo "Nothing to update"
fi
