---
phase: 02-stow-package-migration
plan: 01
subsystem: dotfiles-management
tags: [stow, zsh, xdg-base-directory, symlinks]

# Dependency graph
requires:
  - phase: 01-shell-consolidation
    provides: Modular Zsh configuration split into .zshrc, .zimrc, .zsh_path, .zsh_aliases, .zsh_functions
provides:
  - zsh/ Stow package with XDG-compliant directory structure
  - .stow-local-ignore for preventing infrastructure file symlinking
  - ZDOTDIR-based configuration enabling ~/.config/zsh/ location
affects: [02-02, 02-03, 02-04]

# Tech tracking
tech-stack:
  added: [stow]
  patterns: [Stow package structure mirroring home directory, ZDOTDIR for XDG compliance]

key-files:
  created:
    - zsh/.zshenv
    - .stow-local-ignore
  modified:
    - zsh/.config/zsh/.zshrc (added .dir_colors sourcing)

key-decisions:
  - "Set ZDOTDIR in .zshenv to enable XDG-compliant Zsh config location at ~/.config/zsh/"
  - "Source .dir_colors in .zshrc for Linux only (macOS uses LSCOLORS)"
  - "Use .stow-local-ignore to prevent symlinking repo infrastructure files"

patterns-established:
  - "Stow packages mirror home directory structure (package_name/.zshenv symlinks to ~/.zshenv)"
  - "ZDOTDIR enables Zsh configs to live in ~/.config/zsh/ while keeping only .zshenv at ~/"
  - "Platform-specific conditionals for features like dircolors"

# Metrics
duration: 161s
completed: 2026-02-14
---

# Phase 02 Plan 01: Zsh Stow Package Migration Summary

**XDG-compliant zsh/ Stow package with ZDOTDIR migration, moving all Zsh configs from runcom/ to proper package structure**

## Performance

- **Duration:** 2.7 min (161 seconds)
- **Started:** 2026-02-14T12:25:02Z
- **Completed:** 2026-02-14T12:27:43Z
- **Tasks:** 2
- **Files modified:** 10

## Accomplishments
- Created zsh/ Stow package mirroring home directory structure
- Migrated all Zsh configuration from flat runcom/ directory to XDG-compliant ~/.config/zsh/
- Set ZDOTDIR in .zshenv to enable Zsh reading configs from ~/.config/zsh/ instead of ~/
- Created .stow-local-ignore preventing Stow from symlinking repository infrastructure files
- Integrated .dir_colors from system/ into zsh/ package

## Task Commits

Each task was committed atomically:

1. **Task 1: Create zsh/ Stow package with ZDOTDIR migration** - `f28e479` (feat)
2. **Task 2: Create .stow-local-ignore and remove empty system/ directory** - `e07f1f9` (feat)

## Files Created/Modified
- `zsh/.zshenv` - Root-level .zshenv setting ZDOTDIR and sourcing .zsh_path
- `zsh/.config/zsh/.zshrc` - Interactive shell config (moved from runcom/), now sources .dir_colors on Linux
- `zsh/.config/zsh/.zimrc` - Zimfw module declarations (moved from runcom/)
- `zsh/.config/zsh/.zsh_path` - PATH configuration (moved from runcom/)
- `zsh/.config/zsh/.zsh_aliases` - Shell aliases (moved from runcom/)
- `zsh/.config/zsh/.zsh_functions` - Shell functions (moved from runcom/)
- `zsh/.config/zsh/.dir_colors` - Directory colors for ls (moved from system/)
- `.stow-local-ignore` - Stow ignore patterns preventing symlinking of .git, README, .planning, etc.

## Decisions Made

**ZDOTDIR Migration Strategy:**
- Set `ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"` in .zshenv after XDG base directory exports
- Changed source path from `${0:a:h}/.zsh_path` to `${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}/.zsh_path` because after stowing, .zshenv lives at ~/.zshenv while .zsh_path lives at ~/.config/zsh/.zsh_path
- Existing source paths in .zshrc using `${ZDOTDIR:-$HOME}` already work correctly once ZDOTDIR is set

**Directory Colors Integration:**
- Migrated system/.dir_colors into zsh/ package as decided in Phase 1
- Added platform-conditional sourcing in .zshrc: `if [[ "$OSTYPE" != darwin* ]]` to skip on macOS (uses LSCOLORS instead)

**Stow Ignore Patterns:**
- Created .stow-local-ignore with Perl regex patterns anchored to package root (^/)
- Prevents symlinking: .git, README, LICENSE, .planning, .github, .vscode, Makefile, test/, install/, bin/, macos/, REVIEW_AND_RECOMMENDATIONS.md, TESTING.md

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

**Incidental tmux file moves:**
During Task 2 commit, git staged renames for tmux files (config/tmux/tmux.conf → tmux/.config/tmux/tmux.conf and runcom/tmux.conf.local → tmux/.config/tmux/tmux.conf.local). These were from a prior session's work and got committed alongside .stow-local-ignore. No functional impact - tmux package was already being prepared for Plan 02.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Ready for Plan 02 (Tmux Stow Package):**
- zsh/ package structure established as template
- .stow-local-ignore in place
- system/ directory removed
- runcom/ now contains only tmux.conf.local

**Verification passed:**
- `stow -n -v zsh` dry-run succeeds with correct symlink targets
- No infrastructure files (.git, README, Makefile) in dry-run output
- All Zsh config files pass `zsh -n` syntax checks
- ZDOTDIR correctly set and used in source paths

## Self-Check: PASSED

All claimed files verified to exist:
- ✓ zsh/.zshenv
- ✓ zsh/.config/zsh/.zshrc
- ✓ zsh/.config/zsh/.zimrc
- ✓ zsh/.config/zsh/.zsh_path
- ✓ zsh/.config/zsh/.zsh_aliases
- ✓ zsh/.config/zsh/.zsh_functions
- ✓ zsh/.config/zsh/.dir_colors
- ✓ .stow-local-ignore

All claimed commits verified:
- ✓ f28e479 (Task 1)
- ✓ e07f1f9 (Task 2)

---
*Phase: 02-stow-package-migration*
*Completed: 2026-02-14*
