# Add go library to path
export GOPATH=/usr/local/opt/go/libexec/bin

# Set prompt during privilege escalation
export SUDO_PS1='\h:\W \u\$ '

# Adds a countdown feature to the read timeout
read_prompt() {
  trap true INT TERM EXIT
  if [[ $# -lt 2 ]]; then
    exit 0
  fi
  COUNTDOWN=${1}
  MESSAGE=${2}
  while [[ $COUNTDOWN -ge 0 ]]
  do
    tput hpa $((${#MESSAGE} + 11))
    tput sc
    tput cub 80
    tput el
    echo -n $MESSAGE [y/n] [${COUNTDOWN}] >&2
    ((COUNTDOWN--))
    tput rc
    sleep 1
  done &
  read -t $1 -n 1 -r; kill -9 $!; wait $! 2>/dev/null
}

# Spinner for long running processes with return value check
spinner() {
  trap true INT TERM EXIT
  case $1 in
    start)
      SPINNER_CHARS='\|/-'
      SPINNER_MESSAGE=${2}
      tput cud1
      while true
      do
        tput hpa $((${#SPINNER_MESSAGE} + 2))
        tput sc
        tput cub 80
        tput el
        echo -n $SPINNER_MESSAGE ${SPINNER_CHARS:i++%${#SPINNER_CHARS}:1}
        tput rc
        sleep 0.1
      done
      ;;
    stop)
      SPINNER_RV=${2}
      SPINNER_PID=${3}
      kill -9 $SPINNER_PID; wait $! 2>/dev/null
      echo -n $(tput kbs)
      echo -n [
      if [[ $SPINNER_RV -eq 0 ]]; then
        echo -n $(tput setaf 2)OK$(tput sgr0)
      else
        echo -n $(tput setaf 1)FAIL$(tput sgr0)
      fi
      echo ]
      ;;
  esac
}

# Source ~/.profile
# Set user configurable environment variables here
if [[ -s ~/.profile ]]; then
  . ~/.profile
fi

# Source ~/.bashrc
if [[ -s ~/.bashrc ]]; then
  . ~/.bashrc
fi

# Source ~/.alias
if [[ -f ~/.alias ]]; then
  . ~/.alias
fi

# Run ssh-agent, set the appropriate environment and kill the agent PID on exit
if [[ $- =~ i ]] && [[ -x $(which ssh-add 2>/dev/null) ]]; then
  eval $(ssh-agent -s) > /dev/null 2>&1
  trap "kill $SSH_AGENT_PID" EXIT
  # Add SSH keys to the OS agent and add the ability to override the identity lifetime by
  # setting the environment variable SSH_IDENTITY_LIFETIME=N in ~/.profile
  if [[ $(uname -s) == Linux ]] && [[ -S $SSH_AUTH_SOCK ]]; then
    ssh-add -t ${SSH_IDENTITY_LIFETIME:-604800}
  elif [[ $(uname -s) == Darwin ]] && [[ -S $SSH_AUTH_SOCK ]]; then
    ssh-add -A 2>/dev/null
  fi
fi

# Global git settings
# Override by setting the environment variables GIT_NAME and GIT_EMAIL in ~/.profile
if [[ -x $(which git 2>/dev/null) ]]; then
  git config --global alias.last 'log -1 HEAD'
  git config --global alias.tree 'log --graph --decorate --pretty=oneline --abbrev-commit'
  git config --global alias.unstage 'reset HEAD --'
  git config --global user.email "${GIT_EMAIL:-anonymous@localhost}"
  git config --global user.name "${GIT_NAME:-Anonymous}"
else
  echo -e "$(tput setaf 3)Warning:$(tput sgr0) git not found in your path\nFunctionality that uses git will be disabled"
fi

# Git Prompt settings
# Set config variables first
# GIT_PROMPT_ONLY_IN_REPO=1

# GIT_PROMPT_FETCH_REMOTE_STATUS=0   # uncomment to avoid fetching remote status

# Needed for new prompt theme management
__GIT_PROMPT_DIR=~/.bash-git-prompt
GIT_PROMPT_SHOW_UPSTREAM=1 # uncomment to show upstream tracking branch
GIT_PROMPT_SHOW_UNTRACKED_FILES=all # can be no, normal or all; determines counting of untracked files

# GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh # uncomment to support Git older than 1.7.10
if [[ -x $(which git 2>/dev/null) ]] && [[ $(uname -s) != Darwin ]] && [[ $(git --version | awk '{print $NF,"\n1.7.10"}' | sort -Vr | head -n1) == 1.7.10 ]]; then
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

# Source ~/.bash-git-prompt/gitprompt.sh
if [[ -x $(which git 2>/dev/null) ]] && [[ -f ~/.bash-git-prompt/gitprompt.sh ]]; then
  . ~/.bash-git-prompt/gitprompt.sh
fi

# Keep dotfiles up to date automatically by running ~/.update_dotfiles.sh
# Also provide the ability to disable by setting the environment variable UPDATE_DOTFILES=false in ~/.profile
# Override read timeout by setting the environment variable UPDATE_DOTFILES_TIMEOUT=N in ~/.profile
if [[ -x $(which git 2>/dev/null) ]]; then
  if [[ -x ~/.update_dotfiles.sh ]] && ${UPDATE_DOTFILES:-true} > /dev/null 2>&1; then
    read_prompt ${UPDATE_DOTFILES_TIMEOUT:-5} "Update dotfiles?"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      unset REPLY
      spinner start "Updating dotfiles" & ~/.update_dotfiles.sh > /dev/null 2>&1
      spinner stop $? $!
    else
      echo -e "\nSkipping dotfiles update\nRun '~/.update_dotfiles.sh' to update dotfiles manually"
    fi
  else
    echo "Update dotfiles is disabled, set UPDATE_DOTFILES=true in ~/.profile to enable"
  fi
fi

# Source only on Linux specific operating systems
if [[ $(uname -s) == Linux ]]; then
  . ~/.linux.sh
fi

# Source only on Darwin specific operating systems
if [[ $(uname -s) == Darwin ]]; then
  . ~/.darwin.sh
fi

# Install RVM option
# Also provide the ability to disable by setting the environment variable INSTALL_RVM=false in ~/.profile
# Override read timeout by setting the environment variable INSTALL_RVM_TIMEOUT=N in ~/.profile
if [[ ! -f ${HOME}/.rvm/scripts/rvm ]] && [[ -x $(which curl 2>/dev/null) ]] && ${INSTALL_RVM:-true} > /dev/null 2>&1; then
  read_prompt ${INSTALL_RVM_TIMEOUT:-5} "Install RVM?"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    unset REPLY
    echo "Installing RVM"
    # Test for GPG key
    if ! gpg --list-keys mpapis@gmail.com >/dev/null 2>&1; then
      command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    fi
    command curl -L https://get.rvm.io | bash -s stable --rails --autolibs=enable
  else
    echo -e "\nSkipping RVM install\nInstall RVM manually"
  fi
fi

# Default RVM function
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
