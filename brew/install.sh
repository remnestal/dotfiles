#!/usr/bin/env bash
. "$(dirname "$0")/../common.sh"
LOG_TAG="BREW"

if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

PACKAGES="$(dirname "$0")/packages.txt"
if [ -f "$PACKAGES" ]; then
  while read -r pkg; do
    [ -z "$pkg" ] && continue
    case "$pkg" in \#*) continue ;; esac
    if brew list "$pkg" >/dev/null 2>&1; then
      log_ok "$pkg (already installed)"
      continue
    fi
    if prompt_yn "Install $pkg?"; then
      brew install "$pkg" </dev/null
    fi
  done < "$PACKAGES"
fi
