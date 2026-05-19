# PRD: Neovim Exploration Session Plugin

## Problem Statement

When exploring unfamiliar codebases, developers lose track of their mental map of file relationships. They forget which files they've visited and how those files connect through definitions, references, and other navigation patterns. This leads to redundant exploration and difficulty communicating exploration paths to teammates.

## Solution

An exploration session plugin that automatically tracks file visits during navigation and displays an interactive tree view showing visited files with visit counts by navigation type (definition, reference, search, etc.). The plugin creates a visual mental map of the exploration through color-coded nodes and structured folder hierarchy.

## User Stories

1. As a developer starting to explore a codebase, I want to start an exploration session with a command, so that I can begin tracking my navigation automatically.
2. As a developer opening Neovim in a project, I want a new exploration session to start automatically, so that I don't lose my exploration context.
3. As a developer navigating code, I want the plugin to track when I visit files via LSP definition/reference jumps, so that strong code relationships are captured.
4. As a developer using file trees or search, I want the plugin to track those navigations too, so that all exploration paths are recorded.
5. As a developer viewing my exploration, I want files sorted alphabetically within folders, so that I can quickly find files in the tree.
6. As a developer viewing my exploration, I want folders that contain no visited files to be hidden, so that the tree isn't cluttered with irrelevant directories.
7. As a developer viewing my exploration, I want each file to show a suffix with visit counts by type, so that I can see how I reached each file.
8. As a developer viewing my exploration, I want strong connections (LSP definition) shown with green color and weak connections (search) with gray, so that connection strength is visually apparent.
9. As a developer viewing my exploration, I want the tree to always be fully expanded, so that I can see the complete exploration at a glance.
10. As a developer navigating to a file, I want to see that file highlighted in the explorer, so that I know where I am in my exploration.
11. As a developer pressing Enter on a file in the tree, I want that file to open, so that I can navigate quickly.
12. As a developer pressing 'l' on a folder, I want to expand it, so that I can explore subfolders.
13. As a developer pressing 'h' on an expanded folder, I want to collapse it, so that I can declutter the view.
14. As a developer pressing 'q', I want the explorer window to close, so that I can dismiss it when not needed.
15. As a developer viewing an old file, I want it to remain dimmed in the tree, so that I can distinguish already-explored from current exploration.
16. As a developer who visited a file multiple times, I want the visit counts to accumulate, so that I can see my exploration intensity.
17. As a developer visiting the same file via different methods, I want both edge types to be recorded, so that I capture the full exploration path.
18. As a developer viewing my exploration stats, I want some statusline integration (if lightweight), so that I can see session progress at a glance.
19. As a developer stopping exploration, I want to keep the session data in memory, so that I can resume viewing the tree.
20. As a developer visiting files outside the project root, I want them to be ignored, so that the exploration stays focused on the project.

## Implementation Decisions

- **Architecture**: Four core modules - `init.lua` (setup/commands), `session.lua` (state), `explorer.lua` (window management), `tracker.lua` (BufEnter handling)
- **Session Management**: In-memory only, auto-starts on project load via BufEnter detection, manual `:Trail` and `:TrailStop` commands
- **Project Root**: Detected via git root (`git rev-parse --show-toplevel`) 
- **Edge Types**: definition (green), reference (sky), implementation (cyan), type_definition (blue), file_tree (lavender), search (yellow), buffer_switch (gray)
- **Tree View**: Split window on right side, fixed width, always expanded, alphabetical sorting within folders
- **File Display**: Color-coded by strongest connection type, dimmed for previously visited files
- **Suffix Format**: `[def*N, ref*N, search*N]` sorted by edge type, showing accumulated visit counts
- **Auto-update**: Window refreshes on every BufEnter event with debounce handling if needed
- **Statusline**: Optional lightweight integration showing files visited and edge count
- **Folder Handling**: Directories only shown if they contain visited files, sorted alphabetically

## Testing Decisions

- **Good tests**: Test external behavior (tree viewing, navigation, edge recording) rather than implementation details
- **Tested modules**: `session.lua` (state management), `tracker.lua` (edge detection and recording), `explorer.lua` (window rendering)
- **Test approach**: Unit tests for session state transitions, integration tests for BufEnter flow, mock file system for tree building
- **Prior art**: Following TDD patterns from existing neovim plugin development

## Out of Scope

- Graph visualization view (edge connection diagrams)
- Session persistence to disk
- Multiple parallel sessions
- Session naming or manual session management
- Performance optimization (throttling, caching) until proven necessary
- Integration with neo-tree file browser
- Mobile or external team sharing features

## Further Notes

This PRD synthesizes a thorough exploration planning session that clarified the difference between folder-tree and graph views. The folder-tree view provides immediate practical value while the graph view remains a future enhancement. The plugin focuses on simplicity and immediate utility over comprehensive analysis features.