#!/usr/bin/env bash
. "$(dirname "$0")/../common.sh"
LOG_TAG="GITHUB"

# Register the SSH key (authentication) and GPG key (signing) with GitHub via gh.
# Each upload is independent: a skip/failure in one must not abort the other.

if ! command -v gh >/dev/null 2>&1; then
  log "gh not installed. Skipping."
  exit 0
fi

# --- Authentication -------------------------------------------------------
if ! gh auth status >/dev/null 2>&1; then
  log "Not logged in to GitHub."
  if prompt_yn "Log in now?"; then
    gh auth login
  fi
  if ! gh auth status >/dev/null 2>&1; then
    log_skip "GitHub key upload (not authenticated)"
    exit 0
  fi
fi

# Ensure the session has the scopes needed to manage SSH/GPG keys. Only refresh
# when a scope is actually missing, since `gh auth refresh` runs an interactive
# browser flow. Do NOT suppress stderr: gh prints the one-time code there.
current_scopes=$(gh auth status 2>&1 | sed -n 's/.*Token scopes: //p')
for scope in admin:public_key admin:gpg_key read:gpg_key; do
  case "$current_scopes" in
    *"$scope"*) ;;
    *)
      log "Requesting additional GitHub scopes (follow the browser prompt)..."
      gh auth refresh -h github.com -s admin:public_key -s admin:gpg_key -s read:gpg_key \
        || log "Could not refresh scopes; key uploads may fail."
      break
      ;;
  esac
done

# --- SSH key (authentication) ---------------------------------------------
ssh_pubs=$(ls -1 "$HOME/.ssh"/id_*.pub 2>/dev/null)
if [ -z "$ssh_pubs" ]; then
  log "No SSH public keys found in ~/.ssh. Skipping SSH upload."
else
  pubcount=$(printf "%s\n" "$ssh_pubs" | grep -c .)
  if [ "$pubcount" -gt 1 ]; then
    log "Multiple SSH public keys found:"
    printf "%s\n" "$ssh_pubs" | while read -r p; do log "  - $(basename "$p")"; done
    pubname=$(prompt_input "Which public key to upload?" "id_ed25519.pub")
    pubpath="$HOME/.ssh/$pubname"
  else
    pubpath="$ssh_pubs"
  fi

  if [ ! -f "$pubpath" ]; then
    log "SSH public key $pubpath not found. Skipping SSH upload."
  else
    # Duplicate guard: compare the key body (type + base64) against existing keys.
    keybody=$(awk '{print $1" "$2}' "$pubpath")
    if gh ssh-key list 2>/dev/null | grep -qF "$keybody"; then
      log_skip "SSH key upload (already on GitHub)"
    else
      default_title=$(scutil --get ComputerName 2>/dev/null || hostname -s 2>/dev/null || echo "dotfiles")
      title=$(prompt_input "Title for this SSH key" "$default_title")
      if gh ssh-key add "$pubpath" --type authentication --title "$title"; then
        log_ok "SSH key uploaded as authentication key"
      else
        log "Failed to upload SSH key."
      fi
    fi
  fi
fi

# --- GPG key (signing) ----------------------------------------------------
if ! command -v gpg >/dev/null 2>&1; then
  log "GPG not installed. Skipping GPG upload."
  exit 0
fi

keys=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep "^sec" | awk '{print $2}' | cut -d'/' -f2)
if [ -z "$keys" ]; then
  log "No GPG keys found. Skipping GPG upload."
  exit 0
fi

keycount=$(printf "%s\n" "$keys" | grep -c .)
if [ "$keycount" -gt 1 ]; then
  log "Multiple GPG keys found:"
  printf "%s\n" "$keys" | while read -r k; do log "  - $k"; done
  keyinput=$(prompt_input "Which GPG key ID or email to upload?")
else
  keyinput="$keys"
fi

# Resolve the long key id for duplicate detection.
keyid=$(gpg --list-secret-keys --keyid-format=long "$keyinput" 2>/dev/null \
  | grep "^sec" | awk '{print $2}' | cut -d'/' -f2 | head -1)

if [ -z "$keyid" ]; then
  log "GPG key not found. Skipping GPG upload."
  exit 0
fi

if gh gpg-key list 2>/dev/null | grep -qiF "$keyid"; then
  log_skip "GPG key upload (already on GitHub)"
else
  if gpg --armor --export "$keyid" | gh gpg-key add -; then
    log_ok "GPG key uploaded as signing key"
  else
    log "Failed to upload GPG key."
  fi
fi
