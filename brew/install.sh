#!/usr/bin/env sh

echo_brew() {
  echo "[BREW] $@"
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
    else
      echo_brew "→ Installing $pkg..."
      brew install "$pkg" </dev/null
    fi
  done < "$PACKAGES"
fi
