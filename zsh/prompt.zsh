
function preexec() {
  timer=$SECONDS
}

function precmd() {
  local exit_code=$?
  local status_text=""
  local timer_text=""
  local path="${PWD/#$HOME/~}"
  local path_color

  # Status + path color
  if (( exit_code == 0 )); then
    path_color="%F{green}"
    status_text="${path_color}✔%f"
  else
    path_color="%F{red}"
    status_text="${path_color}✘%f"
  fi

  # Execution time formatting
  if [[ -n "$timer" ]]; then
    local elapsed=$(( SECONDS - timer ))
    local h=$(( elapsed / 3600 ))
    local m=$(( (elapsed % 3600) / 60 ))
    local s=$(( elapsed % 60 ))

    if (( h > 0 )); then
      timer_text="${h}h${m}m${s}s"
    elif (( m > 0 )); then
      timer_text="${m}m${s}s"
    else
      timer_text="${s}s"
    fi

    timer_text="%F{cyan}${timer_text}%f"
    unset timer
  else
    timer_text="%F{cyan}--%f"
  fi

  PROMPT="%B${path_color}${path}%f ${status_text}%b "
  RPROMPT="(${exit_code}) %B%F{yellow}%D %*%f%b ${timer_text}"
}
