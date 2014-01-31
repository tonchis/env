autoload -Uz colors
colors

# VARIABLES

RED="%{$fg[red]%}"
NRED="%{$fg_bold[red]%}"

GREEN="%{$fg[green]%}"
NGREEN="%{$fg_bold[green]%}"

BLUE="%{$fg[blue]%}"
NBLUE="%{$fg_bold[blue]%}"

GREY="%{$fg[grey]%}"
NGREY="%{$fg_bold[grey]%}"

BLACK="%{$fg[black]%}"
GREY="%{$fg[grey]%}"

MAGENTA="%{$fg[magenta]%}"
NMAGENTA="%{$fg_bold[magenta]%}"

CYAN="%{$fg[cyan]%}"
NCYAN="%{$fg_bold[cyan]%}"

WHITE="%{$fg[white]%}"
NWHITE="%{$fg_bold[white]%}"

YELLOW="%{$fg[yellow]%}"
NYELLOW="%{$fg_bold[yellow]%}"

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
alias myip="curl http://whatismyip.org"

if [ "`uname`" = 'Linux' ]; then
  alias ls="ls --color=always"
else
  alias ls="ls -G"
fi

# RSpec
alias spec="spec --color --format doc"

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
alias gd="git diff --word-diff"
alias gdc="git diff --word-diff --cached"
alias gsh="git show"
alias gm="git merge"
alias gush="git push origin"
alias gsp="git stash pop"
alias gull="git pull"
alias gundo="git reset --soft HEAD~1"
alias gpr="git pull-request"

# Vagrant
alias v="vagrant"
alias vu="vagrant up"
alias vh="vagrant halt"

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
  git stash save "$*"
}

# PROMPT

ZSH_THEME_GIT_PROMPT_ADDED="${NGREEN}✘${RESET}"
ZSH_THEME_GIT_PROMPT_RENAMED="${NGREEN}✘${RESET}"
ZSH_THEME_GIT_PROMPT_DELETED="${NYELLOW}✘${RESET}"
ZSH_THEME_GIT_PROMPT_MODIFIED="${NYELLOW}✘${RESET}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="${NRED}✘${RESET}"
ZSH_THEME_GIT_PROMPT_CLEAN="${NGREEN}✔${RESET}"

# get the name of the branch or commit (short SHA) we are on
function git_prompt_info() {
  ref=$(git symbolic-ref --short HEAD 2> /dev/null) || ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref} $(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

# Checks if working tree is dirty
function parse_git_dirty() {
  if [[ -n $(git status -s 2> /dev/null) ]]; then
    echo "$(git_prompt_status)"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

# Checks if there are commits ahead from remote
function git_prompt_ahead() {
  if $(echo "$(git log origin/$(current_branch)..HEAD 2> /dev/null)" | grep '^commit' &> /dev/null); then
    echo "$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
}

# Formats prompt string for current git commit short SHA
function git_prompt_short_sha() {
  SHA=$(git rev-parse --short HEAD 2> /dev/null) && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Formats prompt string for current git commit long SHA
function git_prompt_long_sha() {
  SHA=$(git rev-parse HEAD 2> /dev/null) && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Get the status of the working tree
function git_prompt_status() {
  INDEX=$(git status --porcelain 2> /dev/null)
  STATUS=""
  if $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^MM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
  fi
  if $(echo "$INDEX" | grep 'D ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  fi
  echo $STATUS
}

function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

function in_gemset() {
   if [[ -n $GS_NAME ]]; then
     if [[ $(uname) == "Darwin" ]]; then
       echo "💎"
     else
       echo "♢"
     fi
   else
     return
   fi
}


# PS1

setopt promptsubst

local user='${RED}%n${RESET}'
local host='${GREEN}%m${RESET}'
local full_path='${CYAN}%~${RESET}'
local git_stuff='$(git_prompt_info)${RESET}'
local gemset='${NRED}$(in_gemset)${RESET}'

PROMPT="${user}@${host}:${full_path} ${git_stuff} ${gemset}
%B$%b "

# PATH

# Custom binaries
export PATH=~/bin:$PATH

# Homebrew's bin path
export PATH=/usr/local/bin:$PATH

# gst
export PATH=~/code/gst/bin:$PATH

# git-pull-request
export PATH=~/code/git-pull-request/bin:$PATH

# CHRUBY

CHRUBY_SCRIPT="/usr/local/opt/chruby/share/chruby/chruby.sh"
CHRUBY_AUTO="/usr/local/share/chruby/auto.sh"
if [[ -f $CHRUBY_SCRIPT ]] && [[ -f $CHRUBY_AUTO ]]; then
  source $CHRUBY_SCRIPT
  source $CHRUBY_AUTO
fi

