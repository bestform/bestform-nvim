## Parent

trail-prd.md

## What to build

Upgrade the flat file list into a sorted, pruned folder tree. Group each visited file by its directory path within the project. Within each folder, files sort alphabetically. Folders sort alphabetically too. Only directories that contain at least one visited file appear; empty branches are pruned.

The tree is always fully expanded — no expand/collapse yet (that comes in a later slice). This slice turns the flat list into a navigable, clutter-free tree view.

## Status

Done — implemented by `lua/trail/tree.lua`, rendered from `lua/trail/view.lua`, and covered by `tests/trail_tree_spec.lua`.

## Acceptance criteria

- [x] Visited files are grouped by directory path into a tree structure
- [x] Files within each folder sort alphabetically
- [x] Folders sort alphabetically among siblings
- [x] Empty (unvisited) folders are hidden entirely
- [x] Each file line shows the file name only (indentation handled by tree rendering)
- [x] Existing `<CR>` open and `q` close behaviors still work
- [x] Unit tests for tree building from a flat file list; mock file system for deterministic assertion

## Blocked by

- 01-session-commands-flat-trail
