## Parent

trail-prd.md

## What to build

Automatically start an exploration session when Neovim opens inside a project. Detect the project root via `git rev-parse --show-toplevel`. Ignore any file visited outside that project root (e.g. plugins, system config files).

The key open question is **opt-in vs. opt-out**: should auto-start be the default, gated by a setup option, or should it require explicit enabling? Decide the intended default behavior and how a user opts in or out (setup function, global variable, or command).

Once decided, implement the auto-start logic and root scoping so the session only records files within the detected root.

## Status

Not started

## Acceptance criteria

- [ ] A decision on auto-start default behavior (opt-in vs. opt-out) is recorded in a comment or small doc
- [ ] When Neovim starts in a git-tracked directory, a session auto-starts if enabled
- [ ] The project root is detected via `git rev-parse --show-toplevel`
- [ ] Files outside the detected root are silently ignored during session tracking
- [ ] The manual `:Trail` command still works and starts a fresh session
- [ ] If root detection fails (not inside a git repo), behavior is defined (no auto-start, or cwd fallback)
- [ ] Unit tests for root detection and file-scoping logic; mock git and file system for determinism

## Blocked by

- 01-session-commands-flat-trail
