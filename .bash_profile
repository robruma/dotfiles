if [[ -s ~/.profile ]]; then
  . ~/.profile
fi

if [[ -s ~/.bashrc ]]; then
  . ~/.bashrc
fi

# Set config variables first
# GIT_PROMPT_ONLY_IN_REPO=1

# GIT_PROMPT_FETCH_REMOTE_STATUS=0   # uncomment to avoid fetching remote status

GIT_PROMPT_SHOW_UPSTREAM=1 # uncomment to show upstream tracking branch
GIT_PROMPT_SHOW_UNTRACKED_FILES=all # can be no, normal or all; determines counting of untracked files

# GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh # uncomment to support Git older than 1.7.10
if [[ $(which git 2>&1 > /dev/null) ]] && [[ $(uname -s) != Darwin ]] && [[ $(git --version | awk '{print $NF,"\n1.7.10"}' | sort -Vr | head -n1) == 1.7.10 ]]; then
  GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh
fi

# GIT_PROMPT_START=...    # uncomment for custom prompt start sequence
# GIT_PROMPT_END=...      # uncomment for custom prompt end sequence
GIT_PROMPT_START="[\u@\h \W]"
if [[ $UID == 0 ]]; then
  GIT_PROMPT_END='# '
else
  GIT_PROMPT_END='$ '
fi

# as last entry source the gitprompt script
# GIT_PROMPT_THEME=Custom # use custom .git-prompt-colors.sh
# GIT_PROMPT_THEME=Solarized # use theme optimized for solarized color scheme
GIT_PROMPT_THEME=Chmike

if [[ -f ~/.bash-git-prompt/gitprompt.sh ]]; then
  . ~/.bash-git-prompt/gitprompt.sh
fi

if [[ -x /usr/local/bin/brew ]] && [[ -f $(brew --prefix)/etc/bash_completion ]]; then
  . $(brew --prefix)/etc/bash_completion
fi

export SUDO_PS1='\h:\W \u\$ '

if [[ -f /usr/libexec/java_home ]]; then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi

if [[ -x /usr/local/bin/brew ]] && [[ -f $(brew --prefix gnu-getopt)/bin/getopt ]]; then
  export FLAGS_GETOPT_CMD="$(brew --prefix gnu-getopt)/bin/getopt"
fi

if [[ -f ~/.alias ]]; then
  . ~/.alias
fi
