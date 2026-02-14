---
phase: 05-ci-validation
plan: 01
subsystem: ci-infrastructure
tags: [ci, github-actions, docker, testing, bats]
dependency_graph:
  requires: [Makefile, stow-packages]
  provides: [ci-workflow, test-infrastructure, docker-ubuntu-env]
  affects: [.github/workflows, test/]
tech_stack:
  added: [GitHub Actions, Docker, BATS]
  patterns: [docker-containerized-tests, matrix-strategy, test-helpers]
key_files:
  created:
    - .github/workflows/ci.yml
    - .github/Dockerfile.ubuntu
    - test/test_helper.bash
  modified:
    - Makefile
decisions:
  - Use Docker for Ubuntu tests to ensure consistent environment
  - Use native runners for macOS tests (no Docker support)
  - BATS test framework for shell-based testing
  - Non-root testuser in Docker mimics real user installation
  - Matrix strategy for multiple macOS versions (macos-14, macos-15)
metrics:
  duration: 90
  completed_date: 2026-02-14
---

# Phase 05 Plan 01: CI Infrastructure Summary

**One-liner:** GitHub Actions CI with Docker Ubuntu tests, native macOS matrix tests, and BATS test infrastructure.

## What Was Built

Created complete CI pipeline infrastructure:
- GitHub Actions workflow with push/PR/dispatch triggers
- Ubuntu test environment using Docker (ubuntu:24.04)
- Native macOS test runners (macos-14, macos-15)
- BATS test helper library with platform skip and symlink assertion functions
- Makefile test targets for automated test execution

## Tasks Completed

| Task | Name                                              | Commit  | Files                                                            |
| ---- | ------------------------------------------------- | ------- | ---------------------------------------------------------------- |
| 1    | Create GitHub Actions workflow and Ubuntu Dockerfile | 9b0f1c9 | .github/workflows/ci.yml, .github/Dockerfile.ubuntu              |
| 2    | Create BATS test helper and add Makefile test target | b232ae6 | test/test_helper.bash, Makefile                                  |

## Implementation Details

### CI Workflow Structure

**Triggers:**
- Push to any branch
- Pull requests to any branch
- Manual workflow dispatch
- No scheduled runs (removed from old workflow)

**Jobs:**

1. **test-ubuntu-docker**
   - Runs on ubuntu-24.04 GitHub runner
   - Builds Docker image from .github/Dockerfile.ubuntu
   - Executes `make install && make test` inside container
   - Container uses non-root testuser with zsh shell

2. **test-macos**
   - Matrix strategy: macos-14 and macos-15 (ARM64 runners)
   - fail-fast: false (tests both versions even if one fails)
   - Native execution (no Docker)
   - Runs `make install` then `make test`

### Docker Environment

**Base:** ubuntu:24.04

**Installed packages:**
- build-essential (gcc, make, etc.)
- curl, git (installation dependencies)
- sudo (for privilege elevation)
- zsh (target shell)
- file (for readlink in symlink tests)

**User setup:**
- Non-root user: testuser
- Home: /home/testuser
- Shell: /bin/zsh
- Passwordless sudo enabled
- Working directory: /home/testuser/projects/dotfiles

### BATS Test Helpers

**Functions provided:**

1. `command_exists "$cmd"` - Check if command is available
2. `skip_if_not_macos` - Skip test on non-macOS platforms
3. `skip_if_not_linux` - Skip test on non-Linux platforms
4. `assert_dotfiles_symlink "$path"` - Verify symlink points to dotfiles/stow

### Makefile Test Targets

**test-setup:**
- Installs bats-core via Homebrew if not present
- Run automatically before test target

**test:**
- Depends on test-setup
- Executes: `bats test/*.bats`
- Runs all BATS test files in test/ directory

## Files Changed

### Created
- `.github/workflows/ci.yml` - CI workflow definition (36 lines)
- `.github/Dockerfile.ubuntu` - Ubuntu test container (31 lines)
- `test/test_helper.bash` - Shared BATS helpers (31 lines)

### Modified
- `Makefile` - Added test-setup and test targets (+5 lines, now 67 lines)

### Deleted
- `.github/workflows/dotfiles-installation.yml` - Obsolete workflow
- `.github/workflows/markdown-link-checker.yml` - Obsolete checker

## Deviations from Plan

None - plan executed exactly as written.

## Verification Results

All verification checks passed:

- [x] ci.yml triggers: push, pull_request, workflow_dispatch (no schedule)
- [x] ci.yml has test-ubuntu-docker job referencing Dockerfile.ubuntu
- [x] ci.yml has test-macos job with matrix [macos-14, macos-15]
- [x] Dockerfile creates non-root testuser with zsh
- [x] test_helper.bash has platform skip and symlink assertion helpers
- [x] Makefile test target runs bats test/*.bats
- [x] Old dotfiles-installation.yml and markdown-link-checker.yml deleted

## Success Criteria Met

✓ CI infrastructure is ready for test files
✓ Workflow triggers correctly (push, PR, dispatch)
✓ Docker builds Ubuntu test environment with non-root user
✓ macOS runs natively on ARM64 runners
✓ `make test` invokes BATS on all test files
✓ Test helpers provide platform checks and symlink assertions

## Next Steps

Ready for Phase 05 Plan 02: Create BATS test files to validate dotfile installation across platforms.

## Self-Check

Verifying all claimed files and commits exist:

**Files:**
- [x] .github/workflows/ci.yml
- [x] .github/Dockerfile.ubuntu
- [x] test/test_helper.bash
- [x] Makefile

**Commits:**
- [x] 9b0f1c9 feat(05-01): create CI workflow and Ubuntu Dockerfile
- [x] b232ae6 feat(05-01): add BATS test infrastructure

**Deleted files:**
- [x] Deleted: .github/workflows/dotfiles-installation.yml
- [x] Deleted: .github/workflows/markdown-link-checker.yml

**Result:** PASSED
