# Feature Research

**Domain:** Minimal Dotfiles Management
**Researched:** 2026-02-13
**Confidence:** MEDIUM

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = dotfiles feel incomplete or broken.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Shell prompt customization | Users expect personalized, informative prompts with git status, path, etc. | LOW | Built into most frameworks (oh-my-zsh, zim, starship) |
| Command history | Users need searchable command history across sessions | LOW | Basic zsh config, increase HISTSIZE to 50000+ |
| Tab completion | Essential for productivity, users expect smart completions | LOW | Zsh built-in, enable completions in .zshrc |
| Git aliases | Speed up git workflow significantly, universal expectation | LOW | ~/.config/git/config or .gitconfig |
| Directory shortcuts (aliases) | Quick navigation to common directories | LOW | Shell aliases for cd commands |
| Cross-shell compatibility (.bashrc, .zshrc) | Users switch between bash and zsh, expect both to work | MEDIUM | Maintain both, source common files |
| Symlink management | Users need easy way to deploy dotfiles without manual copying | MEDIUM | GNU Stow, dotbot, or bare repo method |
| Package installation automation | One-command install of all tools (brew/apt) | MEDIUM | Makefile with platform detection, Brewfile/apt lists |
| PATH management | Consistent PATH across shells and platforms | LOW | Set in .zshenv for zsh, .bash_profile for bash |
| Basic editor config (.editorconfig, .vimrc) | Consistent editing experience across projects | LOW | EditorConfig for project consistency |

### Differentiators (Competitive Advantage)

Features that set dotfiles apart. Not required, but valuable for productivity.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Platform detection (macOS/Linux/WSL) | Single dotfiles repo works everywhere, automatic adaptation | MEDIUM | Use `uname` checks, separate make targets |
| Automated backup before symlink | Safety net when deploying, prevents data loss | LOW | Check existing files, add .bak extension |
| Fast plugin management (lazy loading) | Shell startup time under 100ms vs 1000ms+ with naive configs | MEDIUM | Use lazy.nvim for neovim, zim for zsh (not oh-my-zsh) |
| XDG Base Directory compliance | Clean home directory, organized configs in ~/.config | MEDIUM | Neovim, git support XDG; some tools need env vars |
| Idempotent installation | Can re-run `make install` safely, useful for updates | MEDIUM | Make targets check before installing |
| CI testing on real systems | Confidence configs work on fresh installs | HIGH | GitHub Actions weekly tests on Ubuntu/macOS |
| Minimal plugin count (under 10 for neovim) | Fast, understandable, maintainable | LOW | Resist plugin bloat, use built-in features first |
| Shell function library | Reusable functions for common tasks across projects | LOW | Source from system/ directory |
| Context-aware aliases | Different aliases per OS (e.g., `ls` vs `gls` on macOS) | MEDIUM | Platform-specific sourcing |
| Documentation of choices | Comments explaining why config exists, aids maintenance | LOW | Inline comments in configs |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Oh My Zsh with 50+ plugins | "Everyone uses it", feature-rich | Shell startup 1000ms+, bloated, 90% unused features | Zim (fast, modular) or vanilla zsh with 5-10 plugins |
| Custom plugin manager scripts | Control and understanding | Reinventing wheel, maintenance burden, bugs | Use established tools: lazy.nvim, zim, stow |
| Neovim as full IDE (50+ plugins) | Feature parity with VSCode | Slow startup, config complexity, maintenance nightmare | Keep under 10 plugins, use LSP built-ins, supplement with VSCode |
| Automatic secrets in dotfiles | Convenience, single source | Public repos expose tokens, hard to separate | Use separate .exports file, add to .gitignore, template pattern |
| Multi-branch per machine | Different configs per machine in git branches | Merge conflicts, maintenance, hard to share common changes | Single branch, use platform detection and conditional loading |
| Complex symlink scripts | Custom control over linking | Fragile, doesn't handle edge cases, breaks on updates | GNU Stow (ubiquitous, battle-tested) |
| All configs in version control | Track everything | Home directory pollution in git status, secrets exposure | Only track config files, use bare repo or stow |
| Framework lock-in (Prezto, Oh My Zsh) | Easy setup | Hard to understand what's happening, performance overhead | Minimal vanilla configs with clear comments |
| Auto-updating dotfiles | Always latest features | Breaks workflows unexpectedly, needs review before pulling | Manual updates with `dot update`, review before apply |
| Windows/PowerShell native support | Cross-platform completeness | Completely different paradigm, doubles maintenance | Focus on WSL2, PowerShell is stretch goal only |

## Feature Dependencies

```
Package Installation Automation
    └──requires──> Platform Detection
                       └──requires──> Makefile with OS detection

Symlink Management
    └──requires──> Backup Mechanism
    └──requires──> GNU Stow (or equivalent)

Fast Plugin Management
    └──requires──> Lazy Loading Configuration
                       └──requires──> Plugin Manager (zim, lazy.nvim)

XDG Base Directory Compliance
    └──requires──> Environment Variables ($XDG_CONFIG_HOME)
    └──conflicts──> Legacy dotfile locations in ~/

Cross-Shell Compatibility
    └──requires──> Shared function library
    └──requires──> Shell detection in scripts

CI Testing
    └──requires──> GitHub Actions setup
    └──requires──> Test scripts
    └──enhances──> Confidence in all features
```

### Dependency Notes

- **Package Installation requires Platform Detection:** Cannot install correct packages without knowing if system uses apt, brew, or other package managers
- **Symlink Management requires Backup:** Must backup existing configs before overwriting to prevent data loss
- **Fast Plugin Management requires Lazy Loading:** Loading all plugins at shell start = slow; lazy load on first use
- **XDG compliance conflicts with legacy locations:** Cannot have both ~/.vimrc and ~/.config/nvim without confusion
- **CI Testing enhances all features:** Validates everything works on fresh installs, prevents regressions

## MVP Definition

### Launch With (v1)

Minimum viable dotfiles — what's needed for productive daily use.

- [x] Shell configuration (zsh with zim framework) — Core workflow
- [x] Git configuration with essential aliases — Development workflow
- [x] Tmux configuration with basic keybindings — Terminal multiplexing
- [x] Makefile installation (brew for macOS, apt for Linux) — One-command setup
- [x] Platform detection (macOS/Linux/WSL) — Single repo, multiple systems
- [x] Symlink automation with GNU Stow — Safe deployment
- [x] Shell aliases for common commands — Productivity
- [x] Command history configuration — Searchable past commands
- [x] PATH management — Tool availability

### Add After Validation (v1.x)

Features to add once core is working and tested.

- [ ] Neovim minimal configuration (under 10 plugins) — Trigger: need in-terminal editing beyond nano
- [ ] XDG Base Directory compliance — Trigger: home directory clutter becomes annoying
- [ ] Automated backup before symlink — Trigger: first data loss scare or user request
- [ ] CI testing on GitHub Actions — Trigger: before sharing publicly or after first cross-platform bug
- [ ] Shell function library — Trigger: repeating same script patterns across projects
- [ ] Idempotent installation — Trigger: need to re-run after initial setup

### Future Consideration (v2+)

Features to defer until dotfiles are proven and stable.

- [ ] PowerShell configuration for Windows — Why defer: stretch goal, WSL covers Windows use case
- [ ] Advanced tmux configuration (plugins, themes) — Why defer: current config works, avoid complexity
- [ ] Starship prompt — Why defer: zim provides good prompt, starship adds dependency
- [ ] Automated secrets management (templating) — Why defer: current .exports pattern works, avoid over-engineering
- [ ] Multi-machine config variants — Why defer: platform detection handles most cases, YAGNI

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Shell configuration (zsh) | HIGH | LOW | P1 |
| Git aliases | HIGH | LOW | P1 |
| Makefile installation | HIGH | MEDIUM | P1 |
| Platform detection | HIGH | MEDIUM | P1 |
| Symlink automation | HIGH | MEDIUM | P1 |
| Shell aliases | HIGH | LOW | P1 |
| Command history | HIGH | LOW | P1 |
| Tmux configuration | MEDIUM | LOW | P1 |
| PATH management | HIGH | LOW | P1 |
| Neovim minimal config | MEDIUM | MEDIUM | P2 |
| XDG compliance | MEDIUM | MEDIUM | P2 |
| Automated backup | HIGH | LOW | P2 |
| CI testing | MEDIUM | HIGH | P2 |
| Shell function library | MEDIUM | LOW | P2 |
| Idempotent installation | MEDIUM | MEDIUM | P2 |
| PowerShell config | LOW | HIGH | P3 |
| Advanced tmux | LOW | MEDIUM | P3 |
| Starship prompt | LOW | MEDIUM | P3 |
| Secrets templating | MEDIUM | HIGH | P3 |

**Priority key:**
- P1: Must have for launch (current state of repo)
- P2: Should have, add when refining
- P3: Nice to have, future consideration

## Competitor Feature Analysis

Analysis of popular minimal dotfiles repositories in 2026.

| Feature | thoughtbot/dotfiles | holman/dotfiles | mathiasbynens/dotfiles | Our Approach |
|---------|---------------------|-----------------|------------------------|--------------|
| Plugin framework | None (vanilla) | Custom topics | Oh My Zsh | Zim (fast, minimal) |
| Installation | rcup (custom) | Rake | Bootstrap script | Makefile (ubiquitous) |
| Symlink management | rcm | Custom script | Bootstrap script | GNU Stow |
| Platform support | macOS/Linux | macOS primary | macOS only | macOS/Linux/WSL |
| Neovim config | Minimal | None | None | Minimal (under 10 plugins) |
| Testing | None | None | None | GitHub Actions CI |
| Organization | By tool | By topic | By type | By tool (clearer) |

**Key differentiators of our approach:**
- **Makefile over custom scripts:** Make is ubiquitous, no additional tooling needed
- **Zim over Oh My Zsh:** 10x faster startup, modular, still user-friendly
- **GNU Stow over custom:** Battle-tested, handles edge cases, widely documented
- **CI testing:** Confidence in fresh installs, rare in dotfiles repos
- **WSL support:** Modern Windows development reality

## Sources

**Dotfiles Best Practices:**
- [GitHub does dotfiles - dotfiles.github.io](https://dotfiles.github.io/)
- [GitHub - webpro/awesome-dotfiles](https://github.com/webpro/awesome-dotfiles)
- [How to Store Dotfiles - Atlassian Git Tutorial](https://www.atlassian.com/git/tutorials/dotfiles)
- [The Ultimate Guide to Mastering Dotfiles](https://www.daytona.io/dotfiles/ultimate-guide-to-dotfiles)
- [dotfiles - ArchWiki](https://wiki.archlinux.org/title/Dotfiles)

**Zsh Configuration:**
- [Shell Configuration · Zsh Mac · 2026](https://mac.install.guide/terminal/configuration)
- [You probably don't need Oh My Zsh](https://rushter.com/blog/zsh-shell/)
- [The best minimal zsh configuration](https://felipec.wordpress.com/2025/01/20/zsh-min/)
- [My Updated ZSH Config 2025](https://scottspence.com/posts/my-updated-zsh-config-2025)
- [10 Zsh Tips & Tricks](https://www.sitepoint.com/zsh-tips-tricks/)

**Neovim Minimal Setup:**
- [Minimal Neovim setup from scratch](https://www.khuedoan.com/posts/minimal-neovim-setup-from-scratch)
- [Minimal Neovim config v0.12 edition](https://vieitesss.github.io/posts/Neovim-new-config/)
- [A Flexible Minimalist Neovim for 2024](https://wickstrom.tech/2024-08-12-a-flexible-minimalist-neovim.html)
- [GitHub - NvChad/tinyvim](https://github.com/NvChad/tinyvim)
- [Simple Neovim config](https://vonheikemen.github.io/devlog/tools/simple-neovim-config/)

**Tmux Configuration:**
- [Getting Started · tmux/tmux Wiki](https://github.com/tmux/tmux/wiki/Getting-Started)
- [Make tmux Pretty and Usable](https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/)
- [tmux Configuration Guide](https://tmux.info/docs/configuration)
- [How to use tmux in 2026](https://www.hostinger.com/tutorials/how-to-use-tmux)

**Git Configuration:**
- [Git - Git Aliases](https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases)
- [Git Alias | Atlassian Git Tutorial](https://www.atlassian.com/git/tutorials/git-alias)
- [10 git aliases for faster and productive git workflow](https://snyk.io/blog/10-git-aliases-for-faster-and-productive-git-workflow/)

**Shell Aliases:**
- [30 Handy Bash Shell Aliases](https://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html)
- [20 Essential Linux Aliases - 2026](https://www.linuxoperatingsystem.net/20-essential-linux-aliases/)
- [Boost Productivity with Custom Command Shortcuts](https://www.linuxjournal.com/content/boost-productivity-custom-command-shortcuts-using-linux-aliases)

**Dotfiles Complexity & Anti-Patterns:**
- [Dotfiles were a mistake](https://hiphish.github.io/blog/2020/08/30/dotfiles-were-a-mistake/)
- [Dotfiles: Stop the Madness!](https://pub.gajendra.net/2012/09/dotfiles)
- [Which Dotfiles Should You Commit to Git](https://blog.openreplay.com/dotfiles-commit-ignore/)

**Cross-Platform Dotfiles:**
- [Cross-platform dotfile Management with dotbot](https://brianschiller.com/blog/2024/08/05/cross-platform-dotbot/)
- [GitHub - Shemnei/punktf - Cross-platform multi-target dotfiles manager](https://github.com/Shemnei/punktf)
- [Cross-Platform Dotfiles – Calvin Bui](https://calvin.me/cross-platform-dotfiles/)

**Makefile Installation Patterns:**
- [GitHub - masasam/dotfiles - Makefile based](https://github.com/masasam/dotfiles)
- [Makefile for your dotfiles](https://polothy.github.io/post/2018-10-09-makefile-dotfiles/)
- [Using GNU Make as your Dotfiles manager](https://www.estacouveflor.com/dotfiles-configuration/)
- [Dotfiles with make](https://www.matheusmoreira.com/articles/managing-dotfiles-with-make)

---
*Feature research for: Minimal Dotfiles Management*
*Researched: 2026-02-13*
