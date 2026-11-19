# Prompt

autoload -Uz add-zsh-hook

# Named directory: %~ renders ~/projects/foo as ~p/foo, and `cd ~p/foo` works.
hash -d p="$HOME/projects"

# Dot for whether git can sign: green when id_git is in the agent, yellow when
# only other keys are, red when none. Twin of agent_color() in the Claude
# statusline. Checked every prompt because `gitkeys login` sets a TTL.
# Helpers set REPLY instead of printing, to skip a subshell per call.
_prompt_agent_dot() {
  local out line key
  local -a loaded
  # ssh-add -L exits 1 and prints "no identities" text when the agent is empty.
  out=$(ssh-add -L 2>/dev/null) || out=""
  for line in ${(f)out}; do
    loaded+=(${${=line}[2]})
  done
  [[ -r ~/.ssh/id_git.pub ]] && key=${${=$(<~/.ssh/id_git.pub)}[2]}

  if [[ -n $key ]] && (( ${loaded[(Ie)$key]} )); then
    REPLY="%F{green}●%f"
  elif (( $#loaded )); then
    REPLY="%F{yellow}●%f"
  else
    REPLY="%F{red}●%f"
  fi
}

# " (branch)", " (@sha)" when detached, or nothing outside a repo.
# symbolic-ref first: it also works in a fresh repo with no commits.
_prompt_git() {
  local ref
  REPLY=""
  if ! ref=$(git symbolic-ref --short -q HEAD 2>/dev/null); then
    ref=$(git rev-parse --short HEAD 2>/dev/null) || return
    ref="@$ref"
  fi
  REPLY=" (%F{magenta}${ref//\%/%%}%f)"
}

_prompt_preexec() {
  timer=$SECONDS
}

_prompt_precmd() {
  local exit_code=$?
  local status_text=""
  local timer_text=""
  local path_color dot git

  # Status + path color
  if (( exit_code == 0 )); then
    path_color="%F{green}"
    status_text="${path_color}✔%f"
  else
    path_color="%F{red}"
    status_text="${path_color}✘ ${exit_code}%f"
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

  _prompt_agent_dot; dot=$REPLY
  _prompt_git; git=$REPLY

  PROMPT="${dot} %B${path_color}%~%f%b${git} %B${status_text}%b "
  RPROMPT="%F{242}%D %*%f ${timer_text}"
}

add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd _prompt_precmd
