#!/usr/bin/env bats

# Tests for installation process
# These tests verify that installation detection and setup work correctly

setup() {
  DOTFILES_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export PATH="$DOTFILES_DIR/bin:$PATH"
}

@test "Makefile exists" {
  run [ -f "$DOTFILES_DIR/Makefile" ]
  [ "$status" -eq 0 ]
}

@test "Makefile has macos target" {
  run grep -q "^macos:" "$DOTFILES_DIR/Makefile"
  [ "$status" -eq 0 ]
}

@test "Makefile has linux target" {
  run grep -q "^linux:" "$DOTFILES_DIR/Makefile"
  [ "$status" -eq 0 ]
}

@test "Makefile has wsl target" {
  run grep -q "^wsl:" "$DOTFILES_DIR/Makefile"
  [ "$status" -eq 0 ]
}

@test "Makefile OS detection includes wsl" {
  run grep -q "is-wsl" "$DOTFILES_DIR/Makefile"
  [ "$status" -eq 0 ]
}

@test "remote-install.sh exists and is executable" {
  run [ -x "$DOTFILES_DIR/remote-install.sh" ]
  [ "$status" -eq 0 ]
}

@test "remote-install.sh detects WSL" {
  run grep -q "is-wsl\|microsoft" "$DOTFILES_DIR/remote-install.sh"
  [ "$status" -eq 0 ]
}

@test "remote-install.sh has wsl installation path" {
  run grep -q "make wsl" "$DOTFILES_DIR/remote-install.sh"
  [ "$status" -eq 0 ]
}

@test "wsl target depends on core-linux" {
  run grep -A1 "^wsl:" "$DOTFILES_DIR/Makefile" | grep -q "core-linux"
  [ "$status" -eq 0 ]
}

@test "wsl target depends on packages-linux" {
  run grep -A1 "^wsl:" "$DOTFILES_DIR/Makefile" | grep -q "packages-linux"
  [ "$status" -eq 0 ]
}

@test "wsl target depends on link" {
  run grep -A1 "^wsl:" "$DOTFILES_DIR/Makefile" | grep -q "link"
  [ "$status" -eq 0 ]
}

@test "all required detection scripts exist" {
  run [ -x "$DOTFILES_DIR/bin/is-macos" ]
  [ "$status" -eq 0 ]
  
  run [ -x "$DOTFILES_DIR/bin/is-wsl" ]
  [ "$status" -eq 0 ]
  
  run [ -x "$DOTFILES_DIR/bin/is-ubuntu" ]
  [ "$status" -eq 0 ]
  
  run [ -x "$DOTFILES_DIR/bin/is-debian" ]
  [ "$status" -eq 0 ]
  
  run [ -x "$DOTFILES_DIR/bin/is-arm64" ]
  [ "$status" -eq 0 ]
}

