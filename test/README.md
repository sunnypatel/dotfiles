# Testing the Dotfiles

This directory contains tests for the dotfiles repository.

## Quick Test (No Dependencies)

Run the verification script (doesn't require bats):

```bash
bash test/verify-setup.sh
```

This checks:
- All detection scripts exist and are executable
- Makefile has required targets
- Installation scripts are configured correctly
- Path and shell configurations are set up

## Full Test Suite (Requires bats)

### Install bats

**macOS:**
```bash
brew install bats-core
```

**Linux/Ubuntu:**
```bash
sudo apt-get install bats
```

**WSL:**
```bash
sudo apt-get install bats
```

### Run all tests

```bash
make test
# or
dot test
# or
bats test
```

### Run specific test files

```bash
# OS detection tests
bats test/os-detection.bats

# Path configuration tests
bats test/path-config.bats

# Installation tests
bats test/installation.bats

# Binary utility tests
bats test/bin.bats

# Function tests
bats test/function.bats
```

### Run specific tests

```bash
# Run only tests matching a pattern
bats test/os-detection.bats -f "is-wsl"
bats test/path-config.bats -f "WSL"
```

## Test Files

- **os-detection.bats** - Tests for `is-macos`, `is-wsl`, `is-ubuntu`, `is-debian`, `is-arm64`
- **path-config.bats** - Tests for path configuration and management
- **installation.bats** - Tests for Makefile targets and installation scripts
- **bin.bats** - Tests for binary utilities (`dot`, `json`, `is-executable`, `is-supported`)
- **function.bats** - Tests for shell functions

## Platform-Specific Testing

### macOS

```bash
# Verify macOS detection
./bin/is-macos && echo "macOS detected"

# Run tests
make test
```

### Linux (Ubuntu/Debian)

```bash
# Verify Linux detection
./bin/is-ubuntu && echo "Ubuntu detected" || ./bin/is-debian && echo "Debian detected"

# Run tests
make test
```

### WSL

```bash
# Verify WSL detection
./bin/is-wsl && echo "WSL detected"

# Run WSL-specific tests
bats test/os-detection.bats -f "is-wsl"
bats test/path-config.bats -f "WSL"

# Run all tests
make test
```

## Continuous Integration

Tests are designed to work in CI environments. See `TESTING.md` in the root directory for CI setup examples.

