#!/usr/bin/env bash
# Shared helpers for the dotfiles setup scripts. Source this; don't execute it.
# Each sourcing script should set LOG_TAG before logging/prompting, e.g.:
#   . "$(dirname "$0")/common.sh"   (or ../common.sh from a subdir)
#   LOG_TAG="BREW"

set -u

# Resolve the repo root from this file's own location (symlink-resolved via
# `cd -P`, so symlink comparisons against DOTFILES_DIR are accurate).
DOTFILES_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors, but only when stdout is a terminal.
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  RESET='\033[0m'
else
  GREEN=''
  RED=''
  RESET=''
fi

# Default tag so logging never prints an empty [].
LOG_TAG="${LOG_TAG:-SETUP}"

log()      { printf "[%s] %s\n" "$LOG_TAG" "$*"; }
log_ok()   { printf "[%s] ✓ %s\n" "$LOG_TAG" "$*"; }
log_act()  { printf "[%s] → %s\n" "$LOG_TAG" "$*"; }
log_skip() { printf "[%s] ✓ Skipped %s\n" "$LOG_TAG" "$*"; }

# prompt_yn "question" -> returns 0 for yes, 1 for no.
# Single-key, colored feedback, always reads from the terminal.
prompt_yn() {
  local reply
  while true; do
    printf "[%s] %s [y/n] " "$LOG_TAG" "$1"
    read -r -s -n1 reply </dev/tty
    case "$reply" in
      y|Y) printf "y ${GREEN}→ yes${RESET}\n"; return 0 ;;
      n|N) printf "n ${RED}→ no${RESET}\n"; return 1 ;;
      *)   printf "\n" ;;
    esac
  done
}

# prompt_input "question" [default] -> echoes the entered value (or default).
# Line read from the terminal; supports an optional default.
prompt_input() {
  local question="$1" default="${2:-}" value
  if [ -n "$default" ]; then
    printf "[%s] %s (default: %s): " "$LOG_TAG" "$question" "$default"
  else
    printf "[%s] %s: " "$LOG_TAG" "$question"
  fi
  read -r value </dev/tty
  printf "%s" "${value:-$default}"
}
