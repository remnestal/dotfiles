# dotfiles

chezmoi source dir.

`chezmoi apply` writes:

    dot_zshrc.tmpl     -> ~/.zshrc
    dot_zsh/           -> ~/.zsh/
    dot_gitconfig      -> ~/.gitconfig
    dot_vimrc          -> ~/.vimrc
    dot_Brewfile.tmpl  -> ~/.Brewfile
    dot_claude/        -> ~/.claude/   (settings, statusline)
    private_dot_ssh/   -> ~/.ssh/      (forge hosts only)
    dot_config/task/   -> ~/.config/task/Taskfile.yml

## Git keys

`gitkeys` (zsh wrapper around the Taskfile) manages the single SSH key git uses
for push/pull and commit signing. Nothing runs at init; it is on-demand.

    gitkeys setup     keygen + register + trust
    gitkeys login     ssh-add -t 8h   (the key has a passphrase and is not
                      loaded at login, so nothing can sign outside the window)
    gitkeys status    ssh-add -l, gh ssh-key list

Signing is SSH, not GPG (`gpg.format = ssh`), so there is no GPG key, no
gpg-agent and no pinentry. Verification needs `~/.config/git/allowed_signers`
-- without it `%G?` prints `N` even for your own commits; `gitkeys trust` adds
you to it.

It does not wrap `gh auth login`. If you are not authenticated, gh says so and
that is the error message.

`chezmoi init` asks once whether you use GitHub and/or GitLab, and stores the
answers in `~/.config/chezmoi/chezmoi.toml` (machine-local, not committed).

## Extending

Anything private or machine-specific goes in `~/.local/share/dotfiles/`, cloned
by hand. Nothing here creates or updates it, and everything works if it's
missing. Drop files in and they're picked up:

    zsh/*.zsh          sourced after ~/.zsh/*     sorted, last wins
    vim/*.vim          sourced after ~/.vimrc     sorted, last wins
    brew/*.Brewfile    eval'd into ~/.Brewfile    union, no override
    git/gitconfig      included last              last key wins

The merge models differ per tool, which is the only thing here worth
remembering:

- **zsh/vim** — re-sourced, so later files override earlier ones. Overlay
  numbering is its own namespace: overlay `00-` still runs after base `30-`.
- **brew** — no override exists; a package is installed or it isn't. Everything
  is unioned into one file so `brew bundle cleanup` sees the whole set.
- **git** — merges per key, not per section. The overlay owns its own
  `includeIf` rules for per-repo identity. `insteadOf` is multi-valued, so an
  overlay can add URL rewrites but never remove the ones in `dot_gitconfig`.
- **git can't glob.** `include.path` takes explicit paths only, so the overlay
  is one fixed file; split it further with its own `[include]` lines.
- **claude** has no include mechanism at all. `settings.json` is managed as a
  plain file with no overlay.
