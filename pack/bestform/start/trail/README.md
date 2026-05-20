# trail.nvim

An exploration session plugin for Neovim that automatically tracks file visits
and displays an interactive tree view showing visited files with visit counts
by navigation type (definition, reference, search, etc.).

## Features

- Tracks file visits via LSP jumps, file trees, search pickers, and buffer switches
- Color-coded edge types to show connection strength
- Interactive tree view with folder expansion/collapse
- Statusline integration
- Zero dependencies

## Installation

### Using lazy.nvim

```lua
{ "yourusername/trail.nvim", config = function() require("trail").setup() end }
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

| Command      | Description                              |
|--------------|------------------------------------------|
| `:Trail`     | Start an exploration trail session       |
| `:TrailStop` | Stop tracking the active session         |

## Usage

1. Run `:Trail` to start a session
2. Navigate code normally — jumps via LSP, file trees, and search are tracked automatically
3. The trail tree view opens automatically and updates as you explore
4. Press `Enter` on a file in the tree to open it
5. Press `l` to expand folders, `h` to collapse, `q` to close the view

## Configuration

The plugin does not require any configuration. Call `setup()` once:

```lua
require("trail").setup()
```

### Auto-start on launch

The plugin intentionally never auto-starts. Add your own autocmd if desired:

```lua
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() require("trail").start() end,
})
```

### Statusline

```lua
-- lualine.nvim example
{
  function() return require("trail").statusline() end,
  color = { fg = "#5c6370" },
}
```

## Tests

Run individual test files from the plugin root:

```bash
nvim -u NONE -c "lua dofile('tests/trail_session_spec.lua')" -c "q"
```

Or run all tests:

```bash
for f in tests/trail_*_spec.lua; do
  nvim -u NONE -c "lua dofile('$f')" -c "q" || exit 1
done
```

## Structure

```
lua/trail/
  init.lua     -- setup, commands, public API
  session.lua  -- state management
  tracker.lua  -- BufEnter / LSP / UI edge detection
  view.lua     -- window management and rendering
  tree.lua     -- tree building from file records
  edges.lua    -- edge type definitions and formatting
```
