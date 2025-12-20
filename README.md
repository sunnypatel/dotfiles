# .files

These are my dotfiles. Take anything you want, but at your own risk.

Supports **macOS**, **Linux** (Ubuntu/Debian tested), and **Windows Subsystem for Linux (WSL)**.

## Highlights

- Minimal efforts to install everything, using a [Makefile](./Makefile)
- Fast and colored prompt
- Well-organized and easy to customize
- The installation and runcom setup is
  [tested weekly on real Ubuntu and macOS machines](https://github.com/sunnypatel/dotfiles/actions)
  (Ventura/13, Sonoma/14, Sequoia/15) using [a GitHub Action](./.github/workflows/dotfiles-installation.yml)
- Supports both Apple Silicon (M1) and Intel chips

## Packages Overview

### macOS
- [Homebrew](https://brew.sh) (packages: [Brewfile](./install/Brewfile))
- [homebrew-cask](https://github.com/Homebrew/homebrew-cask) (packages: [Caskfile](./install/Caskfile))
- Node.js via [n](https://github.com/tj/n) (packages: [npmfile](./install/npmfile))
- Rust via [rustup](https://rustup.rs) (packages: [Rustfile](./install/Rustfile))

### Linux
- APT packages for core utilities (bat, fd, fzf, ripgrep, etc.)
- Node.js via [n](https://github.com/tj/n) (packages: [npmfile](./install/npmfile))
- Rust via [rustup](https://rustup.rs) (packages: [Rustfile](./install/Rustfile))

### Common
- Latest Git, Bash, Python, GNU coreutils, curl
- `$EDITOR` is [GNU nano](https://www.nano-editor.org)
- ZSH with [Zim](https://zimfw.sh/) framework

## Installation

Choose your operating system section below:

<details>
<summary><b>🍎 macOS Installation</b></summary>

### Prerequisites

On a sparkling fresh installation of macOS:

```bash
sudo softwareupdate -i -a
xcode-select --install
```

The Xcode Command Line Tools includes `git` and `make` (not available on stock macOS).

### Quick Installation

Install with the automated script:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sunnypatel/dotfiles/main/remote-install.sh)"
```

This will clone this repo to `~/.dotfiles` and automatically run `make macos`.

### Manual Installation

1. Clone the repository:

```bash
git clone https://github.com/sunnypatel/dotfiles.git ~/.dotfiles
```

2. Install packages and symlink dotfiles:

```bash
cd ~/.dotfiles
make macos
```

### macOS Post-Installation

1. Set your Git credentials:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global github.user "your-github-username"
```

2. Set macOS Dock and system defaults:

```bash
dot dock
dot macos
```

3. Create exports file for tokens:

```bash
touch ~/.dotfiles/system/.exports
```

</details>

<details>
<summary><b>🐧 Linux Installation</b></summary>

### Prerequisites

On Ubuntu/Debian systems, ensure you have basic tools:

```bash
sudo apt update
sudo apt install -y curl git make
```

### Quick Installation

Install with the automated script:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sunnypatel/dotfiles/main/remote-install.sh)"
```

This will clone this repo to `~/.dotfiles` and automatically run `make linux`.

### Manual Installation

1. Clone the repository:

```bash
git clone https://github.com/sunnypatel/dotfiles.git ~/.dotfiles
```

2. Install packages and symlink dotfiles:

```bash
cd ~/.dotfiles
make linux
```

### Linux Post-Installation

1. Set your Git credentials:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global github.user "your-github-username"
```

2. Create exports file for tokens:

```bash
touch ~/.dotfiles/system/.exports
```

3. Restart your shell or source the configuration:

```bash
exec $SHELL
# or
source ~/.bashrc  # for bash
source ~/.zshrc   # for zsh
```

</details>

<details>
<summary><b>🪟 WSL (Windows Subsystem for Linux) Installation</b></summary>

### Prerequisites

WSL is automatically detected during installation. Ensure you have WSL2 set up with Ubuntu:

```bash
# In PowerShell (Windows)
wsl --install -d Ubuntu
```

Once in your WSL Ubuntu environment, ensure you have basic tools:

```bash
sudo apt update
sudo apt install -y curl git make
```

### Quick Installation

Install with the automated script (WSL is automatically detected):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sunnypatel/dotfiles/main/remote-install.sh)"
```

This will clone this repo to `~/.dotfiles` and automatically run `make wsl`.

### Manual Installation

1. Clone the repository:

```bash
git clone https://github.com/sunnypatel/dotfiles.git ~/.dotfiles
```

2. Install packages and symlink dotfiles:

```bash
cd ~/.dotfiles
make wsl
```

### WSL Post-Installation

1. Set your Git credentials:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global github.user "your-github-username"
```

2. Create exports file for tokens:

```bash
touch ~/.dotfiles/system/.exports
```

3. Restart your shell or source the configuration:

```bash
exec $SHELL
# or
source ~/.bashrc  # for bash
source ~/.zshrc   # for zsh
```

### WSL-Specific Features

- **Windows Integration**: Access Windows executables via `/mnt/c/Windows/System32`
- **Path Optimization**: WSL-specific paths are automatically configured
- **Performance**: Optimized for WSL2 filesystem characteristics

</details>

## Common Post-Installation

After installation on any platform:

1. **Populate exports file** with your tokens (example: `export GITHUB_TOKEN=abc`):

```bash
$EDITOR ~/.dotfiles/system/.exports
```

2. **Test your installation** by running:

```bash
dot test
```

   Or run a quick verification (no bats required):

```bash
bash test/verify-setup.sh
```

## The `dot` command

```
$ dot help
Usage: dot <command>

Commands:
   clean            Clean up caches (brew, cargo, gem, pip)
   dock             Apply macOS Dock settings (macOS only)
   edit             Open dotfiles in IDE ($VISUAL) and Git GUI ($VISUAL_GIT)
   help             This help message
   macos            Apply macOS system defaults (macOS only)
   test             Run tests
   update           Update packages and pkg managers (OS-appropriate)
```

## Troubleshooting

### Common Issues

- **Permission denied**: Make sure to run commands with appropriate permissions (some require `sudo`)
- **Command not found**: Restart your shell after installation: `exec $SHELL`
- **Homebrew on Linux/WSL**: The dotfiles will install Homebrew for Linux automatically if needed
- **WSL Detection**: WSL is automatically detected and uses optimized settings. If detection fails, you can manually run `make wsl`

### Getting Help

If you encounter issues:

1. Check the [GitHub Actions logs](https://github.com/sunnypatel/dotfiles/actions) for recent test results
2. Run `dot test` to validate your installation
3. File an issue in this repository with details about your system and error messages

## Customize

To customize the dotfiles to your likings, fork it and [be the king of your castle!](https://www.sunnypatel.nl/articles/getting-started-with-dotfiles)

### Key Files to Customize

- `system/.exports` - Your personal environment variables and tokens
- `install/npmfile` - Node.js packages to install globally
- `install/Brewfile` - Homebrew packages (macOS) 
- `install/Rustfile` - Rust crates to install
- `config/` - Application-specific configurations

## Symlink Management

This dotfiles project uses [GNU Stow](https://www.gnu.org/software/stow/) to manage symlinks between your configuration files and their expected locations.

### How it Works

The `make link` command (automatically run during installation) creates symlinks:
- Files in `runcom/` are symlinked to your home directory (`~`)
- Files in `config/` are symlinked to `~/.config/`

For example:
- `runcom/tmux.conf.local` → `~/.tmux.conf.local`
- `config/git/config` → `~/.config/git/config`

### Manual Symlink Commands

To manually set up symlinks after adding new config files:

```bash
make link
```

This command will:
1. Install GNU Stow if not already installed
2. Backup any existing conflicting files (adds `.bak` extension)
3. Create symlinks using stow for both `runcom/` and `config/` directories

To remove all symlinks and restore backed up files:

```bash
make unlink
```

This will:
1. Remove all symlinks created by stow
2. Restore any `.bak` files to their original names

### Adding New Configuration Files

To add new dotfiles:
1. Place files that belong in `~` in the `runcom/` directory
2. Place files that belong in `~/.config/` in the `config/` directory
3. Run `make link` to create the symlinks

## Credits

Many thanks to the [dotfiles community](https://dotfiles.github.io) and the original [webpro/dotfiles](https://github.com/webpro/dotfiles) repository.
