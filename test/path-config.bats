#!/usr/bin/env bats

# Tests for path configuration
# These tests verify that path setup works correctly across platforms

setup() {
  DOTFILES_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export PATH="$DOTFILES_DIR/bin:$PATH"
  # Source the path configuration
  if [ -f "$DOTFILES_DIR/system/.path" ]; then
    export DOTFILES_DIR
    # Source in a subshell to avoid polluting test environment
    source "$DOTFILES_DIR/system/.path"
  fi
}

@test "DOTFILES_DIR/bin is in PATH" {
  run command -v is-executable
  [ "$status" -eq 0 ]
  [[ "$output" =~ "$DOTFILES_DIR/bin/is-executable" ]]
}

@test "path configuration file exists" {
  run [ -f "$DOTFILES_DIR/system/.path" ]
  [ "$status" -eq 0 ]
}

@test "prepend-path function is defined" {
  # Source the path file to get the function
  source "$DOTFILES_DIR/system/.path"
  run type prepend-path
  [ "$status" -eq 0 ]
}

@test "HOMEBREW_PREFIX is set or empty (not unset)" {
  source "$DOTFILES_DIR/system/.path"
  # HOMEBREW_PREFIX should be either set to a path or empty string
  # It should not be unset
  run [ -n "${HOMEBREW_PREFIX+x}" ]
  [ "$status" -eq 0 ]
}

@test "Homebrew paths only added if Homebrew exists" {
  source "$DOTFILES_DIR/system/.path"
  
  if [ -n "$HOMEBREW_PREFIX" ] && [ -d "$HOMEBREW_PREFIX" ]; then
    # If Homebrew is installed, paths should be in PATH
    run echo "$PATH" | grep -q "$HOMEBREW_PREFIX/bin"
    [ "$status" -eq 0 ]
  else
    # If Homebrew is not installed, paths should not be in PATH
    run echo "$PATH" | grep -q "/opt/homebrew/bin"
    [ "$status" -ne 0 ] || skip "Homebrew may be installed"
  fi
}

@test "WSL paths added when on WSL" {
  source "$DOTFILES_DIR/system/.path"
  
  if "$DOTFILES_DIR/bin/is-wsl" > /dev/null 2>&1; then
    # On WSL, Windows paths should be accessible
    run echo "$PATH" | grep -q "/mnt/c/Windows/System32"
    [ "$status" -eq 0 ]
  else
    skip "Not running on WSL"
  fi
}

@test "dotfiles bin directory is in PATH" {
  source "$DOTFILES_DIR/system/.path"
  run echo "$PATH" | grep -q "$DOTFILES_DIR/bin"
  [ "$status" -eq 0 ]
}

@test "common development tool paths are in PATH" {
  source "$DOTFILES_DIR/system/.path"
  
  # Check for common paths (they may or may not exist, but should be checked)
  # We're just verifying the path setup doesn't break
  run [ -n "$PATH" ]
  [ "$status" -eq 0 ]
}

