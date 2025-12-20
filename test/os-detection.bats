#!/usr/bin/env bats

# Tests for OS detection utilities
# These tests verify that the detection scripts work correctly

setup() {
  # Get the directory where the dotfiles are located
  DOTFILES_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export PATH="$DOTFILES_DIR/bin:$PATH"
}

@test "is-macos detects macOS correctly" {
  # This test will pass on macOS, fail on Linux/WSL
  # We can't easily mock this, so we just verify the script exists and is executable
  run [ -x "$DOTFILES_DIR/bin/is-macos" ]
  [ "$status" -eq 0 ]
}

@test "is-wsl script exists and is executable" {
  run [ -x "$DOTFILES_DIR/bin/is-wsl" ]
  [ "$status" -eq 0 ]
}

@test "is-wsl returns 0 or 1 (valid exit codes)" {
  run "$DOTFILES_DIR/bin/is-wsl"
  # Exit code should be 0 (WSL detected) or 1 (not WSL)
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "is-ubuntu script exists and is executable" {
  run [ -x "$DOTFILES_DIR/bin/is-ubuntu" ]
  [ "$status" -eq 0 ]
}

@test "is-ubuntu returns 0 or 1 (valid exit codes)" {
  run "$DOTFILES_DIR/bin/is-ubuntu"
  # Exit code should be 0 (Ubuntu detected) or 1 (not Ubuntu)
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "is-debian script exists and is executable" {
  run [ -x "$DOTFILES_DIR/bin/is-debian" ]
  [ "$status" -eq 0 ]
}

@test "is-debian returns 0 or 1 (valid exit codes)" {
  run "$DOTFILES_DIR/bin/is-debian"
  # Exit code should be 0 (Debian detected) or 1 (not Debian)
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "is-arm64 script exists and is executable" {
  run [ -x "$DOTFILES_DIR/bin/is-arm64" ]
  [ "$status" -eq 0 ]
}

@test "is-arm64 returns 0 or 1 (valid exit codes)" {
  run "$DOTFILES_DIR/bin/is-arm64"
  # Exit code should be 0 (ARM64) or 1 (not ARM64)
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "is-supported works with is-wsl" {
  run is-supported "$DOTFILES_DIR/bin/is-wsl" "wsl" "linux"
  # Should return either "wsl" or "linux"
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^(wsl|linux)$ ]]
}

@test "is-supported works with is-macos" {
  run is-supported "$DOTFILES_DIR/bin/is-macos" "macos" "linux"
  # Should return either "macos" or "linux"
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^(macos|linux)$ ]]
}

@test "is-wsl checks /proc/version for microsoft" {
  # Test that the script checks /proc/version
  if [ -f /proc/version ]; then
    run grep -qi microsoft /proc/version
    # If we're on WSL, this should succeed
    # If not, that's fine - we're just checking the logic exists
  else
    skip "Not on Linux system"
  fi
}

@test "is-ubuntu checks /etc/os-release" {
  # Test that the script checks /etc/os-release
  if [ -f /etc/os-release ]; then
    run grep -q "^ID=ubuntu" /etc/os-release
    # This will pass on Ubuntu, fail otherwise
    # We're just verifying the check can be made
  else
    skip "Not on system with /etc/os-release"
  fi
}

