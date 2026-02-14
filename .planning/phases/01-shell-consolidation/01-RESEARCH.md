# Phase 1: Shell Consolidation - Research

**Researched:** 2026-02-13
**Domain:** Zsh shell configuration, migration from bash, startup performance optimization
**Confidence:** HIGH

## Summary

Shell consolidation requires migrating from a dual bash/zsh setup to Zsh-only while eliminating bash-specific configurations and maintaining sub-100ms startup times. The current configuration sources .bash_profile from .zshrc, creating unnecessary complexity and potential compatibility issues.

Modern Zsh configuration emphasizes minimal frameworks (Zimfw over Oh My Zsh), native completion system optimization via compinit caching, and careful startup file organization. The key challenges are: 1) understanding Zsh-specific syntax differences from bash (array indexing, globbing, prompt escapes), 2) optimizing compinit performance through daily cache checks rather than per-startup validation, and 3) properly structuring startup files (.zshenv for PATH, .zshrc for interactive features).

Zimfw is already partially configured in the current .zshrc but lacks a .zimrc module configuration file. The framework provides blazing-fast initialization through static init.zsh compilation and modular plugin loading without Oh My Zsh's 1000ms+ overhead.

**Primary recommendation:** Create single .zshrc entry point with Zimfw minimal modules (environment, git, input, completion, prompt), migrate bash-sourced configurations to Zsh-native syntax, implement daily compinit cache checking, and remove all bash configuration files.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Zsh | 5.8+ | Primary shell | Industry standard for developer shells, superior completion and scripting |
| Zimfw | Latest stable | Plugin manager | Fastest Zsh framework, 30-70ms startup vs Oh My Zsh 500-1000ms |
| compinit | Native Zsh | Completion system | Built-in Zsh completion, no external dependencies needed |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| GNU Stow | 2.3+ | Symlink management | Already in use, no change needed |
| Homebrew | Latest | Package manager | Platform-aware PATH management (ARM/Intel/Linux) |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Zimfw | Oh My Zsh | OMZ has 2000+ files and 500-1000ms startup time, fails performance requirement |
| Zimfw | Prezto | Prezto slower than Zimfw, less active maintenance |
| Zimfw | Manual plugin management | Manual approach achievable but Zimfw provides free optimization |
| Native prompt | Starship | Starship universal (bash/zsh/fish) but adds ~50ms overhead, pure Zsh faster |
| Native prompt | Powerlevel10k | P10k on life support as of 2025, Starship recommended as replacement |

**Installation:**
```bash
# Zimfw auto-installs on first shell launch if not present
# Current .zshrc already has auto-install logic (lines 7-17)
# No additional installation needed
```

## Architecture Patterns

### Recommended Project Structure
```
dotfiles/
├── zsh/
│   ├── .zshenv          # PATH and essential environment (sourced always)
│   ├── .zshrc           # Interactive shell config (sourced for interactive shells)
│   └── .zimrc           # Zimfw module configuration
├── system/              # Legacy - to be migrated into zsh/
│   ├── .alias          # Migrate to .zshrc or modular files
│   ├── .function       # Migrate useful functions only
│   └── .path           # Migrate to .zshenv
└── runcom/             # Symlink sources - to be reorganized
    └── .zshrc          # Entry point (Stow symlinks to ~/)
```

### Pattern 1: Startup File Organization
**What:** Zsh loads files in specific order: .zshenv → .zprofile → .zshrc → .zlogin
**When to use:** Always — proper separation prevents duplication and ensures correct loading
**Example:**
```zsh
# ~/.zshenv - Loaded for ALL shells (interactive, non-interactive, login, non-login)
# Source: https://zsh.sourceforge.io/Intro/intro_3.html
# Purpose: PATH, EDITOR, essential environment variables
# Keep minimal - this runs for every zsh invocation including scripts

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/projects/dotfiles}"
export EDITOR="nvim"
export VISUAL="$EDITOR"

# PATH setup (platform-aware Homebrew detection)
if [[ -d /opt/homebrew ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"  # Apple Silicon
elif [[ -d /usr/local/Homebrew ]]; then
  export HOMEBREW_PREFIX="/usr/local"     # Intel Mac
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"  # Linux
fi

# Build PATH
typeset -U path  # Ensure unique entries
path=(
  $DOTFILES_DIR/bin
  $HOME/.cargo/bin
  $HOME/.local/share/pnpm
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin}
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin}
  $path
)
export PATH
```

```zsh
# ~/.zshrc - Loaded for INTERACTIVE shells only
# Source: https://zsh.sourceforge.io/Intro/intro_3.html
# Purpose: Aliases, functions, completion, prompt, Zimfw modules

# Return early if non-interactive
[[ -o interactive ]] || return

# Zimfw initialization
ZIM_HOME="${ZDOTDIR:-$HOME}/.zim"
if [[ ! -f ${ZIM_HOME}/init.zsh ]]; then
  # Auto-install on first run
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/zimfw/zimfw/master/zimfw.zsh -o ${ZIM_HOME}/zimfw.zsh
    zsh ${ZIM_HOME}/zimfw.zsh install
  fi
fi

# Source Zimfw (this calls compinit via completion module)
[[ -f ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh

# History configuration
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY          # Write timestamp
setopt SHARE_HISTORY             # Share across sessions (implies INC_APPEND_HISTORY)
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Don't record consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate when new added
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates to file
setopt HIST_FIND_NO_DUPS         # Don't show duplicates in search

# Aliases
alias reload="exec zsh"          # Changed from source ~/.bash_profile
alias g="git"
alias p="pnpm"
# ... more aliases from system/.alias

# Functions (only keep commonly used)
# ... curated from system/.function
```

```zsh
# ~/.zimrc - Zimfw module configuration
# Source: https://zimfw.sh/docs/modules/
# Purpose: Define which Zimfw modules to load

# Core modules
zmodule environment     # Sets sane Zsh defaults
zmodule git            # Git aliases and functions
zmodule input          # Proper keybindings
zmodule utility        # Utility aliases and functions

# Completion (must be near end, before syntax highlighting)
zmodule completion

# Syntax highlighting (must be last)
zmodule zsh-users/zsh-syntax-highlighting
```

### Pattern 2: Compinit Performance Optimization
**What:** Cache completion dump file and only rebuild once per day
**When to use:** Always — reduces startup time by 100-300ms
**Example:**
```zsh
# Handled automatically by Zimfw completion module
# Manual approach (if not using Zimfw):
# Source: https://gist.github.com/ctechols/ca1035271ad134841284

autoload -Uz compinit

# Check cache once per day
setopt EXTENDEDGLOB
for dump in ${ZDOTDIR:-$HOME}/.zcompdump(N.mh+24); do
  compinit
done
compinit -C  # Use -C to skip check if cache < 24hrs old
unsetopt EXTENDEDGLOB
```

### Pattern 3: Platform-Aware PATH Management
**What:** Detect macOS architecture (Intel/ARM) and Linux to set correct Homebrew paths
**When to use:** Always for cross-platform dotfiles
**Example:**
```zsh
# Current implementation in system/.path (lines 6-20)
# Works well, migrate to .zshenv with minor Zsh syntax improvements

# Zsh-native version using [[ ]] and typeset
if [[ "$OSTYPE" == darwin* ]]; then
  # macOS - detect ARM vs Intel
  if [[ -d /opt/homebrew ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
  elif [[ -d /usr/local/Homebrew ]]; then
    export HOMEBREW_PREFIX="/usr/local"
  fi
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi
```

### Anti-Patterns to Avoid

- **Sourcing bash files from zsh:** Current .zshrc sources .bash_profile (line 36-39). Bash and Zsh are different languages with incompatible syntax. Migrate content to Zsh-native format instead.

- **Multiple compinit calls:** Calling compinit twice adds 30-50ms per call. Let Zimfw's completion module handle it, or call once manually.

- **Using $BASH_VERSION conditionals:** Files like system/.completion check `$BASH_VERSION` (line 3). In Zsh-only setup, remove bash branches entirely.

- **Hardcoded 'reload' alias to bash:** Current alias is `alias reload="source ~/.bash_profile"`. Should be `alias reload="exec zsh"` or `source ~/.zshrc`.

- **Complex symlink resolution in shell startup:** Current .bash_profile has 20+ lines of symlink resolution (lines 1-22). Move to installation script, not runtime.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Plugin management | Custom git submodule system | Zimfw | Handles dependencies, compilation, updates automatically |
| Completion caching | Custom date checking logic | Zimfw completion module | Already optimized, well-tested approach |
| Prompt with git info | Custom git status parsing | Zimfw git-info module or Starship | Edge cases (detached HEAD, rebases, submodules) are complex |
| Command timing | Custom PROMPT_COMMAND | Zimfw duration-info module | Already integrated with prompt system |
| PATH deduplication | Custom awk scripts | Zsh typeset -U path | Native Zsh feature, guaranteed correct |

**Key insight:** Zsh has powerful native features (typeset -U for unique arrays, compinit for completion) that eliminate need for custom solutions. Zimfw provides well-tested modules for common needs without Oh My Zsh bloat.

## Common Pitfalls

### Pitfall 1: Array Indexing Differences
**What goes wrong:** Bash arrays start at index 0, Zsh arrays start at index 1. Code like `${PATH_ARRAY[0]}` returns wrong element.
**Why it happens:** Direct migration from bash without syntax adaptation.
**How to avoid:** Review all array operations during migration. Use Zsh's associative arrays or `setopt KSH_ARRAYS` if needed (not recommended).
**Warning signs:** Off-by-one errors when accessing PATH elements or function arguments.

### Pitfall 2: Unmatched Glob Patterns Cause Errors
**What goes wrong:** In bash, `ls *.txt` with no .txt files expands to literal `*.txt`. In Zsh, this errors with "no matches found".
**Why it happens:** Zsh's default behavior is stricter about globbing.
**How to avoid:** Use `setopt NO_NOMATCH` if you want bash-like behavior, or use `(N)` glob qualifier for null glob: `ls *.txt(N)`.
**Warning signs:** Scripts that work in bash fail in Zsh with "no matches found" errors.

### Pitfall 3: Prompt Escape Codes Different
**What goes wrong:** Bash uses `\u` for username, `\h` for hostname. Zsh uses `%n` and `%m`. Current .prompt file for bash won't work.
**Why it happens:** Different prompt syntaxes between shells.
**How to avoid:** Rewrite prompt using Zsh percent escapes or use Zimfw prompt module.
**Warning signs:** Prompt shows literal `\u@\h` instead of username@hostname.

### Pitfall 4: SHARE_HISTORY and INC_APPEND_HISTORY Conflict
**What goes wrong:** Setting both `SHARE_HISTORY` and `INC_APPEND_HISTORY` causes confusion — SHARE_HISTORY implies immediate append.
**Why it happens:** Copy-pasting configurations without understanding option relationships.
**How to avoid:** Use `SHARE_HISTORY` alone for cross-session sharing. If you want immediate append without sharing, use `INC_APPEND_HISTORY` alone.
**Warning signs:** History behavior inconsistent or duplicated across sessions.

### Pitfall 5: Sourcing .zshrc Multiple Times
**What goes wrong:** Aliases stack, PATH gets duplicated, startup slows down.
**Why it happens:** Using `source ~/.zshrc` instead of `exec zsh` for reload.
**How to avoid:** Use `exec zsh` to restart shell cleanly, or use `typeset -U path` to ensure unique PATH entries.
**Warning signs:** PATH grows every time you reload, aliases break with "already defined" errors.

### Pitfall 6: Loading Completion Before Modules Add Completions
**What goes wrong:** Git/npm/other completions missing even though modules installed.
**Why it happens:** Calling compinit before modules add their completion functions.
**How to avoid:** In .zimrc, put completion module near end, after all modules that add completions (git, utility, etc).
**Warning signs:** Tab completion works for basic commands but not git/npm/pnpm.

### Pitfall 7: Forgetting to Create .zimrc
**What goes wrong:** Zimfw installed but no modules configured, missing git aliases and completion.
**Why it happens:** Current setup has Zimfw auto-install but no .zimrc file exists.
**How to avoid:** Create .zimrc with zmodule declarations before running zimfw install.
**Warning signs:** Zim installed but git aliases missing, completion basic only.

## Code Examples

Verified patterns from official sources.

### Minimal .zshenv Template
```zsh
# Source: https://zsh.sourceforge.io/Intro/intro_3.html
# Loaded for: All shells (interactive, non-interactive, login, non-login)
# Purpose: PATH and critical environment variables only

# Essential paths
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/projects/dotfiles}"
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Platform detection
if [[ "$OSTYPE" == darwin* ]]; then
  if [[ -d /opt/homebrew ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
  elif [[ -d /usr/local/Homebrew ]]; then
    export HOMEBREW_PREFIX="/usr/local"
  fi
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

# Build PATH with unique entries
typeset -U path
path=(
  $DOTFILES_DIR/bin
  $HOME/.cargo/bin
  $HOME/.local/share/pnpm
  $HOME/.bun/bin
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin}
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin}
  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $path
)
export PATH
```

### Minimal .zshrc Template
```zsh
# Source: Zimfw documentation https://github.com/zimfw/zimfw
# Loaded for: Interactive shells only
# Purpose: Aliases, functions, prompt, completion, Zimfw

# Skip if non-interactive
[[ -o interactive ]] || return

###############################################################################
# Zimfw Initialization
###############################################################################

ZIM_HOME="${ZDOTDIR:-$HOME}/.zim"

# Download zimfw if missing
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi

# Install missing modules and update init.zsh if needed
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-$HOME}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules
source ${ZIM_HOME}/init.zsh

###############################################################################
# History Configuration
###############################################################################

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY          # Record timestamp
setopt SHARE_HISTORY             # Share across all sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_DUPS          # Don't record consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate when new added
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates to history file
setopt HIST_FIND_NO_DUPS         # Don't display duplicates when searching

###############################################################################
# Zsh Options
###############################################################################

setopt AUTO_CD              # Type directory name to cd
setopt NO_NOMATCH          # Pass through unmatched globs (bash-like)
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell

###############################################################################
# Aliases
###############################################################################

# Shortcuts
alias reload="exec zsh"
alias g="git"
alias p="pnpm"
alias npm="pnpm"
alias npx="pnpm dlx"

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias -- -="cd -"

# List files
alias l="ls -lAh --color=auto"
alias ll="ls -lA --color=auto"

###############################################################################
# Functions
###############################################################################

# Calculator
calc() {
  echo "$*" | bc -l
}
```

### Minimal .zimrc Template
```zsh
# Source: https://zimfw.sh/docs/modules/
# Purpose: Define Zimfw modules to load
# Note: Order matters - completion must be near end

# Environment - sets sane Zsh defaults
zmodule environment

# Git - aliases and functions
zmodule git

# Input - proper key bindings
zmodule input

# Utility - common aliases and functions
zmodule utility

# Completion - MUST be after modules that add completions
zmodule completion

# Optional: Syntax highlighting (must be last)
zmodule zsh-users/zsh-syntax-highlighting
```

### History Deduplication
```zsh
# Source: https://jdhao.github.io/2021/03/24/zsh_history_setup/
# Best practice configuration for unique, shared history

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# Core options for deduplication
setopt EXTENDED_HISTORY          # Write format: ':start:elapsed;command'
setopt SHARE_HISTORY             # Share history across all sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Trim duplicates first when HISTFILE exceeds HISTSIZE
setopt HIST_IGNORE_DUPS          # Don't record command if same as previous
setopt HIST_IGNORE_ALL_DUPS      # Delete old occurrence when new duplicate added
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate commands to HISTFILE
setopt HIST_FIND_NO_DUPS         # Don't show duplicates when searching history

# Optional: ignore commands starting with space
setopt HIST_IGNORE_SPACE         # Don't save commands starting with space
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Oh My Zsh | Zimfw, Prezto, or manual | 2020-2023 | 10x startup speed improvement (1000ms → 30-70ms) |
| Single compinit call | Daily cache checking with -C flag | 2018+ | 100-300ms startup reduction |
| Powerlevel10k prompt | Starship or native Zsh | 2025 | P10k on life support, Starship recommended replacement |
| HISTFILE per-session | SHARE_HISTORY across sessions | Current best practice | Better multi-terminal workflow |
| Manual plugin git submodules | Plugin managers (Zimfw, Zinit) | 2018+ | Automatic updates, dependency management |

**Deprecated/outdated:**
- **Oh My Zsh for minimal setups**: 2000+ files, 500-1000ms startup. Use Zimfw for performance-critical configs.
- **Powerlevel10k**: On life support as of 2025. Use Starship or native Zsh prompts.
- **INC_APPEND_HISTORY with SHARE_HISTORY**: SHARE_HISTORY implies immediate append. Setting both is redundant and confusing.
- **Sourcing .bash_profile from .zshrc**: Bash and Zsh are incompatible languages. Migrate to native Zsh syntax.

## Open Questions

1. **Should we keep Zimfw or go fully manual?**
   - What we know: Zimfw already partially installed, provides free performance optimizations
   - What's unclear: User preference for "no magic" vs practical performance gains
   - Recommendation: Keep Zimfw with explicit .zimrc. Removes only ~500 lines vs Oh My Zsh's 2000+ files, and user can see exactly which modules are loaded. Zimfw's static init.zsh compilation is transparent.

2. **Which prompt to use?**
   - What we know: Current setup has no prompt (sources bash prompt which won't work). P10k deprecated. Starship adds ~50ms overhead.
   - What's unclear: Balance between features and performance for sub-100ms target
   - Recommendation: Start with Zimfw's minimal asciiship module (Spaceship/Starship clone). If too heavy, use pure Zsh prompt with git-info module.

3. **Keep existing bin/ helper scripts or migrate to Zsh functions?**
   - What we know: Current system/.path uses $DOTFILES_DIR/bin/is-macos, is-wsl, etc. These add process spawn overhead.
   - What's unclear: Performance impact of spawning processes vs inline Zsh conditionals
   - Recommendation: Replace with inline Zsh tests: `[[ "$OSTYPE" == darwin* ]]` instead of `is-macos`. Eliminates process spawning in startup path.

4. **Should we migrate all system/.alias content or curate?**
   - What we know: Current .alias has 74 lines including some tool-specific (pnpm, git) and platform-specific (macOS)
   - What's unclear: Which aliases are actively used vs legacy
   - Recommendation: Migrate all initially (preserves functionality), then user can remove unused ones iteratively. Track with comments for potential cleanup.

## Sources

### Primary (HIGH confidence)
- [Zsh Completion System Official Documentation](https://zsh.sourceforge.io/Doc/Release/Completion-System.html) - compinit flags, cache configuration, completion styles
- [Zsh FAQ Chapter 2: How does zsh differ from Bash?](https://zsh.sourceforge.io/FAQ/zshfaq02.html) - Array indexing, globbing, startup files, compatibility
- [Zsh Introduction: Startup Files](https://zsh.sourceforge.io/Intro/intro_3.html) - Load order and purposes of .zshenv, .zprofile, .zshrc, .zlogin
- [Zimfw GitHub Repository](https://github.com/zimfw/zimfw) - Module system, installation, performance characteristics
- Current dotfiles repository - Existing implementation patterns in runcom/.zshrc, system/.path, system/.alias

### Secondary (MEDIUM confidence)
- [Speed up zsh compinit by only checking cache once a day](https://gist.github.com/ctechols/ca1035271ad134841284) - Daily cache optimization pattern
- [Better Zsh History](https://jdhao.github.io/2021/03/24/zsh_history_setup/) - HISTFILE configuration and deduplication options
- [Zsh Bash startup files loading order](https://medium.com/@rajsek/zsh-bash-startup-files-loading-order-bashrc-zshrc-etc-e30045652f2e) - Practical startup file organization
- [Zsh History Configuration](https://nilesh2000.github.io/til/zsh-history-configuration/) - History options and best practices
- [Homebrew on Linux Documentation](https://docs.brew.sh/Homebrew-on-Linux) - Linux Homebrew paths
- [macOS Shell Configuration Guide](https://osxhub.com/macos-shell-configuration-zsh-environment-variables/) - PATH management on macOS
- [Zimfw Modules Documentation](https://zimfw.sh/docs/modules/) - Available modules and configuration
- [Setting up zim with zsh](https://jade.fyi/blog/zsh-zim-setup/) - Practical Zimfw setup guide
- [Powerlevel10k is on Life Support. Hello Starship!](https://hashir.blog/2025/06/powerlevel10k-is-on-life-support-hello-starship/) - 2025 prompt landscape
- [Bash vs Zsh migration guide](https://www.real-world-systems.com/docs/zsh.1.html) - Compatibility issues and differences

### Tertiary (LOW confidence)
- [Optimizing Zsh Startup Performance](http://santacloud.dev/posts/optimizing-zsh-startup-performance/) - Sub-70ms techniques (needs verification with zimfw approach)
- [ZSH dotfiles management pitfalls](https://discussion.fedoraproject.org/t/zsh-dotfiles-how-to-manage-integration-of-variables-paths-from-bash-pitfalls/46765) - Community discussion on migration issues

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Zimfw and native Zsh completion are well-documented, current best practices verified across multiple sources
- Architecture: HIGH - Startup file order and structure documented in official Zsh documentation, migration patterns verified
- Pitfalls: HIGH - Bash/Zsh differences documented in official FAQ, history conflicts verified in multiple sources
- Performance: HIGH - Compinit caching and Zimfw speed verified across multiple benchmarks and official docs

**Research date:** 2026-02-13
**Valid until:** 2026-03-13 (30 days - stable domain, Zsh changes slowly)
