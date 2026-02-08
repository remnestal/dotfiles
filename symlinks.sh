#!/usr/bin/env sh
set -u

echo_symlinks() {
  echo "[SYMLINKS] $@"
}

DOTFILES_DIR="$(grealpath "$(dirname "$0")")"

link_file() {
  src="$1"
  dest="$2"

  if [ -L "$dest" ]; then
    target="$(readlink "$dest")"
    if [ "$target" = "$src" ]; then
      echo_symlinks "✓ Skipping $dest (already linked)"
      return
    else
      echo_symlinks "✓ Skipping $dest (symlink points to $target, not $src)"
      return
    fi
  elif [ -e "$dest" ]; then
    echo_symlinks "$dest (file exists, not a symlink)"
    return
  fi

  printf "[SYMLINKS] Create symlink for %s? [y/n] " "$dest"
  read -r answer
  case "$answer" in
    y|Y)
      ln -s "$src" "$dest"
      echo_symlinks "→ Linked $dest → $src"
      ;;
    *)
      echo_symlinks "✓ Skipped $dest"
      ;;
  esac
}

link_file "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/git/gitconfig.local" "$HOME/.gitconfig.local"
link_file "$DOTFILES_DIR/vi/vimrc" "$HOME/.vimrc"
