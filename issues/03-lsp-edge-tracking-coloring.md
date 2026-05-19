## Parent

explorer-prd.md

## What to build

Hook LSP jump handlers (`definition`, `reference`, `implementation`, `type_definition`) so that when an LSP navigation lands in a file, that file's edge type is recorded. Extend the file record to store per-edge-type visit counts.

Render each file's strongest (or only) edge type as a color on the file name in the tree. Display a basic suffix like `[def*2]` sorted by edge type. If a file was reached by both definition and reference, show both in the suffix.

Non-LSP navigations are still tracked as generic visits with no special edge type. The edge palette: definition (green), reference (sky), implementation (cyan), type_definition (blue).

## Status

Done — implemented with per-file edge records, LSP handler/request wrapping, suffix rendering, and edge highlights.

## Acceptance criteria

- [x] `vim.lsp.handlers` are wrapped for `textDocument/definition`, `textDocument/references`, `textDocument/implementation`, `textDocument/typeDefinition`
- [x] When an LSP navigation completes, the destination file records the edge type with an incremented count
- [x] Each file in the tree shows a suffix with its edge counts, e.g. `[def*2, ref*1]`, sorted by edge type
- [x] File names are colored by their strongest edge type; generic visits have no special color
- [x] LSP edge counts accumulate across multiple visits
- [x] Unit tests for edge recording and aggregation; integration tests verify handler wrapping triggers correctly

## Blocked by

- 02-folder-tree-sorting-pruning
