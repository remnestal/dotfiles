# Git status
gs() {
  git status
}

# Git commit with default signing key if set
gc() {
  if git config user.signingkey >/dev/null 2>&1; then
    git commit -S "$@"
  else
    git commit "$@"
  fi
}

# Git pull
gp() {
  git pull "$@"
}

# Git log with custom formatting
gl() {
  git log --pretty=format:'%C(blue)%h %C(yellow)%ad %C(white)(%G?) %C(blue)%an %C(white)%s' --date=short "$@"
}

# Git diff
gd() {
  git diff "$@"
}

# Git add 
ga() {
  git add "$@"
  git status
}

# Git add changes with patch, plus new and removed files
gap() {
  # Run interactive patch add for tracked files
  git add -p "$@"

  # Handle untracked files
  for file in $(git ls-files --others --exclude-standard -- "$@"); do
    while true; do
      printf "Add '%s'? [y/n] " "$file"
      read -r reply </dev/tty
      case "$reply" in
        y|Y)
          git add "$file"
          break
          ;;
        n|N)
          break
          ;;
        *)
          echo "Please answer y or n."
          ;;
      esac
    done
  done
  git status
}
