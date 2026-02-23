# Technology Stack

**Analysis Date:** 2024-07-25

## Languages

**Primary:**
- Shell (Bash/Zsh) - Used for all scripts, configuration, and setup logic.
- Makefile - Used as the main task runner for installation and testing.

**Secondary:**
- Lua - Used for Neovim configuration in `stow/nvim/.config/nvim/init.lua`.

## Runtime

**Environment:**
- The scripts are designed to run on Unix-like shells (Zsh and Bash) on multiple OSs.
- Supported OS: macOS (Intel/ARM), Linux, and WSL2.
- Node.js is managed via `nvm` (Node Version Manager), as specified in the `Makefile`.

**Package Manager:**
- Homebrew (`brew`) - Used to install system-level dependencies like `git`, `stow`, `neovim`, etc.
- NVM (`nvm`) - Used to manage Node.js versions. The `Makefile` includes an installation step for it.
- pnpm - The `Makefile` includes an installation step for this package manager, suggesting it's used for Node.js projects.
- Zim (`zim`) - Used as a framework manager for Zsh, configured in `stow/zsh/.zimrc`.

## Frameworks

**Core:**
- GNU Stow - Used for managing dotfiles by symlinking them from the `stow/` directory to the home directory.
- Zim - A Zsh configuration framework for managing plugins and themes.

**Testing:**
- Bats (`bats-core`) - A "Bash Automated Testing System" used for testing shell scripts. Test files are located in `test/*.bats`.

**Build/Dev:**
- GNU Make - Used as the primary task runner for commands like `install`, `test`, and `unlink`.
- Docker - Used in the CI pipeline to create a reproducible testing environment for Ubuntu. The configuration is in `.github/Dockerfile.ubuntu`.

## Key Dependencies

**Critical:**
- `stow`: The core tool for symlinking the dotfiles.
- `zsh`: The target shell environment.
- `git`: For version control and interacting with git repositories.
- `homebrew`: For installing all other dependencies.

**Infrastructure:**
- `make`: For running installation and testing tasks defined in the `Makefile`.
- `bats-core`: For running the test suite.

## Configuration

**Environment:**
- Configuration is managed through files in the `stow/` directory which are symlinked into the `$HOME` directory.
- Key configuration files include `.zshenv`, `.zshrc`, `.zsh_aliases`, `git/config`, and `tmux.conf`.

**Build:**
- `Makefile`: Defines the build and installation logic.
- `.github/Dockerfile.ubuntu`: Defines the Docker build for the CI environment.

## Platform Requirements

**Development:**
- A Unix-like environment (macOS, Linux, WSL2).
- `curl` and `git` are required for the installation script to work.

**Production:**
- This is a development environment configuration, not a deployable application. "Production" is the user's local machine.
