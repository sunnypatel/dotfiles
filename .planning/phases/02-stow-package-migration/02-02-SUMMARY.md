---
phase: 02-stow-package-migration
plan: 02
subsystem: dotfiles-infrastructure
tags: [stow, xdg, git, tmux, gpakosz, symlinks]

# Dependency graph
requires:
  - phase: 01-shell-consolidation
    provides: Modular Zsh config structure as template for other tools
provides:
  - git/ Stow package with curated config at XDG-compliant location
  - tmux/ Stow package with gpakosz/.tmux two-file config at XDG-compliant location
  - Fully XDG-migrated git and tmux configurations
affects: [03-stow-finalization, 04-cleanup]

# Tech tracking
tech-stack:
  added: [nvimdiff]
  patterns: [XDG path migration, Stow package structure, gpakosz two-file pattern]

key-files:
  created:
    - git/.config/git/config
    - git/.config/git/ignore
    - tmux/.config/tmux/tmux.conf
    - tmux/.config/tmux/tmux.conf.local
  modified:
    - git/.config/git/config (curated: nvim editor, delta removed, aliases preserved)
    - tmux/.config/tmux/tmux.conf (XDG paths updated throughout)
    - tmux/.config/tmux/tmux.conf.local (XDG paths in user customizations)

key-decisions:
  - "Changed git editor from 'code --wait' to 'nvim' (project uses neovim now)"
  - "Removed delta pager dependency from git config (tool being removed per CLN-02)"
  - "Updated git diff/merge tools from vscode to nvimdiff"
  - "Removed platform-specific credential helper (macOS will auto-detect)"
  - "Updated all tmux.conf path references to XDG locations (~/.config/tmux/)"
  - "Preserved gpakosz/.tmux two-file pattern (immutable base + user customizations)"
  - "Removed duplicate git aliases ('d' and 'go' had two definitions each)"

patterns-established:
  - "Stow packages mirror home directory structure exactly (git/.config/git/config)"
  - "XDG-compliant configs use ~/.config/ prefix"
  - "Gpakosz/.tmux pattern: tmux.conf (upstream, edited for XDG) + tmux.conf.local (user customizations)"
  - "Git config curated: remove platform-specific and deprecated tool references"

# Metrics
duration: 5min
completed: 2026-02-14
---

# Phase 02 Plan 02: Git and Tmux Stow Packages Summary

**Git and tmux Stow packages created with XDG-compliant paths, curated git config (nvim editor, delta removed), and gpakosz/.tmux two-file pattern migrated to ~/.config/tmux/**

## Performance

- **Duration:** 5 min 6 sec
- **Started:** 2026-02-14T12:25:04Z
- **Completed:** 2026-02-14T12:30:10Z
- **Tasks:** 2
- **Files modified:** 4 (2 created git, 2 created tmux)

## Accomplishments
- Created git/ Stow package with curated configuration at XDG-compliant location
- Updated git config: nvim editor, removed delta pager, removed vscode tools, switched to nvimdiff
- Created tmux/ Stow package with gpakosz/.tmux config at XDG-compliant location
- Updated all tmux path references from legacy ~/.tmux.conf to XDG ~/.config/tmux/tmux.conf
- Both packages pass `stow -n` dry run successfully
- config/git/ and config/tmux/ directories now empty
- runcom/ directory now empty (tmux.conf.local migrated)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create git/ Stow package with curated config** - `b0ee135` (feat)
   - Migrated config from config/git/ to git/.config/git/
   - Curated settings: nvim editor, delta removed, vscode removed, nvimdiff tools
   - Removed duplicate aliases

2. **Task 2: Create tmux/ Stow package with gpakosz/.tmux config** - `b43f18d` (feat)
   - Migrated tmux.conf from config/tmux/ to tmux/.config/tmux/
   - Migrated tmux.conf.local from runcom/ to tmux/.config/tmux/
   - Updated all path references throughout both files to XDG locations

## Files Created/Modified
- `git/.config/git/config` - Git configuration with curated aliases, nvim editor, nvimdiff tools, XDG-compliant excludesfile
- `git/.config/git/ignore` - Global gitignore patterns (.DS_Store, .idea, node_modules, etc.)
- `tmux/.config/tmux/tmux.conf` - gpakosz/.tmux base configuration (updated to XDG paths)
- `tmux/.config/tmux/tmux.conf.local` - User tmux customizations (updated to XDG paths)

## Decisions Made

**Git Configuration Curation:**
- Changed editor from `code --wait` to `nvim` - project now uses Neovim as primary editor
- Removed `pager = delta` from [core] section - delta tool being removed in cleanup phase (CLN-02)
- Removed entire [delta] section - no longer needed
- Removed [credential] helper = osxkeychain - too platform-specific, let macOS auto-detect
- Removed [difftool "vscode"] and [mergetool "vscode"] sections - switching to nvim
- Updated diff.tool and merge.tool from "vscode" to "nvimdiff"
- Removed duplicate `d` alias (kept the more useful version)
- Removed duplicate `go` alias (kept the simpler checkout version)
- Kept excludesfile path as-is (~/.config/git/ignore) - already XDG-compliant

**Tmux XDG Migration:**
- Updated source-file directive from `~/.tmux.conf.local` to `~/.config/tmux/tmux.conf.local`
- Updated bind e (edit keybinding) to use XDG paths
- Updated bind r (reload keybinding) to use XDG paths
- Updated all run commands (bind +, bind m, bind U, bind F) to use XDG paths
- Updated embedded shell script references (cut -c3-) to use XDG paths throughout
- Updated user customizations in tmux.conf.local (bind-key r, bind-key M) to use XDG paths
- Updated tpm plugin path comment to reference XDG location

## Deviations from Plan

None - plan executed exactly as written.

The plan anticipated needing to update tmux.conf for XDG paths and noted "this is the one acceptable edit to the gpakosz file for XDG migration." All path updates were necessary and expected.

## Issues Encountered

None. Git and tmux configs migrated smoothly. Both `stow -n git` and `stow -n tmux` dry runs succeeded on first attempt.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- git/ and tmux/ Stow packages ready for `stow git` and `stow tmux`
- config/git/, config/tmux/, and runcom/ directories now empty and ready for removal in Phase 04 cleanup
- XDG path patterns established for remaining tools (nvim already uses XDG)
- Next: Plan 03 will create nvim/ Stow package with lazy.nvim config
- Next: Plan 04 will remove unused configs and empty directories

## Self-Check: PASSED

All files and commits verified:
- git/.config/git/config - FOUND
- git/.config/git/ignore - FOUND
- tmux/.config/tmux/tmux.conf - FOUND
- tmux/.config/tmux/tmux.conf.local - FOUND
- Commit b0ee135 - FOUND
- Commit b43f18d - FOUND

---
*Phase: 02-stow-package-migration*
*Completed: 2026-02-14*
