#!/usr/bin/env bash
. "$(dirname "$0")/common.sh"
LOG_TAG="SETUP"

prompt_section() {
  local name="$1"
  local script="$2"

  if prompt_yn "Run: $name?"; then
    bash "$script"
  fi
}

prompt_section "Install Homebrew packages" "./brew/install.sh"
prompt_section "Set up SSH keys" "./ssh/setup.sh"
prompt_section "Set up GPG keys" "./gpg/setup.sh"
prompt_section "Configure Git" "./git/setup.sh"
prompt_section "Set up symlinks" "./symlinks.sh"
prompt_section "Copy config files" "./copy.sh"
