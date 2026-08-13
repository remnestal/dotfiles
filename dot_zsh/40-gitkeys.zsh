# gitkeys -- wrapper around ~/.config/task/Taskfile.yml
#
# Passing -t explicitly rather than using `task -g`: global mode only reads
# $HOME/Taskfile.yml, and a bare `task` inside a project would pick up that
# project's Taskfile instead.

gitkeys() {
  task -t "$HOME/.config/task/Taskfile.yml" "${@:-status}"
}
