## Parent

trail-prd.md

## What to build

The thinnest possible end-to-end working slice. Add `:Trail` and `:TrailStop` commands. `:Trail` creates an in-memory session and opens a right-side split that shows a flat list of visited file paths, in visit order. `:TrailStop` ends active tracking but keeps the list in memory.

Track files via `BufEnter` — nothing fancy yet, just record every file enter. In the right-side split, highlight the current file, let `<CR>` open a file, and `q` close the split.

No folders, no edges, no colors, no suffixes. Flat list of paths. This validates the command → session → window wiring.

## Status

Done — implemented in `lua/trail/` and covered by `tests/trail_session_spec.lua`.

## Acceptance criteria

- [x] `:Trail` command exists and creates a session
- [x] `:TrailStop` command exists and stops tracking, preserving session data in memory
- [x] Right-side split opens on `:Trail`, fixed reasonable width
- [x] Flat list of all visited file paths appears, in visit order
- [x] Current file is visually highlighted in the list
- [x] Pressing `<CR>` on an item opens that file
- [x] Pressing `q` closes the trail split
- [x] `BufEnter` drives updates; each unique file is recorded once per entry
- [x] Unit tests for session start/stop state transitions and file list building

## Blocked by

None — can start immediately.
