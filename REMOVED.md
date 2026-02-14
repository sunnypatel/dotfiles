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

## Earlier Phases (Brief Summary)

### Phase 1: Shell Consolidation (2026-02-12)
- Bash configurations removed (switched to Zsh-only)
- system/.dir_colors removed (integrated into .zshrc for Linux)

### Phase 2: Stow Package Migration (2026-02-13)
- config/ directory removed (tool configs migrated to stow packages or removed)
- .stow-local-ignore removed (packages isolated under stow/ don't need it)
- Multiple tool configs removed: alacritty, prettier, thefuck, topgrade

### Phase 3: Platform Support (2026-02-14)
- bin/ directory removed (platform detection scripts: is-macos, is-wsl, is-arm64, etc.)
- test/ directory removed (old BATS test infrastructure)
- All bin/ utility scripts removed (append, dot, json, etc.)

See git log for complete details: `git log --diff-filter=D --summary`
