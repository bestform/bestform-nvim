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

Done — root detection via `git rev-parse`, project-root scoping in `session.lua`, tree rendering uses session root, and covered by `tests/trail_project_scoping_spec.lua`.

## Acceptance criteria

- [x] A decision on auto-start default behavior (opt-in via user config) is recorded in a comment or small doc
- [x] The plugin does **not** auto-start a session on startup; manual `:Trail` is required unless the user adds her own autocmd
- [x] The project root is detected via `git rev-parse --show-toplevel`
- [x] Files outside the detected root are silently ignored during session tracking
- [x] The manual `:Trail` command still works and starts a fresh session
- [x] If root detection fails (not inside a git repo), behavior is defined (cwd fallback)
- [x] Unit tests for root detection and file-scoping logic; mock git and file system for determinism

## Blocked by

- 01-session-commands-flat-trail
