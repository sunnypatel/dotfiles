# Cross-platform dotfiles installation
# Supports: macOS (Intel/ARM), Linux, WSL2
# Usage: make [macos|linux|wsl] or just 'make' to auto-detect

DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

ifeq ($(UNAME_S),Darwin)
    OS := macos
    ifeq ($(UNAME_M),arm64)
        BREW_PREFIX := /opt/homebrew
    else
        BREW_PREFIX := /usr/local
    endif
else ifeq ($(UNAME_S),Linux)
    IS_WSL := $(shell grep -qi microsoft /proc/version 2>/dev/null && echo true || echo false)
    ifeq ($(IS_WSL),true)
        OS := wsl
    else
        OS := linux
    endif
    BREW_PREFIX := /home/linuxbrew/.linuxbrew
endif

.PHONY: all install macos linux wsl install-deps install-brew install-packages stow-packages unlink

all: $(OS)
install: all
macos: install-brew install-packages stow-packages
linux: install-deps install-brew install-packages stow-packages
wsl: linux

install-deps:
ifeq ($(UNAME_S),Linux)
	@if ! command -v gcc >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y build-essential curl git; \
	fi
endif
install-brew:
	@if ! command -v brew >/dev/null 2>&1 && ! [ -x $(BREW_PREFIX)/bin/brew ]; then \
		echo "Installing Homebrew..."; \
		curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash; \
	fi
install-packages: install-brew
	@for entry in git neovim:nvim tmux stow zsh fzf ripgrep:rg bat; do \
		pkg=$${entry%%:*}; cmd=$${entry##*:}; \
		command -v $$cmd >/dev/null 2>&1 || $(BREW_PREFIX)/bin/brew install $$pkg; \
	done
stow-packages:
	stow -R -d $(DOTFILES_DIR)/stow -t $(HOME) zsh git tmux nvim
unlink:
	stow -d $(DOTFILES_DIR)/stow -t $(HOME) -D zsh git tmux nvim
