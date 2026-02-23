# Architecture

**Analysis Date:** 2024-07-25

## Pattern Overview

**Overall:** **Declarative Dotfiles Management via Stow and Make**

This project uses a combination of GNU Stow and a `Makefile` to manage and deploy configuration files (dotfiles) in a structured, repeatable, and platform-aware manner. The core idea is to separate configurations into logical "packages" which are then symlinked into the home directory.

**Key Characteristics:**
- **Modular:** Configurations are grouped by application (e.g., `git`, `nvim`) into packages.
- **Declarative:** The `Makefile` declares the desired state (dependencies, installed packages), and running `make` converges the system to that state.
- **Idempotent:** The `stow-packages` command uses the `-R` flag (`--restow`), ensuring that running the installation multiple times has a consistent and non-destructive result.
- **Portable:** The `Makefile` includes logic to detect the operating system (`Linux`, `macOS`, `WSL`) and adapt the installation process, primarily for dependency management via Homebrew.

## Layers

**Orchestration Layer:**
- **Purpose**: Provides a high-level interface for managing the dotfiles lifecycle.
- **Location**: `Makefile`
- **Contains**: `make` targets for installation (`install`), removal (`unlink`), and testing (`test`).
- **Depends on**: System commands (`uname`, `grep`), Homebrew, and Stow.
- **Used by**: The user/developer.

**Packaging (Module) Layer:**
- **Purpose**: Organizes configuration files into self-contained modules.
- **Location**: `stow/`
- **Contains**: Subdirectories for each application (`zsh`, `git`, `tmux`, `nvim`).
- **Depends on**: N/A
- **Used by**: The Orchestration Layer (`Makefile` passes these package names to `stow`).

**Configuration Layer:**
- **Purpose**: The actual dotfiles and configuration scripts.
- **Location**: Files within the `stow/*` directories (e.g., `stow/zsh/.zshrc`).
- **Contains**: Shell scripts, config files, Vimscript/Lua files.
- **Depends on**: The applications they configure (e.g., `zsh`, `nvim`).
- **Used by**: The target applications at runtime.

**Testing Layer:**
- **Purpose**: Verifies that the dotfiles are installed correctly and function as expected.
- **Location**: `test/`
- **Contains**: Test scripts written in [Bats](https://github.com/bats-core/bats-core).
- **Depends on**: `bats-core` and the installed dotfiles.
- **Used by**: The Orchestration Layer (`make test`).

## Data Flow

**Installation Flow (`make install`):**
1.  **Platform Detection**: The `Makefile` determines the OS (`Linux`, `macOS`, `WSL`) using `uname`.
2.  **Dependency Check/Installation**: It checks for and installs dependencies like Homebrew (`brew`), core utilities (`git`, `curl`), and required applications (`stow`, `zsh`, `nvim`, etc.).
3.  **Stow Execution**: The `stow-packages` target runs the command `stow -R -d stow -t ~ zsh git tmux nvim`.
4.  **Symlinking**: For each package (e.g., `zsh`), `stow` creates symlinks from the repository (`./stow/zsh/.zshenv`) to the target directory (`~/.zshenv`).
5.  **Post-Install**: The `set-shell` target attempts to change the user's default shell to `zsh`.

## Key Abstractions

**Stow Package:**
- **Purpose**: Represents a logical grouping of configuration for a single application. It's the unit of management.
- **Examples**: The `git` package in `stow/git/`, the `nvim` package in `stow/nvim/`.
- **Pattern**: A directory in `stow/` containing files and subdirectories that mirror the desired structure within the `$HOME` directory.

## Entry Points

**`Makefile` Targets:**
- **Location**: `Makefile`
- **Triggers**: Invoked by the user running `make <target>`.
- **Responsibilities**:
    - `install`: The primary entry point. Installs dependencies and symlinks all configuration packages.
    - `test`: Runs the Bats test suite to validate the installation.
    - `unlink`: Removes all symlinks created by `stow`, effectively uninstalling the dotfiles.

## Error Handling

**Strategy**: The architecture relies on the underlying shell commands (`stow`, `brew`, `git`) to report errors.
- **Patterns**: `make` will halt execution if any command in a recipe fails. The `Makefile` also uses constructs like `command -v` to check for the existence of a command before trying to use it. There is no custom in-script error handling.

## Cross-Cutting Concerns

**Platform Support:**
- **Approach**: The `Makefile` uses `uname -s` and `grep /proc/version` to detect the OS and tailors dependency installation accordingly. Homebrew is used as a unifying package manager across platforms.
- **Files**: `Makefile`

**Dependency Management:**
- **Approach**: Dependencies are managed in two ways: system dependencies via Homebrew (`install-packages` target) and shell/editor plugins via their own managers (e.g., `zsh` uses `zim`).
- **Files**: `Makefile`, `stow/zsh/.zimrc`

---
*Architecture analysis: 2024-07-25*
