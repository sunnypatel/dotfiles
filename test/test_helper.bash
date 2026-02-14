#!/usr/bin/env bash
###############################################################################
# test_helper.bash - Shared BATS Test Helpers
###############################################################################
# Purpose: Common utilities for BATS tests
###############################################################################

# command_exists "$cmd" - returns 0 if command found
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# skip_if_not_macos - skips test on non-macOS
skip_if_not_macos() {
    [[ "$OSTYPE" == darwin* ]] || skip "macOS only"
}

# skip_if_not_linux - skips test on non-Linux
skip_if_not_linux() {
    [[ "$OSTYPE" == linux* ]] || skip "Linux only"
}

# assert_dotfiles_symlink "$path" - verify path is symlink pointing into dotfiles/stow
assert_dotfiles_symlink() {
    local symlink_path="$1"
    [ -L "$symlink_path" ] || {
        echo "Not a symlink: $symlink_path"
        return 1
    }
    local target
    target=$(readlink "$symlink_path")
    [[ "$target" =~ dotfiles/stow ]] || [[ "$target" =~ "stow/" ]] || {
        echo "Symlink doesn't point to dotfiles stow: $target"
        return 1
    }
}
