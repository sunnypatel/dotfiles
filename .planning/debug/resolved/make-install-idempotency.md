---
status: resolved
trigger: "Investigate and fix: make-install-idempotency"
created: 2026-02-14T00:00:00Z
updated: 2026-02-14T00:08:00Z
---

## Current Focus

hypothesis: make install has issues with PATH detection, stow resolution, and package idempotency
test: run make install locally and in Docker to identify current failure modes
expecting: identify specific errors in both environments
next_action: test make install locally first

## Symptoms

expected: `make install` runs without errors on both fresh and existing systems, and running it twice produces no errors
actual: Various issues found during Phase 4 testing — brew PATH issues, stow path resolution, redundant package installs. Recent fixes applied but not fully validated.
errors: Previous errors included: stow not found at brew prefix (when installed via apt), brew not in PATH, sudo prompts for apt when deps already installed
reproduction: `make install` in /home/sunny/projects/dotfiles
started: Phase 4 execution, multiple fix iterations today

## Eliminated

## Evidence

- timestamp: 2026-02-14T00:01:00Z
  checked: make install on local system
  found: stow command fails with "BUG in find_stowed_path? Absolute/relative mismatch between Stow dir projects/dotfiles/stow and path /home/sunny/projects/dotfiles"
  implication: The STOW variable resolves to /usr/bin/stow (apt version) but the Makefile uses relative paths

- timestamp: 2026-02-14T00:02:00Z
  checked: which stow and brew stow availability
  found: /usr/bin/stow is in PATH, /home/linuxbrew/.linuxbrew/bin/stow does not exist
  implication: stow was installed via apt, not brew, but Makefile STOW variable logic expects brew path fallback

- timestamp: 2026-02-14T00:03:00Z
  checked: stow exit code and verbose output
  found: stow completes with exit code 0 (success) but prints BUG warnings to stderr
  implication: stow succeeds but output is not clean

- timestamp: 2026-02-14T00:04:00Z
  checked: symlinks in /home/sunny
  found: /home/sunny/dotfiles -> /home/sunny/projects/dotfiles symlink exists
  implication: This symlink confuses stow's path detection logic, causing the "Absolute/relative mismatch" warnings

- timestamp: 2026-02-14T00:05:00Z
  checked: make install after removing symlink (local, run 1)
  found: No stow errors, only brew warnings about packages already installed
  implication: Removing the symlink fixes the stow path mismatch issue

- timestamp: 2026-02-14T00:06:00Z
  checked: make install idempotency (local, run 2)
  found: Identical output to run 1 - no errors
  implication: make install is idempotent on local system

- timestamp: 2026-02-14T00:07:00Z
  checked: make install in fresh Docker container (ubuntu:22.04)
  found: First run installs all packages successfully, second run shows "already installed" warnings, no errors
  implication: make install works in fresh environment and is idempotent

## Resolution

root_cause: Symlink /home/sunny/dotfiles -> /home/sunny/projects/dotfiles exists in target directory, confusing stow's path comparison logic when it checks if stow dir is inside target dir
fix: Remove the /home/sunny/dotfiles symlink (it's not needed and causes stow path confusion)
verification: Tested locally (2 runs) and in Docker fresh install (2 runs) - all passed cleanly with no errors
files_changed: []

root_cause:
fix:
verification:
files_changed: []
