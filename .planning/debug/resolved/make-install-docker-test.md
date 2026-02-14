---
status: resolved
trigger: "make-install-docker-test"
created: 2026-02-14T00:00:00Z
updated: 2026-02-14T00:05:00Z
symptoms_prefilled: true
goal: find_and_fix
---

## Current Focus

hypothesis: CONFIRMED - stow-packages fails because stow command is not in PATH
test: Applied patch to use $(BREW_PREFIX)/bin/stow instead of bare 'stow'
expecting: Full installation success
next_action: verify fix and document resolution

## Symptoms

expected: `make install` works cleanly on a fresh Linux system
actual: Repeated local testing has broken brew. User wants isolated Docker testing.
errors: brew not in PATH on host (installed at /home/linuxbrew/.linuxbrew but not in PATH)
reproduction: `make install` in the dotfiles repo
started: Broke during Phase 4 execution — multiple brew install/uninstall cycles

## Eliminated

## Evidence

- timestamp: 2026-02-14T00:01:00Z
  checked: Docker build with clean Ubuntu 22.04
  found: `make` not found - Ubuntu base image doesn't include make
  implication: Need to install make first, or document prerequisite

- timestamp: 2026-02-14T00:02:00Z
  checked: Full Docker build with make installed
  found: All brew packages install successfully (git, neovim, tmux, stow, zsh, fzf, ripgrep, bat), but stow-packages target fails with "make: stow: No such file or directory"
  implication: stow is installed via brew to /home/linuxbrew/.linuxbrew/bin/stow but not in PATH when stow-packages target runs

- timestamp: 2026-02-14T00:03:00Z
  checked: Applied patch to use $(BREW_PREFIX)/bin/stow in Makefile
  found: Docker build completes successfully, all packages installed, all dotfiles stowed correctly to ~/.config/{git,nvim,tmux,zsh} and ~/.zshenv
  implication: Fix confirmed working in clean Ubuntu environment

## Resolution

root_cause: The stow-packages and unlink targets in Makefile use bare 'stow' command which is not in PATH when running in a fresh environment. The install-packages target correctly uses $(BREW_PREFIX)/bin/brew but stow-packages assumes stow is in PATH.

fix: Update Makefile stow-packages and unlink targets to use $(BREW_PREFIX)/bin/stow instead of bare 'stow' command, consistent with how install-packages uses $(BREW_PREFIX)/bin/brew

verification: |
  - Docker build in clean Ubuntu 22.04 completes successfully
  - All brew packages installed (git, neovim, tmux, stow, zsh, fzf, ripgrep, bat)
  - All dotfiles correctly stowed to ~/.config/{git,nvim,tmux,zsh} and ~/.zshenv
  - Verified with docker run dotfiles-install-test:final

files_changed:
  - Makefile (lines 51, 53): Changed 'stow' to '$(BREW_PREFIX)/bin/stow'
