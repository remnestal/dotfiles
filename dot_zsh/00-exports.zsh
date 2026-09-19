# Environment variables and PATH

export EDITOR=vim
export VISUAL="$EDITOR"

export GOPATH="$HOME/go"

# Highest precedence first; $path holds whatever was inherited (Homebrew etc).
path=(
  "$HOME/.local/bin"
  "$GOPATH/bin"
  $path
  /usr/local/bin  # last: a no-op if inherited, never shadows anything
)

# Drop duplicates, and entries that aren't existing directories.
typeset -U path
path=(${^path}(N-/))
export PATH
