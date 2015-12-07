if [[ -s ~/.profile ]]; then
  . ~/.profile
fi

if [[ -x /usr/local/bin/brew ]] && [[ -f $(brew --prefix)/etc/bash_completion ]]; then
  . $(brew --prefix)/etc/bash_completion
fi

if tput setaf 1 &> /dev/null; then
  tput sgr0
  if [[ $(tput colors) -gt 256 ]] 2>/dev/null; then
    MAGENTA=$(tput setaf 9)
    ORANGE=$(tput setaf 172)
    GREEN=$(tput setaf 190)
    PURPLE=$(tput setaf 141)
    WHITE=$(tput setaf 0)
  else
    MAGENTA=$(tput setaf 5)
    RED=$(tput setaf 1)
    ORANGE=$(tput setaf 172)
    BLUE=$(tput setaf 4)
    LTBLUE=$(tput setaf 32)
    GREEN=$(tput setaf 2)
    PURPLE=$(tput setaf 141)
    WHITE=$(tput setaf 7)
    LTGRAYBG=$(tput setab 240)
    BLINK=$(tput blink)
  fi
  BOLD=$(tput bold)
  RESET=$(tput sgr0)
else
  MAGENTA="\033[1;31m"
  ORANGE="\033[1;33m"
  GREEN="\033[1;32m"
  PURPLE="\033[1;35m"
  WHITE="\033[1;37m"
  BOLD=""
  RESET="\033[m"
fi

function is_on_git() {
  git rev-parse 2> /dev/null
}

function parse_git_dirty() {
  [[ $(git status 2> /dev/null | tail -n1) != *"working directory clean"* ]] && echo -n "${RESET}${BLINK}${ORANGE}±"
}

function parse_git_branch() {
  BRANCH=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\(\1\)$(parse_git_dirty)/")
  case $BRANCH in
    \(master\)*) if [[ ! $(git config --get remote.origin.url) =~ dotfiles ]]; then echo -n "${RESET}${LTBLUE}${BRANCH}" ; else parse_git_dirty; fi ;;
    \(production\)*) echo -n "${RESET}${RED}${BRANCH}" ;;
    \(testing\)*) echo -n "${RESET}${GREEN}${BRANCH}" ;;
    \(${USER}\)*) echo -n "${RESET}${GREEN}${BRANCH}" ;;
    *) echo -n $BRANCH
  esac
}

PS1="[\u@\h \W]\$(is_on_git && [[ -n \$(git branch 2> /dev/null) ]])\[$LTGRAYBG\]\[$WHITE\]\$(parse_git_branch)\[$RESET\]\\$ "
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
