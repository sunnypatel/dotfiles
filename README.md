# .files

Personal dotfiles for zsh, neovim, tmux, and git. Managed with GNU Stow.

Supports **macOS** (Intel/ARM), **Linux** (Ubuntu/Debian), and **Windows Subsystem for Linux (WSL2)**.

## What's Included

This repository manages configurations for four tools:

- **zsh** - Shell with [Zim framework](https://zimfw.sh/), modular config at `~/.config/zsh/`
- **git** - Aliases and XDG-compliant config at `~/.config/git/`
- **tmux** - Terminal multiplexer using [gpakosz/.tmux](https://github.com/gpakosz/.tmux) at `~/.config/tmux/`
- **neovim** - Editor with [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager and LSP via [mason.nvim](https://github.com/williamboman/mason.nvim)

Installation includes 8 Homebrew packages: git, neovim, tmux, stow, zsh, fzf, ripgrep, bat.

## Repository Structure

```
.
├── Makefile              # Cross-platform installer
├── stow/
│   ├── zsh/              # Shell config (ZDOTDIR=~/.config/zsh)
│   ├── git/              # Git config (~/.config/git/)
│   ├── tmux/             # Tmux config (~/.config/tmux/)
│   └── nvim/             # Neovim config (~/.config/nvim/)
├── test/                 # BATS test suite
├── .github/              # CI workflows + Dockerfile
└── REMOVED.md            # What was deleted and why
```

## Installation

<details>
<summary>macOS Installation</summary>

### Prerequisites

Install Xcode Command Line Tools (provides git and make):

```bash
xcode-select --install
```

### Install

Clone the repository (use any path you prefer):

```bash
git clone https://github.com/sunnypatel/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

This will:
1. Install Homebrew (if not already installed)
2. Install the 8 required packages
3. Symlink configs using Stow
4. Set zsh as default shell

</details>

<details>
<summary>Linux Installation</summary>

### Prerequisites

Ensure you have build tools and git:

```bash
sudo apt update
sudo apt install -y build-essential curl git
```

### Install

Clone the repository (use any path you prefer):

```bash
git clone https://github.com/sunnypatel/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

This will:
1. Install Homebrew for Linux (if not already installed)
2. Install the 8 required packages
3. Symlink configs using Stow
4. Set zsh as default shell

</details>

<details>
<summary>WSL Installation</summary>

### Prerequisites

Ensure WSL2 is set up with Ubuntu. From PowerShell:

```powershell
wsl --install -d Ubuntu
```

In your WSL Ubuntu environment, install build tools:

```bash
sudo apt update
sudo apt install -y build-essential curl git
```

### Install

Clone the repository (use any path you prefer):

```bash
git clone https://github.com/sunnypatel/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

WSL is automatically detected and uses the Linux installation path.

</details>

### Post-Installation

After installing on any platform, configure git credentials:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

Restart your shell to load the new configuration:

```bash
exec zsh
```

## How It Works

The `Makefile` automates installation:

1. Detects your platform (macOS/Linux/WSL)
2. Installs Homebrew if needed
3. Installs 8 core packages: git, neovim, tmux, stow, zsh, fzf, ripgrep, bat
4. Runs `stow -R -d stow -t $HOME zsh git tmux nvim`
5. Sets zsh as your default shell

Stow creates symlinks from the package directories into `$HOME`. For example:
- `stow/zsh/.zshenv` → `~/.zshenv`
- `stow/git/.config/git/config` → `~/.config/git/config`
- `stow/tmux/.config/tmux/tmux.conf` → `~/.config/tmux/tmux.conf`
- `stow/nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`

## Customization

### Key Files to Edit

- **Shell**: `stow/zsh/.config/zsh/.zshrc` - aliases, functions, shell behavior
- **Git**: `stow/git/.config/git/config` - git aliases and settings
- **Tmux**: `stow/tmux/.config/tmux/tmux.conf.local` - tmux key bindings and appearance
- **Neovim**: `stow/nvim/.config/nvim/init.lua` - editor config and plugins

### Adding New Tools

To add configuration for a new tool:

1. Create a new package directory under `stow/toolname/`
2. Add files in the structure they should have relative to `$HOME`
3. Update the `stow-packages` target in `Makefile` to include your new package
4. Run `make stow-packages` to create symlinks

Example for adding a hypothetical `alacritty` config:

```bash
mkdir -p stow/alacritty/.config/alacritty
# Add your alacritty.yml there
# Edit Makefile stow-packages target to include 'alacritty'
make stow-packages
```

## Testing

Run the BATS test suite:

```bash
make test
```

CI runs on every push via GitHub Actions, testing on:
- Ubuntu 22.04 (Docker)
- macOS 14 (Sonoma)
- macOS 15 (Sequoia)

## Uninstall

Remove all symlinks created by Stow:

```bash
make unlink
```

This does not uninstall packages, only removes the symlinks.

## Credits

Many thanks to the [dotfiles community](https://dotfiles.github.io).
