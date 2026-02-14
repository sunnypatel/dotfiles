# Phase 5: CI Validation - Research

**Researched:** 2026-02-14
**Domain:** GitHub Actions CI/CD, Shell Testing, Docker Containerization
**Confidence:** HIGH

## Summary

Phase 5 requires automated CI testing to validate fresh dotfiles installations on Ubuntu and macOS using GitHub Actions. The primary challenges are: (1) measuring zsh startup time with a hard 100ms threshold, (2) validating shell functionality (aliases, functions, env vars, PATH), (3) verifying Stow symlink structure, and (4) running smoke tests on tool configurations.

The standard approach uses GitHub Actions with Docker containers for Ubuntu testing and native runners for macOS (due to Docker limitations on macOS runners). Testing can be implemented using BATS (Bash Automated Testing System) for structured test cases, combined with zsh-bench for startup time measurement and basic shell scripts for symlink validation. ShellCheck should be integrated for linting test scripts.

GitHub Actions provides ubuntu-24.04 and ubuntu-22.04 runners (4 CPUs, 16 GB RAM for public repos), and macos-15/macos-14 runners (3 CPUs on ARM64, 4 CPUs on Intel). Docker support works natively on Ubuntu runners but requires workarounds on macOS (Colima), making native macOS runners preferable.

**Primary recommendation:** Use GitHub Actions with Docker for Ubuntu testing, native runners for macOS, BATS for test structure, zsh-bench for startup measurement, and custom shell validation for symlinks and configuration.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Test scope:**
- Hard threshold: zsh startup must be under 100ms or build fails
- Full audit of shell functionality: all aliases/functions from config, every PATH entry, env vars (EDITOR, ZDOTDIR), plugin loading
- Verify Stow symlink structure after install (e.g., ~/.config/git/config symlinked correctly)

**Workflow structure:**
- Docker containers for CI environment
- Dockerfile lives in the dotfiles repo (e.g., .github/ or test/)

**Triggers:**
- Push to any branch
- Pull requests
- Manual dispatch (workflow_dispatch)
- No scheduled runs
- Notifications via default GitHub behavior only (check marks on commits/PRs)

### Claude's Discretion

- Tool config validation depth (smoke tests vs file existence)
- Docker strategy for macOS (native runner vs Docker)
- Test logic organization (test.sh, make test, or both)

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope

</user_constraints>

## Standard Stack

### Core

| Library/Tool | Version | Purpose | Why Standard |
|--------------|---------|---------|--------------|
| GitHub Actions | N/A | CI/CD platform | Native to GitHub, zero setup, free for public repos |
| Docker | 20.10+ | Container runtime | Industry standard for reproducible test environments |
| BATS | 1.x | Shell test framework | TAP-compliant, Bash-native, widely adopted for shell testing |
| zsh-bench | latest | Zsh startup measurement | Purpose-built tool by romkatv for accurate interactive shell benchmarking |

### Supporting

| Library/Tool | Version | Purpose | When to Use |
|--------------|---------|---------|-------------|
| ShellCheck | 0.9+ | Shell script linting | Validate test scripts, catch common errors |
| actions/checkout | v3/v4 | Repository checkout | Standard GitHub Action for code checkout |
| actions/cache | v3/v4 | Dependency caching | Cache Homebrew packages to speed up CI |
| jq | 1.6+ | JSON parsing | Parse structured test output if needed |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| BATS | shUnit2 | shUnit2 less actively maintained, smaller ecosystem |
| BATS | Custom shell scripts | BATS provides TAP output, test discovery, better error reporting |
| zsh-bench | Manual timing with `time` | zsh-bench measures interactive lag accurately, `time` measures process time |
| Docker on macOS | Colima setup | Adds complexity, nested virtualization limitations on M1 |
| GitHub Actions | Self-hosted runners | More complexity, maintenance overhead, no cost benefit for this scale |

**Installation:**

```bash
# BATS (via Homebrew - already using for other tools)
brew install bats-core

# zsh-bench (clone from GitHub)
git clone https://github.com/romkatv/zsh-bench
# Run: ~/zsh-bench/zsh-bench

# ShellCheck (via Homebrew)
brew install shellcheck
```

## Architecture Patterns

### Recommended Project Structure

```
dotfiles/
├── .github/
│   ├── workflows/
│   │   └── ci.yml                    # Main CI workflow
│   └── Dockerfile.ubuntu             # Ubuntu test container
├── test/
│   ├── test_helper.bash              # BATS test helpers
│   ├── installation.bats             # Installation tests
│   ├── shell_config.bats             # Shell configuration tests
│   ├── symlinks.bats                 # Stow symlink validation
│   └── performance.bats              # Startup time tests
└── Makefile                          # Add 'test' target
```

### Pattern 1: GitHub Actions Matrix Strategy

**What:** Run tests across multiple OS versions using matrix builds
**When to use:** When you need to test on multiple platforms (Ubuntu/macOS) or OS versions
**Example:**

```yaml
# Source: GitHub Actions best practices
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false  # Continue testing other OS even if one fails
      matrix:
        os: [ubuntu-24.04, ubuntu-22.04, macos-15, macos-14]
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: make test
```

### Pattern 2: Docker Container Testing (Ubuntu Only)

**What:** Use Docker to create clean, reproducible Ubuntu environments
**When to use:** For Ubuntu/Linux testing to ensure consistent environment
**Example:**

```yaml
# Source: Docker best practices for CI
jobs:
  test-ubuntu-docker:
    runs-on: ubuntu-24.04
    container:
      image: ubuntu:24.04
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          apt-get update
          apt-get install -y build-essential curl git sudo
      - name: Create test user
        run: |
          useradd -m -s /bin/bash testuser
          echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
      - name: Run installation as test user
        run: |
          su - testuser -c "cd /github/workspace && make install"
      - name: Run tests
        run: |
          su - testuser -c "cd /github/workspace && make test"
```

### Pattern 3: BATS Test Structure

**What:** Organize tests with setup/teardown and helper functions
**When to use:** All shell testing scenarios
**Example:**

```bash
# Source: https://bats-core.readthedocs.io/en/stable/writing-tests.html
# test/shell_config.bats

setup() {
    # Runs before each test
    load 'test_helper'
    source "$HOME/.zshenv"
}

@test "EDITOR is set to nvim" {
    [ "$EDITOR" = "nvim" ]
}

@test "ZDOTDIR points to .config/zsh" {
    [ "$ZDOTDIR" = "$HOME/.config/zsh" ]
}

@test "alias reload exists and executes zsh" {
    run zsh -ic 'alias reload'
    [ "$status" -eq 0 ]
    [[ "$output" =~ "exec zsh" ]]
}
```

### Pattern 4: Zsh Startup Time Measurement

**What:** Use zsh-bench to measure first prompt lag with threshold validation
**When to use:** Performance testing for shell startup
**Example:**

```bash
# test/performance.bats
@test "zsh startup time is under 100ms" {
    # Clone zsh-bench if not present
    if [ ! -d "$HOME/zsh-bench" ]; then
        git clone --depth=1 https://github.com/romkatv/zsh-bench "$HOME/zsh-bench"
    fi

    # Run benchmark and extract first_prompt_lag_ms
    output=$("$HOME/zsh-bench/zsh-bench" 2>&1)

    # Extract timing (format: "first_prompt_lag_ms     42.3")
    time_ms=$(echo "$output" | grep first_prompt_lag_ms | awk '{print $2}')

    # Convert to integer for comparison (42.3 -> 42)
    time_int=${time_ms%.*}

    # Assert under 100ms
    [ "$time_int" -lt 100 ]
}
```

### Pattern 5: Symlink Validation

**What:** Verify Stow created correct symlink structure
**When to use:** After installation to ensure Stow worked correctly
**Example:**

```bash
# test/symlinks.bats
@test "~/.zshenv is a symlink to stow package" {
    [ -L "$HOME/.zshenv" ]

    # Verify it points into dotfiles repo
    target=$(readlink "$HOME/.zshenv")
    [[ "$target" =~ "dotfiles/stow/zsh/.zshenv" ]]
}

@test "~/.config/git/config is a symlink" {
    [ -L "$HOME/.config/git/config" ]
    target=$(readlink "$HOME/.config/git/config")
    [[ "$target" =~ "dotfiles/stow/git/.config/git/config" ]]
}

@test "all expected symlinks exist" {
    local expected_symlinks=(
        "$HOME/.zshenv"
        "$HOME/.config/zsh/.zshrc"
        "$HOME/.config/git/config"
        "$HOME/.config/tmux/tmux.conf"
        "$HOME/.config/nvim/init.lua"
    )

    for symlink in "${expected_symlinks[@]}"; do
        [ -L "$symlink" ] || {
            echo "Missing symlink: $symlink"
            return 1
        }
    done
}
```

### Pattern 6: PATH Validation

**What:** Verify all expected PATH entries exist and are in correct order
**When to use:** Testing environment setup
**Example:**

```bash
# test/shell_config.bats
@test "PATH contains all expected entries" {
    # Source shell config
    run zsh -ic 'echo $PATH'
    [ "$status" -eq 0 ]

    # Check for critical paths
    [[ "$output" =~ "$HOME/.local/bin" ]]
    [[ "$output" =~ "/bin" ]]
    [[ "$output" =~ "/usr/bin" ]]
}

@test "~/.local/bin has highest priority in PATH" {
    run zsh -ic 'echo $PATH | cut -d: -f1'
    [ "$output" = "$HOME/.local/bin" ]
}

@test "Homebrew bin directory is in PATH" {
    # Skip if Homebrew not installed
    command -v brew >/dev/null 2>&1 || skip "Homebrew not installed"

    run zsh -ic 'echo $PATH'
    brew_prefix=$(brew --prefix)
    [[ "$output" =~ "$brew_prefix/bin" ]]
}
```

### Pattern 7: Function and Alias Testing

**What:** Verify all aliases and functions from config are loaded
**When to use:** Shell functionality validation
**Example:**

```bash
# test/shell_config.bats
@test "all expected aliases are defined" {
    local expected_aliases=(
        "reload"
        "g"
        "l"
        ".."
        "quit"
    )

    for alias_name in "${expected_aliases[@]}"; do
        run zsh -ic "alias $alias_name"
        [ "$status" -eq 0 ] || {
            echo "Missing alias: $alias_name"
            return 1
        }
    done
}

@test "mk function exists and creates directory" {
    run zsh -ic 'type mk'
    [ "$status" -eq 0 ]
    [[ "$output" =~ "function" ]]
}

@test "calc function works" {
    run zsh -ic 'calc "2+2"'
    [ "$status" -eq 0 ]
    [ "$output" = "4" ]
}
```

### Pattern 8: Homebrew Cache Strategy

**What:** Cache Homebrew installation and packages to speed up CI
**When to use:** GitHub Actions workflows that install via Homebrew
**Example:**

```yaml
# Source: https://docs.github.com/en/actions/concepts/workflows-and-actions/dependency-caching
- name: Cache Homebrew packages
  uses: actions/cache@v4
  with:
    path: |
      ~/Library/Caches/Homebrew
      /home/linuxbrew/.linuxbrew/Cellar
    key: ${{ runner.os }}-brew-${{ hashFiles('Makefile') }}
    restore-keys: |
      ${{ runner.os }}-brew-
```

### Anti-Patterns to Avoid

- **Testing in CI differently than installation runs:** Always run `make install` first, then test the result. Don't mock or stub installation steps.
- **Hardcoding paths:** Use `$HOME`, `$DOTFILES_DIR`, environment variables. Paths differ between local and CI.
- **Not testing actual shell startup:** Running `zsh -c 'command'` doesn't load full interactive config. Use `zsh -ic` or login shell `zsh -l`.
- **Ignoring platform differences:** macOS uses BSD tools, Linux uses GNU. Test both or use portable commands.
- **Over-relying on Docker for macOS:** Docker on macOS runners is problematic (nested virtualization, licensing). Use native runners.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Shell startup timing | Custom `time` wrapper | zsh-bench | Measures interactive lag (first prompt), not process time; handles TTY setup |
| Test framework | Custom test runner | BATS | TAP output, test discovery, setup/teardown, helper functions, error reporting |
| Shell script linting | Manual code review | ShellCheck | Catches 100+ common errors, POSIX compliance, integration with editors |
| GitHub Actions runner selection | Hardcoded OS | Matrix strategy | Test multiple OS versions simultaneously, catch platform drift |
| Docker image building | Full Ubuntu image | Multi-stage builds | Smaller images, faster CI, separation of build/test/runtime |
| Symlink validation | grep/sed parsing | Shell test operators | `-L` for symlink check, `readlink` for target, built-in and reliable |

**Key insight:** Shell testing has mature tooling. Custom solutions miss edge cases (signal handling, TTY interaction, subshell behavior) that these tools handle. BATS provides structure; zsh-bench provides accuracy; ShellCheck catches mistakes before runtime.

## Common Pitfalls

### Pitfall 1: False Positive Startup Time

**What goes wrong:** Using `time zsh -c "exit"` reports much faster time than real interactive startup
**Why it happens:** Non-interactive shells skip .zshrc, plugins, prompt rendering. Actual user experience includes first prompt rendering.
**How to avoid:** Use zsh-bench which creates a virtual TTY and measures first_prompt_lag_ms (time until interactive prompt appears)
**Warning signs:** Startup time passes locally but users report slow shells; time command shows <10ms but shell feels slow

### Pitfall 2: Docker on macOS Runners

**What goes wrong:** Attempting to use Docker containers on macOS runners fails or requires complex workarounds
**Why it happens:** GitHub removed Docker from macOS images due to licensing. M1 processors don't support nested virtualization for Colima.
**How to avoid:** Use native macOS runners for macOS testing, Docker only for Ubuntu
**Warning signs:** CI fails with "docker: command not found" on macos-* runners; Colima setup hangs

### Pitfall 3: Testing Non-Interactive Shells

**What goes wrong:** Tests pass but aliases/functions don't work when user opens terminal
**Why it happens:** Running `zsh -c 'alias l'` doesn't source .zshrc (interactive config)
**How to avoid:** Use `zsh -ic 'command'` to force interactive mode, or `zsh -l` for login shell
**Warning signs:** Environment variables work but aliases fail; `echo $EDITOR` works but `reload` doesn't

### Pitfall 4: Stow Symlink Assumptions

**What goes wrong:** Tests assume symlinks are absolute paths, fail when Stow creates relative symlinks
**Why it happens:** Stow only creates relative symlinks (by design for portability)
**How to avoid:** Test that symlink exists (`-L`) and verify target with `readlink`, not that it equals specific absolute path
**Warning signs:** Tests fail with "symlink points to wrong location" despite correct structure

### Pitfall 5: PATH Testing Without Shell Init

**What goes wrong:** `$PATH` looks correct in test but doesn't include Homebrew or ~/.local/bin
**Why it happens:** Test runs before sourcing .zshenv/.zsh_path which constructs PATH
**How to avoid:** Source shell config in BATS setup() or run commands in interactive shell context
**Warning signs:** Tests report system PATH (/usr/bin:/bin) without custom additions

### Pitfall 6: Race Conditions in Zimfw Init

**What goes wrong:** Tests fail intermittently because Zimfw downloads plugins on first run
**Why it happens:** Zimfw checks if modules are installed and downloads missing ones, which is network-dependent
**How to avoid:** Either run installation once before tests (pre-populate .zim) or add retry logic for first shell startup
**Warning signs:** Tests pass locally (cached plugins) but fail in CI; "curl" or "download" in test output

### Pitfall 7: Homebrew Cache Invalidation

**What goes wrong:** CI uses outdated cached Homebrew packages, tests pass but fresh install fails
**Why it happens:** Cache key doesn't change when dependencies update
**How to avoid:** Include dependency specification in cache key: `hashFiles('Makefile')` or use date-based keys with weekly rotation
**Warning signs:** CI passes but manual install fails; package versions differ between CI and local

### Pitfall 8: sudo in CI Tests

**What goes wrong:** Tests hang waiting for sudo password or fail with permission errors
**Why it happens:** GitHub Actions runners require passwordless sudo, but test scripts don't account for it
**How to avoid:** GitHub Actions runners have passwordless sudo configured. Ensure Makefile's set-shell target uses `chsh` correctly.
**Warning signs:** CI hangs indefinitely; "sudo: no tty present" errors

### Pitfall 9: Git Submodules Not Initialized

**What goes wrong:** Zimfw modules (which may be git submodules) are missing in CI
**Why it happens:** actions/checkout@v4 doesn't recursively clone submodules by default
**How to avoid:** Check if .zim modules are submodules. If so, use `with: submodules: true` in checkout action. However, current dotfiles use Zimfw's auto-install (downloads modules on first run), so this shouldn't apply.
**Warning signs:** Tests fail with ".zim/modules not found"; missing plugin errors

### Pitfall 10: Comparing Float vs Integer for Startup Time

**What goes wrong:** Bash comparison fails: `[ 42.3 -lt 100 ]` gives syntax error
**Why it happens:** Bash doesn't support float arithmetic in test operators
**How to avoid:** Convert to integer before comparison: `time_int=${time_ms%.*}` or use `bc` for float comparison
**Warning signs:** Test fails with "integer expression expected" error

## Code Examples

Verified patterns from official sources and best practices:

### Complete BATS Test File

```bash
#!/usr/bin/env bats
# test/shell_config.bats
# Source: https://bats-core.readthedocs.io/en/stable/

# Load test helpers (shared setup across test files)
load test_helper

# Runs before each @test
setup() {
    # Source shell config to test actual loaded state
    export HOME="${HOME:-/home/testuser}"
    export DOTFILES_DIR="$HOME/projects/dotfiles"
}

# Environment variables
@test "EDITOR is set to nvim" {
    run zsh -ic 'echo $EDITOR'
    [ "$status" -eq 0 ]
    [ "$output" = "nvim" ]
}

@test "ZDOTDIR points to .config/zsh" {
    run zsh -ic 'echo $ZDOTDIR'
    [ "$status" -eq 0 ]
    [[ "$output" =~ ".config/zsh" ]]
}

@test "XDG_CONFIG_HOME is set" {
    run zsh -ic 'echo $XDG_CONFIG_HOME'
    [ "$status" -eq 0 ]
    [ "$output" = "$HOME/.config" ]
}

# PATH validation
@test "~/.local/bin is in PATH" {
    run zsh -ic 'echo $PATH'
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$HOME/.local/bin" ]]
}

@test "Homebrew bin is in PATH (if Homebrew installed)" {
    # Conditional test - skip if Homebrew not present
    if ! command -v brew >/dev/null 2>&1; then
        skip "Homebrew not installed"
    fi

    brew_prefix=$(brew --prefix)
    run zsh -ic 'echo $PATH'
    [[ "$output" =~ "$brew_prefix/bin" ]]
}

# Aliases
@test "reload alias is defined" {
    run zsh -ic 'alias reload'
    [ "$status" -eq 0 ]
    [[ "$output" =~ "exec zsh" ]]
}

@test "g alias points to git" {
    run zsh -ic 'alias g'
    [ "$status" -eq 0 ]
    [[ "$output" =~ "git" ]]
}

# Functions
@test "mk function is defined" {
    run zsh -ic 'type mk'
    [ "$status" -eq 0 ]
    [[ "$output" =~ "function" ]]
}

@test "calc function works correctly" {
    run zsh -ic 'calc "10 + 32"'
    [ "$status" -eq 0 ]
    [ "$output" = "42" ]
}
```

### Helper Functions

```bash
# test/test_helper.bash
# Source: Common BATS patterns

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Skip test if on wrong platform
skip_if_not_macos() {
    [[ "$OSTYPE" == darwin* ]] || skip "macOS only"
}

skip_if_not_linux() {
    [[ "$OSTYPE" == linux* ]] || skip "Linux only"
}

# Verify symlink points into dotfiles repo
assert_dotfiles_symlink() {
    local symlink_path="$1"

    [ -L "$symlink_path" ] || {
        echo "Not a symlink: $symlink_path"
        return 1
    }

    local target=$(readlink "$symlink_path")
    [[ "$target" =~ "dotfiles/stow" ]] || {
        echo "Symlink doesn't point to dotfiles: $target"
        return 1
    }
}
```

### Complete GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
# Source: GitHub Actions best practices + Docker best practices
name: CI

on:
  push:
    branches: ['**']  # All branches
  pull_request:
    branches: ['**']
  workflow_dispatch:  # Manual trigger

jobs:
  test-ubuntu:
    runs-on: ubuntu-24.04

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install system dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y build-essential curl git

      - name: Cache Homebrew
        uses: actions/cache@v4
        with:
          path: /home/linuxbrew/.linuxbrew
          key: ubuntu-brew-${{ hashFiles('Makefile') }}
          restore-keys: |
            ubuntu-brew-

      - name: Install dotfiles
        run: make install

      - name: Run tests
        run: make test

  test-macos:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [macos-14, macos-15]  # ARM64 runners

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Cache Homebrew
        uses: actions/cache@v4
        with:
          path: |
            ~/Library/Caches/Homebrew
            /opt/homebrew
          key: ${{ matrix.os }}-brew-${{ hashFiles('Makefile') }}
          restore-keys: |
            ${{ matrix.os }}-brew-

      - name: Install dotfiles
        run: make install

      - name: Run tests
        run: make test

  test-ubuntu-docker:
    runs-on: ubuntu-24.04

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Build test container
        run: docker build -f .github/Dockerfile.ubuntu -t dotfiles-test .

      - name: Run installation and tests in container
        run: |
          docker run --rm dotfiles-test bash -c "
            make install &&
            make test
          "
```

### Dockerfile for Ubuntu Testing

```dockerfile
# .github/Dockerfile.ubuntu
# Source: Docker multi-stage builds best practices
FROM ubuntu:24.04

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        git \
        sudo \
        zsh \
    && rm -rf /var/lib/apt/lists/*

# Create test user (non-root)
RUN useradd -m -s /bin/zsh testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /home/testuser/projects/dotfiles

# Copy dotfiles repo
COPY --chown=testuser:testuser . .

# Switch to test user
USER testuser

# Set environment
ENV HOME=/home/testuser
ENV USER=testuser

# Default command runs tests
CMD ["make", "test"]
```

### Makefile Test Target

```makefile
# Add to existing Makefile
.PHONY: test test-setup test-installation test-shell test-symlinks test-performance

test: test-installation test-symlinks test-shell test-performance

test-setup:
	@command -v bats >/dev/null 2>&1 || $(BREW) install bats-core
	@[ -d "$$HOME/zsh-bench" ] || git clone --depth=1 https://github.com/romkatv/zsh-bench "$$HOME/zsh-bench"

test-installation: test-setup
	@echo "Testing installation..."
	bats test/installation.bats

test-symlinks: test-setup
	@echo "Testing symlink structure..."
	bats test/symlinks.bats

test-shell: test-setup
	@echo "Testing shell configuration..."
	bats test/shell_config.bats

test-performance: test-setup
	@echo "Testing shell startup performance..."
	bats test/performance.bats
```

### Smoke Tests (Optional - Claude's Discretion)

```bash
# test/smoke_tests.bats
# Optional: Test that tools actually work, not just that files exist

@test "nvim can start in headless mode" {
    run nvim --headless +quit
    [ "$status" -eq 0 ]
}

@test "git config is readable" {
    run git config --get user.name
    [ "$status" -eq 0 ]
    # Output will be empty if not configured, but command should succeed
}

@test "tmux can start server" {
    # Start tmux server without attaching
    run tmux start-server
    [ "$status" -eq 0 ]

    # Clean up
    tmux kill-server 2>/dev/null || true
}

@test "fzf is executable" {
    run fzf --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "fzf" ]]
}

@test "ripgrep is executable" {
    run rg --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "ripgrep" ]]
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| actions/checkout@v3 | actions/checkout@v4 | 2023 | Faster checkout, better Git handling |
| actions/cache@v3 | actions/cache@v4 | 2024 | Improved cache restore performance |
| ubuntu-20.04 | ubuntu-24.04 | 2024 | LTS support, newer packages |
| macos-13 (Intel) | macos-14/15 (ARM64) | 2024 | Apple Silicon native, 3x faster for M1 optimized code |
| Scheduled CI runs (weekly) | Event-based only (push/PR) | User decision | Avoid platform drift checks to reduce CI minutes |
| Docker Desktop on macOS | Native macOS runners | 2023 | GitHub removed Docker due to licensing |
| Manual timing | zsh-bench | Ongoing | Accurate interactive startup measurement vs process time |
| Custom test scripts | BATS | Industry standard | Structured tests, TAP output, better reporting |

**Deprecated/outdated:**
- **sstephenson/bats**: Original BATS repo is archived and read-only (as of 2021). Use bats-core/bats-core instead.
- **macos-13 and earlier Intel runners**: Still available but ARM64 runners (macos-14+) are now standard and faster.
- **ubuntu-slim**: Available but only 1 CPU vs 4 CPU for standard runners. Not worth the trade-off for these tests.

## Open Questions

1. **Should smoke tests be comprehensive or minimal?**
   - What we know: Can run `nvim --headless`, `git config --get`, `tmux start-server` to verify tools work
   - What's unclear: How much value vs CI time cost? False positives if tools work but config is wrong?
   - Recommendation: Start with file existence checks only. Add smoke tests if issues arise that file checks don't catch.

2. **Should we test multiple Ubuntu versions or just latest?**
   - What we know: GitHub offers ubuntu-24.04 and ubuntu-22.04. Matrix testing both increases CI time.
   - What's unclear: Likelihood of Ubuntu version-specific issues in dotfiles setup?
   - Recommendation: Test ubuntu-24.04 only initially. Add ubuntu-22.04 if we see version-specific issues or need to support older Ubuntu.

3. **How to handle Zimfw plugin download flakiness in CI?**
   - What we know: Zimfw downloads plugins on first shell startup, network-dependent
   - What's unclear: Frequency of download failures? Should we pre-populate .zim in CI?
   - Recommendation: Let Zimfw auto-install (matches user experience). Add retry logic if failures occur.

4. **Should Dockerfile be in .github/ or test/?**
   - What we know: User specified "e.g., .github/ or test/" - both are common
   - What's unclear: User preference for organization
   - Recommendation: Use `.github/Dockerfile.ubuntu` (keeps CI config together, common pattern in GitHub Actions projects)

## Sources

### Primary (HIGH confidence)

- [GitHub Actions Documentation - Runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners) - Official runner specs and versions
- [BATS Core Documentation](https://bats-core.readthedocs.io/en/stable/writing-tests.html) - Official test writing guide
- [zsh-bench Repository](https://github.com/romkatv/zsh-bench) - Official tool for zsh benchmarking
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html) - Official symlink behavior documentation
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/) - Official Docker documentation
- [GitHub Actions Dependency Caching](https://docs.github.com/en/actions/concepts/workflows-and-actions/dependency-caching) - Official caching reference

### Secondary (MEDIUM confidence)

- [webpro/dotfiles](https://github.com/webpro/dotfiles) - Real-world example of dotfiles CI testing on Ubuntu and macOS
- [ashishb/dotfiles](https://github.com/ashishb/dotfiles) - Dotfiles with comprehensive CI testing
- [CI your MacOS dotfiles with GitHub Actions](https://mattorb.com/ci-your-dotfiles-with-github-actions/) - Tutorial on dotfiles CI
- [ShellCheck Repository](https://github.com/koalaman/shellcheck) - Shell script linting tool
- [Setup Docker on macOS Action](https://github.com/douglascamata/setup-docker-macos-action) - Workaround for Docker on macOS runners (not recommended)

### Tertiary (LOW confidence)

- Various blog posts and tutorials on BATS usage patterns
- Community discussions on GitHub Actions runner performance
- Stack Overflow threads on shell testing approaches

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - BATS, zsh-bench, GitHub Actions are industry standard with official documentation
- Architecture: HIGH - Patterns verified from official docs and real-world dotfiles repos
- Pitfalls: MEDIUM-HIGH - Based on common issues in dotfiles testing, verified through docs where possible
- Docker strategy: HIGH - Official docs clearly state macOS limitations
- Startup measurement: HIGH - zsh-bench is purpose-built for this exact use case
- BATS syntax: HIGH - Official documentation with examples

**Research date:** 2026-02-14
**Valid until:** 2026-04-14 (60 days - stable ecosystem, but GitHub Actions runners update regularly)

**Notes:**
- User decision to skip scheduled runs means no automated platform drift detection. Tests only run on code changes.
- 100ms startup threshold is aggressive but achievable with the current minimal config.
- macOS Docker limitations are a known constraint; native runners are the correct approach.
- BATS is the clear choice over alternatives (shUnit2 less maintained, custom scripts lack structure).
