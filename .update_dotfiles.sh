#!/bin/bash
# Setting COMMENT with a default value
# This will use all arguments to the script as the commit message
COMMENT=${@:-"Updating dotfiles"}

# Run git commands to properly update all submodules within this repo
git fetch
git pull origin master 
git submodule init 
git submodule foreach --recursive git pull origin master
git commit -a -m "${COMMENT}"
git push origin master
git submodule update
