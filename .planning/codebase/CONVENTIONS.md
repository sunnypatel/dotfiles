# Coding Conventions

**Analysis Date:** 2024-07-25

## Naming Patterns

**Files:**
- Shell configuration files are prefixed with a dot and organized by purpose (e.g., `.zshrc`, `.zsh_aliases`, `.zsh_functions`).
- Test files use the `.bats` extension (e.g., `symlinks.bats`).
- Helper scripts use `.bash` (e.g., `test_helper.bash`).
- Task definitions are in `Makefile`.

**Functions:**
- Lower-case, `snake_case` is preferred for shell functions.
- Examples: `command_exists`, `skip_if_not_macos` in `test/test_helper.bash`.
- Short, verb-based names are also used for simple utilities (e.g., `mk`, `calc` in `stow/zsh/.config/zsh/.zsh_functions`).

**Variables:**
- Environment-style variables are `UPPER_CASE` (e.g., `HISTFILE`, `ZIM_HOME` in `stow/zsh/.config/zsh/.zshrc`).
- Local variables within functions are typically `lower_case` (e.g., `symlink_path` in `test/test_helper.bash`).
- Variables are consistently quoted when used (e.g., `"$@"`).

**Types:**
- Not applicable for this shell-based project.

## Code Style

**Formatting:**
- Enforced via `.editorconfig`:
  - `indent_style = space`
  - `indent_size = 2`
  - `end_of_line = lf`
  - `charset = utf-8`
  - `trim_trailing_whitespace = true`
  - `insert_final_newline = true`

**Linting:**
- No automated linter (like ShellCheck) is configured in the repository's tooling.
- Style is maintained by convention.

## Import Organization

**Order:**
- Shell scripts use `source` to include other files. The main entry point `stow/zsh/.config/zsh/.zshrc` sources dependencies in a specific order:
    1. Zimfw (plugin manager) init script
    2. `.zsh_aliases`
    3. `.zsh_functions`

**Path Aliases:**
- Not applicable in the same way as a JS/TS project. `ZDOTDIR` is used to establish a base path for zsh configuration files.

## Error Handling

**Patterns:**
- **Command Checks:** Scripts frequently check for the existence of a command before using it, especially in the `Makefile`.
  ```bash
  # From Makefile
  @if ! command -v gcc >/dev/null 2>&1; then ...
  ```
- **File Checks:** Scripts check for file or directory existence before proceeding.
  ```bash
  # From stow/zsh/.config/zsh/.zshrc
  if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then ...
  ```
- **Test Failures:** BATS tests fail by returning a non-zero exit code (`return 1`).

## Logging

**Framework:** `echo` command.

**Patterns:**
- Informational messages are printed to stdout during installation via the `Makefile`.
  ```makefile
  # From Makefile
  @echo "Installing NVM..."; \
  ```
- Test failures in BATS also use `echo` to provide context before returning an error.

## Comments

**When to Comment:**
- File headers are used extensively to describe the purpose of the file and how it's sourced.
- Important or complex blocks of code are preceded by a comment.
- Comments explain platform-specific logic (e.g., macOS vs. Linux).

**Style:**
- A block of `#` characters is used to create a large, visible header at the top of shell files.
  ```bash
  ###############################################################################
  # .zsh_aliases - Shell Aliases
  ###############################################################################
  # Sourced by: .zshrc
  # Purpose: All alias definitions in one place
  ###############################################################################
  ```

## Function Design

**Size:**
- Functions are small and have a single responsibility.
- Example: `mk()` in `stow/zsh/.config/zsh/.zsh_functions` creates a directory and cds into it.

**Parameters:**
- Parameters are accessed using `$1`, `$@`, etc. and are always quoted.

**Return Values:**
- Functions primarily return status via exit codes (0 for success, non-zero for failure). Output is written to stdout.

## Module Design

**Exports:**
- Not applicable in the traditional sense. Function and alias definitions are made available to the shell session by `source`-ing the relevant files.

**Barrel Files:**
- `.zshrc` acts as a "barrel file" by sourcing `.zsh_aliases` and `.zsh_functions` to aggregate shell configurations.

---

*Convention analysis: 2024-07-25*
