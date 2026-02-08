#!/usr/bin/env sh

echo_git() {
  echo "[GIT] $@"
}

GIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Check for existing GPG keys to sign commits with
if ! command -v gpg >/dev/null 2>&1; then
  echo_git "GPG not installed. Skipping commit signing setup."
  exit 0
fi

keys=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep "^sec" | awk '{print $2}' | cut -d'/' -f2)

if [ -z "$keys" ]; then
  echo_git "No GPG keys found. Run GPG setup first if you want to sign commits."
  exit 0
fi

echo_git "Available GPG keys:"
echo "$keys" | while read -r keyid; do
  fpr=$(gpg --with-colons --list-secret-keys "$keyid" 2>/dev/null | awk -F: '/^fpr:/ {print $10; exit}')
  uid=$(gpg --list-secret-keys --keyid-format=long "$keyid" 2>/dev/null | sed -n 's/^[ \t]*uid[ \t]*//p' | tr '\n' ' ' | sed 's/[ \t]*$//')
  echo_git "$keyid  $fpr  $uid"
done

printf "[GIT] Enter GPG key ID or email to use for signing: "
read -r keyinput

if [ -z "$keyinput" ]; then
  echo_git "Key ID or email cannot be empty. Skipped."
  exit 0
fi

# Resolve the full fingerprint for the provided key ID/email
keyfpr=$(gpg --with-colons --list-secret-keys "$keyinput" 2>/dev/null | awk -F: '/^fpr:/ {print $10; exit}')

if [ -z "$keyfpr" ]; then
  echo_git "Key not found. Skipped."
  exit 0
fi

mkdir -p "$GIT_DIR/git"
cat > "$GIT_DIR/git/gitconfig.local" << EOF
[user]
  signingkey = $keyfpr
[commit]
  gpgsign = true
EOF

echo_git "✓ Git configured to sign commits with key (fingerprint): $keyfpr"
