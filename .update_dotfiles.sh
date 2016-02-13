#!/bin/bash
if [[ $# -gt 0 ]]; then
  COMMENT=${@}
else
  COMMENT="Updating dotfiles"
fi
git pull origin master 
git submodule init 
git submodule foreach --recursive git pull origin master
git commit -a -m "${COMMENT}"
git push origin master
git submodule update
