#!/usr/bin/env sh
set -u

prompt_section() {
  local name="$1"
  local script="$2"
  
  printf "Run %s? [y/n] " "$name"
  read -r answer
  case "$answer" in
    y|Y)
      echo "============================"
      echo "$name"
      echo "============================"
      /bin/sh "$script"
      ;;
    *)
      echo "Skipped $name"
      ;;
  esac
}

prompt_section "Installing Homebrew packages" "./brew/install.sh"
prompt_section "Setting up symlinks" "./symlinks.sh"
prompt_section "Setting up SSH keys" "./ssh/setup.sh"
