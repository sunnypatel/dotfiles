# Architecture

**Analysis Date:** 2026-02-13

## Pattern Overview

**Overall:** Multi-platform shell configuration management system with platform detection, modular configuration sourcing, and declarative package installation.

**Key Characteristics:**
- **Platform-aware**: Automatic detection and conditional setup for macOS, Linux, WSL, and architecture (Intel/ARM)
- **Modular sourcing**: Configuration split into focused files, selectively sourced based on context
- **Declarative package management**: Package lists stored as manifest files, applied via Makefile orchestration
- **Symlink-based distribution**: GNU Stow manages symlinks from repo to home directory and XDG config locations
- **Shell-agnostic core**: Base configuration works with bash and zsh; framework-specific features added conditionally

## Layers

**Entry Point / Initialization Layer:**
- Purpose: Bootstrap shell environment and establish paths
- Location: `runcom/.bash_profile` (bash), `runcom/.zshrc` (zsh)
- Contains: DOTFILES_DIR resolution, initial PATH setup, sourcing orchestration
- Depends on: `bin/` detection utilities, `system/` configuration files
- Used by: Shell processes at startup

**Detection & Platform Layer:**
- Purpose: Determine OS type, distribution, architecture for conditional setup
- Location: `bin/is-macos`, `bin/is-wsl`, `bin/is-ubuntu`, `bin/is-debian`, `bin/is-arm64`, `bin/is-supported`, `bin/is-executable`
- Contains: Exit-code-based detection scripts (0 for true, 1 for false)
- Depends on: System files (`/proc/version`, environment variables, `$OSTYPE`)
- Used by: Makefile, shell initialization, conditional feature loading

**Configuration Layer:**
- Purpose: Define environment variables, functions, aliases, and behavior
- Location: `system/` directory with modular `.dotfiles` files
- Contains: Grouped by concern: `.env*`, `.alias*`, `.function*`, `.path`, `.completion*`, `.fzf`, `.grep`, `.prompt`, `.fix`, `.zoxide`
- Depends on: Detection layer for conditional sourcing
- Used by: Shell sessions for interactive features

**Installation & Package Management Layer:**
- Purpose: Install and manage system packages and tools across platforms
- Location: `Makefile`, `install/` directory (Brewfile, Caskfile, npmfile, Rustfile, duti, etc.)
- Contains: Platform-specific package lists, installation orchestration, Homebrew setup
- Depends on: Detection layer to determine which installer to use
- Used by: Initial setup, package updates

**Application Configuration Layer:**
- Purpose: Store application-specific settings distributed via symlinks
- Location: `config/` directory (git, tmux, alacritty, prettier, thefuck, topgrade)
- Contains: Actual config files that symlink to `~/.config/` via stow
- Depends on: Symlink setup (stow)
- Used by: Applications reading from `~/.config/`

**System Defaults Layer:**
- Purpose: Apply macOS-specific system and UI defaults
- Location: `macos/` directory (defaults.sh, defaults-chrome.sh, dock.sh)
- Contains: macOS system preferences via `defaults write` commands, Dock configuration
- Depends on: macOS only
- Used by: `dot macos` and `dot dock` commands

**Command Interface Layer:**
- Purpose: Provide user-facing CLI for dotfiles operations
- Location: `bin/dot` shell script with sub-command dispatcher
- Contains: Command router (help, test, update, macos, dock, edit, clean, duti)
- Depends on: All other layers
- Used by: User shell sessions

## Data Flow

**Installation Flow:**

1. **Remote Bootstrap** → `remote-install.sh` detects OS, clones repo to `~/.dotfiles`, invokes appropriate make target
2. **OS Detection** → Makefile runs detection scripts, sets `OS` variable (macos/linux/wsl)
3. **System Setup** → Platform-specific `core-*` targets install foundational tools (git, bash, package managers)
4. **Package Installation** → Multi-stage installation: brew/apt → casks/node/rust → application-specific packages
5. **Symlink Creation** → Stow creates symlinks: `runcom/` → `~`, `config/` → `~/.config/`
6. **Completion** → User runs post-install commands (git config, dot macos)

**Shell Initialization Flow:**

1. **Shell Startup** → Bash or Zsh reads `~/.bash_profile` or `~/.zshrc` (symlinked from `runcom/`)
2. **DOTFILES_DIR Resolution** → Script resolves symlink chain to find actual repo location
3. **PATH Assembly** → `.path` file builds PATH from system paths, Homebrew, dotfiles/bin
4. **Non-interactive Return** → If not interactive shell, stop here (no aliases/functions needed)
5. **Core Utilities Load** → Essential files loaded: `.function`, `.function_*`, `.env`, `.exports`
6. **Node Version Management** → `.nvm` sourced to enable Node.js version switching
7. **Interactive Features** → Load shell-specific features: `.alias`, `.prompt` (bash only), `.completion`, `.fzf`
8. **Platform Features** → Load OS-specific extras (`.env.macos`, `.env.wsl`, `.alias.macos`)
9. **Color Setup** → Build dircolors cache from `.dir_colors` for faster startup
10. **Framework Initialization** → Zsh loads Zim framework and initialization

**State Management:**

- **Path state**: Deduplicates `$PATH` to remove duplicates while preserving prepended items
- **Environment variables**: Centralized in `system/.env*` files, conditionally set per-platform
- **History state**: Configured through bash/zsh-specific options in `.env`
- **Shell function state**: Functions live in memory after sourcing; persist across session
- **Alias state**: Aliases live in memory after sourcing; reset when shell reloads

## Key Abstractions

**Detection Scripts:**
- Purpose: Encapsulate OS/platform checks as reusable boolean functions
- Examples: `bin/is-macos`, `bin/is-wsl`, `bin/is-ubuntu`
- Pattern: Exit with 0 (true) or 1 (false); composable with shell conditionals and Makefile `$(shell ...)`

**Shell Configuration Modules:**
- Purpose: Group related configuration concerns into single-purpose files
- Examples: `system/.alias`, `system/.completion`, `system/.function_fs`
- Pattern: Sourced conditionally based on shell type or interactivity; prefixed with dot for hidden files

**Package Manifests:**
- Purpose: Declarative lists of packages to install per tool/platform
- Examples: `install/Brewfile`, `install/npmfile`, `install/Rustfile`
- Pattern: Simple text files (one package per line or Homebrew formula syntax); processed by respective package managers

**Symlink Configuration:**
- Purpose: Separate repo structure from home directory structure via symlinks
- Examples: `runcom/` → `~`, `config/` → `~/.config/`
- Pattern: Uses GNU Stow; automatically handles conflicts, backups to `.bak` files

**Sub-command Dispatcher:**
- Purpose: Route user commands to implementation functions
- Location: `bin/dot`
- Pattern: `sub_<command>() { ... }` functions; `$1` parsed to determine which function to call

## Entry Points

**Installation Entry Point:**
- Location: `remote-install.sh`
- Triggers: User runs one-line curl/bash command from README
- Responsibilities: Clone repository, detect OS, execute appropriate Makefile target

**Shell Initialization Entry Point:**
- Location: `runcom/.bash_profile` (bash) and `runcom/.zshrc` (zsh)
- Triggers: Shell startup
- Responsibilities: Resolve DOTFILES_DIR, setup PATH, source configuration modules, initialize prompt/completion

**Makefile Entry Point:**
- Location: `Makefile`
- Triggers: `make macos`, `make linux`, `make wsl` from user or remote-install.sh
- Responsibilities: Orchestrate multi-stage installation, detect platform, manage symlinks

**User Command Entry Point:**
- Location: `bin/dot`
- Triggers: User runs `dot <command>` from shell
- Responsibilities: Route to sub-command implementation, provide help, orchestrate operations

## Error Handling

**Strategy:** Silent failures with fallbacks; exit codes indicate success/failure

**Patterns:**

- **Detection scripts**: Return exit code (0=true/1=false); used with `if script; then` pattern
- **Installation**: Individual tools may fail but installation continues (`|| true`); later steps may compensate
- **Path building**: Directory existence checked before adding to PATH (`[ -d $1 ] && ...`)
- **Command fallbacks**: Multiple methods tried for download (git → curl → wget in `remote-install.sh`)
- **Locale setup**: Attempts UTF-8, falls back to C.UTF-8, continues without error
- **DOTFILES_DIR resolution**: Multiple methods tried; returns early if resolved; falls back to heuristics

## Cross-Cutting Concerns

**Logging:** No centralized logging; operations output to stdout with descriptive messages (echo commands)

**Validation:** Implicit via exit codes; explicit checks via `is-executable`, `is-supported` before running tools

**Authentication:** None required; uses public repos and API endpoints; `$GITHUB_TOKEN` optional for grip command

**Secrets/Tokens:** Not handled by core system; users create `system/.exports` file for personal tokens (not tracked)

**Platform Abstraction:** Pervasive; `is-*` scripts encapsulate checks; Makefile uses `$(OS)` variable to dispatch targets

**Performance Optimization:** `dircolors` output cached to `.cache/dircolors.sh`; Zim completion settings configured for fast startup

---

*Architecture analysis: 2026-02-13*
