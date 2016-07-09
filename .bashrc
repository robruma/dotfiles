# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [[ -f /etc/bashrc ]]; then
  . /etc/bashrc
fi

# Ensure ~/.bash_profile is sourced
if [[ -f ~/.bash_profile ]]; then
  . ~/.bash_profile
fi

# Set history date/time stamping
export HISTTIMEFORMAT="%D %T "

# Set the default editor to vim
export EDITOR=vim
