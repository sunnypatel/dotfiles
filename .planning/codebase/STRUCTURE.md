# Codebase Structure

**Analysis Date:** 2026-02-13

## Directory Layout

```
/home/sunny/projects/dotfiles/
├── bin/              # Utility scripts and CLI entry point
├── config/           # Application configurations (symlinked to ~/.config)
│   ├── alacritty/
│   ├── git/
│   ├── prettier/
│   ├── thefuck/
│   ├── tmux/
│   └── topgrade.toml
├── install/          # Package manifests for installation
├── macos/            # macOS-specific system defaults and configuration
├── runcom/           # Shell configuration and runtime dotfiles (symlinked to ~)
├── system/           # Core system environment and function files
├── test/             # Test suite and verification scripts
├── .github/          # GitHub Actions and workflows
├── .planning/        # Planning and analysis documents (git-tracked)
├── .vscode/          # VS Code settings
├── Makefile          # Build and installation orchestration
├── README.md         # User documentation and installation instructions
├── remote-install.sh # One-liner bootstrap script
├── TESTING.md        # Testing guide and documentation
└── .editorconfig     # Editor configuration standards
```

## Directory Purposes

**`bin/`:**
- Purpose: Utility scripts and CLI interface
- Contains: Platform detection scripts, command dispatcher, helper utilities
- Key files:
  - `dot` - Main CLI entry point (sub-command dispatcher)
  - `is-macos`, `is-wsl`, `is-ubuntu`, `is-debian` - Platform detection
  - `is-arm64`, `is-executable`, `is-supported` - Capability detection
  - `append` - Append to file utility
  - `json` - JSON parsing helper

**`config/`:**
- Purpose: Application-specific configuration files
- Contains: Config files for tmux, git, alacritty, code editors, system utilities
- Distributed via: GNU Stow symlinks to `~/.config/`
- Key files:
  - `git/config` - Git configuration
  - `tmux/tmux.conf.local` - Tmux settings
  - `alacritty/alacritty.yml` - Terminal emulator config
  - `topgrade.toml` - System update tool config
  - `prettier/`, `thefuck/` - Tool configurations

**`install/`:**
- Purpose: Declarative package manifests for system installation
- Contains: Lists of packages and applications to install per tool/platform
- Key files:
  - `Brewfile` - Homebrew packages (macOS)
  - `Caskfile` - Homebrew cask GUI apps (macOS)
  - `npmfile` - Global NPM packages
  - `Rustfile` - Rust crates via cargo
  - `Codefile` - VS Code extensions
  - `duti` - File type associations (macOS)

**`macos/`:**
- Purpose: macOS-specific system defaults and configurations
- Contains: Scripts to apply macOS system preferences
- Key files:
  - `defaults.sh` - macOS system preferences (finder, dock, keyboard, etc.)
  - `defaults-chrome.sh` - Google Chrome-specific defaults
  - `dock.sh` - Dock icon reordering and configuration

**`runcom/`:**
- Purpose: Shell runtime configuration files (rc files)
- Contains: Shell startup files (.bashrc, .bash_profile, .zshrc), shell utilities (.inputrc)
- Distributed via: GNU Stow symlinks to `~`
- Key files:
  - `.bash_profile` - Bash login shell initialization (main entry point)
  - `.zshrc` - Zsh interactive shell initialization
  - `.zshenv` - Zsh environment variables (non-interactive)
  - `.zimrc` - Zim framework configuration
  - `tmux.conf.local` - Tmux configuration
  - `.inputrc` - GNU Readline configuration

**`system/`:**
- Purpose: Core system configuration and utility functions
- Contains: Modular shell configuration files sourced during initialization
- Grouped by concern (environment, functions, aliases, completion, etc.)
- Key files:
  - `.path` - PATH assembly logic
  - `.env`, `.env.bash`, `.env.macos`, `.env.zsh` - Environment variables
  - `.function`, `.function_*` - Shell utility functions
  - `.alias`, `.alias.macos` - Shell aliases
  - `.completion`, `.completion.bash`, `.completion.zsh` - Completion setup
  - `.prompt` - Bash prompt configuration
  - `.fzf` - Fuzzy finder integration
  - `.grep` - Grep options and colors
  - `.dir_colors` - Color output definitions
  - `.exports` - User-specific exports (not tracked, git-ignored)
  - `.fix` - Shell fixes/workarounds
  - `.nvm` - Node Version Manager setup
  - `.zoxide` - Directory navigation shortcut setup

**`test/`:**
- Purpose: Automated testing and verification
- Contains: Test suite using Bats (Bash Automated Testing System) and quick verification script
- Key files:
  - `os-detection.bats` - Platform detection tests
  - `installation.bats` - Installation process tests
  - `path-config.bats` - PATH configuration tests
  - `bin.bats` - Binary/utility script tests
  - `function.bats` - Shell function tests
  - `verify-setup.sh` - Quick verification without Bats dependency
  - `README.md` - Testing documentation

**`.planning/codebase/`:**
- Purpose: GSD codebase mapping and analysis documents
- Contains: Architecture, structure, conventions, testing patterns analysis
- Files: ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md, TESTING.md, CONCERNS.md

## Key File Locations

**Entry Points:**

- `remote-install.sh` - Bootstrap script for one-line installation from GitHub
- `runcom/.bash_profile` - Bash shell initialization (main shell entry point)
- `runcom/.zshrc` - Zsh shell initialization (alternative shell entry point)
- `Makefile` - Installation and setup orchestration

**Configuration:**

- `system/.env` - Core environment variables (cross-platform)
- `system/.path` - PATH assembly logic
- `runcom/.zshenv` - Zsh environment (sourced before .zshrc)
- `.editorconfig` - Editor formatting standards

**Core Logic:**

- `bin/dot` - Main CLI dispatcher for user commands
- `system/.prompt` - Bash prompt rendering and git status
- `system/.function*` - Utility functions for shell operations
- `Makefile` - Installation orchestration and target definitions

**Testing:**

- `test/verify-setup.sh` - Quick setup verification script
- `test/*.bats` - Full test suite using Bats framework
- `test/README.md` - Testing documentation

**Package Management:**

- `install/Brewfile` - Homebrew packages list
- `install/npmfile` - Global NPM packages
- `install/Rustfile` - Cargo crates to install

## Naming Conventions

**Files:**

- **Dotfiles** (hidden): Start with `.` (e.g., `.bashrc`, `.zshrc`, `.gitignore`)
- **System modules** (hidden): `system/.[name]` for core config modules (e.g., `.path`, `.env`, `.alias`)
- **Platform variants** (hidden): `system/.[name].[platform]` for OS-specific modules (e.g., `.env.macos`, `.alias.macos`)
- **Detection scripts** (executable): `bin/is-*` for platform/capability checks
- **Bash scripts**: Typically `bin/*.sh` or executable without extension in `bin/`
- **Package lists**: Simple names reflecting tool (`Brewfile`, `npmfile`, `Rustfile`)
- **Makefile targets**: kebab-case (e.g., `core-macos`, `brew-packages`, `stow-wsl`)

**Directories:**

- **Config directories**: Lowercase, reflect application name (`alacritty/`, `tmux/`, `git/`)
- **System directories**: Grouped by function (`bin/`, `config/`, `install/`, `system/`, `macos/`)
- **Platform variants**: If needed, suffix with platform (`_macos`, `_wsl`, `_linux`) - currently mixed in files

## Where to Add New Code

**New Shell Feature/Function:**
1. **Small utility** → Add to `system/.function` or create new `system/.function_[category]`
2. **Large feature** → Create new `system/.[name]` file and source from `runcom/.bash_profile`
3. **Platform-specific** → Add to `system/.[name].[platform]` and conditionally source
4. **Tests** → Create `test/[feature-name].bats` or add to existing test file

**New Shell Alias:**
1. **Global alias** → Add to `system/.alias`
2. **Platform-specific** → Add to `system/.alias.[platform]`
3. **Tool-specific** → Group with related aliases in same file or create `system/.alias_[tool]`

**New Application Configuration:**
1. **Standard app** → Create `config/[app-name]/[config-filename]`
2. **Structure** → Match expected XDG structure (will symlink correctly to `~/.config/`)
3. **Add to tracking** → File is automatically tracked once in `config/` directory

**New System Package:**
1. **Homebrew** → Add to `install/Brewfile` (macOS) or mention Linux equivalents
2. **NPM global** → Add to `install/npmfile`
3. **Rust** → Add to `install/Rustfile`
4. **macOS apps** → Add to `install/Caskfile`
5. **Linux** → Add to `apt-packages` target in Makefile

**New Installation Step:**
1. **Makefile target** → Add to `Makefile` following naming pattern `[stage]-[platform]` or `[tool]`
2. **Dependencies** → Use target dependencies (e.g., `packages: brew-packages cask-apps node-packages`)
3. **Documentation** → Update README.md with new steps if user-facing

**New Utility Script:**
1. **CLI command** → Add to `bin/` as executable file
2. **Detection script** → Use pattern `bin/is-[capability]` for boolean checks
3. **Helper** → Use pattern `bin/[verb]` (e.g., `bin/append`)

**New Test:**
1. **Detection tests** → Add to `test/os-detection.bats`
2. **Function tests** → Add to `test/function.bats`
3. **Installation tests** → Add to `test/installation.bats`
4. **New area** → Create `test/[feature].bats` following Bats syntax
5. **Quick verification** → Add check to `test/verify-setup.sh`

## Special Directories

**`.git/`:**
- Purpose: Git version control
- Generated: Yes (by git init)
- Committed: No

**`.github/workflows/`:**
- Purpose: GitHub Actions CI/CD pipelines
- Contains: `dotfiles-installation.yml` for automated testing
- Generated: No
- Committed: Yes

**`.planning/`:**
- Purpose: GSD planning and codebase analysis
- Contains: Architecture, structure, conventions documents
- Generated: By GSD tools (gsd:map-codebase)
- Committed: Yes

**`~/.dotfiles` (in user home):**
- Purpose: Runtime clone location (installation target)
- Note: Not in this repo; created by `remote-install.sh`

**`.cache/` (user home)**
- Purpose: Runtime caches (dircolors, zsh completion)
- Generated: Yes (by initialization scripts)
- Committed: No

---

*Structure analysis: 2026-02-13*
