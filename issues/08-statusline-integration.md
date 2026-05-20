## Parent

trail-prd.md

## What to build

Expose a lightweight statusline component that reports session statistics: total files visited and total edge count across all files. This should be usable by any statusline plugin (lualine, mini.statusline, heirline, manual), not hard-wired to one.

The open question is the **integration surface**: should this be a module function that returns a string (e.g. `require("explore").statusline()`), or should it expose data structures and let the caller format? Decide before implementation.

Once the interface is chosen, implement it and provide a minimal example of usage with at least one common statusline plugin.

## Status

Not started

## Acceptance criteria

- [x] A decision on the integration surface (function vs. data API) is recorded
- [x] A public function or API returns session stats: files visited count and total edge count
- [x] The statusline information updates as the session evolves
- [x] An example snippet shows integration with at least one statusline plugin (e.g. lualine)
- [x] If no session is active, the statusline component shows a neutral/inactive state (e.g. empty string or "—")
- [x] Unit tests verify that stats are computed correctly from session state

## Blocked by

- 01-session-commands-flat-trail
