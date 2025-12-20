# Testing Guide

This document explains how to run tests for the dotfiles repository across different platforms.

## Quick Start

Run all tests:
```bash
make test
# or
dot test
```

Run specific test files:
```bash
bats test/os-detection.bats
bats test/path-config.bats
bats test/installation.bats
bats test/bin.bats
bats test/function.bats
```

## Test Files Overview

### `test/os-detection.bats`
Tests for OS detection utilities:
- `is-macos` - macOS detection
- `is-wsl` - WSL detection
- `is-ubuntu` - Ubuntu detection
- `is-debian` - Debian detection
- `is-arm64` - ARM64 architecture detection
- `is-supported` - Conditional execution

**Run on:** All platforms (tests adapt to current environment)

### `test/path-config.bats`
Tests for path configuration:
- PATH setup and management
- Homebrew path detection
- WSL-specific paths
- Development tool paths

**Run on:** All platforms (tests adapt to current environment)

### `test/installation.bats`
Tests for installation process:
- Makefile targets (macos, linux, wsl)
- Installation script detection
- Required scripts exist and are executable

**Run on:** All platforms (structural tests, no platform-specific execution)

### `test/bin.bats`
Tests for binary utilities:
- `dot` command
- `json` utility
- `is-executable` utility
- `is-supported` utility

**Run on:** All platforms

### `test/function.bats`
Tests for shell functions:
- Various utility functions from `system/.function`

**Run on:** All platforms

## Platform-Specific Testing

### macOS Testing

1. **Run all tests:**
   ```bash
   make test
   ```

2. **Verify macOS-specific detection:**
   ```bash
   bats test/os-detection.bats -f "is-macos"
   ```

3. **Test macOS installation (dry run):**
   ```bash
   # Check that Makefile detects macOS correctly
   make -n macos
   ```

### Linux (Ubuntu/Debian) Testing

1. **Run all tests:**
   ```bash
   make test
   ```

2. **Verify Linux detection:**
   ```bash
   bats test/os-detection.bats -f "is-ubuntu\|is-debian"
   ```

3. **Test Linux installation (dry run):**
   ```bash
   make -n linux
   ```

### WSL Testing

1. **Run all tests:**
   ```bash
   make test
   ```

2. **Verify WSL detection:**
   ```bash
   # Should detect WSL
   bin/is-wsl && echo "WSL detected" || echo "Not WSL"
   
   # Run WSL-specific tests
   bats test/os-detection.bats -f "is-wsl"
   bats test/path-config.bats -f "WSL"
   ```

3. **Test WSL installation (dry run):**
   ```bash
   make -n wsl
   ```

4. **Verify WSL paths:**
   ```bash
   # After sourcing .path, check for Windows paths
   source system/.path
   echo $PATH | grep -q "/mnt/c/Windows/System32" && echo "WSL paths configured"
   ```

## Manual Testing Checklist

### OS Detection Utilities

Test each detection script manually:

```bash
# Test macOS detection
./bin/is-macos && echo "macOS" || echo "Not macOS"

# Test WSL detection
./bin/is-wsl && echo "WSL" || echo "Not WSL"

# Test Ubuntu detection
./bin/is-ubuntu && echo "Ubuntu" || echo "Not Ubuntu"

# Test Debian detection
./bin/is-debian && echo "Debian" || echo "Not Debian"

# Test ARM64 detection
./bin/is-arm64 && echo "ARM64" || echo "Not ARM64"
```

### Installation Detection

Test that the Makefile correctly detects your OS:

```bash
# Check OS detection
make -n all

# Should show which target will run (macos, wsl, or linux)
```

### Path Configuration

Test path setup:

```bash
# Source the path configuration
export DOTFILES_DIR="$(pwd)"
source system/.path

# Check that dotfiles bin is in PATH
echo $PATH | grep -q "$DOTFILES_DIR/bin" && echo "✓ Dotfiles bin in PATH"

# Check Homebrew prefix (if applicable)
echo "HOMEBREW_PREFIX: $HOMEBREW_PREFIX"

# Check WSL paths (if on WSL)
if ./bin/is-wsl; then
  echo $PATH | grep -q "/mnt/c/Windows/System32" && echo "✓ WSL paths configured"
fi
```

### Remote Installation Script

Test the remote installation script detection:

```bash
# Check WSL detection in script
grep -A5 "microsoft" remote-install.sh

# Test the detection logic (without actually installing)
# This will show what make target would be called
if [[ "$OSTYPE" =~ ^darwin ]]; then
  echo "Would run: make macos"
elif [ -f /proc/version ] && grep -qi microsoft /proc/version; then
  echo "Would run: make wsl"
else
  echo "Would run: make linux"
fi
```

## Continuous Integration Testing

If you have GitHub Actions set up, you can test across platforms:

### Example GitHub Actions Workflow

```yaml
name: Test Dotfiles

on: [push, pull_request]

jobs:
  test-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install bats
        run: brew install bats-core
      - name: Run tests
        run: make test

  test-ubuntu:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install bats
        run: sudo apt-get install -y bats
      - name: Run tests
        run: make test

  test-wsl:
    runs-on: ubuntu-latest
    steps:
      - uses: Vampire/setup-wsl@v2
        with:
          distribution: Ubuntu
      - name: Install bats
        run: sudo apt-get install -y bats
      - name: Run tests
        run: wsl make test
```

## Troubleshooting Tests

### Tests Fail on WSL

If WSL detection tests fail:
1. Verify `/proc/version` contains "microsoft"
2. Check that `WSL_DISTRO_NAME` or `WSL_INTEROP` environment variables are set
3. Run `bin/is-wsl` manually to debug

### Tests Fail on macOS

If macOS detection tests fail:
1. Verify `OSTYPE` contains "darwin"
2. Check that `bin/is-macos` is executable
3. Run `bin/is-macos` manually to debug

### Path Tests Fail

If path configuration tests fail:
1. Ensure `DOTFILES_DIR` is set correctly
2. Check that `system/.path` is readable
3. Verify no syntax errors in `system/.path`
4. Source the file manually and check for errors

### Installation Tests Fail

If installation tests fail:
1. Verify Makefile syntax: `make -n all`
2. Check that all required scripts exist and are executable
3. Verify `remote-install.sh` has correct detection logic

## Test Coverage

Current test coverage includes:
- ✅ OS detection utilities (macOS, WSL, Ubuntu, Debian, ARM64)
- ✅ Path configuration and management
- ✅ Installation targets and scripts
- ✅ Binary utilities (dot, json, is-executable, is-supported)
- ✅ Shell functions

Areas that could use more testing:
- ⚠️ Actual installation process (requires clean environment)
- ⚠️ Symlink creation with Stow
- ⚠️ Package installation (requires root/sudo)
- ⚠️ Shell configuration loading

## Running Tests in Isolation

To test a specific component without running all tests:

```bash
# Test only OS detection
bats test/os-detection.bats

# Test only path configuration
bats test/path-config.bats

# Test only installation
bats test/installation.bats

# Test with verbose output
bats -v test/os-detection.bats

# Test with tap output (for CI)
bats --tap test/os-detection.bats
```

## Best Practices

1. **Run tests before committing:** Always run `make test` before pushing changes
2. **Test on target platform:** If possible, test on the actual platform you're targeting
3. **Test edge cases:** Test with and without Homebrew, with and without WSL, etc.
4. **Keep tests updated:** When adding new features, add corresponding tests
5. **Document test failures:** If a test fails, document the environment and error

## Contributing Tests

When adding new features:
1. Add tests to the appropriate test file
2. Follow the existing test patterns
3. Ensure tests work on all supported platforms
4. Update this guide if adding new test files

