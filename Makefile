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
# apt packages required before anything else runs, as pkg:command-to-probe
LINUX_DEPS := build-essential:gcc curl:curl git:git unzip:unzip

# Must match PNPM_HOME/FNM_PATH in stow/zsh/.config/zsh/.zsh_path
PNPM_HOME := $(HOME)/.local/share/pnpm
FNM_PATH := $(HOME)/.local/share/fnm

BREW := $(or $(shell command -v brew 2>/dev/null),$(BREW_PREFIX)/bin/brew)
STOW := $(or $(shell command -v stow 2>/dev/null),$(BREW_PREFIX)/bin/stow)

.PHONY: all install macos linux wsl install-deps install-brew install-packages install-fnm install-pnpm stow-packages link ssh-config set-shell post-install unlink test test-setup

all: $(OS)
install: all
macos: install-brew install-packages install-fnm install-pnpm stow-packages ssh-config set-shell post-install
linux: install-deps install-brew install-packages install-fnm install-pnpm stow-packages ssh-config set-shell post-install
wsl: linux

install-deps:
ifeq ($(UNAME_S),Linux)
	@missing=""; \
	for entry in $(LINUX_DEPS); do \
		pkg=$${entry%%:*}; cmd=$${entry##*:}; \
		command -v $$cmd >/dev/null 2>&1 || missing="$$missing $$pkg"; \
	done; \
	if [ -n "$$missing" ]; then \
		echo "Installing system dependencies:$$missing"; \
		sudo apt-get update && sudo apt-get install -y $$missing; \
	fi
endif
install-brew: install-deps
	@if ! [ -x $(BREW) ]; then \
		echo "Installing Homebrew..."; \
		curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash; \
	fi
install-packages: install-brew
	@for entry in git neovim:nvim tmux stow zsh fzf ripgrep:rg bat jq aerc pandoc; do \
		pkg=$${entry%%:*}; cmd=$${entry##*:}; \
		command -v $$cmd >/dev/null 2>&1 || $(BREW) install $$pkg; \
	done
install-fnm: install-deps
	@if ! command -v fnm >/dev/null 2>&1 && ! [ -x "$(FNM_PATH)/fnm" ]; then \
		echo "Installing fnm..."; \
		curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$(FNM_PATH)" --skip-shell; \
	fi
# The installer ends in `pnpm setup`, which aborts unless it can map $SHELL to
# an rc file; under make that is sh, and sh needs $ENV set. Point it at bash
# (~/.bashrc, unmanaged) rather than the stowed zsh config, which does not exist
# until stow-packages runs later and would then conflict. PATH for the real
# shell comes from stow/zsh/.config/zsh/.zsh_path.
install-pnpm: install-deps
	@if ! command -v pnpm >/dev/null 2>&1 && ! [ -x "$(PNPM_HOME)/bin/pnpm" ]; then \
		echo "Installing pnpm..."; \
		curl -fsSL https://get.pnpm.io/install.sh | env \
			PNPM_HOME="$(PNPM_HOME)" \
			SHELL="$$(command -v bash || echo /bin/sh)" \
			ENV="$${ENV:-$$HOME/.profile}" \
			sh -; \
	fi
stow-packages:
	$(STOW) -R -d $(DOTFILES_DIR)/stow -t $(HOME) zsh git tmux nvim alacritty aerc
link: stow-packages ssh-config
ssh-config:
	@$(DOTFILES_DIR)/scripts/gen-ssh-config.sh
set-shell:
	@ZSH_PATH=$$(command -v zsh || echo $(BREW_PREFIX)/bin/zsh); \
	if ! [ -x "$$ZSH_PATH" ]; then \
		echo "zsh not found, skipping shell change."; \
		exit 0; \
	fi; \
	current=$$(getent passwd "$$USER" 2>/dev/null | cut -d: -f7); \
	[ -n "$$current" ] || current="$$SHELL"; \
	if [ "$$current" = "$$ZSH_PATH" ]; then \
		exit 0; \
	fi; \
	if ! grep -qxF "$$ZSH_PATH" /etc/shells 2>/dev/null; then \
		echo "Registering $$ZSH_PATH in /etc/shells..."; \
		echo "$$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null; \
	fi; \
	echo "Changing default shell to zsh..."; \
	sudo chsh -s "$$ZSH_PATH" "$$USER"
post-install:
	@echo ""
	@echo "======================================"
	@echo "  Dotfiles installed successfully!"
	@echo "======================================"
	@echo ""
	@echo "Log out and back in for zsh to take effect."
	@echo ""
unlink:
	$(STOW) -d $(DOTFILES_DIR)/stow -t $(HOME) -D zsh git tmux nvim alacritty aerc

test-setup:
	@command -v bats >/dev/null 2>&1 || $(BREW) install bats-core

test: test-setup
	bats test/*.bats
