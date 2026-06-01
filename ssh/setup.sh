#!/usr/bin/env bash
. "$(dirname "$0")/../common.sh"
LOG_TAG="SSH"

SSH_DIR="$HOME/.ssh"

if [ -d "$SSH_DIR" ]; then
  log "Found existing SSH keys:"
  ls -1 "$SSH_DIR"/id_*.pub 2>/dev/null | while read -r key; do
    log "  - $(basename "$key" .pub)"
  done

  if ! prompt_yn "Create a new SSH key?"; then
    log_skip "creating new key"
    exit 0
  fi
else
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
fi

email=$(prompt_input "Enter your email for the new SSH key")

if [ -z "$email" ]; then
  log "Email cannot be empty. Skipped."
  exit 0
fi

keyname=$(prompt_input "Key filename" "id_ed25519")
keypath="$SSH_DIR/$keyname"

if [ -f "$keypath" ]; then
  log "Key $keyname already exists. Skipped."
  exit 0
fi

log "Generating SSH key..."
ssh-keygen -t ed25519 -C "$email" -f "$keypath" -N ""
chmod 600 "$keypath"
chmod 644 "$keypath.pub"

log_ok "SSH key created at $keypath"
log "Public key:"
cat "$keypath.pub"
