#!/usr/bin/env bash
. "$(dirname "$0")/common.sh"
LOG_TAG="COPY"

copy_file() {
  src="$1"
  dest="$2"

  if [ -L "$dest" ]; then
    if cmp -s "$src" "$dest"; then
      rm "$dest" && cp "$src" "$dest"
      log_act "$dest (converted symlink to copy)"
      return
    fi
    git diff --no-index --color "$dest" "$src" || true
    if prompt_yn "Replace symlink $dest with repo version?"; then
      rm "$dest" && cp "$src" "$dest"
      log_act "Updated $dest"
    else
      log_skip "$dest"
    fi
    return
  fi

  if [ -e "$dest" ]; then
    if cmp -s "$src" "$dest"; then
      log_ok "$dest (up to date)"
      return
    fi
    git diff --no-index --color "$dest" "$src" || true
    if prompt_yn "Overwrite $dest?"; then
      cp "$src" "$dest"
      log_act "Updated $dest"
    else
      log_skip "$dest"
    fi
    return
  fi

  cp "$src" "$dest"
  log_act "Copied $dest"
}

mkdir -p "$HOME/.claude"
copy_file "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
