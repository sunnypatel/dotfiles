# Coding Conventions

**Analysis Date:** 2026-02-13

## Naming Patterns

**Files:**
- Shell scripts with shebang: `#!/usr/bin/env bash` convention used throughout
- Utility scripts in `bin/` are lowercase with hyphens: `is-macos`, `is-wsl`, `is-ubuntu`, `is-debian`, `is-arm64`, `is-executable`, `is-supported`
- Configuration files in `system/` are dot-prefixed: `.alias`, `.completion`, `.env`, `.function`, `.path`, `.prompt`
- Configuration files use platform-specific suffixes: `.macos`, `.bash`, `.zsh` (e.g., `.alias.macos`, `.env.bash`)
- Installation files in `install/` are uppercase: `Brewfile`, `Caskfile`, `Codefile`, `Rustfile`, `npmfile`
- Test files use `.bats` extension: `os-detection.bats`, `path-config.bats`, `bin.bats`, `function.bats`, `installation.bats`

**Functions:**
- Snake_case for function definitions: `sub_help()`, `sub_clean()`, `sub_dock()`, `sub_edit()`, `sub_test()`, `sub_update()`, `sub_duti()`, `sub_macos()` in `bin/dot`
- Lowercase with hyphens for bash functions: `prepend-path()` in `system/.path`, `ps0()`, `ps1()`, `ps2()`, `calc()`, `meteo()` in `system/.function`
- Utility functions are prefixed with descriptive names: `is-*` for boolean checks, `sub_*` for subcommand handlers

**Variables:**
- UPPERCASE_WITH_UNDERSCORES for environment variables: `DOTFILES_DIR`, `PATH`, `HOMEBREW_PREFIX`, `XDG_CONFIG_HOME`, `STOW_DIR`, `NVM_DIR`, `ACCEPT_EULA`, `GITHUB_ACTION`
- Local variables in functions use lowercase_with_underscores: `BIN_NAME`, `COMMAND_NAME`, `SUB_COMMAND_NAME`, `FIXTURE`, `FIXTURE_TEXT`, `OPT_COLOR`, `PASSED`, `FAILED`, `LOCALE`, `LOCATION`
- Command substitution assigned to uppercase: `ACTUAL=$(command)`, `EXPECTED=$'string'`, `DOTFILES_DIR="$(cd "$(dirname "$0")"/.. && pwd)"`

**Types:**
- Not applicable (bash script codebase)

## Code Style

**Formatting:**
- EditorConfig used as primary formatting standard: file `.editorconfig`
- 2-space indentation throughout (configured in `.editorconfig`)
- UTF-8 charset required
- Unix line endings (LF) enforced
- Final newline required on all files
- Trailing whitespace trimmed

**Linting:**
- ShellCheck configured for bash script linting (referenced in Makefile as `apt-get install shellcheck`)
- Scripts must pass ShellCheck validation before commit

## Import Organization

**Order:**
- Not applicable (bash sourcing, not module imports)

**Sourcing:**
- Environment variables and paths loaded first (`.env`, `.path` in shell rc files)
- Shell functions loaded with `load` statement in bats tests: `load "../system/.function"`
- Subshell sourcing used in tests to avoid polluting environment: `source "$DOTFILES_DIR/system/.path"` within `()` or subshells

**Path Aliases:**
- Shell aliases defined in `system/.alias`, platform-specific in `system/.alias.macos`
- Environment setup in `system/.env` with platform variants (`.env.bash`, `.env.zsh`, `.env.macos`)

## Error Handling

**Patterns:**
- Exit codes for boolean utilities: `exit 0` for success/true, `exit 1` for failure/false in all `is-*` scripts
- Command substitution with error redirection: `$(command 2>&1)` or `$(command > /dev/null 2>&1)`
- Conditional execution with `||` and `&&`: `is-executable brew || curl ... | bash` (install if not exists)
- Test assertions wrapped in `[ ]` or `[[ ]]` with status checks: `[ "$status" -eq 0 ]`, `[ "$status" -ne 0 ]`
- Error suppression common: `eval "$1" > /dev/null 2>&1` in `is-supported`, `"$DOTFILES_DIR/bin/is-wsl" > /dev/null 2>&1`
- Makefile error handling with `|| true`: `brew bundle --file=... || true` to continue on non-critical failures
- Conditional blocks with shell-specific syntax: `@if ! locale -a | grep -q "en_US.utf8"` in Makefile with platform detection

## Logging

**Framework:** Bash builtins and echo

**Patterns:**
- Simple echo for user-facing messages: `echo "Usage: $BIN_NAME <command>"`, `echo "$ command"` to show what's running
- Status messages with icons: `echo "✓ $name"` and `echo "✗ $name"` in `test/verify-setup.sh`
- Debug output to stderr: `echo "..."` piped to stderr or suppressed with `> /dev/null 2>&1`
- Test output: bats framework handles all output with `@test` declarations
- Makefile echo: `@echo "..."` with `@` prefix to suppress command echo (example: `@echo "Running full test suite with bats..."`)
- Subcommand messages: In `bin/dot`, output explains what's happening: `echo "Applying ${DEFAULTS_FILE}"`, `echo "Done. Some changes may require..."`

## Comments

**When to Comment:**
- Shebang as first line of all scripts: `#!/usr/bin/env bash`
- Section separators with comment blocks: `# [Task name]` in `system/.function` (e.g., `# Switch long/short prompt`, `# Get named var`, `# Calculator`)
- Complex logic explained inline: `# Detect if running in WSL (Windows Subsystem for Linux)` in `bin/is-wsl`
- Multi-method detection documented: `# Checks multiple methods to reliably detect WSL`
- Setup/teardown documented in tests: `# Get the directory where the dotfiles are located` in `setup()` blocks
- Test purpose documented: `# Tests for OS detection utilities`
- Conditional logic explained when non-obvious: `# Prefer repository bin over system binaries (e.g., graphviz 'dot')` in `bin/dot`

**JSDoc/TSDoc:**
- Not used (bash shell scripts)

## Function Design

**Size:**
- Functions kept focused and small: `is-macos` is 7 lines, `is-wsl` is 14 lines
- Utility functions under 15 lines typically
- Exception: `bin/dot` main dispatcher is ~80 lines but uses subcommand pattern for clarity

**Parameters:**
- Positional parameters used: `$1`, `$2` for command name and subcommand
- Optional flags via getopts: `: getopts ":c" OPT` in `bin/json` for `-c` color flag
- Arguments passed through with `$@`: `sub_${COMMAND_NAME} $@` in `bin/dot`
- Environment variables preferred over parameters for configuration

**Return Values:**
- Exit codes (0/1) for boolean functions
- Output via stdout for data-returning functions: `echo -n "$2"` or `echo -n "$3"` in `is-supported`
- No explicit return statements in most functions, relies on last command exit code

## Module Design

**Exports:**
- Environment variables explicitly exported: `export DOTFILES_DIR`, `export PATH`, `export HOMEBREW_PREFIX`
- Functions sourced via `load` in tests, no explicit export needed for bats
- Global environment modification expected: scripts modify PATH, set environment variables globally

**Barrel Files:**
- Configuration files act as entry points: `runcom/.bash_profile`, `runcom/.zshrc` source multiple system files
- Example from shell init pattern:
  ```bash
  source "$DOTFILES_DIR/system/.path"
  source "$DOTFILES_DIR/system/.env"
  source "$DOTFILES_DIR/system/.alias"
  ```
- Test files group related tests: `test/os-detection.bats`, `test/path-config.bats` organized by feature
- Load statements in tests import dependencies: `load "../system/.function"` imports utility functions

## Testing Integration Points

**Shell Configuration Loading:**
- Scripts assume DOTFILES_DIR is set or derive it: `DOTFILES_DIR="$(cd "$(dirname "$0")"/.. && pwd)"`
- Platform detection is critical: functions check `is-macos`, `is-wsl`, `is-ubuntu`, `is-debian`, `is-arm64`
- Path setup depends on correct OS detection and Homebrew location discovery
- Test isolation via subshells to prevent environment pollution

---

*Convention analysis: 2026-02-13*
