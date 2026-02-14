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

### CLN-04: macOS Defaults Scripts

**Files:**
- `macos/defaults.sh` (381 lines) - System preferences automation
- `macos/defaults-chrome.sh` (11 lines) - Chrome-specific settings
- `macos/dock.sh` (11 lines) - Dock configuration via dockutil

**Rationale:** macOS defaults scripts are fragile across OS versions. Each macOS release changes preference keys, removes options, or moves settings to different domains. Scripts break silently - settings fail to apply but produce no errors. Debugging requires deep system knowledge and `defaults read` exploration.

Manual configuration through System Settings is more reliable. Users verify settings visually, get immediate feedback when options don't exist, and avoid silent failures.

**Do not reintroduce:** Defaults scripts create maintenance burden disproportionate to value. If automation is desired in future, use declarative tools with version-specific profiles.

### CLN-05: Remote Install Script

**Files:**
- `remote-install.sh` (36 lines) - One-line curl-to-bash installer

**Rationale:** Remote install adds complexity (tarball extraction, git-less install, OSTYPE detection) for personal dotfiles repo. Installation pattern `curl URL | bash` is a security anti-pattern. Local clone + make install is simple and explicit.

Dotfiles are personal configuration. Remote install suggests distribution to many users, which isn't this repo's purpose.

**Do not reintroduce:** This is personal config, not distributed software. Clone repo, review contents, run make - that's the right pattern.

### CLN-06: Language Package Managers

**Files:**
- `install/npmfile` (17 packages) - Node.js global packages
- `install/Rustfile` (3 packages) - Rust cargo packages

**Rationale:** Language package management is not a dotfiles concern (see REQUIREMENTS.md "Out of Scope"). Each language has its own version manager (nvm, rustup) and installation approach. Dotfiles should configure the shell environment, not manage language toolchains.

Including language packages couples dotfiles updates to language ecosystem changes. npmfile packages become outdated, deprecated, or irrelevant. Users manage language tools separately with project-specific tooling.

**Do not reintroduce:** Language packages belong in project-level package.json, Cargo.toml, etc., not in dotfiles.

### Old install/ Directory

**Files:**
- `install/Brewfile` (56 lines) - Obsolete package list
- `install/Caskfile` (20 lines) - GUI applications
- `install/Codefile` (9 lines) - VS Code extensions
- `install/duti` (91 lines) - File type handlers

**Rationale:** Obsolete infrastructure from pre-Phase-3 setup. Casks (GUI apps) managed manually per REQUIREMENTS.md. VS Code extensions managed via VS Code Settings Sync. File associations (duti) require manual setup - auto-configuration is brittle.

**Do not reintroduce:** Don't split package management across multiple files.

### Brewfile

**Files:**
- `Brewfile` (16 lines) - Root-level Homebrew package list

**Rationale:** Package list moved inline into Makefile's `install-packages` target. Each package is checked against system PATH before installing via Homebrew, avoiding redundant installs (e.g., git already present via apt). Brewfile had no way to express this "skip if system provides it" logic.

**Do not reintroduce:** Makefile is the single source of truth for package installation.

---

## Phase 3: Platform Support (2026-02-14)

### bin/ Directory

**Files:**
- `bin/is-macos` - macOS platform detection
- `bin/is-wsl` - WSL environment detection
- `bin/is-arm64` - ARM64 architecture detection
- `bin/is-debian` - Debian distribution detection
- `bin/is-ubuntu` - Ubuntu distribution detection
- `bin/is-supported` - Platform support checker
- `bin/is-executable` - Executable test helper
- `bin/append` - Append to file utility
- `bin/dot` - Dotfiles script runner
- `bin/json` - JSON processing utility

**Rationale:** Platform detection moved inline using `uname` directly in shell configuration. Every `bin/is-*` script spawned a subprocess - replacing with inline `[[ $(uname -s) == "Darwin" ]]` checks eliminated process overhead. Utility scripts (append, dot, json) were unused.

Scripts obscured simple operations. `is-macos` was a wrapper around `uname -s`. Direct conditionals are clearer and faster.

**Do not reintroduce:** Use inline platform detection with `uname`. If helper functions are needed, define them in shell config files, not as separate executables.

### Old Test Infrastructure

**Files:**
- `test/README.md` - Test documentation
- `test/bin.bats` - Binary utilities tests
- `test/function.bats` - Function tests
- `test/installation.bats` - Installation tests
- `test/os-detection.bats` - Platform detection tests
- `test/path-config.bats` - PATH configuration tests
- `test/verify-setup.sh` - Setup verification script
- `TESTING.md` - Testing guide

**Rationale:** Old test infrastructure replaced with new BATS-based CI tests in Phase 5. Old tests covered functionality that no longer exists (bin/ scripts, installation patterns removed in Phase 4).

**Do not reintroduce:** Current test infrastructure is in `.github/workflows/` with BATS tests. Don't maintain separate test/ directory.

---

## Phase 2: Stow Package Migration (2026-02-13)

### config/ Directory

**Files:**
- `config/alacritty/alacritty.toml` - Alacritty terminal config
- `config/alacritty/alacritty.yml` - Alacritty legacy config
- `config/prettier/.prettierrc` - Code formatter config
- `config/thefuck/settings.py` - Command correction tool config
- `config/topgrade.toml` - Update automation config

**Rationale:** XDG-compliant configs migrated to Stow packages under `stow/<tool>/.config/<tool>/`. Tools like alacritty, prettier, thefuck, and topgrade are no longer used. Topgrade tried to be a universal updater but added complexity - manual updates are clearer.

**Do not reintroduce:** Tool configs belong in Stow packages if the tool is actively used. Don't add configs for unused tools.

### Legacy Structure Files

**Files:**
- `.stow-local-ignore` - Stow ignore patterns
- `runcom/.zshrc.swp` - Vim swap file

**Rationale:** When all Stow packages moved under `stow/` directory, ignore rules became unnecessary. Each package is isolated. Swap file was accidental commit.

**Do not reintroduce:** Stow packages under `stow/` are self-contained. No ignore file needed.

### Obsolete system/ Directory

**Files:**
- `system/.alias` - Shell aliases
- `system/.alias.macos` - macOS-specific aliases
- `system/.completion` - Shell completions
- `system/.completion.bash` - Bash completions
- `system/.completion.zsh` - Zsh completions
- `system/.env` - Environment variables
- `system/.env.bash` - Bash environment
- `system/.env.macos` - macOS environment
- `system/.env.zsh` - Zsh environment
- `system/.fix` - Shell fixes
- `system/.function` - Shell functions
- `system/.function.macos` - macOS-specific functions
- `system/.function_fs` - Filesystem functions
- `system/.function_network` - Network functions
- `system/.function_text` - Text processing functions
- `system/.fzf` - FZF configuration
- `system/.grep` - Grep configuration
- `system/.java` - Java environment
- `system/.nvm` - NVM configuration
- `system/.path` - PATH configuration
- `system/.prompt` - Shell prompt
- `system/.zoxide` - Zoxide configuration

**Rationale:** Replaced by modular Zsh config in `stow/zsh/.config/zsh/`. New structure uses `.zsh_aliases`, `.zsh_functions`, `.zsh_path` for clarity. Platform-specific files (`.alias.macos`, `.env.macos`) eliminated - inline conditionals handle platform differences.

Splitting by shell type (.bash, .zsh) created duplication. Zsh-only approach removed this complexity.

**Do not reintroduce:** Use Zsh modular config in ZDOTDIR. Platform detection is inline, not separate files.

---

## Phase 1: Shell Consolidation (2026-02-12)

### Bash Configuration

**Files:**
- `runcom/.bash_profile` - Bash login shell config
- `runcom/.bashrc` - Bash interactive shell config
- `runcom/.inputrc` - Readline input config

**Rationale:** Switched to Zsh-only configuration. Maintaining both Bash and Zsh configs doubled maintenance burden with no benefit. Bash was legacy - all active usage was in Zsh.

Dual-shell support meant testing changes across two environments, handling subtle behavior differences, and maintaining parallel configuration sets.

**Do not reintroduce:** Zsh is the sole shell. If Bash compatibility is required, it's a different project.

### system/.dir_colors

**Files:**
- `system/.dir_colors` - LS_COLORS configuration

**Rationale:** Integrated inline into `.zshrc` for Linux-only loading via platform conditional. File contained dircolors configuration used only on Linux (macOS uses LSCOLORS). Sourcing inline eliminated extra file while maintaining functionality.

**Do not reintroduce:** Platform-specific configs belong inline with conditionals, not as separate files.
