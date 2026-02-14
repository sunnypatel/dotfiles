---
phase: 03-platform-support
plan: 01
subsystem: installation
tags: [brewfile, makefile, cross-platform, stow]
dependency_graph:
  requires: [02-04]
  provides: [cross-platform-install]
  affects: [installation-infrastructure]
tech_stack:
  added: [homebrew-bundle]
  patterns: [inline-platform-detection, simple-make-expansion]
key_files:
  created:
    - Brewfile
  modified:
    - Makefile
decisions:
  - title: "Inline platform detection via uname"
    rationale: "Eliminates dependency on bin/is-* scripts, makes Makefile self-contained"
    alternatives: ["External detection scripts (old approach)", "Python/shell detection script"]
  - title: "Simple expansion (:=) for all shell variables"
    rationale: "Prevents multiple uname invocations, more efficient and predictable"
    alternatives: ["Recursive expansion (=)"]
  - title: "WSL treated as Linux platform"
    rationale: "WSL2 uses Linux kernel, Homebrew for Linux, same package management as native Linux"
    alternatives: ["Separate WSL target with custom logic"]
  - title: "8 essential packages only in Brewfile"
    rationale: "Satisfies INS-02 minimal requirement, reduces installation overhead"
    alternatives: ["Include nice-to-have tools (old 57-package approach)"]
metrics:
  duration_seconds: 82
  tasks_completed: 2
  files_created: 1
  files_modified: 1
  commits: 2
  completed_date: 2026-02-14
---

# Phase 03 Plan 01: Cross-Platform Installation Infrastructure Summary

**One-liner:** Minimal Brewfile (8 packages) and self-contained Makefile with inline platform detection for macOS/Linux/WSL2

## Objective Achieved

Created cross-platform installation infrastructure with:
- New minimal Brewfile at repo root (8 essential packages vs old 57)
- Completely rewritten Makefile with inline platform detection (54 lines vs old 180)
- Support for macOS (Intel/ARM), Linux, and WSL2
- Eliminated all references to deleted infrastructure (runcom/, config/, bin/is-* scripts)

## Tasks Completed

### Task 1: Create minimal cross-platform Brewfile at repo root
**Status:** ✅ Complete
**Commit:** 84f2aa7
**Files:** Brewfile (created)

Created new Brewfile at repository root with exactly 8 essential packages:
- Core tools: git, neovim, tmux, stow, zsh
- Direct dependencies: fzf (fuzzy finder), ripgrep (fast search), bat (syntax highlighting)

Replaced functional role of `install/Brewfile` (57 packages). Old file remains for Phase 4 cleanup.

**Verification:**
- ✅ 15 lines total (within 15-20 expected range)
- ✅ Exactly 8 brew entries
- ✅ 0 cask or tap entries
- ✅ No language toolchains or GUI apps

### Task 2: Rewrite Makefile with inline platform detection
**Status:** ✅ Complete
**Commit:** cb44fdd
**Files:** Makefile (modified)

Completely replaced old Makefile (180 lines → 54 lines) with:
- Inline platform detection via `uname -s` and `uname -m` (no external scripts)
- macOS Intel/ARM detection (different Homebrew prefix)
- Linux vs WSL2 detection (via /proc/version check)
- Proper stow invocation with `-d stow -t $HOME` flags (fixes GAP-01)
- Linux prerequisite installation (build-essential, curl, git)
- Simple expansion (`:=`) for all shell variables (efficiency)

**Removed (out of scope):**
- All bash, npm, rust, java, bun installation targets
- All references to runcom/, config/, bin/ directories
- 17-package apt-packages target (Homebrew handles Linux packages)
- sudo keepalive trick, cask-apps, duti, vscode-extensions targets

**Verification:**
- ✅ `make -n` runs without errors, detects Linux platform
- ✅ `make -n stow-packages` shows correct flags: `stow -d ... stow -t $HOME`
- ✅ `make -n install-packages` references root Brewfile, not install/Brewfile
- ✅ 0 references to runcom/, config/, bin/is-*, install/Brewfile
- ✅ All 4 shell variables use `:=` (simple expansion)
- ✅ 54 lines (under 60-line target)

## Deviations from Plan

None - plan executed exactly as written.

## Overall Verification

All verification criteria passed:

1. ✅ `make -n` runs without parse errors and shows correct platform target
2. ✅ `make -n stow-packages` shows `stow -d ... stow -t $HOME zsh git tmux nvim`
3. ✅ `make -n install-packages` shows `brew bundle --file=.../Brewfile` referencing root Brewfile
4. ✅ Brewfile has exactly 8 brew entries, no casks or taps
5. ✅ Makefile has zero references to runcom/, config/, bin/is-*, install/Brewfile
6. ✅ All $(shell) variables use := (simple expansion)

## Success Criteria Met

- ✅ Brewfile at repo root with 8 essential packages
- ✅ Makefile rewrites entire installation flow with inline platform detection
- ✅ `make -n` succeeds on current platform
- ✅ No references to old/deleted infrastructure

## Next Steps

Phase 03 Plan 02 will implement automated platform detection tests to verify installation infrastructure works on all supported platforms.

## Self-Check

Verifying all claimed artifacts exist and commits are valid:

**Files created:**
- ✅ FOUND: Brewfile

**Files modified:**
- ✅ FOUND: Makefile

**Commits:**
- ✅ FOUND: 84f2aa7 (feat(03-01): create minimal cross-platform Brewfile)
- ✅ FOUND: cb44fdd (feat(03-01): rewrite Makefile with inline platform detection)

## Self-Check: PASSED

All files and commits verified successfully.
