#!/usr/bin/env bash
. "$(dirname "$0")/../common.sh"
LOG_TAG="GPG"

if ! command -v gpg >/dev/null 2>&1; then
  log "GPG not installed. Skipping."
  exit 0
fi
# Ensure gpg-agent is configured to use pinentry-mac on macOS (Apple Silicon/Intel)
if command -v pinentry-mac >/dev/null 2>&1; then
  mkdir -p "$HOME/.gnupg"
  pinpath="/opt/homebrew/bin/pinentry-mac"
  if [ ! -x "$pinpath" ]; then
    pinpath="/usr/local/bin/pinentry-mac"
  fi
  if [ -x "$pinpath" ]; then
    if [ ! -f "$HOME/.gnupg/gpg-agent.conf" ] || ! grep -q "pinentry-program" "$HOME/.gnupg/gpg-agent.conf"; then
      log "Configuring GPG agent to use pinentry-mac ($pinpath)"
      echo "pinentry-program $pinpath" >> "$HOME/.gnupg/gpg-agent.conf"
      chmod 600 "$HOME/.gnupg/gpg-agent.conf"
      # restart gpg-agent so the change takes effect
      gpgconf --kill gpg-agent 2>/dev/null || true
    fi
  fi
fi

# List existing GPG keys
keys=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep "^sec" | awk '{print $2}' | cut -d'/' -f2)

if [ -n "$keys" ]; then
  log "Existing GPG key(s):"
  echo "$keys" | while read -r keyid; do
    fpr=$(gpg --with-colons --list-secret-keys "$keyid" 2>/dev/null | awk -F: '/^fpr:/ {print $10; exit}')
    uid=$(gpg --list-secret-keys --keyid-format=long "$keyid" 2>/dev/null | sed -n 's/^[ \t]*uid[ \t]*//p' | tr '\n' ' ' | sed 's/[ \t]*$//')
    log "$keyid  $fpr  $uid"
  done
  echo ""
fi

if ! prompt_yn "Create a new GPG key?"; then
  log_skip "creating GPG key"
  exit 0
fi

name=$(prompt_input "Enter your name")
email=$(prompt_input "Enter your email")
comment=$(prompt_input "Enter a comment for this key (e.g., 'Git signing key') [optional]")

if [ -z "$name" ] || [ -z "$email" ]; then
  log "Name and email cannot be empty. Skipped."
  exit 0
fi

log "Generating GPG key (this may take a moment)..."
gpg --batch --generate-key << EOF
Key-Type: EdDSA
Key-Curve: ed25519
Name-Real: $name
Name-Email: $email
Name-Comment: $comment
Expire-Date: 0
EOF

if [ $? -eq 0 ]; then
  keyid=$(gpg --list-secret-keys --keyid-format=long "$email" 2>/dev/null | grep "^sec" | awk '{print $2}' | cut -d'/' -f2 | head -1)
  log_ok "GPG key created with ID: $keyid"
else
  log "Failed to create GPG key"
  exit 1
fi
