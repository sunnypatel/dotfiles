# Technology Stack

**Analysis Date:** 2026-02-13

## Languages

**Primary:**
- Bash - System configuration, shell scripts, automation in `runcom/`, `system/`, `bin/`, `install/`, and `Makefile`
- Zsh - Shell configuration via Zim framework in `runcom/.zshrc` with `config/` terminal config
- Python - Limited use for specific tool configuration in `config/thefuck/settings.py`

**Secondary:**
- Shell/POSIX - Portable shell scripts for cross-platform OS detection in `bin/`

## Runtime

**Environment:**
- macOS (13+, 14, 15 with Apple Silicon and Intel support)
- Linux (Ubuntu/Debian tested, WSL2 supported)
- Windows Subsystem for Linux (WSL2)

**Package Manager:**
- Homebrew (macOS and Linux via Linuxbrew) - Primary package manager
- APT (Linux/WSL) - System package manager for Ubuntu/Debian
- npm (via Node Version Manager) - JavaScript packages
- Cargo (Rust) - Rust binaries
- Lockfile: Not applicable (package lists in text files)

## Frameworks

**Core:**
- Zim - `1.x` - Zsh framework/module system sourced in `runcom/.zshrc`
- GNU Stow - Configuration file symlink management in Makefile targets (`make link`, `make unlink`)

**Build/Dev:**
- Make - Makefile-based orchestration in `Makefile` for installation, testing, and updates
- BATS (Bash Automated Testing System) - Test framework in `test/` directory for unit and integration tests

**Version Management:**
- nvm (Node Version Manager) - Node.js version management with lazy loading in `system/.nvm`
- Rustup - Rust toolchain management

## Key Dependencies

**Critical for Installation:**
- coreutils - GNU core utilities (installed via Homebrew)
- bash 5+ - Modern Bash features for scripting
- git - Version control and Git utilities via `install/Brewfile`
- curl - Remote script downloading in Makefile targets
- stow - Symlink management via GNU Stow in `Makefile`

**Shell Enhancement:**
- zimfw (Zsh plugin manager) - Zim framework auto-installation in `runcom/.zshrc`
- fzf - Fuzzy finder sourced in `system/.fzf`
- zoxide - Directory jumping sourced in `system/.zoxide`
- git-delta - Enhanced diff viewer configured in `config/git/config`

**Development Tools:**
- ripgrep (rg) - Fast grep alternative
- fd - Fast find alternative
- bat - Syntax-highlighted cat replacement
- shellcheck - Shell script linting
- prettier - Code formatter configured in `config/prettier/.prettierrc`
- topgrade - Universal package manager updater used in `bin/dot`

**Runtime/CLI:**
- jq - JSON query processor
- httpie - HTTP client
- imagemagick - Image processing
- ffmpeg - Media processing
- thefuck - Command correction
- tmux - Terminal multiplexer configuration in `config/tmux/tmux.conf`

**Rust Utilities:**
- cargo-cache - Rust build cache management
- cargo-update - Cargo crate updates
- jless - JSON viewer

**Node.js Utilities:**
- @antfu/ni - Universal package manager runner
- pnpm - JavaScript package manager
- yarn - JavaScript package manager
- npm-check-updates - Update checker
- release-it - Release automation
- remark-cli - Markdown processor
- svgo - SVG optimization
- prettier - Code formatter

## Configuration

**Environment:**
- XDG Base Directory Specification compliance in `system/.env`:
  - `$XDG_CONFIG_HOME` → `~/.config`
  - `$XDG_DATA_HOME` → `~/.local/share`
  - `$XDG_CACHE_HOME` → `~/.cache`
  - `$XDG_STATE_HOME` → `~/.local/state`
  - `$XDG_RUNTIME_DIR` → `~/.local/runtime` (macOS only, managed by systemd on Linux)

- Locale Configuration: `en_US.UTF-8` or `C.UTF-8` fallback with generation support in `system/.env`

- History Configuration:
  - `HISTSIZE`: 32768 entries
  - `SAVEHIST`: 4096 (Zsh)
  - `HISTCONTROL`: ignoredups:erasedups

**Build Configuration:**
- Makefile targets in `/home/sunny/projects/dotfiles/Makefile`:
  - `make macos` - Install on macOS
  - `make linux` - Install on Linux
  - `make wsl` - Install on WSL
  - `make link` - Create symlinks via Stow
  - `make test` - Run tests with bats

**Code Formatting:**
- EditorConfig in `.editorconfig`:
  - UTF-8 charset
  - LF line endings
  - 2-space indentation
  - Final newline required
  - Trim trailing whitespace

- Prettier in `config/prettier/.prettierrc`:
  - 120 character print width
  - Single quotes for strings
  - Avoid parens on arrow functions
  - Bracket on same line (JSX)

**Git Configuration:**
- Delta as diff pager in `config/git/config`
- VSCode as merge tool and editor
- GPG signing optional
- Extensive git aliases configured in `config/git/config`

## Platform Requirements

**Development:**
- macOS: Xcode Command Line Tools (includes git, make)
- Linux: build-essential, curl, git, make
- WSL2: Windows Subsystem for Linux with Ubuntu distro

**Supported macOS Versions:**
- macOS 13 (Ventura)
- macOS 14 (Sonoma)
- macOS 15 (Sequoia)
- Both Apple Silicon (M1+) and Intel architectures

**Supported Linux:**
- Ubuntu (latest tested)
- Debian
- WSL2 with auto-detection

**Production:**
- Not a production application - personal dotfiles for development environments

---

*Stack analysis: 2026-02-13*
