---
phase: 02-stow-package-migration
plan: 03
subsystem: neovim
tags: [neovim, lua, lazy.nvim, lsp, treesitter, stow-package]
dependency-graph:
  requires: []
  provides: [nvim-stow-package, neovim-config]
  affects: [dotfiles-structure]
tech-stack:
  added: [lazy.nvim, nvim-lspconfig, mason.nvim, nvim-cmp, nvim-treesitter, telescope.nvim, catppuccin]
  patterns: [lazy-loading, plugin-modularization]
key-files:
  created:
    - nvim/.config/nvim/init.lua
    - nvim/.config/nvim/lua/plugins/lsp.lua
    - nvim/.config/nvim/lua/plugins/editor.lua
    - nvim/.config/nvim/lua/plugins/ui.lua
  modified: []
decisions:
  - Use lazy.nvim for plugin management (modern, fast, lazy-loading)
  - Organize plugins by concern (lsp, editor, ui) not by plugin name
  - Include mason for automatic LSP server installation
  - Use catppuccin colorscheme for consistent UI
  - Set leader key before lazy.nvim loads (requirement)
  - Keep config minimal and self-explanatory (under 250 total lines)
metrics:
  duration: 133
  completed: 2026-02-14
---

# Phase 02 Plan 03: Neovim Stow Package Summary

**One-liner:** Created from-scratch Neovim config with lazy.nvim plugin management, LSP auto-install via mason, Treesitter syntax highlighting, and Telescope file navigation

## What Was Built

Created the `nvim/` Stow package with a lightweight, self-explanatory Neovim configuration using Lua and lazy.nvim. This is a minimal, readable config (not a distribution like LazyVim) that provides essential IDE features out of the box.

### Directory Structure

```
nvim/
└── .config/
    └── nvim/
        ├── init.lua                    # Entry point (66 lines)
        └── lua/
            └── plugins/
                ├── lsp.lua             # LSP + completion (82 lines)
                ├── editor.lua          # Treesitter, Telescope, editing (40 lines)
                └── ui.lua              # Colorscheme, statusline, visual aids (44 lines)
```

### Core Features

**Plugin Management (lazy.nvim)**
- Auto-installs if missing on first launch
- Plugins organized by concern in `lua/plugins/`
- Lazy-loading for performance
- Rounded borders, no auto-update notifications

**LSP Support (nvim-lspconfig + mason.nvim)**
- Automatic language server installation for: lua_ls, ts_ls, jsonls
- LSP keymaps: gd (definition), gr (references), K (hover), <leader>rn (rename), <leader>ca (code action)
- Diagnostic navigation: [d and ]d

**Completion (nvim-cmp)**
- Sources: LSP, snippets, buffer, path
- Keymaps: <C-n>/<C-p> (navigate), <C-y> (confirm), <C-Space> (trigger)

**Syntax Highlighting (nvim-treesitter)**
- Installed parsers: lua, javascript, typescript, json, yaml, markdown, bash, vim, vimdoc
- Treesitter-based indentation

**File Navigation (telescope.nvim)**
- Keymaps: <leader>ff (files), <leader>fg (grep), <leader>fb (buffers), <leader>fh (help)

**Editor Enhancements**
- Comment.nvim: gcc to toggle comments
- nvim-surround: ys, ds, cs for surrounding text
- nvim-autopairs: auto-close brackets/quotes

**UI**
- Colorscheme: catppuccin
- Statusline: lualine with catppuccin theme
- Indent guides: indent-blankline
- Git integration: gitsigns (shows changes in gutter)
- Keybinding hints: which-key (shows available keys)

**Core Settings**
- Line numbers (relative + absolute)
- System clipboard integration
- Persistent undo
- Smart case-insensitive search
- Sensible splits (right, below)
- 2-space indentation
- Cursorline highlight
- Window navigation: <C-h/j/k/l>

### Plugin Count

Total plugins: 21 (within reasonable range for a functional setup)

**LSP/Completion:** 6 plugins (lspconfig, mason, mason-lspconfig, nvim-cmp, luasnip, cmp sources)
**Editor:** 5 plugins (treesitter, telescope, Comment, surround, autopairs)
**UI:** 6 plugins (catppuccin, lualine, nvim-web-devicons, indent-blankline, gitsigns, which-key)
**Dependencies:** 4 plugins (plenary, luasnip, cmp_luasnip, nvim-web-devicons)

## Tasks Completed

### Task 1: Create init.lua with lazy.nvim bootstrap
**Status:** Complete
**Commit:** d5960e8
**Files:** nvim/.config/nvim/init.lua, nvim/.config/nvim/lua/plugins/

Created the Neovim entry point with:
- Leader key configuration (before lazy.nvim)
- lazy.nvim auto-install bootstrap
- Plugin loading from lua/plugins/
- Core vim options (18 settings)
- Essential keymaps (window navigation, diagnostic navigation, search clear)
- File size: 66 lines (under 80-line target)

### Task 2: Create plugin specs for LSP, editor features, and UI
**Status:** Complete
**Commit:** 5ee3224
**Files:** nvim/.config/nvim/lua/plugins/lsp.lua, editor.lua, ui.lua

Created three plugin spec files:
- **lsp.lua:** nvim-lspconfig with mason auto-install, nvim-cmp completion
- **editor.lua:** Treesitter, Telescope, Comment, surround, autopairs
- **ui.lua:** catppuccin, lualine, indent guides, gitsigns, which-key

All plugins lazy-load appropriately (InsertEnter, VeryLazy, or on keymap trigger).

## Verification Results

- [x] nvim/.config/nvim/ structure exists with init.lua and lua/plugins/
- [x] init.lua bootstraps lazy.nvim and loads plugins from lua/plugins/
- [x] LSP configured with mason for automatic server installation
- [x] Treesitter syntax highlighting for common languages
- [x] Telescope file finding and live grep
- [x] Colorscheme, statusline, and visual aids configured
- [x] `stow -n nvim` dry run succeeds
- [x] Total config: 232 lines (reasonable for functionality provided)
- [x] All files are self-explanatory with clear comments

## Deviations from Plan

None - plan executed exactly as written. The plugin count is 21 (1 over the suggested 20), but this is because the plan specified these exact plugins and they're all essential for the minimal working configuration.

## Dependencies

**Requires:** None (fresh Stow package)

**Provides:**
- `nvim/` Stow package ready for `stow nvim`
- Neovim configuration at `~/.config/nvim/` after stowing
- Auto-installing plugin system (lazy.nvim)
- LSP, completion, syntax highlighting, file navigation out of the box

**Affects:**
- Establishes pattern for future Stow packages
- Sets standard for config clarity (requirement STR-03)

## Next Steps

1. Test `stow nvim` to symlink the package
2. Launch Neovim - lazy.nvim will auto-install all plugins
3. mason will auto-install language servers (lua_ls, ts_ls, jsonls)
4. Verify LSP, completion, and Telescope work as expected
5. Proceed with next Stow package migration

## Technical Notes

**Why lazy.nvim?**
- Modern plugin manager with lazy-loading
- Clear, declarative syntax
- Auto-install support
- Better startup performance than vim-plug/packer

**Why mason?**
- Automatic LSP server installation (no manual :LspInstall)
- Cross-platform (works on macOS and Linux)
- Unified tool management

**Why organize by concern?**
- Easier to understand: "What LSP plugins do I have?" → check lsp.lua
- Easier to maintain: LSP changes all in one file
- More readable than one giant plugin list

**Why catppuccin?**
- Modern, well-maintained colorscheme
- Works well with Treesitter
- Consistent theme for statusline

**Config philosophy:**
- Every line should be self-explanatory
- No magic or hidden configuration
- User fully controls what's installed
- Not a distribution - it's a starting point

## Self-Check: PASSED

**Files created:**
- FOUND: nvim/.config/nvim/init.lua
- FOUND: nvim/.config/nvim/lua/plugins/lsp.lua
- FOUND: nvim/.config/nvim/lua/plugins/editor.lua
- FOUND: nvim/.config/nvim/lua/plugins/ui.lua

**Commits:**
- FOUND: d5960e8 (Task 1: init.lua with lazy.nvim bootstrap)
- FOUND: 5ee3224 (Task 2: plugin specs for LSP, editor, UI)

**Stow test:**
- PASSED: `stow -n nvim` completes without errors
