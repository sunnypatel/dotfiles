#!/usr/bin/env bats
###############################################################################
# symlinks.bats - Stow Symlink Validation
###############################################################################
# Purpose: Verify all Stow packages create correct symlinks
###############################################################################

load test_helper

#
# Zsh Package Symlinks
#

@test "zsh: ~/.zshenv symlink points to stow/zsh/.zshenv" {
    assert_dotfiles_symlink "$HOME/.zshenv"
}

@test "zsh: ~/.config/zsh/.zshrc symlink points to stow" {
    assert_dotfiles_symlink "$HOME/.config/zsh/.zshrc"
}

@test "zsh: ~/.config/zsh/.zimrc symlink points to stow" {
    assert_dotfiles_symlink "$HOME/.config/zsh/.zimrc"
}

@test "zsh: ~/.config/zsh/.zsh_aliases symlink points to stow" {
    assert_dotfiles_symlink "$HOME/.config/zsh/.zsh_aliases"
}

@test "zsh: ~/.config/zsh/.zsh_functions symlink points to stow" {
    assert_dotfiles_symlink "$HOME/.config/zsh/.zsh_functions"
}

@test "zsh: ~/.config/zsh/.zsh_path symlink points to stow" {
    assert_dotfiles_symlink "$HOME/.config/zsh/.zsh_path"
}

@test "zsh: ~/.config/zsh/.dir_colors symlink points to stow" {
    assert_dotfiles_symlink "$HOME/.config/zsh/.dir_colors"
}

#
# Git Package Symlinks
#

@test "git: ~/.config/git/config symlink points to stow" {
    assert_dotfiles_symlink "$HOME/.config/git/config"
}

@test "git: ~/.config/git/ignore symlink points to stow" {
    assert_dotfiles_symlink "$HOME/.config/git/ignore"
}

#
# Tmux Package Symlinks
#

@test "tmux: ~/.config/tmux/tmux.conf symlink points to stow" {
    assert_dotfiles_symlink "$HOME/.config/tmux/tmux.conf"
}

@test "tmux: ~/.config/tmux/tmux.conf.local symlink points to stow" {
    assert_dotfiles_symlink "$HOME/.config/tmux/tmux.conf.local"
}

#
# Nvim Package Symlinks
#

@test "nvim: ~/.config/nvim/init.lua symlink points to stow" {
    assert_dotfiles_symlink "$HOME/.config/nvim/init.lua"
}

@test "nvim: ~/.config/nvim/lua directory exists" {
    # For lua directory, check if it's a symlink or contains symlinked files
    [ -e "$HOME/.config/nvim/lua" ] || {
        echo "lua directory does not exist"
        return 1
    }
}

#
# Summary Test
#

@test "all expected symlinks exist" {
    local symlinks=(
        "$HOME/.zshenv"
        "$HOME/.config/zsh/.zshrc"
        "$HOME/.config/zsh/.zimrc"
        "$HOME/.config/zsh/.zsh_aliases"
        "$HOME/.config/zsh/.zsh_functions"
        "$HOME/.config/zsh/.zsh_path"
        "$HOME/.config/zsh/.dir_colors"
        "$HOME/.config/git/config"
        "$HOME/.config/git/ignore"
        "$HOME/.config/tmux/tmux.conf"
        "$HOME/.config/tmux/tmux.conf.local"
        "$HOME/.config/nvim/init.lua"
    )
    
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
