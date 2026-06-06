# trail.nvim

An exploration-session plugin for Neovim that records files you view during a
manual session and displays them in a project-relative tree. File names are
colored by visit recency so the tree stays spatially stable while still showing
where you have been recently.

## Features

- Manual exploration sessions with `:Trail`, `:TrailStop`, and `:TrailReset`
- Tracks normal file buffers viewed while a session is active
- Project-scoped tree of visited files
- Recency-colored file names
- Tree view with file-only cursor navigation
- Zero dependencies

## Installation

### Using lazy.nvim

```lua
{ "yourusername/trail.nvim", opts = {} }
```

### Using built-in packages (no plugin manager)

```bash
git clone https://github.com/yourusername/trail.nvim \
  ~/.local/share/nvim/site/pack/trail/start/trail.nvim
```

Then in your init.lua:

```lua
require("trail").setup()
```

### Local development

Place or symlink the plugin directory into your Neovim pack path:

```bash
ln -s /path/to/trail.nvim ~/.config/nvim/pack/trail/start/trail
```

## Commands

| Command       | Description                              |
|---------------|------------------------------------------|
| `:Trail`      | Start an exploration trail session       |
| `:TrailStop`  | Stop tracking the active session         |
| `:TrailReset` | Clear the current session's trail data   |

## Usage

1. Run `:Trail` to start a session
2. Navigate code normally; every normal file buffer you view is tracked
3. The trail tree view opens automatically and updates as you explore
4. Move with `j`/`k`; navigation skips folders and lands only on files
5. Press `Enter` on a file in the tree to open it, or `q` to close the view
6. Run `:TrailReset` to clear the current trail without changing whether tracking is active

## Configuration

The plugin does not require any configuration. Call `setup()` once:

```lua
require("trail").setup()
```

Trail colors can be customized by recency. Any omitted value falls back to the default:

```lua
require("trail").setup({
  recency = {
    newest = "#ffb86c",
    oldest = "#6f8f72",
    steps = 6,
  },
})
```

For example, to only choose the freshest file color:

```lua
require("trail").setup({
  recency = {
    newest = "#c792ea",
  },
})
```

### Auto-start on launch

The plugin intentionally never auto-starts. Add your own autocmd if desired:

```lua
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() require("trail").start() end,
})
```

## Tests

Run individual test files from the plugin root:

```bash
nvim --headless -u NONE -c "lua dofile('tests/trail_session_spec.lua')" -c "qa!"
```

Or run all tests:

```bash
for f in tests/trail_*_spec.lua; do
  nvim --headless -u NONE -c "lua dofile('$f')" -c "qa!" || exit 1
done
```

You can also use the Makefile to run all tests:

```bash
make test
```

## Structure

```
lua/trail/
  init.lua     -- setup, commands, public API
  session.lua  -- state management
  tracker.lua  -- BufEnter-based file tracking
  view.lua     -- window management and rendering
  tree.lua     -- tree building from file records
  recency.lua  -- visit-recency highlight palette
```
