#!/usr/bin/env sh

echo_ssh() {
  echo "[SSH] $@"
}

SSH_DIR="$HOME/.ssh"

if [ -d "$SSH_DIR" ]; then
  echo_ssh "Found existing SSH keys:"
  ls -1 "$SSH_DIR"/id_*.pub 2>/dev/null | while read -r key; do
    echo_ssh "  - $(basename "$key" .pub)"
  done
  
  printf "[SSH] Create a new SSH key? [y/n] "
  read -r answer
  if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
    echo_ssh "Skipped creating new key"
    exit 0
  fi
else
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
fi

printf "[SSH] Enter your email for the new SSH key: "
read -r email

if [ -z "$email" ]; then
  echo_ssh "Email cannot be empty. Skipped."
  exit 0
fi

printf "[SSH] Key filename (default: id_ed25519): "
read -r keyname
keyname="${keyname:-id_ed25519}"
keypath="$SSH_DIR/$keyname"

if [ -f "$keypath" ]; then
  echo_ssh "Key $keyname already exists. Skipped."
  exit 0
fi

echo_ssh "Generating SSH key..."
ssh-keygen -t ed25519 -C "$email" -f "$keypath" -N ""
chmod 600 "$keypath"
chmod 644 "$keypath.pub"

echo_ssh "✓ SSH key created at $keypath"
echo_ssh "Public key:"
cat "$keypath.pub"
