## Parent

trail-prd.md

## What to build

Provide project-root detection so the session can scope itself to a single project, but **do not auto-start a session from plugin code**. The user can opt in to auto-start via her own `VimEnter` autocmd or setup configuration.

Detect the project root via `git rev-parse --show-toplevel`. Ignore any file visited outside that project root (e.g. plugins, system config files).

The decision is **opt-in via user configuration**: the plugin never starts a session automatically. A user who wants auto-start can add something like:

```lua
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("trail").start()
  end,
})
```

Once a session is active, only files within the detected project root are recorded.

## Status

Partially done — decision recorded (opt-in via user config, no plugin-side auto-start). Project-root detection and file-scoping logic still needs implementation in `session.lua` or `tracker.lua`.

## Acceptance criteria

- [x] A decision on auto-start default behavior (opt-in via user config) is recorded in a comment or small doc
- [x] The plugin does **not** auto-start a session on startup; manual `:Trail` is required unless the user adds her own autocmd
- [ ] The project root is detected via `git rev-parse --show-toplevel`
- [ ] Files outside the detected root are silently ignored during session tracking
- [x] The manual `:Trail` command still works and starts a fresh session
- [ ] If root detection fails (not inside a git repo), behavior is defined (no scoping, or cwd fallback)
- [ ] Unit tests for root detection and file-scoping logic; mock git and file system for determinism

## Blocked by

- 01-session-commands-flat-trail
