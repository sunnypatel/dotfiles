# Testing Patterns

**Analysis Date:** 2026-02-13

## Test Framework

**Runner:**
- BATS (Bash Automated Testing System)
- All test files located in `test/` directory
- Test execution via `make test` which runs: `bats test`
- Config: No separate bats config file; tests are standalone executable scripts

**Assertion Library:**
- BATS built-in assertions: `[ "$status" -eq 0 ]`, `[[ "$output" =~ pattern ]]`, `[ -f "$file" ]`
- Return codes checked via `$status` variable set by `run` command
- Output captured in `$output` variable
- File/directory existence checks with `[ -x file ]`, `[ -f file ]`, `[ -d dir ]`

**Run Commands:**
```bash
make test              # Run all tests with bats
make test-verify       # Run quick verification without bats (uses verify-setup.sh)
make test-all          # Run both verify and bats tests
bats test              # Run all test files directly
bats test/os-detection.bats    # Run specific test file
bats -v test/os-detection.bats # Verbose output
bats --tap test/os-detection.bats  # TAP format for CI
```

## Test File Organization

**Location:**
- All tests in `test/` directory co-located with codebase
- Test files separate from implementation: `test/` is sibling to `bin/`, `system/`, `runcom/`

**Naming:**
- Pattern: `[feature].bats` for BATS tests
- Examples: `os-detection.bats`, `path-config.bats`, `bin.bats`, `function.bats`, `installation.bats`
- Supplementary: `verify-setup.sh` for quick checks without bats dependency
- Documentation: `README.md` in test directory explains all tests

**Structure:**
```
test/
├── os-detection.bats       # OS and architecture detection tests
├── path-config.bats        # PATH configuration tests
├── bin.bats                # Binary utility tests (dot, json, is-executable, is-supported)
├── function.bats           # Shell function tests
├── installation.bats       # Installation targets and script tests
├── verify-setup.sh         # Quick verification without bats
└── README.md               # Testing documentation
```

## Test Structure

**Suite Organization:**
BATS tests use `@test` declarations with descriptive names:

```bash
#!/usr/bin/env bats

setup() {
  # Runs before each test
  DOTFILES_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export PATH="$DOTFILES_DIR/bin:$PATH"
}

@test "descriptive test name" {
  run command-to-test
  [ "$status" -eq 0 ]
}
```

**Patterns:**

- **Setup block:** Establishes test environment before each test
  ```bash
  setup() {
    DOTFILES_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    export PATH="$DOTFILES_DIR/bin:$PATH"
  }
  ```

- **Run command pattern:** Executes command and captures output/status
  ```bash
  run is-macos
  [ "$status" -eq 0 ]   # Assert exit code
  ```

- **Output assertion pattern:** Check captured output
  ```bash
  run dot
  [[ $output =~ "Usage" ]]
  ```

- **Conditional skip pattern:** Skip test if not applicable
  ```bash
  if [ -f /proc/version ]; then
    run grep -qi microsoft /proc/version
  else
    skip "Not on Linux system"
  fi
  ```

- **Multiple exit code assertion:** Accept either success or failure
  ```bash
  run "$DOTFILES_DIR/bin/is-wsl"
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
  ```

## Mocking

**Framework:** Not used

**Patterns:**
- Actual file/command checks instead of mocks: `[ -x "$DOTFILES_DIR/bin/is-macos" ]`
- Environment variables tested directly: `grep -q "^ID=ubuntu" /etc/os-release`
- File system state validated: `-f /proc/version`, `-d /home/linuxbrew/.linuxbrew`
- Test isolation via subshells when needed:
  ```bash
  source "$DOTFILES_DIR/system/.path"
  # Subshell sourcing in subshell: ( source file ) or $(source file)
  ```

**What to Mock:**
- Not applicable; codebase uses real files and environment variables
- Tests verify actual detection logic by checking system files directly

**What NOT to Mock:**
- OS detection: scripts check real `/proc/version` and `$OSTYPE`
- Path configuration: tests source actual shell files
- Installation targets: tests verify Makefile targets exist (not executed, just verified)

## Fixtures and Factories

**Test Data:**
```bash
# From function.bats
FIXTURE=$'foo\nbar\nbaz\nfoo'
FIXTURE_TEXT="foo"

@test "get" {
  ACTUAL=$(get "FIXTURE_TEXT")
  EXPECTED="foo"
  [ "$ACTUAL" = "$EXPECTED" ]
}
```

**Location:**
- Inline in test file: Variables declared at top of test file or in setup()
- Example: `FIXTURE`, `FIXTURE_TEXT` defined at test file scope
- No separate fixture files; test data embedded in test scripts

## Coverage

**Requirements:** No coverage enforcement configured

**View Coverage:**
- Not configured; no coverage tool set up
- All test areas documented in TESTING.md: 5 test files covering 5 feature areas
- Coverage includes:
  - OS detection (is-macos, is-wsl, is-ubuntu, is-debian, is-arm64)
  - Path configuration (HOMEBREW_PREFIX, WSL paths, dotfiles bin)
  - Binary utilities (dot, json, is-executable, is-supported)
  - Shell functions (ps0, ps1, ps2, get, calc, line, duplines, uniqlines)
  - Installation process (Makefile targets, remote-install.sh, detection scripts)

## Test Types

**Unit Tests:**
- Scope: Individual shell scripts and functions
- Approach: Direct execution via `run` command, assertion on exit code
- Examples: `test/os-detection.bats` tests each `is-*` script independently
- Assertion style: Exit code validation and output pattern matching
- File from codebase: `test/os-detection.bats` (lines 12-76) tests 5 detection utilities

**Integration Tests:**
- Scope: Multiple components working together (PATH configuration with detection scripts)
- Approach: Source shell files and verify resulting state
- Example from `test/path-config.bats`:
  ```bash
  @test "WSL paths added when on WSL" {
    source "$DOTFILES_DIR/system/.path"
    if "$DOTFILES_DIR/bin/is-wsl" > /dev/null 2>&1; then
      run echo "$PATH" | grep -q "/mnt/c/Windows/System32"
      [ "$status" -eq 0 ]
    else
      skip "Not running on WSL"
    fi
  }
  ```
- Makefile integration: Verify targets call correct dependencies

**E2E Tests:**
- Framework: Not used
- Manual testing documented: `test/verify-setup.sh` provides quick smoke tests
- `verify-setup.sh` pattern:
  ```bash
  test_check() {
    local name="$1"
    local command="$2"
    if eval "$command" > /dev/null 2>&1; then
      echo "✓ $name"
      ((PASSED++))
      return 0
    else
      echo "✗ $name"
      ((FAILED++))
      return 1
    fi
  }
  ```

## Common Patterns

**Async Testing:**
- Not applicable (synchronous shell execution)

**Error Testing:**
```bash
@test "is-executable (false)" {
  run is-executable nonexistent
  [ "$status" -eq 1 ]
}

@test "is-supported (false)" {
  run is-supported "ls --nonexistent"
  [ "$status" -eq 1 ]
}
```

**Platform-Conditional Testing:**
```bash
@test "is-macos detects macOS correctly" {
  run [ -x "$DOTFILES_DIR/bin/is-macos" ]
  [ "$status" -eq 0 ]
}
```

**Output Validation:**
```bash
@test "json" {
  ACTUAL=$(echo '{"x":1}' | json)
  EXPECTED=$'{ "x": 1 }'
  [ "$ACTUAL" = "$EXPECTED" ]
}
```

## Test Execution

**Environment Setup:**
- DOTFILES_DIR derived from test file location: `DOTFILES_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"`
- PATH prepended with dotfiles bin: `export PATH="$DOTFILES_DIR/bin:$PATH"`
- Repeat for each test via `setup()` function

**Sourcing in Tests:**
- Load functions: `load "../system/.function"` in `test/function.bats`
- Source complete files: `source "$DOTFILES_DIR/system/.path"` to test state changes
- Subshell isolation when needed to prevent environment pollution

**Skip Conditions:**
- Platform-specific tests skip gracefully:
  ```bash
  if ./bin/is-wsl; then
    # test WSL-specific behavior
  else
    skip "Not running on WSL"
  fi
  ```

---

*Testing analysis: 2026-02-13*
