# Adding New Tools

## Overview

Each tool gets its own Stow package under `stow/`. The package directory structure mirrors where files should end up in `$HOME`. GNU Stow creates the symlinks.

## Example: Adding Starship Prompt

**1. Create the package directory structure:**

```
stow/starship/.config/starship.toml
```

This mirrors `~/.config/starship.toml` (the file's target location in your home directory).

**2. Add the config file** with your desired settings.

**3. Register the package in the Makefile:**

Open `Makefile` and make two updates:

- Add `starship` to the `stow-packages` target's `stow -R` command line
- If the tool needs Homebrew installation, add it to the `install-packages` loop using format `package:command` (e.g., `starship:starship`)

**4. Test the setup:**

```bash
make stow-packages              # Verify symlinks are created
ls -la ~/.config/starship.toml  # Confirm symlink exists
```

## Package Structure Conventions

**XDG-compliant configs** go under `stow/<tool>/.config/<tool>/`:
```
stow/nvim/.config/nvim/init.lua
stow/tmux/.config/tmux/tmux.conf
```

**Home-directory dotfiles** go under `stow/<tool>/.<filename>`:
```
stow/zsh/.zshenv
stow/ruby/.gemrc
```

**Rules:**
- One tool per package - never mix tools
- Package name matches the tool name
- Directory structure must exactly mirror target paths in `$HOME`

## Example: Tool with Home Directory Config

For a `.gemrc` file that should live at `~/.gemrc`:

```
stow/ruby/.gemrc
```

The structure `stow/ruby/.gemrc` mirrors `~/.gemrc`.

## What NOT to Add

- Language package managers (npm, cargo, pip) - see REMOVED.md
- GUI application configs - manage separately
- Secrets or tokens - use .gitignore
