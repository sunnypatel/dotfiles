# Phase 4: Installation & Cleanup - Research

**Researched:** 2026-02-14
**Domain:** Make-based installation systems, GNU Stow symlink management, idempotent operations
**Confidence:** HIGH

## Summary

Phase 4 focuses on two critical goals: making the installation process fully idempotent (safe to re-run without errors), and removing all obsolete installation infrastructure from the old bloated setup. The primary technical domains are GNU Make for cross-platform installation orchestration, GNU Stow for safe symlink management, and Homebrew Bundle for package installation.

The current Makefile (55 lines) is already well-structured with proper platform detection using `uname`. The main challenge is ensuring idempotency across all targets and systematically removing obsolete files: macOS defaults scripts (3 files), remote install script (1 file), language package managers (npmfile, Rustfile), and an entire outdated install/ directory with old Brewfiles and configuration files.

Idempotency requires: (1) declaring all targets as .PHONY since they don't create files, (2) using commands that are inherently safe to re-run (brew bundle, stow), and (3) adding conditional checks where needed (Homebrew installer). Documentation via REMOVED.md establishes clear rationale for deletions, preventing future reintroduction.

**Primary recommendation:** Use .PHONY for all targets, leverage built-in idempotency of brew bundle and stow, add Homebrew install guard, and systematically document all deletions in REMOVED.md with clear rationale.

## Standard Stack

### Core Tools

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| GNU Make | 3.81+ | Installation orchestration | Universal build tool, present on all Unix-like systems, cross-platform conditionals via `uname` |
| GNU Stow | 2.4.0+ | Symlink management | Stateless design, safe re-runs, automatic conflict detection, reversible operations |
| Homebrew | Latest | Package manager | Cross-platform (macOS/Linux), declarative Brewfiles, idempotent `brew bundle` command |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| uname | POSIX | Platform detection | Built-in command for OS/architecture detection, no external dependencies |
| grep | GNU/BSD | WSL detection | Check /proc/version for Microsoft signature (WSL-specific pattern) |
| test/command -v | POSIX shell | Conditional execution | Check if commands exist before running them |

**Installation:**
```bash
# All tools already present or installed by Phase 3
# No additional dependencies needed
```

## Architecture Patterns

### Recommended Makefile Structure

```makefile
# 1. Platform detection variables (simple expansion :=)
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# 2. Conditional OS/architecture detection
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

# 3. Phony target declarations (all targets that don't create files)
.PHONY: all macos linux wsl install-brew install-packages stow-packages unlink

# 4. Platform-specific targets
all: $(OS)

macos: install-brew install-packages stow-packages
linux: install-deps install-brew install-packages stow-packages
wsl: linux

# 5. Implementation targets (idempotent commands)
```

### Pattern 1: Phony Targets for Idempotent Operations

**What:** Declare all installation targets as `.PHONY` to ensure they always run when requested, regardless of file state.

**When to use:** For any target that represents an action (install, clean, unlink) rather than a file to be created.

**Why:** Without `.PHONY`, if a file with the same name as the target exists in the directory, Make will think the target is up-to-date and skip execution. Installation targets never create files named after themselves, so they must be phony.

**Example:**
```makefile
# Source: GNU Make official documentation
# https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html

.PHONY: all macos linux wsl install-brew install-packages stow-packages unlink

# Now these targets run every time, regardless of files in directory
all: $(OS)
macos: install-brew install-packages stow-packages
```

### Pattern 2: Simple Variable Expansion for Platform Detection

**What:** Use `:=` (simple expansion) instead of `=` (recursive expansion) for all variables in the Makefile.

**When to use:** For all variable assignments, especially those using `$(shell ...)` commands.

**Why:** Simple expansion evaluates the right-hand side once at definition time. Recursive expansion re-evaluates every time the variable is referenced, causing `$(shell uname -s)` to run multiple times and slowing down Make. Additionally, functions like `shell` and `wildcard` can give unpredictable results with recursive expansion.

**Example:**
```makefile
# Source: GNU Make documentation - Simple Assignment
# https://www.gnu.org/software/make/manual/html_node/Simple-Assignment.html

# GOOD: Simple expansion - evaluated once
UNAME_S := $(shell uname -s)

# BAD: Recursive expansion - runs uname every time UNAME_S is referenced
UNAME_S = $(shell uname -s)
```

### Pattern 3: Idempotent Command Selection

**What:** Use commands that are inherently safe to re-run, or add guards for commands that aren't.

**When to use:** For every command in every target recipe.

**Commands that are idempotent:**
- `brew bundle --file=Brewfile` - skips already-installed packages automatically
- `stow -d DIR -t TARGET package` - skips existing correct symlinks, only errors on conflicts
- `apt-get install -y package` - skips already-installed packages

**Commands that need guards:**
- Homebrew installer script - check if `brew` command exists first
- `rm` commands - use `-f` flag or check existence first
- File creation - check if file exists first

**Example:**
```makefile
# Source: Homebrew official install documentation
# https://github.com/Homebrew/install

install-brew:
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Installing Homebrew..."; \
		curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash; \
	fi

install-packages: install-brew
	brew bundle --file=$(DOTFILES_DIR)/Brewfile

stow-packages:
	stow -d $(DOTFILES_DIR)/stow -t $(HOME) zsh git tmux nvim
```

### Pattern 4: Two-Phase Stow Safety

**What:** Stow uses a two-phase algorithm (since version 2.0): first scan for conflicts, then apply changes only if no conflicts exist.

**When to use:** Default behavior when using `stow` command. Use `stow -R` (restow) when package structure has changed.

**Why:** This ensures atomicity - either all symlinks are created successfully, or none are modified. Prevents partial stowing due to conflicts mid-operation.

**Example:**
```bash
# Source: GNU Stow manual - Conflicts section
# https://www.gnu.org/software/stow/manual/html_node/Conflicts.html

# Normal stow - safe for initial installation and re-runs
stow -d ./stow -t $HOME zsh

# Restow - first unstow, then stow again
# Use after updating package structure (adding/removing files)
stow -R -d ./stow -t $HOME zsh
```

### Anti-Patterns to Avoid

- **Using `=` for shell commands:** Causes `$(shell ...)` to re-execute on every variable reference, slowing Make and potentially causing inconsistent state if external conditions change between calls.

- **Omitting .PHONY declarations:** If someone creates a file named `install` or `clean`, Make will think the target is satisfied and skip execution.

- **Non-idempotent commands without guards:** Commands like `mkdir` (without `-p`), `ln` (without `-f`), or installer scripts that error on re-run break idempotency.

- **Stow conflicts left unhandled:** If files already exist at target locations and aren't symlinks, stow will error and abort. Either remove conflicting files first, or document that manual cleanup is required.

- **Homebrew install without existence check:** The Homebrew installer is idempotent but outputs warnings and takes time on re-runs. Adding a guard improves UX.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Symlink management | Custom shell script to create symlinks | GNU Stow | Handles edge cases: directory folding/unfolding, conflict detection, atomic operations, complete reversibility. Custom scripts miss dozens of corner cases. |
| Package installation | Custom loop over package list | `brew bundle` with Brewfile | Declarative format, built-in idempotency, cross-references between brew/cask/mas, automatic skip of installed packages, dependency resolution. |
| Platform detection | External bin/ scripts (is-macos, is-wsl) | Make conditionals with `uname` | Zero runtime dependencies, evaluated once at Make startup, standard approach in portable Makefiles, no PATH dependencies. |
| File deletion tracking | Git log or memory | REMOVED.md documentation file | Git log shows what was deleted, but not why. REMOVED.md provides rationale, preventing reintroduction and explaining decisions to future maintainers. |

**Key insight:** Idempotent installation is deceptively complex. Edge cases include: partial installation state, concurrent runs, network failures mid-install, permission issues, symlink conflicts, package rename/deprecation. Using mature tools (Make, Stow, Homebrew) means inheriting decades of edge-case handling instead of rediscovering them through failures.

## Common Pitfalls

### Pitfall 1: Stow Conflicts with Existing Files

**What goes wrong:** Running `stow` when files already exist at target locations causes errors like "existing target is neither a link nor a directory" and aborts without creating any symlinks.

**Why it happens:** Stow's safety design refuses to overwrite non-symlink files. Common sources: (1) files from previous manual setup, (2) files created by other dotfiles management approaches, (3) default configs created by tools on first run.

**How to avoid:**
1. Document prerequisite: target directory should be clean for first installation
2. Provide `unlink` target for reversal: `stow -D` removes symlinks safely
3. Consider using `--adopt` flag (Stow 2.3.0+) to move existing files into the stow package, but this modifies package structure

**Warning signs:** Error messages containing "existing target" or "conflicts". Stow's two-phase algorithm means if any conflict exists, no changes are made.

**Example handling:**
```makefile
# Source: Verified via Stow manual and practical experience

unlink:
	stow -d $(DOTFILES_DIR)/stow -t $(HOME) -D zsh git tmux nvim

# Users can run 'make unlink' before 'make install' to clean state
```

### Pitfall 2: Homebrew Installation Takes Minutes on Every Run

**What goes wrong:** If `install-brew` target doesn't check whether Homebrew is already installed, it runs the installer script every time. The script is idempotent but outputs many lines and takes 30-60 seconds even when Homebrew exists.

**Why it happens:** The Homebrew install script doesn't immediately exit when Homebrew is present - it checks various conditions and reports status.

**How to avoid:** Add conditional guard using `command -v brew` to check if `brew` command exists in PATH before running installer.

**Warning signs:** `make install` takes significantly longer on second run than expected. Installer output appears when Homebrew is already installed.

**Example:**
```makefile
# BAD: Always runs installer script
install-brew:
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

# GOOD: Only runs if brew doesn't exist
install-brew:
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Installing Homebrew..."; \
		curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash; \
	fi
```

### Pitfall 3: Target Line Count Pressure

**What goes wrong:** The success criterion specifies "Makefile is under 50 lines." This creates pressure to compress or remove comments, reducing maintainability. Current Makefile is 55 lines.

**Why it happens:** Line count is a proxy metric for simplicity, but comments and whitespace improve clarity without adding complexity.

**How to avoid:** Count only non-blank, non-comment lines for the metric. Or accept that the current 55-line Makefile is already minimal and adjust expectations.

**Warning signs:** Removing helpful comments or compressing multi-line conditionals into hard-to-read one-liners to meet arbitrary line count.

**Recommendation:** The current Makefile structure is sound. Focus on removing unnecessary targets rather than compressing necessary ones. If 5 lines must be removed, candidates: (1) combine `wsl: linux` with linux target, (2) inline install-deps into linux target if it's the only user.

### Pitfall 4: REMOVED.md Becomes Stale or Gets Lost

**What goes wrong:** REMOVED.md is created during Phase 4 but later deleted, moved, or not updated when similar files are removed in future phases. The rationale for deletions is lost, leading to reintroduction of similar patterns.

**Why it happens:** Documentation files feel like overhead and are easy to delete during "cleanup." Git log shows what was deleted but not the reasoning behind decisions.

**How to avoid:**
1. Place REMOVED.md at repository root (high visibility)
2. Include it in README.md's table of contents
3. Structure it with timestamps and clear categories
4. Reference it in commit messages for deletion commits

**Warning signs:** Someone proposes reintroducing a pattern that was already removed (e.g., "should we add macOS defaults scripts?").

**Example structure:**
```markdown
# REMOVED.md

Files removed during dotfiles simplification. Documents what was deleted and why.

## Phase 4: Installation & Cleanup (2026-02-14)

### macOS Defaults Scripts (CLN-04)
- `macos/defaults.sh` (382 lines)
- `macos/defaults-chrome.sh` (12 lines)
- `macos/dock.sh` (11 lines)

**Why removed:** macOS defaults are fragile across OS versions. Settings change with each macOS release, scripts break silently, and debugging requires system-level knowledge. Manual configuration is more reliable.

**Do not reintroduce:** Defaults scripts create maintenance burden disproportionate to value.
```

### Pitfall 5: Wrong Makefile Line Count Metric

**What goes wrong:** Counting total lines (with comments and blank lines) instead of meaningful lines leads to removing helpful documentation.

**Why it happens:** The success criterion says "under 50 lines" without specifying what counts. The current Makefile is 55 lines total but only ~35 lines of actual code.

**How to avoid:** Clarify the metric. Either:
- Count only non-blank, non-comment lines (current: ~35 → already under 50)
- Adjust target to realistic number (55-60 lines with comments is perfectly reasonable)
- Focus on reducing complexity, not line count

**Warning signs:** Removing `# Supports: macOS (Intel/ARM), Linux, WSL2` comment or combining related lines into hard-to-read one-liners.

**Example:**
```bash
# Count meaningful lines (non-blank, non-comment)
grep -v '^\s*#' Makefile | grep -v '^\s*$' | wc -l
# Result: ~35 lines (already under 50)

# Current total with comments and blank lines
wc -l Makefile
# Result: 55 lines
```

## Code Examples

Verified patterns from official sources and existing codebase:

### Complete Idempotent Makefile Structure

```makefile
# Source: Current dotfiles Makefile (Phase 3 output) with Phase 4 improvements
# Cross-platform dotfiles installation
# Supports: macOS (Intel/ARM), Linux, WSL2
# Usage: make [macos|linux|wsl] or just 'make' to auto-detect

DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

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

.PHONY: all macos linux wsl install-deps install-brew install-packages stow-packages unlink

all: $(OS)

macos: install-brew install-packages stow-packages

linux: install-deps install-brew install-packages stow-packages

wsl: linux

install-deps:
ifeq ($(UNAME_S),Linux)
	sudo apt-get update && sudo apt-get install -y build-essential curl git
endif

install-brew:
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Installing Homebrew..."; \
		curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash; \
	fi

install-packages: install-brew
	brew bundle --file=$(DOTFILES_DIR)/Brewfile

stow-packages:
	stow -d $(DOTFILES_DIR)/stow -t $(HOME) zsh git tmux nvim

unlink:
	stow -d $(DOTFILES_DIR)/stow -t $(HOME) -D zsh git tmux nvim
```

### REMOVED.md Template

```markdown
# Source: Keep a Changelog format + standard documentation practices
# https://keepachangelog.com/en/1.1.0/

# REMOVED.md

Files and directories removed during dotfiles simplification.

Documents what was deleted and why. Prevents reintroduction of discarded patterns.

## Format

Each entry includes:
- File path and line count
- Deletion date and related requirement
- Clear rationale
- Guidance on whether similar patterns should be reintroduced

---

## Phase 4: Installation & Cleanup (2026-02-14)

### macOS Defaults Scripts (CLN-04)

**Files:**
- `macos/defaults.sh` (382 lines) - System preferences automation
- `macos/defaults-chrome.sh` (12 lines) - Chrome-specific settings
- `macos/dock.sh` (11 lines) - Dock configuration via dockutil

**Rationale:** macOS defaults scripts are fragile across OS versions. Each macOS release changes preference keys, removes options, or moves settings to different domains. Scripts break silently - settings fail to apply but produce no errors. Debugging requires deep system knowledge and `defaults read` exploration.

Manual configuration through System Settings is more reliable. Users verify settings visually, immediate feedback when options don't exist, no silent failures.

**Do not reintroduce:** Defaults scripts create maintenance burden disproportionate to value. If automation is desired in future, use declarative tools with version-specific profiles.

### Remote Install Script (CLN-05)

**Files:**
- `remote-install.sh` (36 lines) - One-line curl-to-bash installer

**Rationale:** Remote install adds complexity (tarball extraction, git-less install, OSTYPE detection) for personal dotfiles repo. Installation pattern `curl URL | bash` is security anti-pattern. Local clone + make install is simple and explicit.

Dotfiles are personal configuration. Remote install suggests distribution to many users, which isn't this repo's purpose.

**Do not reintroduce:** This is personal config, not distributed software. Clone repo, review contents, run make - that's the right pattern.

### Language Package Managers (CLN-06)

**Files:**
- `install/npmfile` (17 packages) - Node.js global packages
- `install/Rustfile` (3 packages) - Rust cargo packages
- `stow/zsh/.config/zsh/.zsh_path` references to `$HOME/.cargo/bin`, etc.

**Rationale:** Language package management is not a dotfiles concern (see REQUIREMENTS.md "Out of Scope"). Each language has its own version manager (nvm, rustup) and installation approach. Dotfiles should configure the shell environment, not manage language toolchains.

Including language packages couples dotfiles updates to language ecosystem changes. npmfile packages become outdated, deprecated, or irrelevant. Users manage language tools separately with project-specific tooling.

**Do not reintroduce:** Language packages belong in project-level package.json, Cargo.toml, etc., not in dotfiles.

### Old install/ Directory

**Files:**
- `install/Brewfile` (57 packages) - Obsolete package list
- `install/Caskfile` (12 apps) - GUI applications
- `install/Codefile` (9 extensions) - VS Code extensions
- `install/duti` (92 file associations) - File type handlers

**Rationale:** Obsolete infrastructure from pre-Phase-3 setup. Root-level Brewfile (8 packages) replaced install/Brewfile. Casks (GUI apps) managed manually per REQUIREMENTS.md. VS Code extensions managed via VS Code Settings Sync. File associations (duti) require manual setup - auto-configuration is brittle.

**Do not reintroduce:** Root Brewfile is canonical. Don't split package management across multiple files.
```

### Testing Idempotency

```bash
# Source: Practical testing approach from Makefile best practices

# Test 1: Fresh installation
make clean  # if implemented
make all

# Test 2: Re-run should succeed without errors
make all

# Test 3: Specific target re-run
make install-brew    # Should see "brew already installed" or skip
make install-packages  # Should see "packages already installed" or skip
make stow-packages    # Should complete silently (symlinks already exist)

# Test 4: Verify state after multiple runs
ls -la ~/ | grep -E "\.zshrc|\.gitconfig|\.tmux.conf"  # Symlinks exist
which brew  # Homebrew in PATH
brew list | grep -E "git|neovim|tmux|stow|zsh"  # Packages installed

# Test 5: Unstow and restow
make unlink  # Remove symlinks
ls -la ~/ | grep -E "\.zshrc|\.gitconfig"  # Should not exist
make stow-packages  # Recreate symlinks
ls -la ~/ | grep -E "\.zshrc|\.gitconfig"  # Back again
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| External platform detection scripts (bin/is-macos) | Inline Makefile conditionals with uname | Phase 3 (2026-02) | Zero runtime dependencies, faster execution, standard Make pattern |
| Recursive variable expansion (=) | Simple variable expansion (:=) | Phase 3 (2026-02) | Shell commands execute once instead of on every reference, predictable behavior |
| Manual symlink shell scripts | GNU Stow | Common pattern (pre-2020) | Atomic operations, conflict detection, complete reversibility |
| Multiple Brewfiles in install/ | Single root-level Brewfile | Phase 3 (2026-02) | Single source of truth, clear dependency list |
| macOS defaults automation | Manual System Settings configuration | Phase 4 (2026-02) | More reliable across macOS versions, no silent failures |

**Deprecated/outdated:**
- `install/` directory: Old location for installation files. Root-level Brewfile and Makefile are canonical.
- `bin/is-*` scripts: Platform detection moved to inline Makefile and shell OSTYPE checks.
- `remote-install.sh`: Security anti-pattern (curl-to-bash), unnecessary for personal dotfiles.
- nvm integration in .zsh_path: Language version management removed from dotfiles scope.

## Open Questions

1. **Should Makefile include a `clean` target?**
   - What we know: Common Make pattern for reverting installation state
   - What's unclear: What "clean" means for dotfiles - unstow? uninstall packages? both?
   - Recommendation: Provide `unlink` target (already exists) for unstowing. Don't uninstall packages (breaks system). Document that `make unlink` is reversal mechanism.

2. **How to handle Stow conflicts on first install?**
   - What we know: If files exist at target locations, stow errors and aborts
   - What's unclear: Should Makefile detect conflicts and prompt? Auto-backup? Error clearly?
   - Recommendation: Document in README.md that target directory should be clean. Provide clear error message pointing to `make unlink` for reversal. Don't auto-resolve - user should consciously decide.

3. **Exact line count for "under 50 lines" criterion**
   - What we know: Current Makefile is 55 total lines, ~35 code lines
   - What's unclear: Does criterion count comments/blank lines?
   - Recommendation: Count only meaningful lines (non-blank, non-comment). Current Makefile already satisfies criterion. If literal line count is required, inline `install-deps` into `linux` target (saves 4 lines) and compress blank lines (saves 5+ lines).

4. **Should REMOVED.md be committed in Phase 4 or later?**
   - What we know: REMOVED.md documents deletions for future reference
   - What's unclear: Should it be created empty and populated, or created with Phase 4 deletions?
   - Recommendation: Create REMOVED.md in Phase 4 with all Phase 4 deletions documented. Add entries from previous phases if files were deleted without documentation. Establishes pattern for future deletions.

## Sources

### Primary (HIGH confidence)

- [GNU Make - Phony Targets](https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html) - Phony target syntax and purpose
- [GNU Make - Simple Assignment](https://www.gnu.org/software/make/manual/html_node/Simple-Assignment.html) - Simple vs recursive expansion
- [GNU Stow Manual - Conflicts](https://www.gnu.org/software/stow/manual/html_node/Conflicts.html) - Conflict detection and two-phase algorithm
- [Homebrew Documentation - brew bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile) - Brewfile format and bundle command
- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) - Documentation best practices for tracking changes

### Secondary (MEDIUM confidence)

- [Makefile platform detection GitHub Gist](https://gist.github.com/sighingnow/deee806603ec9274fd47) - uname patterns for OS detection
- [Homebrew idempotency GitHub issue #11393](https://github.com/Homebrew/brew/issues/11393) - brew install idempotent behavior
- [Homebrew Bundle issue #170](https://github.com/Homebrew/homebrew-bundle/issues/170) - brew bundle skips installed packages
- [GNU Stow - Ubuntu manpage](https://manpages.ubuntu.com/manpages/jammy/man8/stow.8.html) - Stow command-line options
- [Managing Dotfiles with GNU Stow](https://stevenrbaker.com/tech/managing-dotfiles-with-gnu-stow.html) - Practical stow usage patterns

### Tertiary (LOW confidence - marked for validation)

- Various blog posts and Medium articles about Makefile best practices - general guidance verified against official documentation
- Multiple Stack Overflow discussions about Make variable expansion - patterns verified against GNU Make manual

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - GNU Make, Stow, and Homebrew are mature tools with stable documentation
- Architecture: HIGH - Patterns verified from official documentation and existing working Makefile
- Pitfalls: HIGH - Based on official documentation (Stow conflicts, Make phony targets) and practical experience visible in codebase
- Code examples: HIGH - Derived from official docs and current working Makefile in repository

**Research date:** 2026-02-14
**Valid until:** 2026-03-14 (30 days - stable domain, tools change slowly)

**Notes:**
- No CONTEXT.md exists for this phase, so no user constraints to carry forward
- Current Makefile (Phase 3 output) is already well-structured; Phase 4 primarily removes obsolete files
- All tools (Make, Stow, Homebrew) are already installed and working per Phase 3 completion
- The idempotency requirement is largely met by current implementation; main gap is Homebrew install guard and .PHONY documentation
