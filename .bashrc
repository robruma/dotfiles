# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'

# Source global definitions
if [[ -f /etc/bashrc ]]; then
  . /etc/bashrc
fi

# Set history date/time stamping
export HISTTIMEFORMAT="%D %T "

# Set the default editor to vim
export EDITOR=vim

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
