#!/bin/bash

COMMENT=${@:-"Updating dotfiles"}

git pull origin master 
git submodule init 
git submodule foreach --recursive git pull origin master
git commit -a -m "${COMMENT}"
git push origin master
git submodule update
