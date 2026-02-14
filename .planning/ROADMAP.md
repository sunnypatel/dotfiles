# Roadmap: Dotfiles Simplification

## Overview

This roadmap transforms a bloated multi-tool dotfiles repository (60+ files across 8 directories) into a minimal, maintainable setup for zsh, neovim, tmux, and git. The journey follows a brownfield strip-down approach that preserves git history while consolidating 25+ shell configuration files into 5, establishing canonical GNU Stow package structure, and ensuring cross-platform compatibility across macOS, Linux, and WSL2. Each phase delivers independently verifiable capabilities, starting with the highest-risk shell consolidation and ending with CI validation.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Shell Consolidation** - Zsh-only setup with unified configuration
- [ ] **Phase 2: Stow Package Migration** - Package-per-tool structure for git, tmux, neovim
- [ ] **Phase 3: Platform Support** - Cross-platform detection and installation
- [ ] **Phase 4: Installation & Cleanup** - Simplified Makefile and final cleanup
- [ ] **Phase 5: CI Validation** - Automated testing on Ubuntu and macOS
- [ ] **Phase 6: Documentation** - Updated README and historical record

## Phase Details

### Phase 1: Shell Consolidation
**Goal**: Zsh becomes sole shell with clean, maintainable configuration structure
**Depends on**: Nothing (first phase)
**Requirements**: SHL-01, SHL-02, SHL-03, SHL-04, SHL-05, SHL-06, SHL-07, CLN-01, CLN-03
**Success Criteria** (what must be TRUE):
  1. User has single .zshrc entry point with no bash config files remaining
  2. Shell starts in under 100ms with working aliases, functions, and completion
  3. Tab completion works for common commands without Oh My Zsh dependency
  4. Command history persists across sessions with deduplication
  5. PATH includes platform-aware paths (Homebrew Intel/ARM/Linux locations)
**Plans**: 2 plans

Plans:
- [x] 01-01-PLAN.md — Create consolidated Zsh configuration (.zshenv, .zshrc, .zimrc)
- [x] 01-02-PLAN.md — Remove bash config and unused system files, verify setup

### Phase 2: Stow Package Migration
**Goal**: Package-per-tool directory structure with XDG-compliant configs
**Depends on**: Phase 1
**Requirements**: STR-01, STR-02, STR-03, INS-03, GIT-01, GIT-02, GIT-03, TMX-01, TMX-02, NVM-01, NVM-02, CLN-02
**Success Criteria** (what must be TRUE):
  1. Repository has zsh/, git/, tmux/, nvim/ packages mirroring home directory structure
  2. User can run stow commands to symlink each package independently
  3. Git config exists with curated aliases and core settings at ~/.config/git/
  4. Tmux config (gpakosz/.tmux) exists at XDG-compliant ~/.config/tmux/
  5. Neovim has lightweight Lua config with LSP and basic plugins
**Plans**: 4 plans

Plans:
- [ ] 02-01-PLAN.md — Create zsh/ Stow package with ZDOTDIR and XDG migration
- [ ] 02-02-PLAN.md — Create git/ and tmux/ Stow packages with curated configs
- [ ] 02-03-PLAN.md — Create nvim/ Stow package with lazy.nvim and LSP
- [ ] 02-04-PLAN.md — Remove unused configs, clean up directories, verify stow

### Phase 3: Platform Support
**Goal**: Single repository works identically across macOS, Linux, and WSL2
**Depends on**: Phase 2
**Requirements**: PLT-01, PLT-02, PLT-03, INS-01, INS-02
**Success Criteria** (what must be TRUE):
  1. User can detect current platform (macOS Intel/ARM, Linux, WSL2) via inline checks
  2. Brewfile installs essential packages on both macOS and Linux via Homebrew
  3. Platform-specific shell config loads automatically (aliases-darwin.zsh, aliases-linux.zsh)
  4. Makefile provides install targets that work on macOS and Linux
**Plans**: TBD

Plans:
- [ ] TBD

### Phase 4: Installation & Cleanup
**Goal**: Simplified installation with all unused tools removed
**Depends on**: Phase 3
**Requirements**: INS-04, CLN-04, CLN-05, CLN-06
**Success Criteria** (what must be TRUE):
  1. User can run make install multiple times without errors (idempotent)
  2. Makefile is under 50 lines with clear targets for macOS and Linux
  3. No macOS defaults scripts, remote install scripts, or language package managers remain
  4. REMOVED.md documents all deleted files with rationale
**Plans**: TBD

Plans:
- [ ] TBD

### Phase 5: CI Validation
**Goal**: Automated testing validates fresh installs on all supported platforms
**Depends on**: Phase 4
**Requirements**: (Supports all requirements via validation)
**Success Criteria** (what must be TRUE):
  1. GitHub Actions workflow tests fresh install on Ubuntu and macOS runners
  2. CI validates shell startup time, key aliases, git config, and PATH contents
  3. Tests run weekly on schedule to catch platform drift
**Plans**: TBD

Plans:
- [ ] TBD

### Phase 6: Documentation
**Goal**: Repository is self-explanatory with clear installation and contribution guides
**Depends on**: Phase 5
**Requirements**: (Supports STR-03 - every file self-explanatory)
**Success Criteria** (what must be TRUE):
  1. README explains new structure with installation instructions per platform
  2. REMOVED.md preserves institutional knowledge of what was deleted and why
  3. Contributing guide exists for adding new tools to package structure
**Plans**: TBD

Plans:
- [ ] TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Shell Consolidation | 2/2 | ✓ Complete | 2026-02-14 |
| 2. Stow Package Migration | 0/4 | Planning complete | - |
| 3. Platform Support | 0/TBD | Not started | - |
| 4. Installation & Cleanup | 0/TBD | Not started | - |
| 5. CI Validation | 0/TBD | Not started | - |
| 6. Documentation | 0/TBD | Not started | - |
