# Dotfiles Simplification

## What This Is

A personal dotfiles repo that manages zsh, neovim, tmux, and git configurations across macOS, Linux, and Windows. Stripped down from a bloated multi-tool setup to just the essentials — easy to read, easy to maintain.

## Core Value

Every file in this repo should be immediately understandable. If you can't tell what something does in 10 seconds, it doesn't belong here.

## Requirements

### Validated

<!-- Existing capabilities confirmed worth keeping. -->

- ✓ Cross-platform OS detection (macOS, Linux, WSL) — existing
- ✓ Makefile-based installation — existing
- ✓ GNU Stow symlink management — existing
- ✓ Git configuration with aliases — existing
- ✓ Shell aliases for productivity — existing
- ✓ Homebrew/APT package installation — existing
- ✓ GitHub Actions CI testing — existing

### Active

<!-- Current scope. Building toward these. -->

- [ ] Zsh as sole shell — remove all bash-specific config, single .zshrc entry point
- [ ] Neovim config — lightweight distro or clean from-scratch Lua config
- [ ] Tmux config — bring in existing personal config
- [ ] Simplified git config — keep aliases and core settings, remove unused tooling config
- [ ] Curated shell aliases — keep useful ones, remove the rest
- [ ] Minimal Brewfile — only install zsh, neovim, tmux, git, and direct dependencies
- [ ] Simplified Makefile — clear targets for macOS, Linux, with minimal branching
- [ ] Remove all unused tools — thefuck, topgrade, zoxide, fzf, delta, nvm, cargo, bun, etc.
- [ ] Remove bash config — .bash_profile, .bashrc, bash prompt, bash-specific env
- [ ] Remove unused shell functions — network functions, file utilities, etc.
- [ ] Clean directory structure — minimal directories, obvious naming
- [ ] Windows/PowerShell support — PowerShell profile, Windows Terminal config (stretch goal)

### Out of Scope

<!-- Explicit boundaries. Includes reasoning to prevent re-adding. -->

- Bash support — zsh only, simplifies everything
- Node.js/NVM management — not a dotfiles concern
- Rust/Cargo management — not a dotfiles concern
- Python tooling — not a dotfiles concern
- Custom shell prompt framework — keep it simple, use a lightweight zsh prompt
- Alacritty/terminal emulator config — manage separately
- macOS defaults scripts — too fragile across versions, manage manually
- Homebrew cask apps — install GUI apps manually
- VS Code extensions management — VS Code handles this via sync
- Remote install script — complexity not worth it for personal use

## Context

**Current state:** The repo has ~60+ files across 8 directories. It supports bash and zsh, installs dozens of tools via Brewfile/npmfile/Rustfile, manages macOS system defaults, and has complex platform detection logic. Most of it isn't understood or actively used.

**Brownfield approach:** Strip down iteratively from the current codebase. Keep git history. Remove files and simplify what remains rather than rebuilding from scratch.

**Existing codebase map:** `.planning/codebase/` has full analysis of current architecture, structure, conventions, and concerns.

**Neovim:** User wants a lightweight distro (like kickstart.nvim or mini.nvim) or a clean from-scratch config. Not a heavy distro like LazyVim/NvChad.

**Tmux:** User has an existing tmux config to bring in.

**Windows:** Full PowerShell dev setup is desired but lowest priority. Mac and Linux are primary targets.

## Constraints

- **Approach**: Strip down existing repo, not rebuild — keep git history
- **Shell**: Zsh only — no bash compatibility layer needed
- **Platforms**: macOS + Linux primary, Windows/PowerShell stretch goal
- **Simplicity**: Every file must be self-explanatory — no clever abstractions
- **Installation**: Makefile with brew/apt — no additional package manager dependencies

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Zsh only, drop bash | Eliminates dual-shell complexity | — Pending |
| Strip down vs rebuild | Preserves git history, iterative approach | — Pending |
| Neovim over vim | Modern, Lua config, better plugin ecosystem | — Pending |
| Keep Stow for symlinks | Already works, no reason to change | — Pending |
| Windows as stretch goal | Lowest priority, different config surface entirely | — Pending |

---
*Last updated: 2026-02-13 after initialization*
