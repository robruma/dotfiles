#!/bin/bash

# Install Homebrew
if [[ $(uname -s) == Darwin ]] && [[ ! -x /usr/local/bin/brew ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Homebrew bash completion settings
if [[ -x /usr/local/bin/brew ]] && [[ -f $(brew --prefix)/etc/bash_completion ]]; then
  . $(brew --prefix)/etc/bash_completion
fi

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
      spinner start "Checking for Homebrew updates" & HOMEBREW_OUTDATED=$(/usr/local/bin/brew update > /dev/null 2>&1 && /usr/local/bin/brew outdated && /usr/local/bin/brew cask outdated --greedy)
      HOMEBREW_OUTDATED_RV=$?
      spinner stop $HOMEBREW_OUTDATED_RV $!
      if [[ -n $HOMEBREW_OUTDATED ]]; then
        echo -e "The following Homebrew packages are outdated:\n\n${HOMEBREW_OUTDATED}\n"
        read_prompt ${HOMEBREW_UPDATE_TIMEOUT:-5} "Upgrade outdated Homebrew packages?"
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          unset REPLY
          echo -e "\nUpgrading outdated Homebrew packages"
          /usr/local/bin/brew upgrade
          /usr/local/bin/brew cu --yes --all --cleanup
          HOMEBREW_UPGRADE_RV=$?
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
    echo "Homebrew update check is disabled, set HOMEBREW_UPDATE_CHECK=true in ~/.profile to enable"
  fi
fi
