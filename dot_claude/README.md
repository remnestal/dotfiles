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

## What goes in CLAUDE.md

`CLAUDE.md` is eager: it is in context before the first tool call. Skills and
`~/.claude/rules/*.md` are lazy -- a rule with `paths:` frontmatter loads only
once Claude opens a matching file, not from sitting in a matching repo (tested).

That decides where the Go table lives. Its job is to steer sessions onto the
commands `settings.json` allows -- `go test ./...` runs, `go test -run TestFoo
./pkg` prompts -- which only works if it arrives before the command is formed.
In `rules/` it would not: a session that opens with `go test` has not opened a
`.go` file yet, so it would hit the prompt first and read the advice second.

`rules/` suits guidance consulted *while* editing; a skill needs a procedure
with steps or scripts to be worth the indirection.

Keep it short either way; it is paid for on every session, Go or not.
