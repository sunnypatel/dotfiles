DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell bin/is-supported bin/is-macos macos $(shell bin/is-supported bin/is-wsl wsl linux))
HOMEBREW_PREFIX := $(shell bin/is-supported bin/is-macos $(shell bin/is-supported bin/is-arm64 /opt/homebrew /usr/local) $(shell bin/is-supported bin/is-wsl /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew))
export NVM_DIR = $(HOME)/.nvm
PATH := $(HOMEBREW_PREFIX)/bin:$(DOTFILES_DIR)/bin:$(PATH)
export PATH
SHELL := /bin/bash
SHELLS := /private/etc/shells
BIN := $(HOMEBREW_PREFIX)/bin
export XDG_CONFIG_HOME = $(HOME)/.config
export STOW_DIR = $(DOTFILES_DIR)
export ACCEPT_EULA=Y

.PHONY: test test-verify test-all

all: $(OS)

macos: sudo core-macos packages link duti bun

linux: core-linux packages-linux link

wsl: core-linux packages-linux link

core-macos: brew bash git npm

core-linux:
	sudo apt-get update
	sudo apt-get upgrade -y
	sudo apt-get dist-upgrade -f
	sudo apt-get install -y build-essential curl file git locales
	@if ! locale -a | grep -q "en_US.utf8"; then \
		echo "Generating en_US.UTF-8 locale..."; \
		sudo sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen || \
		echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen; \
		sudo locale-gen; \
	fi

stow-macos: brew
	is-executable stow || brew install stow

stow-linux: core-linux
	is-executable stow || sudo apt-get -y install stow

stow-wsl: core-linux
	is-executable stow || sudo apt-get -y install stow

sudo:
ifndef GITHUB_ACTION
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
endif

packages: brew-packages cask-apps node-packages rust-packages java

packages-linux: apt-packages node-packages-linux rust-packages-linux

link: stow-$(OS)
	for FILE in $$(\ls -A runcom); do \
		if [ -f $(HOME)/$$FILE -a ! -h $(HOME)/$$FILE ]; then \
			case "$$FILE" in *.bak) ;; *) \
				mv -v $(HOME)/$$FILE{,.bak}; \
			esac; \
		fi; \
	done
	mkdir -p "$(XDG_CONFIG_HOME)"
	# Backup conflicting files in XDG config before stowing
	cd $(DOTFILES_DIR)/config && \
	for FILE in $$(find . -type f -o -type l | sed 's|^./||'); do \
		if [ -f "$(XDG_CONFIG_HOME)/$$FILE" -a ! -h "$(XDG_CONFIG_HOME)/$$FILE" ]; then \
			case "$$FILE" in *.bak) ;; *) \
				mv -v "$(XDG_CONFIG_HOME)/$$FILE"{,.bak}; \
			esac; \
		fi; \
	done
	stow -t "$(HOME)" runcom
	stow -t "$(XDG_CONFIG_HOME)" config
	mkdir -p $(HOME)/.local/runtime
	chmod 700 $(HOME)/.local/runtime

unlink: stow-$(OS)
	stow --delete -t "$(HOME)" runcom
	stow --delete -t "$(XDG_CONFIG_HOME)" config
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE.bak ]; then \
		mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done

brew:
	is-executable brew || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash

bash: brew
ifdef GITHUB_ACTION
	if ! grep -q bash $(SHELLS); then \
		brew install bash bash-completion@2 pcre && \
		echo $(shell which bash) | sudo tee -a $(SHELLS) && \
		sudo chsh -s $(shell which bash); \
	fi
else
	if ! grep -q bash $(SHELLS); then \
		brew install bash bash-completion@2 pcre && \
		echo $(shell which bash) | sudo tee -a $(SHELLS) && \
		chsh -s $(shell which bash); \
	fi
endif

git: brew
	brew install git git-extras

npm: brew-packages
	@if [ ! -d "$(NVM_DIR)" ]; then \
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash; \
	fi
	@bash -c '. $(NVM_DIR)/nvm.sh && nvm install --lts && nvm use --lts'

brew-packages: brew
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true

cask-apps: brew
	brew bundle --file=$(DOTFILES_DIR)/install/Caskfile || true

vscode-extensions: cask-apps
	for EXT in $$(cat install/Codefile); do code --install-extension $$EXT; done

node-packages: npm
	@bash -c '. $(NVM_DIR)/nvm.sh && npm install --force --location global $(shell cat install/npmfile)'

rust-packages: brew-packages
	cargo install $(shell cat install/Rustfile)

java: brew-packages
	[ -d $(HOMEBREW_PREFIX)/opt/openjdk ] && sudo ln -sfn $(HOMEBREW_PREFIX)/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk || true

duti:
	duti -v $(DOTFILES_DIR)/install/duti

bun:
	curl -fsSL https://bun.sh/install | bash

apt-packages: core-linux
	sudo apt-get install -y \
		bat \
		fd-find \
		fzf \
		httpie \
		jq \
		ripgrep \
		shellcheck \
		stow \
		tmux \
		tree \
		wget \
		zsh \
		pkg-config \
		libssl-dev \
		libxcb1-dev \
		libx11-xcb-dev \
		libxcb-render0-dev \
		libxcb-shape0-dev \
		libxcb-xfixes0-dev

node-packages-linux:
	@if [ ! -d "$(NVM_DIR)" ]; then \
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash; \
	fi
	@bash -c '. $(NVM_DIR)/nvm.sh && nvm install --lts && nvm use --lts'
	@bash -c '. $(NVM_DIR)/nvm.sh && npm install --force --location global $(shell cat install/npmfile)'

rust-packages-linux:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source $(HOME)/.cargo/env && cargo install $(shell cat install/Rustfile)

test:
	@echo "Running full test suite with bats..."
	@bats test

test-verify:
	@echo "Running quick verification (no bats required)..."
	@bash test/verify-setup.sh

test-all: test-verify test
	@echo "All tests completed!"
