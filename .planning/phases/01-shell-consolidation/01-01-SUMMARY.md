---
phase: 01-shell-consolidation
plan: 01
subsystem: shell-configuration
tags:
  - zsh
  - zimfw
  - shell-startup
  - path-management
  - aliases
dependency_graph:
  requires: []
  provides:
    - consolidated-zsh-config
    - platform-aware-path
    - zimfw-module-system
  affects:
    - runcom/.zshenv
    - runcom/.zshrc
    - runcom/.zimrc
tech_stack:
  added:
    - zsh-native-syntax
    - typeset-path-deduplication
  patterns:
    - platform-detection-via-OSTYPE
    - zimfw-auto-install
    - history-deduplication
key_files:
  created: []
  modified:
    - runcom/.zshenv: "Complete environment file with platform-aware PATH, XDG dirs, locale"
    - runcom/.zshrc: "Self-contained interactive config with Zimfw, history, aliases, functions"
    - runcom/.zimrc: "Curated Zimfw module declarations with clear ordering"
decisions:
  - decision: "Use typeset -U for PATH deduplication"
    rationale: "Zsh-native feature eliminates custom awk scripts, guaranteed correctness"
  - decision: "Inline platform detection with [[ $OSTYPE == darwin* ]]"
    rationale: "Eliminates bin/is-macos process spawning overhead during shell startup"
  - decision: "Use Zimfw auto-install via curl"
    rationale: "More portable than Homebrew-based install, already proven approach"
  - decision: "Keep editor as 'nvim' instead of 'code'"
    rationale: "Plan specifies project is moving to neovim"
metrics:
  duration_minutes: 2.4
  tasks_completed: 3
  files_modified: 3
  commits: 3
  completed_date: 2026-02-14
---

# Phase 1 Plan 1: Shell Consolidation - Core Config Files Summary

**One-liner:** Created consolidated Zsh-only configuration (.zshenv, .zshrc, .zimrc) with platform-aware PATH detection, Zimfw module system, history deduplication, and curated aliases replacing the bash/zsh hybrid setup.

## Objective

Create the consolidated Zsh configuration: three files that replace the current multi-file bash/zsh hybrid setup, establishing a new Zsh-only shell configuration that is self-contained, fast (sub-100ms startup target), and eliminates the .bash_profile sourcing chain.

## What Was Built

### Created Files

None - all were modifications of existing files.

### Modified Files

1. **runcom/.zshenv** (80 lines)
   - Complete environment configuration for all shell types
   - Platform-aware Homebrew detection (ARM macOS, Intel macOS, Linux)
   - PATH construction using `typeset -U` for deduplication
   - DOTFILES_DIR, EDITOR (nvim), XDG Base Directories, locale
   - Preserves `skip_global_compinit=1` for performance

2. **runcom/.zimrc** (79 lines)
   - Curated Zimfw module configuration with 11 modules
   - Enabled previously commented-out modules: environment, input, utility
   - Proper ordering: completion after git/utility, syntax-highlighting last
   - Clear comments explaining each module's purpose

3. **runcom/.zshrc** (167 lines)
   - Self-contained interactive shell configuration
   - Zimfw auto-install and initialization (no Homebrew dependency)
   - History with SHARE_HISTORY and comprehensive deduplication
   - Platform-aware aliases (macOS -G vs Linux --color)
   - Global aliases for piping (G, H, T, L - Zsh-only feature)
   - Minimal functions: mk(), calc()
   - Grep configuration with VCS exclusions
   - macOS-specific settings conditionally loaded

## Key Patterns Implemented

### Pattern 1: Platform-Aware PATH Construction
```zsh
# Detect platform and set HOMEBREW_PREFIX
if [[ "$OSTYPE" == darwin* ]]; then
  if [[ -d /opt/homebrew ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"  # Apple Silicon
  elif [[ -d /usr/local/Homebrew ]]; then
    export HOMEBREW_PREFIX="/usr/local"     # Intel
  fi
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

# Build PATH with automatic deduplication
typeset -U path
path=(
  $DOTFILES_DIR/bin
  $HOME/.cargo/bin
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin}
  $path
)
```

**Impact:** Eliminates bin/is-macos process spawning, uses Zsh-native deduplication instead of awk scripts.

### Pattern 2: History Deduplication
```zsh
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt SHARE_HISTORY             # Share across all sessions
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate when new added
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates to file
setopt HIST_FIND_NO_DUPS         # Don't show duplicates in search
```

**Impact:** Comprehensive deduplication across all sessions, consistent with research recommendations.

### Pattern 3: Zimfw Auto-Install
```zsh
ZIM_HOME="${ZDOTDIR:-$HOME}/.zim"

if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
    https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-$HOME}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
```

**Impact:** Self-healing configuration that auto-installs Zimfw on first run, no manual setup needed.

## Deviations from Plan

None - plan executed exactly as written. All tasks completed with their specified content and verification criteria met.

## Verification Results

All verification criteria passed:

1. ✓ `zsh -n runcom/.zshenv` - no syntax errors
2. ✓ `zsh -n runcom/.zshrc` - no syntax errors
3. ✓ 0 matches for 'bash_profile' or 'BASH_SOURCE' in both files
4. ✓ HOMEBREW_PREFIX platform detection present in .zshenv
5. ✓ `typeset -U path` PATH deduplication present
6. ✓ SHARE_HISTORY history deduplication present
7. ✓ `zmodule completion` declared in .zimrc
8. ✓ All files have reasonable line counts (.zshenv: 80, .zshrc: 167, .zimrc: 79)

## Success Criteria Met

- [x] Three Zsh config files exist: .zshenv (PATH/env), .zshrc (interactive), .zimrc (modules)
- [x] .zshrc does NOT source .bash_profile or any system/ files
- [x] PATH includes platform-aware Homebrew detection (ARM, Intel, Linux)
- [x] History configured with SHARE_HISTORY and deduplication options
- [x] Aliases migrated from system/.alias with unused ones removed
- [x] Functions limited to mk() and calc()
- [x] Tab completion handled by Zimfw completion module
- [x] Prompt handled by Zimfw asciiship module
- [x] All three files pass `zsh -n` syntax check

## Commits

1. **dcf39b9** - `feat(01-shell-consolidation): create .zshenv with platform-aware PATH`
   - Replaced minimal .zshenv with complete environment configuration
   - Platform-aware Homebrew detection, typeset -U PATH deduplication
   - Files: runcom/.zshenv

2. **af0bff4** - `feat(01-shell-consolidation): create .zimrc with curated modules`
   - Well-commented module configuration with 11 modules
   - Enabled environment, input, utility modules
   - Files: runcom/.zimrc

3. **0a7c191** - `feat(01-shell-consolidation): create self-contained .zshrc`
   - Complete Zsh-native config with Zimfw, history, aliases, functions
   - No bash sourcing, platform-aware aliases
   - Files: runcom/.zshrc

## Next Steps

The shell configuration files are now consolidated and Zsh-native. Next plan should:

1. Test the configuration in a live shell session
2. Verify Zimfw modules install correctly on first run
3. Consider removing old bash configuration files (system/.path, system/.alias, etc.)
4. Measure actual shell startup time to confirm sub-100ms target

## Self-Check: PASSED

**Created files check:**
- No new files created (all modifications)

**Modified files check:**
```
FOUND: runcom/.zshenv (80 lines)
FOUND: runcom/.zshrc (167 lines)
FOUND: runcom/.zimrc (79 lines)
```

**Commits check:**
```
FOUND: dcf39b9 (Task 1 - .zshenv)
FOUND: af0bff4 (Task 2 - .zimrc)
FOUND: 0a7c191 (Task 3 - .zshrc)
```

All files exist, all commits verified in git history.
