export LC_CTYPE=en_US.UTF-8

autoload -Uz colors
colors

# VARIABLES

RED="%{$fg[red]%}"
GREEN="%{$fg[green]%}"
BLUE="%{$fg[blue]%}"
GREY="%{$fg[grey]%}"
MAGENTA="%{$fg[magenta]%}"
CYAN="%{$fg[cyan]%}"
WHITE="%{$fg[white]%}"
YELLOW="%{$fg[yellow]%}"
BLACK="%{$fg[black]%}"

BRED="%{$fg_bold[red]%}"
BGREEN="%{$fg_bold[green]%}"
BBLUE="%{$fg_bold[blue]%}"
BGREY="%{$fg_bold[grey]%}"
BMAGENTA="%{$fg_bold[magenta]%}"
BCYAN="%{$fg_bold[cyan]%}"
BWHITE="%{$fg_bold[white]%}"
BYELLOW="%{$fg_bold[yellow]%}"

RESET="%{$reset_color%}"

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Tonchis custom stuff
# Config according to OS.
if [ "`uname`" = 'Darwin' ]; then
  export LSCOLORS="gxfxcxdxbxegedabagacad"
  export COLORTERM=xterm-color256
  export VISUAL="mvim"
else
  export LS_COLORS='di=36:fi=0:ln=31:pi=5:so=5:bd=5:cd=5:or=31:mi=0:ex=35'
  export COLORTERM=gnome-256color
  export VISUAL="gvim"
fi

export EDITOR="vim"

# Binded ^R to history search, like bash.
bindkey '^R' history-incremental-pattern-search-backward

# This is to cycle through results when searching.
bindkey -M viins '^F' history-incremental-pattern-search-forward
bindkey -M viins '^R' history-incremental-pattern-search-backward

# Completion options
# zstyle ':completion:*' completer _ignored _approximate
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' matcher-list '' 'r:|[._-]=** r:|=**'
zstyle ':completion:*' menu 'select=1'
zstyle ':completion:*' original 'true'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' verbose 'true'
zstyle ':completion:*:descriptions' format "${CYAN}Completing %d${RESET}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' group-order \
        local-directories builtins aliases commands

# ALIASES

# Global
alias c="clear"
alias h="history"
alias reload="source ~/.zshrc; clear"
alias ec="$EDITOR ~/env/zshrc"
alias ..="cd .."
alias ~="cd ~/"
alias "bitch,"=sudo
alias quit="exit"
alias ll="ls -lsah"

if [ "`uname`" = 'Linux' ]; then
  alias ls="ls --color=always"
else
  alias ls="ls -G"
fi

# Git
alias gout="git checkout"
alias gca="git commit --amend -C HEAD"
alias ga="git add"
alias gs="git status"
alias gb="git branch"
alias gba="git branch -a"
alias getch="git fetch --prune"
alias gg="git log --decorate --oneline --all --graph -10"
alias gga="git log --decorate --oneline --all --graph"
alias grb="git rebase"
alias gr="git reset"
alias grh="git reset HEAD"
alias gd="git diff --color-words"
alias gdc="git diff --color-words --cached"
alias gsh="git show"
alias gm="git merge"
alias gush="git push origin"
alias gsp="git stash pop"
alias gull="git pull"
alias gundo="git reset --soft HEAD~1"
alias gpr="git pull-request"

# Vagrant
alias v="vagrant"

# Other
alias "1.9.3-in"="chruby 1.9.3; . gst in"
alias t="tmux"
alias f="foreman"
alias tele-ssh="ssh -F .tele/ssh_config"

# Custom functions
function gcm(){
  issue_number=$(git symbolic-ref --short HEAD | grep -Ei "^\d+[-_]" | grep -oEi "^\d+")

  if [[ -n $issue_number ]]; then
    commit_message=$(echo "$*\n\nRefs #${issue_number}.")
  else
    commit_message=$(echo "$*")
  fi

  git commit -m $commit_message
}

function gash(){
  git stash save -u "$*"
}

# PROMPT

ZSH_THEME_GIT_PROMPT_ADDED="${BGREEN}✘${RESET}"
ZSH_THEME_GIT_PROMPT_RENAMED="${BGREEN}✘${RESET}"
ZSH_THEME_GIT_PROMPT_DELETED="${BYELLOW}✘${RESET}"
ZSH_THEME_GIT_PROMPT_MODIFIED="${BYELLOW}✘${RESET}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="${BRED}✘${RESET}"
ZSH_THEME_GIT_PROMPT_CLEAN="${BGREEN}✔${RESET}"

# get the name of the branch or commit (short SHA) we are on
function git_prompt_info() {
  ref=$(git symbolic-ref --short HEAD 2> /dev/null) || ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref}$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

function in_gemset() {
   if [[ -n $GS_NAME ]]; then
     echo $GS_NAME
     # if [[ $(uname) == "Darwin" ]]; then
       # echo "💎"
     # else
       # echo "♢"
     # fi
   else
     echo "default"
     # return
   fi
}

function current_ruby() {
  if [[ -n $RUBY_VERSION ]]; then
    echo $RUBY_VERSION
  else
    echo "system"
  fi
}

# PS1

setopt promptsubst

local user='${RED}%n${RESET}'
local host='${GREEN}%m${RESET}'
local full_path='${CYAN}%~${RESET}'
local git_stuff='${WHITE}$(git_prompt_info)${RESET}'
local ruby_version='${RED}$(current_ruby)${RESET}'
local gemset='${GREEN}$(in_gemset)${RESET}'

PROMPT="${user}@${host} ${ruby_version}@${gemset} ${full_path} ${git_stuff}
%B$%b "

# PATH

# Custom binaries
export PATH=~/bin:$PATH

# Homebrew's bin path
export PATH=/usr/local/sbin:/usr/local/bin:$PATH

# gst
export PATH=~/code/gst/bin:$PATH

# git-pull-request
export PATH=~/code/git-pull-request/bin:$PATH

# tmuxify
export PATH=~/code/tmuxify/bin:$PATH

# CHRUBY

CHRUBY_SCRIPT="/usr/local/opt/chruby/share/chruby/chruby.sh"
if [[ -f $CHRUBY_SCRIPT ]]; then
  source $CHRUBY_SCRIPT
  export RUBY_MANAGER='chruby'
fi

RUBY_DEFAULT_VERSION=$(cat ~/.ruby-version)
if [[ -n $RUBY_DEFAULT_VERSION ]]; then chruby $RUBY_DEFAULT_VERSION; fi

setopt interactivecomments
