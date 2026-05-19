## Parent

explorer-prd.md

## What to build

Detect how the user arrived at a file when it was **not** an LSP jump. We need reliable heuristics for at least:
- Buffer switch (e.g. `:bnext`, `<C-^>`, buffer pickers)
- Search result (e.g. Telescope, fzf-lua)
- File tree selection (e.g. neo-tree, netrw, `:e path`)

This is inherently heuristic and needs a design decision before implementation. Options to evaluate:
1. **LruHistory tracker**: Maintain an LRU of recent \[file, method\] pairs; if `BufEnter` fires on a file that a non-LSP tool just opened, attribute the known method.
2. **Integration hooks**: Provide small adapter modules for Telescope/neo-tree/etc. that push an intent before navigation.
3. **Timer-based heuristic**: If no edge type was recorded within a short window after `BufEnter`, infer from context (e.g. was a Telescope or neo-tree buffer focused recently?).

Evaluate these approaches. The acceptance criteria below should be met by whichever approach we choose, but the specifics will depend on the decision.

## Status

Done — implemented via contextual `BufLeave`/`WinLeave` heuristic in `lua/explorer/tracker.lua`, with new edge types and colors in `lua/explorer/edges.lua`, and covered by `tests/explorer_non_lsp_tracking_spec.lua`.

## Acceptance criteria

- [x] A design for non-LSP edge detection is documented (in comments or a small DESIGN.md snippet)
- [x] Buffer switches are detected and recorded under edge type `buffer_switch`
- [x] Telescope (or primary search tool) selections are detected and recorded under edge type `search`
- [x] neo-tree (or primary file tree) selections are detected and recorded under edge type `file_tree`
- [x] Each non-LSP edge type has a color: file_tree (lavender), search (yellow), buffer_switch (gray)
- [x] Unit tests validate heuristic decisions (mock telescope/neo-tree events, verify correct edge attribution)

## Blocked by

- 03-lsp-edge-tracking-coloring
