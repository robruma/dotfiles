#!/bin/bash

# Install MacOS Command Line Tools
if ! $(${SKIP:-false}) && [[ -x /usr/bin/xcode-select ]] && [[ ! -d /Library/Developer/CommandLineTools/usr/bin ]]; then
  /usr/bin/xcode-select --install
fi

# Determine machine hardware
HOMEBREW_MACHINE_HARDWARE_TYPE=$(uname -m)

if [[ $HOMEBREW_MACHINE_HARDWARE_TYPE == "arm64" ]]; then
  HOMEBREW_BIN_PATH=/opt/homebrew/bin/brew
elif [[ $HOMEBREW_MACHINE_HARDWARE_TYPE == "x86_64" ]]; then
  HOMEBREW_BIN_PATH=/usr/local/bin/brew
fi

# Install Homebrew
if ! $(${SKIP:-false}) && [[ $(uname -s) == Darwin ]] && [[ ! -x $HOMEBREW_BIN_PATH ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Homebrew bash completion settings
if [[ -x $HOMEBREW_BIN_PATH ]] && [[ -f $(brew --prefix)/etc/bash_completion ]]; then
  . $(brew --prefix)/etc/bash_completion
fi

# Homebrew JAVA_HOME settings
if [[ -f /usr/libexec/java_home ]]; then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi

# Homebrew getopt settings
if [[ -x $HOMEBREW_BIN_PATH ]] && [[ -f $(brew --prefix gnu-getopt)/bin/getopt ]]; then
  export FLAGS_GETOPT_CMD="$(brew --prefix gnu-getopt)/bin/getopt"
fi

# Keep Homebrew packages updated
if ! $(${SKIP:-false}) && [[ -x $HOMEBREW_BIN_PATH ]]; then
  # Allow for an override to be applied across all package updates
  read_prompt ${HOMEBREW_UPDATE_TIMEOUT:-5} "Bypass update prompts?"
  case $REPLY in
    Y | y ) UPDATE_ALL=true; unset REPLY;;
    * ) echo -e "\nContinuing..."; unset REPLY;;
  esac

  # Present user with the ability to automatically update and upgrade outdated Homebrew packages
  # Also provide the ability to disable by setting the environment variable HOMEBREW_UPDATE_CHECK=false
  #if ${HOMEBREW_UPDATE_CHECK:-true} > /dev/null 2>&1; then
  if $(${HOMEBREW_UPDATE_CHECK:-true}); then
    # Homebrew update logic
    # Override read timeout by setting the environment variable HOMEBREW_UPDATE_TIMEOUT=N in ~/.profile
    $(${UPDATE_ALL:-false}) || read_prompt ${HOMEBREW_UPDATE_TIMEOUT:-5} "Check for Homebrew updates?"
    if [[ $REPLY =~ ^[Yy]$ ]] || $(${UPDATE_ALL:-false}); then
      unset REPLY
      # Ensure Homebrew bundles are installed
      spinner start "Checking the Brewfile's dependencies" & HOMEBREW_BUNDLED=$($HOMEBREW_BIN_PATH bundle check --global --no-upgrade)
      HOMEBREW_BUNDLED_RV=$?
      spinner stop $HOMEBREW_BUNDLED_RV $!
      echo -e $HOMEBREW_BUNDLED
      if [[ $HOMEBREW_BUNDLED_RV != 0 ]]; then
        echo -e "Ensuring Homebrew bundle tap is installed"
        $HOMEBREW_BIN_PATH tap homebrew/bundle
        $(${UPDATE_ALL:-false}) || read_prompt ${HOMEBREW_UPDATE_TIMEOUT:-5} "Install Homebrew bundles?"
        if [[ $REPLY =~ ^[Yy]$ ]] || $(${UPDATE_ALL:-false}); then
          unset REPLY
          echo -e "\nInstalling Homebrew bundles"
          $HOMEBREW_BIN_PATH bundle --global --no-upgrade
        else
          echo -e "\nSkipping Homebrew bundle install\nRun 'brew bundle --global' to install bundles manually"
        fi
      fi
      spinner start "Checking for Homebrew updates" & HOMEBREW_OUTDATED=($($HOMEBREW_BIN_PATH update > /dev/null 2>&1 && $HOMEBREW_BIN_PATH outdated && $HOMEBREW_BIN_PATH outdated --cask --greedy))
      HOMEBREW_OUTDATED_RV=$?
      spinner stop $HOMEBREW_OUTDATED_RV $!
      # Allow a comma-delimited cask upgrade exclude list by setting the environment variable HOMEBREW_CASK_UPGRADE_EXCLUDE in ~/.profile
      HOMEBREW_CASK_UPGRADE_EXCLUDE=(${HOMEBREW_CASK_UPGRADE_EXCLUDE//,/ })
      for CASK in ${HOMEBREW_CASK_UPGRADE_EXCLUDE[@]}
      do
        for ELEMENT in ${!HOMEBREW_OUTDATED[@]}
        do
          if [[ $CASK =~ ^${HOMEBREW_OUTDATED[$ELEMENT]}$ ]]; then
            HOMEBREW_OUTDATED[$ELEMENT]="$(tput setab 1)${CASK}$(tput sgr0) ($(tput setaf 3)$(tput bold)excluded$(tput sgr0))"
          fi
        done
      done
      if [[ -n ${HOMEBREW_OUTDATED[@]} ]]; then
        echo -e "The following Homebrew packages are outdated:\n"
        for PACKAGE in ${!HOMEBREW_OUTDATED[@]}
        do
          echo -e ${HOMEBREW_OUTDATED[$PACKAGE]} && [[ $PACKAGE -eq $((${#HOMEBREW_OUTDATED[@]} - 1)) ]] && echo
        done
        $(${UPDATE_ALL:-false}) || read_prompt ${HOMEBREW_UPDATE_TIMEOUT:-5} "Upgrade outdated Homebrew packages?"
        if [[ $REPLY =~ ^[Yy]$ ]] || $(${UPDATE_ALL:-false}); then
          unset REPLY
          echo -e "\nUpgrading outdated Homebrew packages\n"
          # Ensure outdated formulae are updated using --formula. See brew upgrade --formula
          $HOMEBREW_BIN_PATH upgrade --formula
          if [[ -z ${HOMEBREW_CASK_UPGRADE_EXCLUDE[@]} ]]; then
            echo -e "No exclude list found: Upgrading all casks\n"
            $HOMEBREW_BIN_PATH cu --yes --all --cleanup
            HOMEBREW_UPGRADE_RV=$?
          else
            HOMEBREW_CASKS=($($HOMEBREW_BIN_PATH list --cask -1))
            NEWLINE="\n"
            for EXCLUDED_CASK in ${HOMEBREW_CASK_UPGRADE_EXCLUDE[@]}
            do
              for EXCLUDED_ELEMENT in ${!HOMEBREW_CASKS[@]}
              do
                if [[ $EXCLUDED_CASK =~ ^${HOMEBREW_CASKS[$EXCLUDED_ELEMENT]}$ ]]; then
                  for EXCLUDED_PACKAGE in ${!HOMEBREW_OUTDATED[@]}
                  do
                    if [[ "$(tput setab 1)${EXCLUDED_CASK}$(tput sgr0) ($(tput setaf 3)$(tput bold)excluded$(tput sgr0))" == ${HOMEBREW_OUTDATED[$EXCLUDED_PACKAGE]} ]]; then
                      echo -e "${NEWLINE}Excluded cask found: Skipping $(tput setab 1)${HOMEBREW_CASKS[$EXCLUDED_ELEMENT]}$(tput sgr0)"
                      unset HOMEBREW_CASKS[$EXCLUDED_ELEMENT] NEWLINE
                    fi
                  done
                fi
              done
            done
            echo && $HOMEBREW_BIN_PATH upgrade --cask ${HOMEBREW_CASKS[@]}
            HOMEBREW_UPGRADE_RV=$?
          fi
          if [[ $HOMEBREW_UPGRADE_RV != 0 ]]; then
            echo -e "$(tput setaf 1)\nHomebrew outdated package upgrade failed\n$(tput sgr0)"
          else
            echo -e "$(tput setaf 2)\nHomebrew outdated package upgrade completed successfully\n$(tput sgr0)"
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
    echo "Homebrew update check is disabled, unset HOMEBREW_UPDATE_CHECK to enable"
  fi
else
  echo -e "\nSkipping updates"
fi

# Update MacOS in the background
if ! $(${SKIP:-false}) && [[ -x /usr/sbin/softwareupdate ]]; then
  $(${UPDATE_ALL:-false}) || read_prompt ${HOMEBREW_UPDATE_TIMEOUT:-5} "Check for MacOS updates?"
  if [[ $REPLY =~ ^[Yy]$ ]] || $(${UPDATE_ALL:-false}); then
    unset REPLY
    echo -e "\nUpdating MacOS"
    sudo /usr/sbin/softwareupdate -i -a
  else
    echo -e "\nSkipping MacOS update check\nRun 'softwareupdate -i -a' to check manually"
  fi
fi

# Initialize rbenv
if [[ -x /usr/local/bin/rbenv ]]; then
  eval "$(rbenv init -)"
fi

# Initialize pyenv
if [[ -x /usr/local/bin/pyenv ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi

# Cleanup
unset UPDATE_ALL SKIP
