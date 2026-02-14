---
phase: 02-stow-package-migration
plan: 04
subsystem: dotfiles-infrastructure
tags: [stow, cleanup, xdg, repository-structure]

# Dependency graph
requires:
  - phase: 02-stow-package-migration/02-01
    provides: zsh/ Stow package
  - phase: 02-stow-package-migration/02-02
    provides: git/ and tmux/ Stow packages
  - phase: 02-stow-package-migration/02-03
    provides: nvim/ Stow package
provides:
  - Clean repository with stow/ directory containing all Stow packages
  - Unused tool configs removed (alacritty, prettier, thefuck, topgrade)
  - Legacy directories removed (config/, runcom/, system/)
affects: [03-installation, 04-cleanup]

# Tech tracking
tech-stack:
  added: []
  patterns: [stow/ directory isolates packages from infrastructure]

key-files:
  created: []
  modified: []

key-decisions:
  - "Move all Stow packages under stow/ directory for self-documenting structure"
  - "Remove .stow-local-ignore — no longer needed with packages isolated under stow/"
  - "Stow usage becomes: stow -d stow zsh git tmux nvim"

patterns-established:
  - "All Stow packages live under stow/ directory, not at repo root"
  - "stow -d stow <package> to install packages"

# Metrics
duration: 3min
completed: 2026-02-14
---

# Phase 02 Plan 04: Cleanup and Stow Package Verification Summary

**Removed unused tool configs, cleaned up legacy directories, and reorganized all Stow packages under stow/ for self-documenting repository structure**

## Performance

- **Duration:** ~3 min
- **Completed:** 2026-02-14
- **Tasks:** 2
- **Files modified:** 16 (5 removed, 11 moved under stow/)

## Accomplishments
- Removed unused tool configs: alacritty, prettier, thefuck, topgrade (CLN-02)
- Cleaned up empty legacy directories: config/, runcom/, system/
- Reorganized all 4 Stow packages under stow/ directory
- Eliminated .stow-local-ignore (no longer needed with isolated packages)
- Verified all packages pass `stow -d stow -n -v` dry run

## Task Commits

Each task was committed atomically:

1. **Task 1: Remove unused tool configs and empty directories** - `6983922` (chore)
2. **Task 2: Move Stow packages under stow/ directory** - `8ec7d76` (refactor)

## Files Created/Modified
- Removed: `config/alacritty/alacritty.toml`, `config/alacritty/alacritty.yml`
- Removed: `config/prettier/.prettierrc`
- Removed: `config/thefuck/settings.py`
- Removed: `config/topgrade.toml`
- Removed: `.stow-local-ignore`
- Moved: `zsh/` → `stow/zsh/`
- Moved: `git/` → `stow/git/`
- Moved: `tmux/` → `stow/tmux/`
- Moved: `nvim/` → `stow/nvim/`

## Decisions Made

**Repository Structure Reorganization:**
- User requested all Stow packages live under their own directory for clarity
- Chose `stow/` as directory name — self-documenting, immediately tells anyone the tool and purpose
- This eliminated the need for `.stow-local-ignore` since packages are isolated from infrastructure files
- Stow usage: `stow -d stow zsh git tmux nvim` (wrappable in Makefile target)

## Deviations from Plan

### User-Directed Change

**Move packages under stow/ directory**
- **Trigger:** User review at checkpoint — asked "shouldn't we have all the stow packages under their own folder?"
- **Change:** Moved all 4 Stow packages under `stow/` directory instead of keeping at repo root
- **Impact:** `.stow-local-ignore` no longer needed (deleted). Stow commands use `-d stow` flag.
- **Benefit:** Self-documenting structure, clearer separation of packages from infrastructure

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Repository structure:**
```
dotfiles/
├── stow/              ← all Stow packages
│   ├── zsh/           ← stow -d stow zsh
│   ├── git/           ← stow -d stow git
│   ├── tmux/          ← stow -d stow tmux
│   └── nvim/          ← stow -d stow nvim
├── bin/               ← infrastructure (Phase 4)
├── install/           ← infrastructure (Phase 4)
├── macos/             ← infrastructure (Phase 4)
├── test/              ← infrastructure (Phase 4)
└── Makefile, README.md, etc.
```

All 4 Stow packages verified working with dry-run.

## Self-Check: PASSED

Verified:
- stow/zsh/.zshenv exists
- stow/git/.config/git/config exists
- stow/tmux/.config/tmux/tmux.conf exists
- stow/nvim/.config/nvim/init.lua exists
- config/, runcom/, system/ directories removed
- `stow -d stow -n -v zsh git tmux nvim` succeeds

---
*Phase: 02-stow-package-migration*
*Completed: 2026-02-14*
