# Aliases

alias v='vim'
alias g='git'
alias kc='kubectl'
alias kz='kustomize'
alias cdp='cd ~/projects'
alias la='ls -lahG'
alias reload='source ~/.zshrc'

# Claude with the albilities plugin when its clone is present, plain claude
# otherwise. The clone is made by .chezmoiscripts/run_after_albilities.sh.tmpl.
# unalias first: a leftover `c` alias (say, after `reload`) would expand inside
# the function definition and break it.
unalias c 2>/dev/null
c() {
  local dir="$HOME/projects/albilities"
  if [[ -d $dir ]]; then
    claude --plugin-dir "$dir" "$@"
  else
    claude "$@"
  fi
}
