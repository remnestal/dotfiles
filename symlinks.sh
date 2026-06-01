#!/usr/bin/env bash
. "$(dirname "$0")/common.sh"
LOG_TAG="SYMLINKS"

link_file() {
  src="$1"
  dest="$2"

  if [ -L "$dest" ]; then
    target="$(readlink "$dest")"
    if [ "$target" = "$src" ]; then
      log_ok "$dest (already linked)"
    else
      log_ok "$dest (symlink points to $target, not $src)"
    fi
    return
  elif [ -e "$dest" ]; then
    log "$dest (file exists, not a symlink)"
    return
  fi

  if prompt_yn "Create symlink for $dest?"; then
    ln -s "$src" "$dest"
    log_act "Linked $dest → $src"
  else
    log_skip "$dest"
  fi
}

link_file "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/git/gitconfig.local" "$HOME/.gitconfig.local"
link_file "$DOTFILES_DIR/vi/vimrc" "$HOME/.vimrc"

mkdir -p "$HOME/.claude"
link_file "$DOTFILES_DIR/claude/statusline.py" "$HOME/.claude/statusline.py"
