# Standard toolbox

Prefer these over ad-hoc invocations. A repo's own docs (Makefile, Taskfile,
project CLAUDE.md) win — they are more specific.

## Go

**Verify a change:** build → format → vet → lint → test.
Add race + vulns before a release or a merge that touches concurrency.

| Step   | Command                   | Notes                                         |
| ------ | ------------------------- | --------------------------------------------- |
| Build  | `go build ./...`          | Compile check; discards output for multi-pkg  |
| Format | `gofumpt -w .`            | Skips vendor/ and testdata/; `-l .` to list   |
| Vet    | `go vet ./...`            | `go test` already runs a vet subset           |
| Lint   | `golangci-lint run ./...` | Scoped to cwd — run from the module root      |
| Test   | `go test ./...`           | Per-package cache makes repeat runs cheap     |
| Race   | `go test -race ./...`     | Slow, needs CGO_ENABLED=1 — not per-iteration |
| Vulns  | `govulncheck ./...`       | Network; only reports *reachable* vulns       |
| Deps   | `go mod tidy`             | Then `go mod verify` to check checksums       |

**Test the whole module.** `go test ./...` re-runs only packages whose inputs
changed, so narrowing with `-run` or a package path saves little and hides
regressions elsewhere. Use `-count=1` to defeat the cache when a test depends on
external state, and `-race` when touching concurrency.

`golangci-lint --fix` and `gofumpt -w` rewrite source — re-read files after.

@~/.local/share/dotfiles/claude/local.md
