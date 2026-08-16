# claude

Applied to `~/.claude/`:

    CLAUDE.md                  instructions, loaded into every session
    settings.json              permissions, model, plugins, statusline
    executable_statusline.py   -> ~/.claude/statusline.py

## Overlay

`CLAUDE.md` ends with an import:

    @~/.local/share/dotfiles/claude/local.md

Put machine-local guidance there and it is added at the end. It is text, not
config, so nothing really overrides: when two lines disagree, Claude picks.
Being last and more specific usually settles it, but it is not a guarantee --
write the overlay so it does not contradict the base.

Imports do not glob. `@` takes one literal path per line, so there is no
`claude/*.md` slot the way zsh and brew have. To split the overlay up, add more
`@` lines inside `local.md` itself.

`settings.json` has no import mechanism, and is managed as a plain file.
