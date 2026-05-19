## Parent

explorer-prd.md

## Status

Done — implemented in `lua/explorer/explorer.lua` and covered by `tests/explorer_expand_collapse_spec.lua`.

## What to build

Add expand/collapse interactivity to the folder tree. Press `l` on a folder to expand it; press `h` on an expanded folder to collapse it. Track per-folder expand/collapse state so that the tree remembers the user's layout across refreshes.

This is independent of edge tracking and can be built as soon as the folder tree exists. The tree may start fully expanded or fully collapsed; either is acceptable, but the behavior must be consistent.

## Acceptance criteria

- [x] Pressing `l` on a collapsed folder expands it
- [x] Pressing `h` on an expanded folder collapses it
- [x] Pressing `l` on a file or leaf does nothing (or opens it, if that aligns with common tree UX)
- [x] Pressing `h` on a collapsed folder or file does nothing
- [x] Tree refreshes preserve expand/collapse state per folder
- [x] The current file remains visible and highlighted regardless of folder state
- [x] Unit tests for expand/collapse state transitions and tree rendering with mixed states

## Blocked by

- 02-folder-tree-sorting-pruning
