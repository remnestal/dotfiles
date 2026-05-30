#!/usr/bin/env sh
set -u

echo_copy() {
  echo "[COPY] $@"
}

DOTFILES_DIR="$(grealpath "$(dirname "$0")")"

copy_file() {
  src="$1"
  dest="$2"

  if [ -L "$dest" ]; then
    if cmp -s "$src" "$dest"; then
      rm "$dest" && cp "$src" "$dest"
      echo_copy "→ $dest (converted symlink to copy)"
      return
    fi
    git diff --no-index --color "$dest" "$src" || true
    printf "[COPY] Replace symlink %s with repo version? [y/n] " "$dest"
    read -r answer </dev/tty
    case "$answer" in
      y|Y) rm "$dest" && cp "$src" "$dest"; echo_copy "→ Updated $dest" ;;
      *) echo_copy "✓ Skipped $dest" ;;
    esac
    return
  fi

  if [ -e "$dest" ]; then
    if cmp -s "$src" "$dest"; then
      echo_copy "✓ $dest (up to date)"
      return
    fi
    git diff --no-index --color "$dest" "$src" || true
    printf "[COPY] Overwrite %s? [y/n] " "$dest"
    read -r answer </dev/tty
    case "$answer" in
      y|Y) cp "$src" "$dest"; echo_copy "→ Updated $dest" ;;
      *) echo_copy "✓ Skipped $dest" ;;
    esac
    return
  fi

  cp "$src" "$dest"
  echo_copy "→ Copied $dest"
}

mkdir -p "$HOME/.claude"
copy_file "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
