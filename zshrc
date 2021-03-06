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

# Keep lots of history within the shell and save it to ~/.zsh_history:
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups
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
alias reload="source ~/.zshrc; clear"
alias e="$EDITOR"
alias ec="$EDITOR ~/env/zshrc"
alias ..="cd .."
alias ~="cd ~/"
alias "bitch,"=sudo
alias quit="exit"
alias ll="ls -lsah"
alias mj="make --jobs=4"
alias pbgist="pbpaste | gist -c -p"

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
alias gsp="git stash pop"
alias gull="git pull"
alias gundo="git reset --soft HEAD~1"
alias gpr="git pull-request"
alias current-branch="git symbolic-ref --short HEAD"
alias grbom="git rebase origin/master master"
alias gullsh="git pull && git push"
alias gap="git add -p"
alias gcw="gc wip"
alias gundie="git reset --hard HEAD~1"

# Vagrant
alias v="vagrant"

# Tmux
alias t="tmux"
alias ta="tmux attach -t"
alias ts="tmux new-session -s"
alias tk="tmux kill-session -t"

# Other
alias f="foreman"
alias tele-ssh="ssh -F .tele/ssh_config"
alias pwm="pwpw protonmail.mailbox"

# Custom functions
function gcm() {
  local issue_number=$(git symbolic-ref --short HEAD | awk -F \[-_\] ' $1 ~ /[[:digit:]]/ { print $1 } ')

  if [[ -n $issue_number ]]; then
    commit_message=$(echo "$*\n\nRefs #${issue_number}.")
  else
    commit_message=$(echo "$*")
  fi

  git commit -m $commit_message
}

function gc() {
  local commit_file=$(mktemp -t `basename $PWD`.XXXXXXXXX)

  if [[ "$1" == "wip" ]]; then
    echo -n "[WIP] " >> $commit_file
    shift
  fi

  if [[ $# -gt 0 ]]; then
    echo "$@" >> $commit_file
    echo "" >> $commit_file
  fi

  local issue_number=$(git symbolic-ref --short HEAD | awk -F \[-_\] ' $1 ~ /[[:digit:]]/ { print $1 } ')
  if [[ -n $issue_number ]]; then
    echo "(refs #${issue_number})." >> $commit_file
  fi

  git commit -e -v -F $commit_file
}

function gash() {
  git stash save -u "$*"
}

function hcurl() {
  (curl -v -o /dev/null $@ 2>&1) | grep '^[<>]' | cat
}

function scurl() {
  curl -L -w '%{http_code}\n' -s -f -o /dev/null $@
}

function yoall() {
  curl -X POST "https://api.justyo.co/yoall" -d api_token=$@
}

function rb-env() {
  echo "which ruby    $(which ruby)"
  echo "gem env home  $(gem env home)"
}

function whowhere() {
  echo "whoami    $(whoami)"
  echo "hostname  $(hostname)"
}

# Git rebase with origin
function grbo() {
  branch=${1:-$(current-branch)}

  git rebase origin/$branch $branch
}

# Git push setting remote tracking
function gushu() {
  branch=${1:-$(current-branch)}

  tests && git push -u origin $branch
}

function gush() {
  tests && git push
}

# Search through LimeChat Transcripts
function ircag() {
  ag $* ~/Documents/LimeChat\ Transcripts
}

function chrb() {
  chruby `cat .ruby-version`
}

# mkdir and touch.
function mkt() {
  mkdir -p $(dirname $1) && touch $1
}

function show() {
  if [[ $(type $1) =~ "shell function" ]] || [[ $(type $1) =~ "alias" ]]; then
    which $1
  else
    less $(which $1)
  fi
}

function grbd() {
  local branch=${1:-$(current-branch)}

  git rebase origin/master master && git branch -d $branch
}

function pwpw() {
  echo -n $(pwsafe -p $1) | pbcopy
}

function vag() {
  ag -l $@ | xargs -o vim -p "+/$1" "+:set hlsearch!"
}

function vc() {
  git status --short | ag "UU .*" | awk '{ print $2 }' | xargs -o vim -p "+/<<<<" "+:set hlsearch!"
}

# Kill current tmux session.
function tdie() {
  tmux kill-session -t $(tmux list-sessions | grep attached | awk '{ print $1 }')
}

function gac() {
  git status --short | ag "UU .*" | awk '{ print $2 }' | xargs git add
}

function vol() {
  mpc -h "mopidi2.local" volume $1 >/dev/null
}

function gpri() {
  local issue_number=$(git symbolic-ref --short HEAD | awk -F \[-_\] ' $1 ~ /[[:digit:]]/ { print $1 } ')

  if [[ -n $issue_number ]]; then
    git pull-request -i $issue_number -c
  fi
}

function timestamp() {
  ruby -e 'p Time.now.to_i' | xargs echo -n | pbcopy
}

function gup() {
  local branch=$(git symbolic-ref --short HEAD)
  git stash
  git fetch --prune
  git checkout stable && git rebase
  git checkout master && git rebase
  git checkout $branch
  git stash pop
}

function ssh-add-key() {
  local full_path=$(echo $1)
  if [[ -n $(ssh-add -l >/dev/null | awk '{ print $3 }' | grep $full_path) ]]; then
    echo "Key already added."
    return
  else
    echo "Adding key:"
    ssh-add $1
  fi
}

# PROMPT

# get the name of the branch or commit (short SHA) we are on
function git_prompt_info() {
  ref=$(git symbolic-ref --short HEAD 2> /dev/null) || ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref}"
}

# PS1

setopt promptsubst

local full_path='${CYAN}%~'
local git_stuff='${RESET}$(git_prompt_info)'

PROMPT="${full_path} ${git_stuff}
%B$%b "

# PATH

# Custom binaries
export PATH=~/bin:$PATH

# Homebrew's bin path
export PATH=/usr/local/sbin:/usr/local/bin:$PATH

# https://github.com/foca/ensure bin path.
export PATH="$PATH:/opt/ensure/bin"

# brew info coreutils
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

# CHRUBY

CHRUBY_SCRIPT="/usr/local/opt/chruby/share/chruby/chruby.sh"
if [[ -f $CHRUBY_SCRIPT ]]; then
  source $CHRUBY_SCRIPT
  export RUBY_MANAGER='chruby'
fi

if [[ -f ~/.ruby-version ]]; then
  RUBY_DEFAULT_VERSION=$(cat ~/.ruby-version)
  if [[ -n $RUBY_DEFAULT_VERSION ]]; then chruby $RUBY_DEFAULT_VERSION; fi
fi

setopt interactivecomments

# OPAM configuration
. /Users/tonchis/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

# GPG
export GPGKEY=2A0AB6FB

# Running yEd without lag issues.
# See http://yed.yworks.com/support/qa/7039/horribly-slow-on-macbook-pro-15-retina-display
alias yed="java -jar ~/code/forks/yed-3.14.1/yed.jar &"

if [[ -f ~/.homebrew_github_api_token ]]; then
  export HOMEBREW_GITHUB_API_TOKEN=$(cat ~/.homebrew_github_api_token)
fi

