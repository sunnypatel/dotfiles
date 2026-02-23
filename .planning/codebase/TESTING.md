# Testing Patterns

**Analysis Date:** 2024-07-25

## Test Framework

**Runner:**
- **Bats-core** (`bats`)
- Config: No specific configuration file. `bats` is invoked directly from the command line.

**Assertion Library:**
- No separate assertion library is used. Assertions are implemented as custom shell functions within a helper file.
- Example: `assert_dotfiles_symlink` in `test/test_helper.bash`.

**Run Commands:**
```bash
make test              # Installs bats if needed and runs all tests
bats test/*.bats       # Run all tests directly
```

## Test File Organization

**Location:**
- All test files are located in the `test/` directory.

**Naming:**
- Test files use the `.bats` extension (e.g., `symlinks.bats`, `shell_config.bats`).

**Structure:**
```
test/
├── shell_config.bats
├── symlinks.bats
└── test_helper.bash
```

## Test Structure

**Suite Organization:**
- Each `.bats` file acts as a test suite for a specific area of functionality.
- A common helper file, `test_helper.bash`, is loaded at the beginning of each test file.

```bash
#!/usr/bin/env bats
###############################################################################
# symlinks.bats - Stow Symlink Validation
###############################################################################

load test_helper

@test "zsh: ~/.zshenv symlink points to stow/zsh/.zshenv" {
    assert_dotfiles_symlink "$HOME/.zshenv"
}

@test "git: ~/.config/git/config symlink points to stow" {
    assert_dotfiles_symlink "$HOME/.config/git/config"
}
```

**Patterns:**
- **Setup:** The `load test_helper` command at the top of each test file loads shared functions.
- **Teardown:** No explicit teardown logic is observed. Tests are designed to be read-only and idempotent where possible.
- **Assertion:** Assertions are custom helper functions that check a condition and `return 1` on failure, which `bats` interprets as a failed test.

## Mocking

**Framework:**
- Not used.

**Patterns:**
- Mocking is not applicable for this test suite, as the tests are integration tests that verify the real state of the filesystem (symlinks, file existence) after the dotfiles are "installed".

**What to Mock:**
- Not applicable.

**What NOT to Mock:**
- The filesystem and symlink targets are the subjects of the tests and are not mocked.

## Fixtures and Factories

**Test Data:**
- Test data is hardcoded into the tests themselves, usually as paths to files that are expected to exist.
- There are no external fixture files.

```bash
# From test/symlinks.bats
@test "all expected symlinks exist" {
    local symlinks=(
        "$HOME/.zshenv"
        "$HOME/.config/zsh/.zshrc"
        # ... and so on
    )
    # ... logic to check symlinks
}
```

**Location:**
- Not applicable.

## Coverage

**Requirements:**
- No coverage metrics are configured or enforced. The focus is on integration testing of key paths.

**View Coverage:**
- Not applicable.

## Test Types

**Unit Tests:**
- Not present. The testing approach does not lend itself to traditional unit tests.

**Integration Tests:**
- This is the primary form of testing used. The entire test suite functions as integration tests.
- **Scope:** They verify that `stow` correctly creates symlinks from the `stow/` directory to the `$HOME` directory, ensuring the dotfiles are correctly "installed". They test the integration between the `stow` utility and the repository's file structure.

**E2E Tests:**
- Not used.

## Common Patterns

**Async Testing:**
- Not used.

**Error Testing:**
- Error conditions are tested by checking for the non-existence of a file or symlink and failing the test if it's missing.

```bash
# From test/symlinks.bats
@test "all expected symlinks exist" {
    local missing=()
    for symlink in "${symlinks[@]}"; do
        [ -L "$symlink" ] || missing+=("$symlink")
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing symlinks:"
        printf '%s\n' "${missing[@]}"
        return 1
    fi
}
```

---

*Testing analysis: 2024-07-25*
