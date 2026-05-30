#!/usr/bin/env sh

GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

echo_brew() {
  printf "[BREW] $@\n"
}

BREW_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo_brew "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

PACKAGES="$BREW_DIR/packages.txt"
if [ -f "$PACKAGES" ]; then
  while read -r pkg; do
    [ -z "$pkg" ] && continue
    case "$pkg" in \#*) continue ;; esac
    if brew list "$pkg" >/dev/null 2>&1; then
      echo_brew "✓ $pkg (already installed)"
      continue
    fi
    while true; do
      printf "[BREW] Install %s? [y/n] " "$pkg"
      read -r -s -n1 reply </dev/tty
      case "$reply" in
        y|Y)
          printf "y ${GREEN}→ yes${RESET}\n"
          brew install "$pkg" </dev/null
          break
          ;;
        n|N)
          printf "n ${RED}→ no${RESET}\n"
          break
          ;;
        *)
          printf "\n"
          ;;
      esac
    done
  done < "$PACKAGES"
fi
