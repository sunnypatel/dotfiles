# Stack Research: Minimal Dotfiles Management

**Domain:** Dotfiles management and shell configuration
**Researched:** 2026-02-13
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| **GNU Stow** | 2.4.x+ | Symlink farm manager | Industry standard for dotfiles. Simple, battle-tested, no dependencies beyond Perl. Works identically on macOS, Linux, and WSL. Stow is "trusted classic" that handles symlinking with minimal overhead. |
| **Zsh** | 5.9+ | Primary shell | Modern, POSIX-compliant shell with powerful completion and customization. Cross-platform (macOS default since Catalina, available on all Linux). Focus on zsh-only simplifies codebase significantly. |
| **Neovim** | 0.10+ | Text editor | Current stable with native LSP, Treesitter, and Lua config. Lightweight, extensible, cross-platform. v0.10+ has stabilized modern features. |
| **Tmux** | 3.5+ | Terminal multiplexer | Standard for terminal session management. Cross-platform, stable config format. v3.5+ has modern features without breaking changes. |
| **Git** | 2.47+ | Version control | Track dotfiles, sync across machines. 2.47+ includes recent credential manager improvements for cross-platform use. |
| **Homebrew** | 4.x | Package manager | Official Linux support since 2019 merge. Works on macOS (Intel/Apple Silicon), Linux, and WSL2. Single Brewfile works cross-platform (except casks). |

### Shell Plugin Management

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| **zcomet** | latest (git stable) | Zsh plugin manager | Minimal, fast startup without caching complexity. No bloat, simple config, lazy-loading support. Benchmarks show it's as fast as zgenom but simpler to understand. More maintainable than Oh My Zsh. |

**Alternative:** Manual plugin sourcing (for ultra-minimal approach) or zgenom (if startup time cache is priority).

**DO NOT USE:** Oh My Zsh - Heavy framework with 100+ plugins you won't use. Slow startup. Obscures what's happening in your shell config. Conflicts with "every file should be immediately understandable" goal.

### Neovim Configuration Approach

| Approach | Version | Purpose | Why Recommended |
|----------|---------|---------|-----------------|
| **kickstart.nvim** | latest (fork-based) | Starting point | Single-file (~1000 line) documented config. Fork it, customize it, understand it. Uses lazy.nvim for plugin management. Maintained by Neovim core team. NOT a distribution - it's a starting point you own. |
| **lazy.nvim** | v11.17.5 (stable) | Neovim plugin manager | Modern, fast, lazy-loading by default. Industry standard in 2025/2026. Powers kickstart.nvim, LazyVim, and most modern configs. |

**Alternative:** Build from scratch with pure Lua + lazy.nvim if you want complete control.

**DO NOT USE:** LazyVim, NvChad, AstroNvim - Full distributions that obscure configuration. You don't learn what's happening. Hard to debug. Conflicts with "immediately understandable" requirement.

### Installation & Automation

| Tool | Purpose | Why Recommended |
|------|---------|-----------------|
| **Makefile** | Installation orchestration | Simple, ubiquitous, no runtime dependencies. POSIX make available everywhere. Better than bash script sprawl. |
| **POSIX shell utilities** | OS detection, helper scripts | Maximum portability. Works on macOS, Linux, WSL without bash-isms. |

**Alternative:** Simple bash scripts (if you're bash-only and don't need strict POSIX portability).

**DO NOT USE:**
- **chezmoi** - Template system adds complexity. Overkill for "every file should be immediately understandable." Secrets management not needed for public dotfiles. Use Stow's simplicity instead.
- **yadm** - Bare git repository approach is clever but non-standard. Harder for others to understand. Stow is more explicit.
- **Ansible** - Way overkill for personal dotfiles. Adds YAML complexity and learning curve.

### Cross-Platform Support

| Platform | Strategy | Tools |
|----------|----------|-------|
| **macOS** | Primary platform | Homebrew (/opt/homebrew or /usr/local), native Zsh |
| **Linux** | Full support | Homebrew (/home/linuxbrew/.linuxbrew), Zsh via package manager |
| **WSL2** | Full support | Treat as Linux + WSL detection for paths. Homebrew or APT. |
| **Windows/PowerShell** | Stretch goal only | Low priority. Fundamentally different environment. |

**WSL Detection:**
```bash
#!/usr/bin/env bash
# bin/is-wsl
if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
  exit 0
fi
exit 1
```

### Supporting Tools

| Tool | Purpose | Installation Method |
|------|---------|---------------------|
| **fzf** | Fuzzy finder | Homebrew + shell integration |
| **ripgrep** | Fast grep replacement | Homebrew |
| **fd** | Fast find replacement | Homebrew |
| **bat** | Syntax-highlighted cat | Homebrew |
| **zoxide** | Smart directory jumping | Homebrew + shell init |
| **delta** | Git diff pager | Homebrew + git config |
| **eza** | Modern ls replacement | Homebrew |

## Installation Pattern

```bash
# Core installation flow
make [platform]  # macos, linux, or wsl
  ↓
install-core     # Install package managers, core utilities
  ↓
install-packages # Brewfile for cross-platform, apt-packages for Linux-specific
  ↓
link             # Stow to symlink dotfiles
  ↓
configure-shell  # Set Zsh as default, source .zshrc
```

## Alternatives Considered

| Category | Recommended | Alternative | When to Use Alternative |
|----------|-------------|-------------|-------------------------|
| **Dotfile manager** | GNU Stow | chezmoi | Multiple machines with different configs (home/work), secrets in dotfiles, heavy templating needs |
| **Dotfile manager** | GNU Stow | yadm | Prefer bare git repo approach, want built-in encryption |
| **Zsh plugin manager** | zcomet | zgenom | Startup time is critical (zgenom caches aggressively) |
| **Zsh plugin manager** | zcomet | Manual sourcing | Ultra-minimal (<5 plugins), want zero abstraction |
| **Neovim config** | kickstart.nvim | From-scratch Lua | Deep Neovim expertise, want complete control |
| **Neovim config** | kickstart.nvim | LazyVim | Want full-featured IDE out-of-box, okay with abstraction |
| **Package manager** | Homebrew | APT-only (Linux) | Linux-only environment, no macOS compatibility needed |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| **Oh My Zsh** | Bloated framework (2000+ files), slow startup, obscures shell config, hard to understand what's happening | zcomet with explicit plugin choices |
| **Prezto** | Similar to OMZ, framework overhead, declining maintenance | zcomet or manual plugin management |
| **Bash** | Requirement is zsh-only. Bash has weaker completion, older syntax. Removing bash simplifies codebase. | Zsh exclusively |
| **vim (not Neovim)** | Neovim has superior Lua config, native LSP, Treesitter, async. Active development. Vim is maintenance mode. | Neovim 0.10+ |
| **Vundle/vim-plug (for Neovim)** | Vimscript-era plugin managers. Slower, less features than lazy.nvim. | lazy.nvim |
| **YADM** | Clever but non-standard bare git approach. Harder to understand, debug, fork. | GNU Stow |
| **rcm** | Thoughtbot's dotfile manager. Less active development. Stow is simpler. | GNU Stow |
| **Dotbot** | Python-based, YAML config adds layer of abstraction. Stow is more direct. | GNU Stow |

## Stack Patterns by Variant

### Minimal (Recommended Starting Point)
**When:** New to dotfiles, want simplicity, learning-focused
- GNU Stow for symlinks
- Makefile with macos/linux/wsl targets
- Zsh with 3-5 carefully chosen plugins via zcomet
- kickstart.nvim (fork it, customize it)
- Tmux with minimal .tmux.conf (no plugins)
- Homebrew Brewfile for packages

**Complexity:** Low
**Maintenance:** Very low
**Startup time:** Fast (<100ms shell)

### Intermediate (Power User)
**When:** Established workflow, want optimizations, comfortable with Lua
- Everything from Minimal, plus:
- Zcomet with 10-15 plugins, lazy-loaded
- kickstart.nvim expanded into modular lua/ directory
- Tmux Plugin Manager (TPM) with 3-5 plugins
- Git delta, fzf, zoxide integrations

**Complexity:** Medium
**Maintenance:** Medium
**Startup time:** Still fast (<150ms shell)

### Advanced (Not Recommended for "Minimal" Goal)
**When:** Multi-machine with divergent configs, secrets management needed
- chezmoi instead of Stow (templating, encryption)
- LazyVim instead of kickstart (full IDE experience)
- Ansible for system configuration

**Complexity:** High
**Maintenance:** High
**Startup time:** Variable

## Version Compatibility

| Package | Minimum | Recommended | Notes |
|---------|---------|-------------|-------|
| Neovim | 0.10.0 | 0.10.x stable | kickstart requires 0.10+. Avoid nightly for stability. |
| Zsh | 5.8 | 5.9+ | 5.9 includes completion improvements. macOS includes 5.9+. |
| Tmux | 3.0 | 3.5+ | 3.5 includes extended keys, OSC 52 clipboard improvements. |
| lazy.nvim | 11.0 | 11.17.5 (latest stable) | Use stable branch, not main. |
| Homebrew | 4.0 | 4.x latest | Auto-updates itself. No manual version management. |
| Git | 2.40 | 2.47+ | 2.47+ has improved credential helpers, better cross-platform. |

**Note on Versions:**
- Homebrew and most tools: Use latest stable. They're designed to be evergreen.
- Neovim: Stick with stable releases (x.10.x). Nightly is for plugin developers.
- Zsh plugins via zcomet: Pin to stable tags or commits for reproducibility.

## XDG Base Directory Compliance

Modern dotfiles should respect XDG Base Directory Specification:

```bash
# system/.env
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
```

**XDG-Compliant Paths:**
- Neovim: `~/.config/nvim/` (native)
- Tmux: `~/.config/tmux/tmux.conf` (3.1+)
- Zsh: `~/.config/zsh/.zshrc` (via ZDOTDIR)
- Git: `~/.config/git/config` (native)

**Legacy Paths to Avoid:**
- `~/.vim/` → Use `~/.config/nvim/`
- `~/.tmux.conf` → Use `~/.config/tmux/tmux.conf`
- `~/.zshrc` → Use `$ZDOTDIR/.zshrc` where ZDOTDIR=~/.config/zsh

**Confidence:** HIGH - XDG is well-established standard (2003), wide adoption in 2025/2026.

## Sources

### HIGH Confidence (Official Documentation & Releases)
- [lazy.nvim GitHub](https://github.com/folke/lazy.nvim) - v11.17.5 current stable (verified 2026-02-13)
- [chezmoi Documentation](https://www.chezmoi.io/) - v2.69.4 latest release
- [kickstart.nvim GitHub](https://github.com/nvim-lua/kickstart.nvim) - Official Neovim core maintained starter
- [Homebrew Official](https://brew.sh/) - Cross-platform macOS/Linux since 2019 Linuxbrew merge
- [zcomet Documentation](https://zcomet.io/) - Minimal zsh plugin manager
- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) - De facto standard for tmux plugins
- [XDG Base Directory Spec (ArchWiki)](https://wiki.archlinux.org/title/XDG_Base_Directory) - Current standard reference

### MEDIUM Confidence (Community Consensus, Multiple Sources)
- [Dotfiles Best Practices (daytona.io)](https://www.daytona.io/dotfiles/ultimate-guide-to-dotfiles) - 2025/2026 guide
- [awesome-dotfiles GitHub](https://github.com/webpro/awesome-dotfiles) - Curated community resources
- [dotfiles.github.io](https://dotfiles.github.io/) - Community examples and utilities
- [Exploring Dotfile Tools (GBergatto)](https://gbergatto.github.io/posts/tools-managing-dotfiles/) - Comparison of Stow, chezmoi, YADM
- [chezmoi vs GNU Stow Discussion](https://www.saashub.com/compare-gnu-stow-vs-chezmoi) - Feature comparison
- [Homebrew on Linux 2025 Discussion](https://github.com/orgs/Homebrew/discussions/5964) - Community feedback on Linux usage
- [Slant: Best Zsh Plugin Managers](https://www.slant.co/topics/3265/~best-plugin-managers-for-zsh) - Community rankings

### MEDIUM Confidence (Cross-Platform Strategy)
- [Cross-platform dotfiles examples](https://github.com/fatso83/dotfiles) - macOS, Linux, WSL2 shared dotfiles
- [Homebrew Linux Documentation](https://docs.brew.sh/Homebrew-on-Linux) - Official Linux support guide

### Verification Notes
- **Versions verified:** lazy.nvim (GitHub releases), chezmoi (official site), Homebrew (active support confirmed)
- **XDG paths:** Multiple sources confirm tmux 3.1+, git, neovim native XDG support
- **Zsh plugin managers:** Multiple 2025/2026 sources recommend zcomet, zgenom, or manual over Oh My Zsh
- **Stow vs alternatives:** Consistent recommendation: Stow for simplicity, chezmoi for complexity/templates
- **kickstart.nvim:** Maintained by Neovim core team (highest trust level for "official" starter config)

---

*Stack research for: Minimal Dotfiles Repository*
*Researched: 2026-02-13*
*Confidence: HIGH - All core recommendations verified with official docs or multiple authoritative sources*
