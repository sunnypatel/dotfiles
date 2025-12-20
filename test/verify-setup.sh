#!/usr/bin/env bash

# Simple verification script that doesn't require bats
# This can be run to verify the setup without installing bats

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASSED=0
FAILED=0

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

echo "Verifying dotfiles setup..."
echo ""

# Check detection scripts exist and are executable
test_check "is-macos exists and is executable" "[ -x \"$DOTFILES_DIR/bin/is-macos\" ]"
test_check "is-wsl exists and is executable" "[ -x \"$DOTFILES_DIR/bin/is-wsl\" ]"
test_check "is-ubuntu exists and is executable" "[ -x \"$DOTFILES_DIR/bin/is-ubuntu\" ]"
test_check "is-debian exists and is executable" "[ -x \"$DOTFILES_DIR/bin/is-debian\" ]"
test_check "is-arm64 exists and is executable" "[ -x \"$DOTFILES_DIR/bin/is-arm64\" ]"

# Check detection scripts return valid exit codes
test_check "is-macos returns valid exit code" "\"$DOTFILES_DIR/bin/is-macos\" 2>/dev/null; [ \$? -eq 0 -o \$? -eq 1 ]"
test_check "is-wsl returns valid exit code" "\"$DOTFILES_DIR/bin/is-wsl\" 2>/dev/null; [ \$? -eq 0 -o \$? -eq 1 ]"
test_check "is-ubuntu returns valid exit code" "\"$DOTFILES_DIR/bin/is-ubuntu\" 2>/dev/null; [ \$? -eq 0 -o \$? -eq 1 ]"
test_check "is-debian returns valid exit code" "\"$DOTFILES_DIR/bin/is-debian\" 2>/dev/null; [ \$? -eq 0 -o \$? -eq 1 ]"
test_check "is-arm64 returns valid exit code" "\"$DOTFILES_DIR/bin/is-arm64\" 2>/dev/null; [ \$? -eq 0 -o \$? -eq 1 ]"

# Check Makefile
test_check "Makefile exists" "[ -f \"$DOTFILES_DIR/Makefile\" ]"
test_check "Makefile has macos target" "grep -q '^macos:' \"$DOTFILES_DIR/Makefile\""
test_check "Makefile has linux target" "grep -q '^linux:' \"$DOTFILES_DIR/Makefile\""
test_check "Makefile has wsl target" "grep -q '^wsl:' \"$DOTFILES_DIR/Makefile\""
test_check "Makefile detects WSL" "grep -q 'is-wsl' \"$DOTFILES_DIR/Makefile\""

# Check installation script
test_check "remote-install.sh exists and is executable" "[ -x \"$DOTFILES_DIR/remote-install.sh\" ]"
test_check "remote-install.sh detects WSL" "grep -q 'is-wsl\\|microsoft' \"$DOTFILES_DIR/remote-install.sh\""

# Check path configuration
test_check "system/.path exists" "[ -f \"$DOTFILES_DIR/system/.path\" ]"
test_check "system/.path handles WSL" "grep -q 'is-wsl' \"$DOTFILES_DIR/system/.path\""

# Check shell configuration
test_check "runcom/.bash_profile exists" "[ -f \"$DOTFILES_DIR/runcom/.bash_profile\" ]"
test_check ".bash_profile handles WSL" "grep -q 'is-wsl' \"$DOTFILES_DIR/runcom/.bash_profile\""

echo ""
echo "Results: $PASSED passed, $FAILED failed"

if [ $FAILED -eq 0 ]; then
  echo "✓ All checks passed!"
  exit 0
else
  echo "✗ Some checks failed"
  exit 1
fi

