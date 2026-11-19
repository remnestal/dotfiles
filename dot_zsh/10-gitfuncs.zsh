# Git functions

# Git status
gs() {
  git status
}

# Git commit. Signing is handled by commit.gpgsign in ~/.gitconfig.
gc() {
  git commit "$@"
}

# Git pull
gp() {
  git pull "$@"
}

# Git log with custom formatting, post-processed per commit line:
#   \x01<parents>\x01<hash>\x02<date>\x03<%G?><subject and the rest>
# Two parents mean a merge, grayed after the hash. The %G? letter becomes a
# mark: ✔ trusted, ? unverifiable, ✘ unsigned, ! bad/expired/revoked.
# Colour only on a terminal.
gl() {
  local color=never
  local -a pager=(cat)
  if [[ -t 1 ]]; then
    color=always
    pager=(less -FRX)
  fi
  local filter='
    my %glyph = (G => "✔", U => "?", E => "?", N => "✘");
    my %code  = (G => "32", U => "38;5;242", E => "38;5;242", N => "31");
    s{\x01([^\x01]*)\x01([^\x02]*)\x02([^\x03]*)\x03(.)(.*)}{
      my ($p, $h, $d, $s, $r) = ($1, $2, $3, $4, $5);
      my $g = $glyph{$s} // "!";
      if ($ENV{GL_COLOR}) {
        if ($p =~ / /) { $r =~ s/\e\[[0-9;]*m//g; $r = "\e[38;5;242m$r\e[0m" }
        $g = "\e[" . ($code{$s} // "1;31") . "m$g\e[0m";
      }
      "$h$d$g$r"
    }e;
  '
  git log --graph --date=short --color=$color \
    --decorate-refs-exclude=refs/remotes/origin/HEAD \
    --pretty=format:'%x01%p%x01%C(yellow)%h%C(reset)%x02 %C(242)%ad%C(reset) %x03%G? %s%C(auto)%d%C(reset) %C(242)· %an%C(reset)' "$@" |
    GL_COLOR=${${(M)color:#always}:+1} perl -pe "$filter" |
    "${pager[@]}"
}

# Git diff
gd() {
  git diff "$@"
}

# Git diff staged changes
gsd() {
  git diff --staged "$@"
}

# Git add
ga() {
  git add "${@:-.}"
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
