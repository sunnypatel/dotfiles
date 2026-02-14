#!/usr/bin/env bats
###############################################################################
# shell_config.bats - Shell Configuration Audit
###############################################################################
# Purpose: Verify shell environment variables, aliases, functions, PATH, plugins
###############################################################################

load test_helper

#
# Environment Variables
#

@test "EDITOR is set to nvim" {
    result=$(zsh -ic 'echo $EDITOR' 2>/dev/null)
    [[ "$result" == "nvim" ]]
}

@test "ZDOTDIR points to .config/zsh" {
    result=$(zsh -ic 'echo $ZDOTDIR' 2>/dev/null)
    [[ "$result" == "$HOME/.config/zsh" ]]
}

@test "XDG_CONFIG_HOME is set" {
    result=$(zsh -ic 'echo $XDG_CONFIG_HOME' 2>/dev/null)
    [[ "$result" == "$HOME/.config" ]]
}

@test "DOTFILES_DIR is set" {
    result=$(zsh -ic 'echo $DOTFILES_DIR' 2>/dev/null)
    [[ -n "$result" ]]
}

@test "LANG is set to en_US.UTF-8" {
    result=$(zsh -ic 'echo $LANG' 2>/dev/null)
    [[ "$result" == "en_US.UTF-8" ]]
}

#
# PATH Validation
#

@test "~/.local/bin is in PATH" {
    result=$(zsh -ic 'echo $PATH' 2>/dev/null)
    [[ "$result" =~ "$HOME/.local/bin" ]]
}

@test "Homebrew bin is in PATH" {
    # Skip if brew not installed
    command_exists brew || skip "Homebrew not installed"
    
    result=$(zsh -ic 'echo $PATH' 2>/dev/null)
    brew_prefix=$(brew --prefix)
    [[ "$result" =~ "$brew_prefix/bin" ]]
}

#
# Aliases
#

@test "reload alias is defined" {
    result=$(zsh -ic 'alias reload' 2>/dev/null)
    [ $? -eq 0 ]
    [[ "$result" =~ "exec zsh" ]]
}

@test "g alias points to git" {
    result=$(zsh -ic 'alias g' 2>/dev/null)
    [ $? -eq 0 ]
    [[ "$result" =~ "git" ]]
}

@test "l alias is defined" {
    run zsh -ic 'alias l' 2>/dev/null
    [ $status -eq 0 ]
}

@test ".. alias is defined" {
    run zsh -ic 'alias ..' 2>/dev/null
    [ $status -eq 0 ]
}

@test "quit alias points to exit" {
    result=$(zsh -ic 'alias quit' 2>/dev/null)
    [ $? -eq 0 ]
    [[ "$result" =~ "exit" ]]
}

#
# Functions
#

@test "mk function is defined" {
    result=$(zsh -ic 'type mk' 2>/dev/null)
    [ $? -eq 0 ]
    [[ "$result" =~ "function" ]]
}

@test "calc function works" {
    result=$(zsh -ic 'calc "2 + 2"' 2>/dev/null)
    [[ "$result" == "4" ]]
}

#
# Zimfw Plugin Loading
#

@test "zsh-syntax-highlighting is loaded" {
    result=$(zsh -ic 'echo ${ZSH_HIGHLIGHT_VERSION:-unset}' 2>/dev/null)
    [[ "$result" != "unset" ]]
}

@test "zsh-autosuggestions is loaded" {
    run zsh -ic 'type _zsh_autosuggest_start' 2>/dev/null
    [ $status -eq 0 ]
}

#
# Tool Smoke Tests
#

@test "git config is readable" {
    run git config --list
    [ $status -eq 0 ]
}

@test "nvim starts in headless mode" {
    command_exists nvim || skip "nvim not found"
    run nvim --headless +quit
    [ $status -eq 0 ]
}

@test "tmux can start server" {
    command_exists tmux || skip "tmux not found"
    run bash -c "tmux start-server && tmux kill-server"
    [ $status -eq 0 ]
}

@test "fzf is executable" {
    command_exists fzf || skip "fzf not found"
    run fzf --version
    [ $status -eq 0 ]
}

@test "ripgrep is executable" {
    command_exists rg || skip "rg not found"
    run rg --version
    [ $status -eq 0 ]
}

@test "bat is executable" {
    command_exists bat || skip "bat not found"
    run bat --version
    [ $status -eq 0 ]
}
