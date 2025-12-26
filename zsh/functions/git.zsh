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
      read -k 1 "reply?Add '$file'? [y/n]: "
      echo  # move to a new line after keypress

      if [[ $reply =~ ^[Yy]$ ]]; then
        git add "$file"
        break
      elif [[ $reply =~ ^[Nn]$ ]]; then
        break
      else
        echo "Please answer y or n."
      fi
    done
  done
  git status
}
