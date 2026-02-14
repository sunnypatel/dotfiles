# Architecture Research: Minimal Dotfiles Management

**Domain:** Cross-platform dotfiles management
**Researched:** 2026-02-13
**Confidence:** HIGH

## Recommended Architecture

### The Canonical Stow-Based Structure

The minimal structure for zsh, neovim, tmux, and git with GNU Stow follows this pattern:

```
~/dotfiles/
├── zsh/
│   ├── .zshenv
│   ├── .zshrc
│   └── .config/
│       └── zsh/
│           └── [additional configs]
├── nvim/
│   └── .config/
│       └── nvim/
│           ├── init.lua
│           └── lua/
│               └── [configs]
├── tmux/
│   ├── .tmux.conf
│   └── .config/
│       └── tmux/
│           └── [additional configs]
├── git/
│   ├── .gitconfig
│   └── .config/
│       └── git/
│           ├── config
│           └── ignore
├── .stow-local-ignore  # Optional: override default ignore list
└── README.md
```

**Core Principle:** The directory structure inside each package mirrors exactly where files live in `$HOME`. When inside `dotfiles/zsh/`, pretend you're in `~` — the structure must match.

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|----------------|-------------------|
| **Stow packages** (zsh/, nvim/, etc.) | Store configs for a single tool, mirroring home directory structure | None (isolated by design) |
| **Installation orchestrator** (Makefile/install script) | Detect platform, install dependencies, invoke stow | All packages |
| **Platform conditionals** | Handle OS-specific differences (macOS vs Linux vs WSL) | Installation orchestrator |
| **.stow-local-ignore** | Define what Stow should skip (README, etc.) | Stow itself |

### Data Flow

```
User runs: make install / stow <package>
    ↓
Installation Script
    ↓ (detects platform)
├─→ macOS: brew install <deps>
├─→ Linux: apt-get install <deps>
└─→ WSL: apt-get install <deps> + WSL-specific tweaks
    ↓
GNU Stow
    ↓ (walks package tree)
Creates symlinks: ~/dotfiles/zsh/.zshrc → ~/.zshrc
    ↓
Shell sources: ~/.zshrc → reads config from version control
```

**Key insight:** Files never move. Stow creates symlinks. Your actual configs stay in git. Changes are immediately versioned.

## Minimal vs. Current Structure Analysis

### Current Structure (Complex)

Your repository uses 7 top-level directories:
- `runcom/` - shell rc files
- `system/` - modular shell snippets (.alias, .env, .function, etc.)
- `config/` - XDG config directory
- `bin/` - utility scripts
- `install/` - package lists (Brewfile, npmfile, etc.)
- `macos/` - macOS-specific settings
- `test/` - test suite

**Complexity score: 7/10** — Many directories, unclear what goes where without reading docs.

### Minimal Structure (Simple)

Package-per-tool approach:
- `zsh/` - everything zsh
- `nvim/` - everything neovim
- `tmux/` - everything tmux
- `git/` - everything git

**Complexity score: 2/10** — Immediately obvious. Each directory = one tool.

### Component Mapping

| Current | Minimal | Notes |
|---------|---------|-------|
| `runcom/.zshrc` | `zsh/.zshrc` | Direct mapping |
| `runcom/.zshenv` | `zsh/.zshenv` | Direct mapping |
| `system/.alias` | `zsh/.config/zsh/aliases.zsh` | Move into zsh package |
| `system/.function` | `zsh/.config/zsh/functions.zsh` | Move into zsh package |
| `system/.env` | `zsh/.config/zsh/env.zsh` | Move into zsh package |
| `system/.path` | `zsh/.config/zsh/path.zsh` | Move into zsh package |
| `system/.completion.zsh` | `zsh/.config/zsh/completion.zsh` | Move into zsh package |
| `config/git/` | `git/.config/git/` | Already aligned |
| `config/tmux/` | `tmux/.config/tmux/` | Already aligned |
| `bin/` | Keep as `bin/` (no stow) | Utility scripts, added to PATH manually |
| `install/` | Keep as `install/` or rename `bootstrap/` | Not stowed |
| `macos/` | `macos/` or integrate into packages | Not stowed |

## Architectural Patterns

### Pattern 1: Package-Based Organization

**What:** One directory per tool, mirroring home directory structure.

**When to use:** When managing configs for 3+ distinct tools. Allows selective installation (e.g., install git configs without zsh on a server).

**Trade-offs:**
- **Pro:** Modular, selective, clear boundaries
- **Pro:** Easy to share individual tool configs
- **Con:** Requires understanding directory mirroring principle
- **Con:** More directories than flat structure

**Example:**
```bash
# Install only git configs on a server
cd ~/dotfiles
stow git

# Install full setup on personal machine
stow zsh nvim tmux git
```

### Pattern 2: Platform-Specific Files Within Packages

**What:** Include platform conditionals inside packages rather than separate platform directories.

**When to use:** When same tool needs different configs per platform (e.g., macOS vs Linux aliases).

**Trade-offs:**
- **Pro:** Keeps tool configs together
- **Pro:** Single package install works across platforms
- **Con:** Packages contain platform-detection logic

**Example:**
```
zsh/
├── .zshrc                      # Sources platform-specific files
└── .config/
    └── zsh/
        ├── aliases.zsh         # Common aliases
        ├── aliases-darwin.zsh  # macOS-specific
        └── aliases-linux.zsh   # Linux-specific
```

`.zshrc` loads conditionally:
```zsh
# Load platform-specific aliases
if [[ "$OSTYPE" == darwin* ]]; then
  source ~/.config/zsh/aliases-darwin.zsh
elif [[ "$OSTYPE" == linux* ]]; then
  source ~/.config/zsh/aliases-linux.zsh
fi
```

### Pattern 3: Separate Platform Packages (Alternative)

**What:** Use separate packages like `zsh-macos/` and `zsh-linux/` with `.stow-global-ignore` to skip platform packages.

**When to use:** When platform differences are substantial (>30% different).

**Trade-offs:**
- **Pro:** Complete separation, no conditionals in configs
- **Con:** More packages to maintain
- **Con:** Common configs duplicated unless symlinked internally

**Example:**
```
dotfiles/
├── zsh/              # Common zsh configs
├── zsh-macos/        # macOS overrides
├── zsh-linux/        # Linux overrides
└── .stow-global-ignore
```

`.stow-global-ignore`:
```
^/zsh-macos
^/zsh-linux
```

Installation detects platform and stows base + platform package.

### Pattern 4: Makefile Orchestration

**What:** Use Makefile to wrap stow commands, detect platform, install dependencies.

**When to use:** When you need dependency installation + config linking in one command.

**Trade-offs:**
- **Pro:** Single entry point (`make install`)
- **Pro:** Handles prerequisites (install stow, create directories)
- **Pro:** Universally available (make exists everywhere)
- **Con:** Make syntax is quirky
- **Con:** Adding another abstraction layer

**Example:**
```makefile
OS := $(shell uname -s)
STOW := stow
PACKAGES := zsh nvim tmux git

install: install-deps link

install-deps:
ifeq ($(OS),Darwin)
	brew install stow neovim tmux
else
	sudo apt-get install -y stow neovim tmux
endif

link:
	$(STOW) $(PACKAGES)

unlink:
	$(STOW) -D $(PACKAGES)
```

### Pattern 5: Bootstrap Script Alternative

**What:** Simple shell script instead of Makefile.

**When to use:** When Makefile feels overkill or you prefer readable shell.

**Trade-offs:**
- **Pro:** More readable than Makefile
- **Pro:** Easier to add complex logic (if/else, loops)
- **Con:** Not idempotent like make targets
- **Con:** Must handle "already installed" checks manually

**Example:**
```bash
#!/usr/bin/env bash
set -euo pipefail

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
  brew install stow neovim tmux
else
  sudo apt-get install -y stow neovim tmux
fi

# Stow configs
cd "$(dirname "$0")"
stow zsh nvim tmux git
```

## Anti-Patterns

### Anti-Pattern 1: Over-Modularization

**What people do:** Split shell configs into 15+ tiny files (.alias, .alias.git, .alias.docker, .function, .function_fs, .function_network, .env, .env.java, .env.node, etc.).

**Why it's wrong:**
- Hard to find where a specific config lives
- File overhead (15 files vs. 3 files doesn't improve clarity)
- Slower shell startup (sources 15 files instead of 3)

**Do this instead:**
- Maximum 5 files per tool: `.zshrc`, `aliases.zsh`, `functions.zsh`, `env.zsh`, `completion.zsh`
- Group related things (e.g., all git aliases in aliases.zsh, not separate file)
- Use comments to create sections within files

**Example comparison:**
```
❌ OVER-MODULARIZED (current)
system/
├── .alias
├── .alias.macos
├── .function
├── .function_fs
├── .function_network
├── .function_text
├── .env
├── .env.bash
├── .env.macos
├── .env.zsh
└── ... (25 files total)

✅ APPROPRIATELY MODULAR
zsh/.config/zsh/
├── aliases.zsh         # ALL aliases, with sections
├── functions.zsh       # ALL functions, with sections
├── env.zsh             # Environment variables
├── completion.zsh      # Completions
└── platform-macos.zsh  # macOS-specific overrides
```

### Anti-Pattern 2: Separate `runcom/` and `system/` Directories

**What people do:** Create `runcom/` for `.bashrc`/`.zshrc` and `system/` for sourced snippets.

**Why it's wrong:**
- Artificial separation — both are zsh configs
- Requires two stow operations or complex stow ignore rules
- User must understand "runcom sources system" indirection

**Do this instead:**
- Single `zsh/` package containing both rc file and sourced configs
- `.zshrc` sources from `.config/zsh/` (XDG standard)

**Example:**
```
✅ BETTER STRUCTURE
zsh/
├── .zshrc              # Sources files from .config/zsh/
└── .config/
    └── zsh/
        ├── aliases.zsh
        ├── functions.zsh
        └── env.zsh
```

### Anti-Pattern 3: Version-Controlling Build Artifacts

**What people do:** Commit `.zshrc.swp` (Vim swap files), `.DS_Store`, `node_modules/` equivalent to dotfiles repo.

**Why it's wrong:**
- Bloats repo with generated files
- Creates merge conflicts on swap files
- Not portable across machines

**Do this instead:**
- Add comprehensive `.gitignore`:
```gitignore
*.swp
*.swo
*.log
.DS_Store
```
- Use `.stow-local-ignore` to prevent stowing unwanted files

### Anti-Pattern 4: Platform Separation at Top Level

**What people do:** Create `macos/` and `linux/` directories at top level, duplicating tool configs.

**Why it's wrong:**
- Duplicates common configs (most zsh config is platform-agnostic)
- Hard to keep in sync
- Forces choice between platforms instead of supporting both

**Do this instead:**
- Single package with platform conditionals inside
- Or base package + platform override packages
- Use pattern 2 or 3 from above

### Anti-Pattern 5: Makefile Complexity

**What people do:** Makefile with complex shell logic, nested conditionals, 200+ lines.

**Why it's wrong:**
- Make is for building software, not scripting
- Make syntax is error-prone (tabs vs spaces, escaping)
- Hard to debug when it breaks

**Do this instead:**
- Keep Makefile under 50 lines
- Only use make for high-level targets (`install`, `unlink`)
- Move complex logic to shell scripts, call from make
- Or skip make entirely, use `install.sh` script

**Example:**
```makefile
# ✅ SIMPLE MAKEFILE (good)
.PHONY: install unlink

install:
	./scripts/install-deps.sh
	stow zsh nvim tmux git

unlink:
	stow -D zsh nvim tmux git
```

## Platform-Specific Handling

### macOS vs. Linux vs. WSL

| Platform | Detection | Key Differences |
|----------|-----------|-----------------|
| **macOS** | `[[ "$OSTYPE" == darwin* ]]` | Homebrew in `/usr/local` or `/opt/homebrew`, BSD utilities, macOS-specific apps |
| **Linux** | `[[ "$OSTYPE" == linux* ]]` | APT/DNF/Pacman, GNU utilities, no macOS apps |
| **WSL** | `grep -qi microsoft /proc/version` | Linux + Windows integration, paths to Windows via `/mnt/c/`, performance considerations |

### Recommended Approach

**Use Pattern 2 (platform files within packages):**

```
zsh/
├── .zshrc
└── .config/zsh/
    ├── aliases.zsh           # Common
    ├── aliases-darwin.zsh    # macOS-only
    ├── aliases-linux.zsh     # Linux-only
    ├── env.zsh               # Common
    └── env-darwin.zsh        # macOS-only
```

**`.zshrc` detection:**
```zsh
# Detect platform
case "$OSTYPE" in
  darwin*)  export PLATFORM="macos" ;;
  linux*)
    if grep -qi microsoft /proc/version; then
      export PLATFORM="wsl"
    else
      export PLATFORM="linux"
    fi
    ;;
esac

# Source common configs
for config in ~/.config/zsh/*.zsh; do
  # Skip platform-specific files
  [[ $config =~ -(darwin|linux|wsl) ]] && continue
  source "$config"
done

# Source platform-specific configs
if [[ "$PLATFORM" == "macos" ]]; then
  for config in ~/.config/zsh/*-darwin.zsh; do
    [[ -f "$config" ]] && source "$config"
  done
elif [[ "$PLATFORM" == "linux" || "$PLATFORM" == "wsl" ]]; then
  for config in ~/.config/zsh/*-linux.zsh; do
    [[ -f "$config" ]] && source "$config"
  done
fi
```

### Windows PowerShell (Stretch Goal)

**Challenge:** GNU Stow doesn't work on Windows (symlinks require admin or developer mode).

**Alternatives:**
1. **Chezmoi** - Cross-platform dotfile manager with native Windows support
2. **PSDotFiles** - PowerShell module mimicking Stow behavior
3. **Manual symlinks** - `New-Item -ItemType SymbolicLink` in PowerShell (requires admin)
4. **Hard links** - `New-Item -ItemType HardLink` (no admin required, but can't link directories)

**Recommendation for stretch goal:** Skip Windows/PowerShell. Focus on macOS/Linux/WSL. WSL covers "Windows users who use Unix tools."

## Stow Ignore Files

### Default Ignore List

Stow automatically ignores:
- `.git/`
- `.gitignore`
- `README.md`
- `LICENSE`
- `Makefile`

### Custom Ignore: `.stow-local-ignore`

**Critical:** Creating `.stow-local-ignore` **overrides defaults**. You must re-specify defaults you want to keep.

**Example `.stow-local-ignore`:**
```
# Stow defaults (must re-specify!)
\.git
\.gitignore
^/README.*
^/LICENSE.*
^/COPYING

# Custom ignores
\.DS_Store
.*\.swp
.*\.swo
^/Makefile
^/install
^/macos
^/bin
```

**Syntax:**
- `^/` = root of package (e.g., `^/README.md` ignores top-level README)
- `\.` = literal dot (escape it)
- No `/` in pattern = matches filename anywhere in tree

### Global Ignore: `~/.stow-global-ignore`

Used when package has no `.stow-local-ignore`. Most users don't need this.

## Build Order for Stripping Down

### Phase 1: Consolidate Shell Configs (Highest Impact)

**Goal:** Collapse `runcom/` and `system/` into `zsh/`.

**Steps:**
1. Create `zsh/.zshrc` (merge `runcom/.zshrc` + `runcom/.zshenv`)
2. Create `zsh/.config/zsh/` directory
3. Move `system/.alias` → `zsh/.config/zsh/aliases.zsh`
4. Move `system/.function*` → `zsh/.config/zsh/functions.zsh` (merge all function files)
5. Move `system/.env*` → `zsh/.config/zsh/env.zsh` (merge all env files)
6. Move `system/.completion.zsh` → `zsh/.config/zsh/completion.zsh`
7. Delete `runcom/` and `system/` directories
8. Update `.zshrc` to source from `.config/zsh/`
9. Test: `stow zsh` should create `~/.zshrc` and `~/.config/zsh/`

**Result:** 2 directories eliminated, configs remain functional.

### Phase 2: Align XDG Configs (Low Effort)

**Goal:** Rename `config/` → individual packages.

**Current structure:**
```
config/
├── git/
├── tmux/
└── alacritty/
```

**Steps:**
1. Create `git/` package: move `config/git/` → `git/.config/git/`
2. Create `tmux/` package: move `config/tmux/` → `tmux/.config/tmux/`
3. Create `alacritty/` package: move `config/alacritty/` → `alacritty/.config/alacritty/`
4. Delete `config/` directory
5. Update Makefile: `stow -t "$(XDG_CONFIG_HOME)" config` → `stow git tmux alacritty`

**Result:** 1 directory eliminated, clearer package boundaries.

### Phase 3: Decide on Neovim (Currently Missing)

User mentioned neovim but it's not in current repo.

**Options:**
1. **Add nvim package:** `nvim/.config/nvim/init.lua`
2. **Skip if not using:** Don't add if you don't use neovim

**If adding:**
```
nvim/
└── .config/
    └── nvim/
        ├── init.lua
        └── lua/
            └── [your config modules]
```

### Phase 4: Simplify Installation (Medium Effort)

**Goal:** Reduce Makefile complexity or replace with install script.

**Current issues:**
- Makefile is 180 lines
- Complex OS detection
- Many targets users don't run manually

**Options:**

**Option A: Simplify Makefile**
```makefile
# Minimal Makefile
PACKAGES := zsh git tmux alacritty

.PHONY: install uninstall deps

install: deps
	stow $(PACKAGES)

uninstall:
	stow -D $(PACKAGES)

deps:
	@./scripts/install-deps.sh
```

Move dependency installation to `scripts/install-deps.sh` (shell is better for this).

**Option B: Replace with Install Script**
```bash
#!/usr/bin/env bash
# install.sh

set -euo pipefail

# Detect platform and install deps
./scripts/install-deps.sh

# Stow configs
cd "$(dirname "$0")"
stow zsh git tmux alacritty

echo "✓ Dotfiles installed"
```

**Recommendation:** Option A (simple Makefile + shell script). Make is useful for idempotency.

### Phase 5: Handle Non-Stowed Directories (Low Priority)

**Directories that shouldn't be stowed:**
- `bin/` - Utility scripts (add to PATH manually or symlink to `~/.local/bin/`)
- `install/` - Package lists (used by install scripts, not stowed)
- `macos/` - macOS defaults scripts (run manually, not stowed)
- `test/` - Test suite (for development, not stowed)

**Options:**
1. **Keep as-is:** Top-level utility directories
2. **Rename for clarity:**
   - `install/` → `bootstrap/`
   - `macos/` → `scripts/macos/`
   - `bin/` → `scripts/bin/`
3. **Move into hidden directory:** `.dotfiles-meta/` containing non-stowed files

**Recommendation:** Keep as-is or option 2 (rename). `.dotfiles-meta/` is clever but adds indirection.

**Update `.stow-local-ignore` to skip these:**
```
^/bin
^/install
^/bootstrap
^/macos
^/scripts
^/test
^/Makefile
```

### Phase 6: Clean Up Documentation (Final Polish)

**Goal:** Update README to reflect new structure.

**Key sections:**
1. **Installation:** `make install` or `./install.sh`
2. **Structure:** Explain package-per-tool organization
3. **Adding configs:** How to add new tool configs
4. **Platform-specific:** How platform detection works
5. **Uninstall:** `make uninstall` or `stow -D <packages>`

## Stripping Down: Order of Operations

**Follow this sequence to avoid breaking existing setup:**

1. ✅ **Create `.stow-local-ignore`** (prevent stowing unwanted files)
2. ✅ **Create new package directories** (`zsh/`, `git/`, `tmux/`, etc.)
3. ✅ **Copy (don't move) configs** into new structure
4. ✅ **Test stowing new structure** in a test directory: `stow -t /tmp/test-home zsh`
5. ✅ **Verify symlinks created correctly** in test directory
6. ✅ **Update `.zshrc`** to source from new locations
7. ✅ **Unlink old structure:** `make unlink` or `stow -D runcom config system`
8. ✅ **Link new structure:** `stow zsh git tmux`
9. ✅ **Test in live environment** (open new shell, verify configs loaded)
10. ✅ **Delete old directories** (`runcom/`, `system/`, `config/`)
11. ✅ **Update Makefile/install script** to use new package names
12. ✅ **Commit changes**
13. ✅ **Update README**

**Critical:** Test before deleting old structure. Keep backup of working setup.

## Minimal Structure Recommendation

**Final target structure for this repo:**

```
~/dotfiles/
├── zsh/                     # Shell configuration
│   ├── .zshenv
│   ├── .zshrc
│   └── .config/
│       └── zsh/
│           ├── aliases.zsh
│           ├── functions.zsh
│           ├── env.zsh
│           ├── completion.zsh
│           └── platform-darwin.zsh
├── git/                     # Git configuration
│   └── .config/
│       └── git/
│           ├── config
│           └── ignore
├── tmux/                    # Tmux configuration
│   └── .config/
│       └── tmux/
│           └── tmux.conf
├── nvim/                    # Neovim configuration (if used)
│   └── .config/
│       └── nvim/
│           └── init.lua
├── alacritty/               # Alacritty terminal (if used)
│   └── .config/
│       └── alacritty/
│           └── alacritty.toml
├── bin/                     # Utility scripts (not stowed)
│   ├── is-macos
│   ├── is-wsl
│   └── is-supported
├── bootstrap/               # Installation files (not stowed)
│   ├── Brewfile
│   ├── aptfile
│   └── npmfile
├── scripts/                 # Helper scripts (not stowed)
│   ├── install-deps.sh
│   └── macos-defaults.sh
├── .stow-local-ignore       # Stow ignore patterns
├── Makefile                 # Simple installation orchestrator
└── README.md
```

**Package count:** 4-5 (zsh, git, tmux, optionally nvim + alacritty)
**Non-stowed directories:** 3 (bin, bootstrap, scripts)
**Total top-level items:** ~10 (down from current ~13, but massively simpler)

**Simplicity improvements:**
1. **Every file's purpose is obvious** — if it's in `zsh/`, it's zsh config
2. **No indirection** — `.zshrc` sources from `.config/zsh/`, not external `system/` directory
3. **Standard XDG layout** — follows `~/.config/<tool>/` convention
4. **Selective installation** — `stow git` installs just git, `stow zsh git tmux` installs all
5. **Platform-agnostic packages** — conditionals inside packages, not separate platform dirs

## Sources

### Official Documentation & Guides
- [GNU Stow Manual - Types and Syntax of Ignore Lists](https://www.gnu.org/software/stow/manual/html_node/Types-And-Syntax-Of-Ignore-Lists.html)
- [Using GNU Stow to manage your dotfiles](https://gist.github.com/andreibosco/cb8506780d0942a712fc)
- [How I manage my dotfiles using GNU Stow](https://tamerlan.dev/how-i-manage-my-dotfiles-using-gnu-stow/)
- [Managing Dotfiles with GNU Stow](https://medium.com/quick-programming/managing-dotfiles-with-gnu-stow-9b04c155ebad)

### Architecture & Best Practices
- [Using GNU Stow to Manage Symbolic Links for Your Dotfiles - System Crafters](https://systemcrafters.net/managing-your-dotfiles/using-gnu-stow/)
- [Managing dotfiles with GNU Stow | Bastian Venthur's Blog](https://venthur.de/2021-12-19-managing-dotfiles-with-stow.html)
- [How I manage dotfiles with Stow - Bytes & Bobs](https://bytesandbobs.net/how-i-manage-dotfiles/)
- [My Dotfiles Setup with GNU Stow | Christopher Penkin](https://www.penkin.me/development/tools/productivity/configuration/2025/10/20/my-dotfiles-setup-with-gnu-stow.html)

### Cross-Platform Approaches
- [Cross-platform dotfile Management with dotbot | Brian Schiller](https://brianschiller.com/blog/2024/08/05/cross-platform-dotbot/)
- [Managing dotfiles with chezmoi](https://stoddart.github.io/2024/09/08/managing-dotfiles-with-chezmoi.html)
- [GitHub - RaphGL/Tuckr: Super powered replacement for GNU Stow](https://github.com/RaphGL/Tuckr)

### Real-World Examples
- [GitHub - numToStr/dotfiles: Includes configs for neovim, tmux, zsh, alacrity, kitty, and more | Managed by GNU stow](https://github.com/numToStr/dotfiles)
- [GitHub - thoughtbot/dotfiles: A set of vim, zsh, git, and tmux configuration files](https://github.com/thoughtbot/dotfiles)
- [Dotfiles Inspiration - dotfiles.github.io](https://dotfiles.github.io/inspiration/)

### Installation Orchestration
- [Dotfiles with make](https://www.matheusmoreira.com/articles/managing-dotfiles-with-make)
- [Makefile for your dotfiles - Blog](https://polothy.github.io/post/2018-10-09-makefile-dotfiles/)
- [Bootstrap repositories - dotfiles.github.io](https://dotfiles.github.io/bootstrap/)

### Complexity & Anti-Patterns
- [Manage Your Dotfiles Like a Superhero](https://www.jakewiesler.com/blog/managing-dotfiles)
- [The Ultimate Guide to Mastering Dotfiles](https://www.daytona.io/dotfiles/ultimate-guide-to-dotfiles)
- [GitHub - citypaul/.dotfiles: My dotfiles](https://github.com/citypaul/.dotfiles) (Critical/High/Nice/Skip classification)

---

*Architecture research for: Minimal cross-platform dotfiles management*
*Researched: 2026-02-13*
*Confidence: HIGH (verified with official docs, multiple real-world examples, community best practices)*
