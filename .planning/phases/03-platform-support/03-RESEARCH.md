# Phase 3: Platform Support - Research

**Researched:** 2026-02-14
**Domain:** Cross-platform dotfiles management (macOS Intel/ARM, Linux, WSL2)
**Confidence:** HIGH

## Summary

Phase 3 enables a single dotfiles repository to work identically across macOS (Intel and Apple Silicon), Linux (Ubuntu/Debian), and WSL2. The research identifies modern patterns for platform detection, cross-platform Homebrew usage, and Makefile-based installation that avoids the complexity of the current 10-script bin/ infrastructure.

**Key findings:**
1. Inline platform detection in Makefiles and shell configs is simpler and faster than external scripts
2. Homebrew officially supports Linux with unified Brewfile syntax (installs to /home/linuxbrew/.linuxbrew)
3. Zsh's OSTYPE variable provides reliable cross-platform detection without external dependencies
4. Current Makefile is stale (references deleted runcom/ and config/) and needs complete rewrite
5. Current Brewfile violates INS-02 requirement (57 packages vs minimal: zsh, neovim, tmux, git, stow)

**Primary recommendation:** Replace external bin/is-* scripts with inline Makefile detection using `uname`, consolidate platform-specific shell config using OSTYPE conditionals, and create minimal cross-platform Brewfile that works on macOS and Linux.

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| GNU Make | 3.8+ | Cross-platform build automation | Universal, built-in on macOS/Linux, no installation needed |
| Homebrew | 5.0+ | Package manager for macOS and Linux | Unified package management, official Linux support since Linuxbrew merge |
| GNU Stow | 2.3+ | Symlink farm manager | Cross-platform (works identically on macOS/Linux), available via apt/brew |
| Zsh | 5.8+ | Shell with OSTYPE built-in | Built-in platform detection, no external dependencies |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| uname | POSIX | Runtime OS/architecture detection | In Makefiles for platform-specific targets |
| /proc/version | WSL2 | WSL2-specific detection | Only when distinguishing WSL2 from native Linux |
| $WSL_DISTRO_NAME | WSL2 | Environment-based WSL detection | Fallback WSL2 detection method |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| External bin/is-* scripts | Inline shell/Make conditionals | External scripts add complexity, performance cost (fork/exec), harder to maintain. Inline is faster, clearer. |
| Separate Brewfile.linux | Single cross-platform Brewfile | Separate files create drift. Single file with conditional cask support is cleaner. |
| Platform-specific Makefiles | Single Makefile with conditionals | Multiple files fragment logic. Single file with clear conditionals is more maintainable. |

**Installation:**

Homebrew on Linux requires prerequisites:
```bash
# Ubuntu/Debian prerequisites
sudo apt update
sudo apt install build-essential curl git

# Install Homebrew (works on macOS and Linux)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (Linux only - macOS already configured)
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

## Architecture Patterns

### Recommended Project Structure

Current repository after Phase 2:
```
dotfiles/
├── stow/
│   ├── zsh/     # ZDOTDIR migration complete (Phase 2)
│   ├── git/     # Curated config (Phase 2)
│   ├── tmux/    # gpakosz/.tmux (Phase 2)
│   └── nvim/    # lazy.nvim + LSP (Phase 2)
├── bin/         # OLD - contains 10 platform detection scripts
├── install/     # OLD - needs consolidation
│   ├── Brewfile      # 57 packages (needs trimming to ~10)
│   ├── Caskfile      # macOS-only GUI apps
│   ├── npmfile       # 17 packages (out of scope until Phase 4)
│   ├── Rustfile      # 3 packages (out of scope until Phase 4)
│   ├── Codefile      # VS Code extensions (out of scope)
│   └── duti          # macOS file associations (out of scope)
├── Makefile     # STALE - references runcom/, config/
└── README.md
```

Target structure after Phase 3:
```
dotfiles/
├── stow/
│   ├── zsh/
│   │   └── .config/zsh/
│   │       ├── .zshrc
│   │       ├── .zsh_aliases        # Platform-aware (already has OSTYPE conditionals)
│   │       └── .zsh_path           # Platform-aware Homebrew paths
│   ├── git/
│   ├── tmux/
│   └── nvim/
├── Brewfile         # NEW - minimal, cross-platform (at repo root)
├── Makefile         # REWRITTEN - clean platform detection
└── README.md
```

### Pattern 1: Inline Platform Detection in Makefiles

**What:** Use `uname` and shell conditionals directly in Makefile instead of external scripts.

**When to use:** Always prefer inline detection over bin/is-* scripts for better performance and maintainability.

**Example:**
```makefile
# Source: https://gist.github.com/sighingnow/deee806603ec9274fd47
# Detect OS
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Detect platform
ifeq ($(UNAME_S),Darwin)
    OS := macos
    ifeq ($(UNAME_M),arm64)
        BREW_PREFIX := /opt/homebrew
    else
        BREW_PREFIX := /usr/local
    endif
else ifeq ($(UNAME_S),Linux)
    # Check if WSL
    IS_WSL := $(shell grep -qi microsoft /proc/version && echo true || echo false)
    ifeq ($(IS_WSL),true)
        OS := wsl
    else
        OS := linux
    endif
    BREW_PREFIX := /home/linuxbrew/.linuxbrew
endif

# Platform-specific targets
all: $(OS)

macos: install-brew install-packages stow-packages

linux: install-brew-linux install-packages stow-packages

wsl: linux
```

**Why this works:** Simple variable assignment evaluated once at parse time, no fork/exec overhead, all logic visible in one file.

### Pattern 2: Zsh OSTYPE-Based Configuration

**What:** Use Zsh's built-in `$OSTYPE` variable for platform-specific shell configuration.

**When to use:** In .zshrc, .zsh_aliases, .zsh_path for runtime platform detection.

**Example:**
```zsh
# Source: Current repository's .zsh_aliases (already implements this pattern)
# Platform-aware ls aliases (macOS uses -G, Linux uses --color=auto)
if [[ "$OSTYPE" == darwin* ]]; then
  alias l="ls -lahA -G"
  alias ll="ls -lA -G"
else
  alias l="ls -lahA --color=auto"
  alias ll="ls -lA --color=auto"
fi

# macOS-specific aliases
if [[ "$OSTYPE" == darwin* ]]; then
  alias cpwd="pwd | tr -d '\n' | pbcopy"
  alias cleanupds="find . -type f -name '*.DS_Store' -ls -delete"
fi
```

**Why this works:** No external dependencies, evaluated at shell startup, works identically on all platforms, regex match handles version strings (darwin23.0.0, etc.).

### Pattern 3: Cross-Platform Brewfile

**What:** Single Brewfile that works on both macOS and Linux, with macOS-specific casks ignored on Linux.

**When to use:** Always - Homebrew handles platform differences automatically.

**Example:**
```ruby
# Source: https://docs.brew.sh/Brew-Bundle-and-Brewfile
# Cross-platform core packages
brew "git"
brew "neovim"
brew "tmux"
brew "stow"
brew "zsh"
brew "fzf"
brew "ripgrep"
brew "bat"

# macOS-only casks (automatically skipped on Linux)
if OS.mac?
  cask "alacritty"
  cask "firefox"
end
```

**Why this works:** Homebrew Bundle evaluates Brewfiles as Ruby, allowing conditional logic. Cask entries automatically skip on Linux (casks don't exist on Linux).

### Pattern 4: WSL2 Detection with Fallbacks

**What:** Multi-method WSL2 detection for reliability.

**When to use:** When behavior must differ between WSL2 and native Linux.

**Example:**
```bash
# Source: https://github.com/microsoft/WSL/issues/4071
# Method 1: Check /proc/version for "Microsoft" or "WSL"
if grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=true
# Method 2: Check environment variables
elif [[ -n "$WSL_DISTRO_NAME" ]] || [[ -n "$WSL_INTEROP" ]]; then
  IS_WSL=true
# Method 3: Check for /etc/wsl.conf
elif [[ -f /etc/wsl.conf ]]; then
  IS_WSL=true
else
  IS_WSL=false
fi
```

**Why multiple methods:** No single method is 100% reliable. /proc/version is most reliable but can be customized. Environment variables may not survive `su`. Combining methods increases reliability.

### Anti-Patterns to Avoid

- **External detection scripts for simple checks:** bin/is-macos, bin/is-wsl add complexity. Use inline `[[ "$OSTYPE" == darwin* ]]` instead.
- **Recursively expanded $(shell) variables:** Use `:=` not `=` for shell function results to avoid repeated invocations.
- **Platform-specific Makefiles:** Creates drift and maintenance burden. Use single Makefile with conditionals.
- **Hard-coded paths:** Use `$(BREW_PREFIX)` variable instead of `/usr/local` or `/opt/homebrew`.
- **Separate platform-specific Brewfiles:** Single Brewfile with conditionals is easier to maintain.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Package management on Linux | apt-only approach | Homebrew on Linux | Unified package management, same Brewfile for macOS/Linux, more recent package versions |
| Platform detection scripts | Custom bin/is-* scripts | Inline Makefile/shell conditionals | Fewer files, faster execution (no fork), easier maintenance, standard patterns |
| Homebrew prefix detection | Hard-coded /usr/local or /opt/homebrew | `brew --prefix` or Makefile variables | Handles Intel/ARM/Linux differences automatically |
| WSL2 detection | Single-method check | Multi-method fallback pattern | No single method is 100% reliable due to customization options |

**Key insight:** The current bin/ directory contains 10 platform detection utilities that can be replaced with 5-10 lines of inline Makefile code. External scripts add fork/exec overhead, extra files to maintain, and obscure the logic. Modern Makefile patterns use `uname` and shell conditionals directly for better performance and clarity.

## Common Pitfalls

### Pitfall 1: Homebrew Prefix Assumptions

**What goes wrong:** Hard-coding `/usr/local` or `/opt/homebrew` breaks on the other platform or Linux.

**Why it happens:** macOS Intel used `/usr/local` for years. Apple Silicon changed to `/opt/homebrew`. Linux uses `/home/linuxbrew/.linuxbrew`.

**How to avoid:** Use platform-detected variables in Makefile, or `$(brew --prefix)` in shell configs.

**Warning signs:**
- Hard-coded `/usr/local/bin` in PATH
- Makefile assumes single Homebrew location
- Shell scripts fail to find brew-installed packages on some platforms

**Example fix:**
```makefile
# BAD
PATH := /usr/local/bin:$(PATH)

# GOOD
ifeq ($(UNAME_S),Darwin)
    ifeq ($(UNAME_M),arm64)
        BREW_PREFIX := /opt/homebrew
    else
        BREW_PREFIX := /usr/local
    endif
else
    BREW_PREFIX := /home/linuxbrew/.linuxbrew
endif
PATH := $(BREW_PREFIX)/bin:$(PATH)
```

### Pitfall 2: Recursively Expanded Shell Variables

**What goes wrong:** Makefile becomes extremely slow as it re-invokes shell commands hundreds of times.

**Why it happens:** Using `=` instead of `:=` for `$(shell)` results causes make to re-evaluate every time the variable is referenced.

**How to avoid:** Always use `:=` (simple expansion) for `$(shell ...)` assignments.

**Warning signs:**
- `make` takes seconds to parse even without running targets
- Verbose output shows repeated identical shell commands
- Adding `--debug=v` shows same shell function called repeatedly

**Example fix:**
```makefile
# BAD - re-invokes uname every reference
OS = $(shell uname -s)

# GOOD - invokes uname once, captures result
OS := $(shell uname -s)
```

### Pitfall 3: OSTYPE Version String Matching

**What goes wrong:** Exact string match `[[ "$OSTYPE" == "darwin" ]]` fails because OSTYPE includes version numbers.

**Why it happens:** OSTYPE is set at compile time and includes full version like "darwin23.0.0" or "linux-gnu".

**How to avoid:** Always use glob patterns `darwin*` or `linux*` for matching.

**Warning signs:**
- Platform-specific aliases don't load
- Conditionals work on one machine but not another with different OS version
- Fresh zsh install breaks existing conditionals

**Example fix:**
```zsh
# BAD - only matches exactly "darwin"
if [[ "$OSTYPE" == "darwin" ]]; then

# GOOD - matches darwin23.0.0, darwin22.1.0, etc.
if [[ "$OSTYPE" == darwin* ]]; then
```

### Pitfall 4: Stow Without -t Flag in New Directory Structure

**What goes wrong:** `stow zsh` fails with "BUG in find_stowed_path" or creates symlinks in wrong location.

**Why it happens:** Phase 2 moved Stow packages under stow/ directory. Default `stow` assumes target is parent directory (../) not home (~).

**How to avoid:** Always use `stow -d stow -t ~ <package>` format.

**Warning signs:**
- Stow creates symlinks in dotfiles directory instead of home
- Stow errors about "not owned by stow"
- Stow tries to create links in wrong location

**Example fix:**
```makefile
# BAD - assumes packages at repo root
stow-packages:
    stow zsh git tmux nvim

# GOOD - explicit source and target
stow-packages:
    stow -d stow -t $(HOME) zsh git tmux nvim
```

### Pitfall 5: Makefile SHELL Variable Inheritance

**What goes wrong:** User's SHELL environment variable is ignored, causing scripts to run with /bin/sh instead of zsh/bash.

**Why it happens:** Make explicitly does NOT inherit SHELL from environment to prevent user's choice of shell from breaking makefiles.

**How to avoid:** Only set SHELL in Makefile if you need non-default behavior. Default /bin/sh is safest for portability.

**Warning signs:**
- Bash-specific syntax fails in Makefile recipes
- Scripts work manually but fail when run via make
- Makefile works for one user but not another

**Best practice:** Write Makefile recipes in POSIX sh syntax, or explicitly set `SHELL := /bin/bash` if you need bash-specific features (but this reduces portability).

### Pitfall 6: Caskfile on Linux

**What goes wrong:** `brew bundle --file=Caskfile` fails on Linux with "cask command not found".

**Why it happens:** Casks are macOS-only (GUI applications). Linux uses different packaging for GUI apps.

**How to avoid:** Either use conditional Brewfile with `if OS.mac?` guards, or separate Caskfile handling in Makefile.

**Warning signs:**
- CI fails on Linux runners but works on macOS
- `make install` requires platform-specific targets to skip casks

**Example fix:**
```makefile
# Brewfile with conditionals (preferred)
brew "neovim"
if OS.mac?
  cask "alacritty"
end

# OR separate targets in Makefile
install-packages: brew-packages
ifeq ($(OS),macos)
    brew bundle --file=Caskfile || true
endif
```

## Code Examples

Verified patterns from official sources and existing repository:

### Minimal Cross-Platform Makefile

```makefile
# Source: Research synthesis from https://gist.github.com/sighingnow/deee806603ec9274fd47
# and https://docs.brew.sh/Homebrew-on-Linux

DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Platform detection (evaluated once at parse time)
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Determine OS and Homebrew prefix
ifeq ($(UNAME_S),Darwin)
    OS := macos
    ifeq ($(UNAME_M),arm64)
        BREW_PREFIX := /opt/homebrew
    else
        BREW_PREFIX := /usr/local
    endif
else ifeq ($(UNAME_S),Linux)
    IS_WSL := $(shell grep -qi microsoft /proc/version 2>/dev/null && echo true || echo false)
    ifeq ($(IS_WSL),true)
        OS := wsl
    else
        OS := linux
    endif
    BREW_PREFIX := /home/linuxbrew/.linuxbrew
endif

PATH := $(BREW_PREFIX)/bin:$(DOTFILES_DIR)/bin:$(PATH)
export PATH

.PHONY: all install install-brew install-packages stow-packages

all: install

install: install-brew install-packages stow-packages

install-brew:
ifeq ($(OS),macos)
	@command -v brew >/dev/null 2>&1 || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	@command -v brew >/dev/null 2>&1 || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@eval "$$($(BREW_PREFIX)/bin/brew shellenv)"
endif

install-packages: install-brew
	brew bundle --file=$(DOTFILES_DIR)/Brewfile

stow-packages:
	@command -v stow >/dev/null 2>&1 || brew install stow
	stow -d $(DOTFILES_DIR)/stow -t $(HOME) zsh git tmux nvim
```

### Platform-Aware Zsh PATH Configuration

```zsh
# Source: Current repository pattern + https://docs.brew.sh/Installation
# .zsh_path - Platform-aware PATH configuration

# Homebrew (platform-specific locations)
if [[ "$OSTYPE" == darwin* ]]; then
  # macOS: detect Apple Silicon vs Intel
  if [[ "$(uname -m)" == "arm64" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
  else
    export HOMEBREW_PREFIX="/usr/local"
  fi
else
  # Linux and WSL2
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

# Add Homebrew to PATH if it exists
if [[ -d "$HOMEBREW_PREFIX/bin" ]]; then
  export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
fi

# User binaries
export PATH="$HOME/.local/bin:$PATH"
```

### Minimal Cross-Platform Brewfile

```ruby
# Source: https://docs.brew.sh/Brew-Bundle-and-Brewfile
# Minimal Brewfile per INS-02 requirement
# Only essential packages: zsh, neovim, tmux, git, stow, and direct dependencies

# Core dotfiles tools
brew "git"
brew "neovim"
brew "tmux"
brew "stow"
brew "zsh"

# Direct dependencies for workflow
brew "fzf"        # Fuzzy finder (used in zsh, nvim, tmux)
brew "ripgrep"    # Fast grep (nvim LSP, general usage)
brew "bat"        # Better cat (shell workflow)

# macOS-only GUI applications
if OS.mac?
  cask "alacritty"  # Terminal emulator
end
```

### WSL2 Detection Function

```bash
# Source: https://github.com/microsoft/WSL/issues/4071
# Multi-method WSL2 detection for maximum reliability

is_wsl() {
  # Method 1: Check /proc/version for "Microsoft" or "WSL"
  if grep -qi microsoft /proc/version 2>/dev/null || grep -qi wsl /proc/version 2>/dev/null; then
    return 0
  fi

  # Method 2: Check environment variables (may not survive su/sudo)
  if [[ -n "$WSL_DISTRO_NAME" ]] || [[ -n "$WSL_INTEROP" ]]; then
    return 0
  fi

  # Method 3: Check for WSL-specific config file
  if [[ -f /etc/wsl.conf ]]; then
    return 0
  fi

  return 1
}

# Usage in Makefile or shell script
if is_wsl; then
  echo "Running in WSL2"
else
  echo "Native Linux"
fi
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| External bin/is-* scripts | Inline Makefile conditionals with uname | 2020s | Fewer files, faster execution, clearer logic |
| Separate Linuxbrew project | Unified Homebrew (merged 2019) | 2019 | Single Brewfile for macOS and Linux |
| Hard-coded /usr/local | Platform-detected BREW_PREFIX | Apple Silicon launch (2020) | Works on Intel, ARM, and Linux |
| OS-specific package lists | Cross-platform Brewfile with conditionals | Homebrew 3.0+ (2021) | Single source of truth, less drift |
| Recursively expanded shell vars | Simple expansion with := | Always recommended, emphasized in 2020s guides | 10-100x faster Makefile parsing |

**Deprecated/outdated:**

- **Linuxbrew as separate project**: Merged into Homebrew in 2019. Use unified "Homebrew" for both platforms.
- **bin/is-supported script pattern**: Created unnecessary abstraction. Modern approach uses direct conditionals.
- **Multiple shells in dotfiles**: Phase 1 eliminated bash. Single shell (zsh) simplifies platform detection.
- **Makefile runcom/ and config/ directories**: Phase 2 moved to stow/ packages. Current Makefile is stale.

## Open Questions

### 1. Should we keep bin/ directory at all?

**What we know:**
- Current bin/ has 10 scripts: is-macos, is-wsl, is-arm64, is-supported, is-executable, is-debian, is-ubuntu, dot, append, json
- is-* scripts can be replaced with inline Makefile/shell conditionals
- is-executable, dot, append, json are utility scripts (not platform detection)

**What's unclear:**
- Are utility scripts (is-executable, dot, append, json) used anywhere?
- Should utilities move to stow/zsh/.local/bin for proper PATH management?

**Recommendation:** Audit bin/ usage in Phase 3, move utilities to proper location or remove if unused. Eliminate platform detection scripts.

### 2. How minimal should minimal Brewfile be?

**What we know:**
- INS-02 requires "zsh, neovim, tmux, git, stow, and direct dependencies"
- Current Brewfile has 57 packages
- Some packages have legitimate dependency relationships (fzf used by nvim, zsh, tmux)

**What's unclear:**
- Definition of "direct dependencies" - how transitive should we go?
- Should development tools (gh, python, rust) be in minimal Brewfile or separate?

**Recommendation:** Start with strict interpretation (5 core + 3-5 workflow essentials = 8-10 packages). Can add more in Phase 4 with clear justification.

### 3. Should we handle apt packages on Linux?

**What we know:**
- Homebrew on Linux requires build-essential, curl, git prerequisites via apt
- Current Makefile has apt-packages target with 17 packages
- Homebrew can install most of these packages on Linux

**What's unclear:**
- Should apt-packages target remain for native packages (faster, more reliable)?
- Or should everything go through Homebrew for consistency?

**Recommendation:** Keep minimal apt prerequisites (build-essential, curl, git) in Makefile. Install other packages via Homebrew for consistency.

### 4. Do we need WSL2-specific behavior?

**What we know:**
- WSL2 is detected by current is-wsl script
- Makefile has `wsl:` target that just calls `linux:` target
- WSL2 can run Linux binaries and Homebrew

**What's unclear:**
- Are there actual behavioral differences needed between WSL2 and native Linux?
- Or is WSL2 detection just for informational purposes?

**Recommendation:** Research if any config/installation differs for WSL2. If not, treat WSL2 as Linux (no special case).

## Sources

### Primary (HIGH confidence)

- [Homebrew on Linux - Official Documentation](https://docs.brew.sh/Homebrew-on-Linux)
- [Homebrew Installation - Official Documentation](https://docs.brew.sh/Installation)
- [Homebrew Bundle and Brewfile - Official Documentation](https://docs.brew.sh/Brew-Bundle-and-Brewfile)
- [GNU Make Shell Function - Official Documentation](https://www.gnu.org/software/make/manual/html_node/Shell-Function.html)
- [Detect operating system in Makefile - GitHub Gist](https://gist.github.com/sighingnow/deee806603ec9274fd47)
- Current repository files: Makefile, install/Brewfile, bin/is-*, stow/zsh/.config/zsh/.zsh_aliases

### Secondary (MEDIUM confidence)

- [WSL Detection from Bash Script - Microsoft/WSL Issue #4071](https://github.com/microsoft/WSL/issues/4071)
- [Homebrew Brewfile Tips - GitHub Gist](https://gist.github.com/ChristopherA/a579274536aab36ea9966f301ff14f3f)
- [Makefile Performance: $(shell)](https://www.cloudbees.com/blog/makefile-performance-shell)
- [Installing Homebrew on Ubuntu/Debian - LinuxConfig](https://linuxconfig.org/installing-homebrew-on-ubuntu-debian-a-step-by-step-guide)
- [Using GNU Stow to Manage Dotfiles - System Crafters](https://systemcrafters.net/managing-your-dotfiles/using-gnu-stow/)
- [My Dotfiles Setup with GNU Stow - Christopher Penkin](https://www.penkin.me/development/tools/productivity/configuration/2025/10/20/my-dotfiles-setup-with-gnu-stow.html)

### Tertiary (LOW confidence - community practices)

- [Homebrew prefix detection - GitHub discussions](https://github.com/orgs/Homebrew/discussions/417)
- [Cross-Platform Makefiles guide - MoldStud](https://moldstud.com/articles/p-cross-platform-compatibility-the-future-of-makefiles-in-multi-os-environments)
- [Bash Scripting Best Practices - DevToolbox 2026](https://devtoolbox.dedyn.io/blog/bash-scripting-complete-guide)
- [Portable Shell Scripts - OneUpTime Blog](https://oneuptime.com/blog/post/2026-01-24-portable-shell-scripts/view)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Official Homebrew Linux support, proven Makefile patterns, Zsh OSTYPE is documented
- Architecture: HIGH - Patterns verified in current repository and official docs, clear examples available
- Pitfalls: HIGH - Based on official documentation warnings and current repository structure issues
- Brewfile trimming: MEDIUM - INS-02 requirement is clear, but "direct dependencies" interpretation needs validation

**Research date:** 2026-02-14
**Valid until:** 2026-03-14 (30 days - stable domain, but Homebrew versions update frequently)

**Key gap identified:** Current Makefile references deleted directories (runcom/, config/) from pre-Phase-2 structure. Complete rewrite required, not incremental update.

**Phase 2 dependency verified:** Assumes stow/ directory structure with zsh/, git/, tmux/, nvim/ packages. Stow commands require -d stow -t ~ flags (GAP-01 from Phase 2 UAT).
