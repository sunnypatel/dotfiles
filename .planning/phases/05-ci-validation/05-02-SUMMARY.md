---
phase: 05-ci-validation
plan: 02
subsystem: testing
tags:
  - bats
  - validation
  - symlinks
  - performance
  - shell-config
dependency_graph:
  requires:
    - test/test_helper.bash
    - stow/zsh/.config/zsh/.zsh_aliases
    - stow/zsh/.config/zsh/.zsh_functions
  provides:
    - test/symlinks.bats
    - test/shell_config.bats
    - test/performance.bats
  affects:
    - .github/workflows/ci.yml (uses these tests)
tech_stack:
  added:
    - zsh-bench (for accurate startup timing)
  patterns:
    - BATS helper functions for reusable test utilities
    - Platform-aware test skipping (skip_if_not_macos, skip_if_not_linux)
    - Interactive shell testing (zsh -ic) for alias/function validation
key_files:
  created:
    - test/symlinks.bats
    - test/shell_config.bats
    - test/performance.bats
  modified: []
decisions:
  - choice: Use zsh-bench with time-based fallback for performance testing
    rationale: zsh-bench most accurate but requires TTY, fallback ensures CI compatibility
    alternatives:
      - zsh-bench only: Would fail in CI without TTY
      - time-based only: Less accurate startup measurement
  - choice: Test aliases and functions in interactive shell (zsh -ic)
    rationale: Aliases and functions only available in interactive mode
    alternatives:
      - Source .zshrc manually: More fragile, doesn't test real user experience
metrics:
  duration: 164
  tasks_completed: 2
  tests_created: 37
  completed_date: "2026-02-14"
---

# Phase 05 Plan 02: BATS Test Suite Summary

**One-liner:** Complete BATS test suite validates Stow symlinks, shell configuration (env vars, aliases, functions, PATH), Zimfw plugins, tool installation, and enforces hard 100ms startup threshold.

## What Was Built

Created three comprehensive BATS test files covering all validation requirements:

1. **test/symlinks.bats (14 tests)** - Validates all Stow package symlinks
   - Zsh package: .zshenv, .zshrc, .zimrc, .zsh_aliases, .zsh_functions, .zsh_path, .dir_colors
   - Git package: config, ignore
   - Tmux package: tmux.conf, tmux.conf.local
   - Nvim package: init.lua, lua directory
   - Summary test verifying all expected symlinks exist

2. **test/shell_config.bats (22 tests)** - Comprehensive shell audit
   - Environment variables: EDITOR, ZDOTDIR, XDG_CONFIG_HOME, DOTFILES_DIR, LANG
   - PATH validation: ~/.local/bin, Homebrew bin
   - Aliases: reload, g, l, .., quit (all from .zsh_aliases)
   - Functions: mk, calc (all from .zsh_functions)
   - Zimfw plugins: zsh-syntax-highlighting, zsh-autosuggestions
   - Tool smoke tests: git, nvim, tmux, fzf, rg, bat (with skip if not installed)

3. **test/performance.bats (1 test)** - Hard startup threshold enforcement
   - Primary: zsh-bench for accurate first_prompt_lag_ms measurement
   - Fallback: time-based measurement (average of 5 runs) for CI without TTY
   - Hard fail if startup exceeds 100ms

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Missing test_helper.bash dependency**
- **Found during:** Task 1 initialization
- **Issue:** test_helper.bash referenced in plan but didn't exist (05-01 partially executed)
- **Fix:** Created test_helper.bash with required helper functions (command_exists, skip_if_not_macos, skip_if_not_linux, assert_dotfiles_symlink)
- **Files created:** test/test_helper.bash
- **Commit:** Part of Task 1 staging (file already tracked in git)

## Technical Implementation

**Test structure:**
- All tests use `load test_helper` for shared utilities
- Symlink tests use `assert_dotfiles_symlink` to verify Stow-created links
- Shell config tests use `zsh -ic` to test interactive shell context
- Platform-specific tests use skip helpers for macOS/Linux-only features
- Tool tests use skip if tool not installed (graceful degradation)

**Performance testing approach:**
- zsh-bench cloned on first run, cached in $HOME/zsh-bench
- Graceful fallback to time-based measurement if zsh-bench fails (no TTY)
- Averages 5 runs for fallback timing to reduce noise
- Hard assertion: startup must be < 100ms or build fails

**Coverage:**
- 37 total tests across 3 files
- Every symlink from all 4 Stow packages validated
- Every env var, alias, function from config files tested
- All essential tools verified with smoke tests
- Startup performance enforced with hard threshold

## Verification Results

- test/symlinks.bats validates all Stow package symlinks (zsh, git, tmux, nvim) ✓
- test/shell_config.bats validates env vars (EDITOR, ZDOTDIR, XDG_CONFIG_HOME, DOTFILES_DIR, LANG) ✓
- test/shell_config.bats validates PATH (~/.local/bin, Homebrew) ✓
- test/shell_config.bats validates all aliases (reload, g, l, .., quit) ✓
- test/shell_config.bats validates all functions (mk, calc) ✓
- test/shell_config.bats validates Zimfw plugin loading (syntax-highlighting, autosuggestions) ✓
- test/shell_config.bats has tool smoke tests (git, nvim, tmux, fzf, rg, bat) ✓
- test/performance.bats enforces 100ms startup threshold ✓
- All test files load test_helper ✓

## Self-Check: PASSED

**Files created:**
- test/symlinks.bats: ✓ EXISTS
- test/shell_config.bats: ✓ EXISTS
- test/performance.bats: ✓ EXISTS

**Commits:**
- a61f86d: ✓ EXISTS (Task 1: symlink and shell config tests)
- 85ef073: ✓ EXISTS (Task 2: performance test)

All claimed files exist and all commits verified.

## Success Criteria Met

✓ Complete BATS test suite covers all user-specified validation
✓ Stow symlinks validated for all 4 packages
✓ Shell functionality audit (env vars, aliases, functions, PATH, plugins)
✓ Tool smoke tests confirm installation
✓ Hard 100ms startup threshold enforced
✓ Tests can run via `bats test/*.bats`

## Impact

**Testing coverage:**
- First comprehensive validation of dotfiles installation
- Replaces manual verification with automated tests
- CI will catch configuration regressions immediately

**Performance enforcement:**
- Hard 100ms threshold prevents shell slowdown
- Measured with zsh-bench (industry standard)
- Fallback ensures CI compatibility

**Maintainability:**
- New config files must add corresponding tests
- Test helpers reduce duplication
- Skip patterns allow platform-specific testing

## Next Steps

Ready for CI integration:
- CI workflow (05-01) already configured to run `make test`
- These tests will run on every push, PR, and manual dispatch
- Ubuntu tests run in Docker, macOS tests run natively
- Any test failure blocks merge

**Future enhancements:**
- Add more shell_config tests as new aliases/functions added
- Consider zsh-bench installation in CI setup phase
- Add nvim plugin loading tests (lazy.nvim health check)
