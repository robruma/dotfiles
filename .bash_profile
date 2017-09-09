# Add go library to path
export GOPATH=/usr/local/opt/go/libexec/bin

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

# Add SSH keys to the OS agent and add the ability to override the identity lifetime by setting the environment variable SSH_IDENTITY_LIFETIME=N
if [[ $- =~ i ]] && [[ -x $(which ssh-add 2>/dev/null) ]]; then
  eval $(ssh-agent -s) > /dev/null 2>&1;
  trap "kill $SSH_AGENT_PID" EXIT
  if [[ $(uname -s) != Darwin ]] && [[ -S $SSH_AUTH_SOCK ]]; then
    ssh-add -t ${SSH_IDENTITY_LIFETIME:-604800}
  else
    ssh-add -A 2>/dev/null
  fi
fi

# Global git settings
# Override by setting the environment variables GIT_NAME and GIT_EMAIL
if [[ -x $(which git 2>/dev/null) ]]; then
  git config --global user.name "${GIT_NAME:-Anonymous}"
  git config --global user.email "${GIT_EMAIL:-anonymous@localhost}"
else
  echo -e "Warning: git not found in your path.\nFunctionality that uses git will be disabled"
fi

# Git Prompt settings
# Set config variables first
# GIT_PROMPT_ONLY_IN_REPO=1

# GIT_PROMPT_FETCH_REMOTE_STATUS=0   # uncomment to avoid fetching remote status

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
# Also provide the ability to disable by setting the environment variable UPDATE_DOTFILES=false
# Override read timeout by setting the environment variable UPDATE_DOTFILES_TIMEOUT=N in ~/.profile
if [[ -x $(which git 2>/dev/null) ]] && [[ -x ~/.update_dotfiles.sh ]] && ${UPDATE_DOTFILES:-true} > /dev/null 2>&1; then
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

# Install Homebrew
if [[ $(uname -s) == Darwin ]] && [[ ! -x /usr/local/bin/brew ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Homebrew bash completion settings
if [[ -x /usr/local/bin/brew ]] && [[ -f $(brew --prefix)/etc/bash_completion ]]; then
  . $(brew --prefix)/etc/bash_completion
fi

export SUDO_PS1='\h:\W \u\$ '

# Homebrew JAVA_HOME settings
if [[ -f /usr/libexec/java_home ]]; then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi

# Homebrew getopt settings
if [[ -x /usr/local/bin/brew ]] && [[ -f $(brew --prefix gnu-getopt)/bin/getopt ]]; then
  export FLAGS_GETOPT_CMD="$(brew --prefix gnu-getopt)/bin/getopt"
fi

# Keep Homebrew packages updated
if [[ -x /usr/local/bin/brew ]]; then
  # Present user with the abilty to automatically update and upgrade outdated Homebrew packages
  # Also provide the ability to disable by setting the environment variable HOMEBREW_UPDATE_CHECK=false
  if ${HOMEBREW_UPDATE_CHECK:-true} > /dev/null 2>&1; then
    # Homebrew update logic
    # Override read timeout by setting the environment variable HOMEBREW_UPDATE_TIMEOUT=N in ~/.profile
    read_prompt ${HOMEBREW_UPDATE_TIMEOUT:-5} "Check for Homebrew updates?"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      unset REPLY
      # Ensure Homebrew bundles are installed
      spinner start "Checking the Brewfile's dependencies" & HOMEBREW_BUNDLED=$(/usr/local/bin/brew bundle check --global --no-upgrade)
      HOMEBREW_BUNDLED_RV=$?
      spinner stop $HOMEBREW_BUNDLED_RV $!
      echo -e $HOMEBREW_BUNDLED
      if [[ $HOMEBREW_BUNDLED_RV != 0 ]]; then
        echo -e "Ensuring Homebrew bundle tap is installed"
        /usr/local/bin/brew tap homebrew/bundle
        read_prompt ${HOMEBREW_UPDATE_TIMEOUT:-5} "Install Homebrew bundles?"
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          unset REPLY
          echo -e "\nInstalling Homebrew bundles"
          /usr/local/bin/brew bundle --global --no-upgrade
        else
          echo -e "\nSkipping Homebrew bundle install\nRun 'brew bundle --global' to install bundles manually"
        fi
      fi
      spinner start "Checking for Homebrew updates" & HOMEBREW_OUTDATED=$(/usr/local/bin/brew update > /dev/null 2>&1 && /usr/local/bin/brew outdated)
      HOMEBREW_OUTDATED_RV=$?
      spinner stop $HOMEBREW_OUTDATED_RV $!
      if [[ -n $HOMEBREW_OUTDATED ]]; then
        echo -e "The following Homebrew packages are outdated:\n\n${HOMEBREW_OUTDATED}\n"
        read_prompt ${HOMEBREW_UPDATE_TIMEOUT:-5} "Upgrade outdated Homebrew packages?"
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          unset REPLY
          echo -e "\nUpgrading outdated Homebrew packages"
          /usr/local/bin/brew upgrade
          HOMEBREW_UPGRADE_RV=$?
          if [[ $HOMEBREW_UPGRADE_RV != 0 ]]; then
            echo "$(tput setaf 1)Homebrew outdated package upgrade failed$(tput sgr0)"
          fi
        else
          echo -e "\nSkipping Homebrew outdated package upgrade\nRun 'brew upgrade' to upgrade outdated packages manually"
        fi
      elif [[ $HOMEBREW_OUTDATED_RV != 0 ]]; then
        echo "$(tput setaf 1)Homebrew update check failed$(tput sgr0)"
      else
        echo "No Homebrew packages are outdated"
      fi
    else
      echo -e "\nSkipping Homebrew update check\nRun 'brew update; brew outdated' to check manually then 'brew upgrade' if necessary"
    fi
  else
    echo "Homebrew update check is disabled, set HOMEBREW_UPDATE_CHECK=true in ~/.profile to enable"
  fi
fi
