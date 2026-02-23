# Codebase Structure

**Analysis Date:** 2024-07-25

## Directory Layout

```
dotfiles/
├── .github/        # CI/CD workflows (e.g., running tests)
├── .planning/      # GSD planning and analysis documents
├── stow/           # Directory for application configuration packages (stow packages)
│   ├── git/        # Git configuration
│   ├── nvim/       # Neovim configuration
│   ├── tmux/       # Tmux configuration
│   └── zsh/        # Zsh shell configuration
├── test/           # Test files (using BATS)
├── .editorconfig   # Editor configuration
├── .gitignore      # Git ignore rules
├── Makefile        # Main entry point for installation, testing, and management
└── README.md       # Project documentation
```

## Directory Purposes

**`stow/`**:
- **Purpose**: This is the core of the repository. It contains the dotfiles, organized into "packages" for `stow` to manage.
- **Contains**: Subdirectories, where each subdirectory represents a software package whose configuration is being managed (e.g., `git`, `zsh`).
- **Key files**: The files within each package directory, like `stow/zsh/.zshenv` or `stow/git/.config/git/config`.

**`test/`**:
- **Purpose**: Contains automated tests for verifying the dotfiles' installation and behavior.
- **Contains**: `*.bats` files, which are test scripts for the [Bats](https://github.com/bats-core/bats-core) testing framework.
- **Key files**: `test/symlinks.bats`, `test/shell_config.bats`.

**`.github/`**:
- **Purpose**: Defines continuous integration pipelines.
- **Contains**: GitHub Actions workflow files (`*.yml`).
- **Key files**: `.github/workflows/ci.yml` runs `make test` on pushes and pull requests to ensure dotfiles are valid.

## Key File Locations

**Entry Points:**
- `Makefile`: The primary entry point for all operations. Key targets include `install`, `unlink`, and `test`.

**Configuration:**
- `stow/`: All application configurations are stored here, organized by package. For example:
    - Zsh config: `stow/zsh/.config/zsh/.zshrc`
    - Git config: `stow/git/.config/git/config`
    - Tmux config: `stow/tmux/.config/tmux/tmux.conf`
- `.zshenv`: Located at `stow/zsh/.zshenv`, it's a crucial file loaded by Zsh for all shell sessions to set up environment variables.

**Testing:**
- `test/*.bats`: All test suites are located directly in the `test/` directory.

## Naming Conventions

**Files:**
- Dotfiles are named exactly as they should appear in the home directory (e.g., `.zshenv`).
- Test files use the `.bats` extension (e.g., `symlinks.bats`).

**Directories:**
- Directories within `stow/` are named after the application they configure (e.g., `nvim`, `tmux`).
- The directory structure within a stow package (e.g., `stow/git/.config/git`) mirrors the desired structure in the target `$HOME` directory.

## Where to Add New Code

**New Application Configuration:**
- 1. Create a new directory under `stow/`: `stow/<app_name>/`.
- 2. Add the configuration files to this new directory, preserving the path relative to `$HOME` (e.g., `stow/htop/.config/htop/htoprc`).
- 3. Update the `stow-packages` and `unlink` targets in the `Makefile` to include the new `<app_name>`.

**New Test Case:**
- Add a new function with a `@test "description"` annotation to an existing `*.bats` file in `test/`, or create a new `test/new_feature.bats` file.

---
*Structure analysis: 2024-07-25*
