#!/bin/bash
git pull origin master 
git submodule init 
git submodule foreach --recursive git pull origin master
git commit -a -m "Updating dotfiles"
git push origin master
git submodule update
