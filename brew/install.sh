#!/usr/bin/env bash
. "$(dirname "$0")/../common.sh"
LOG_TAG="BREW"

if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

PACKAGES="$(dirname "$0")/packages.txt"
if [ -f "$PACKAGES" ]; then
  # Snapshot installed formulae+casks once; per-package `brew list` spawns a
  # slow brew process each time, so we check membership in-shell instead.
  INSTALLED=" $(brew list -1 2>/dev/null | tr '\n' ' ') "

  # Pre-pass: collect packages that need a decision (skip blanks, comments,
  # and already-installed), so numbering reflects only what gets prompted.
  TO_PROMPT=()
  while read -r pkg; do
    [ -z "$pkg" ] && continue
    case "$pkg" in \#*) continue ;; esac
    if [ "${INSTALLED#* $pkg }" != "$INSTALLED" ]; then
      log_ok "$pkg (already installed)"
      continue
    fi
    TO_PROMPT+=("$pkg")
  done < "$PACKAGES"

  # Pass 1: ask about everything up front, recording choices.
  TOTAL=${#TO_PROMPT[@]}
  TO_INSTALL=()
  i=0
  for pkg in "${TO_PROMPT[@]}"; do
    i=$((i + 1))
    if prompt_yn "[$i/$TOTAL] Install $pkg?"; then
      TO_INSTALL+=("$pkg")
    fi
  done

  # Pass 2: install everything marked yes in one swoop.
  if [ "${#TO_INSTALL[@]}" -gt 0 ]; then
    log "Installing: ${TO_INSTALL[*]}"
    brew install "${TO_INSTALL[@]}" </dev/null
  else
    log "Nothing to install."
  fi
fi
