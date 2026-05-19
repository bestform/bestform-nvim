## Parent

trail-prd.md

## What to build

Final visual polish for the edge system. When a file has been visited via multiple navigation methods, show a combined suffix that includes all recorded edge types and their counts (e.g. `[def*2, ref*1, search*3]`), sorted alphabetically by edge type.

The file's name color is determined by its "strongest" edge relationship — defined by a priority order: definition > implementation > type_definition > reference > file_tree > search > buffer_switch.

Files that were visited in the past but are not the currently active file should appear dimmed. This helps distinguish "current exploration context" from "already seen."

## Status

Done — implemented in `lua/trail/edges.lua` (alphabetical suffix + strongest priority), `lua/trail/view.lua` (dimming via `TrailDim`), and covered by `tests/trail_multi_edge_spec.lua`.

## Acceptance criteria

- [x] Files with multiple edge types show a combined suffix `[type*count, type*count]` sorted alphabetically
- [x] File name color follows strongest-wins priority: definition > implementation > type_definition > reference > file_tree > search > buffer_switch
- [x] Non-current files are rendered dimmed (reduced brightness / grayed)
- [x] The active (current) file is never dimmed and renders at full color brightness
- [x] Edge counts continue to accumulate across multiple visits
- [x] Unit tests verify priority ordering and combined suffix formatting

## Blocked by

- 04-non-lsp-edge-detection
