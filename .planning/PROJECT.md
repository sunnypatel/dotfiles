# Dotfiles Simplification

## What This Is

A personal dotfiles repo that manages zsh, neovim, tmux, and git configurations across macOS, Linux, and WSL2. Uses GNU Stow for symlink management with XDG-compliant paths. Stripped down from a bloated 60+ file multi-tool setup to ~30 focused config files.

## Core Value

Every file in this repo should be immediately understandable. If you can't tell what something does in 10 seconds, it doesn't belong here.

## Requirements

### Validated

- ✓ SHL-01: Zsh sole shell with single .zshrc entry point — v1.0
- ✓ SHL-02: Curated shell aliases for productivity — v1.0
- ✓ SHL-03: Shell functions limited to commonly used utilities — v1.0
- ✓ SHL-04: Tab completion via Zim framework (not Oh My Zsh) — v1.0
- ✓ SHL-05: Command history with deduplication — v1.0
- ✓ SHL-06: Clean shell prompt via Zim — v1.0
- ✓ SHL-07: PATH management with platform-aware paths — v1.0
- ✓ GIT-01: Git config with curated aliases — v1.0
- ✓ GIT-02: Core git settings (nvim editor, nvimdiff merge) — v1.0
- ✓ GIT-03: Global gitignore patterns — v1.0
- ✓ TMX-01: Full gpakosz/.tmux config at XDG path — v1.0
- ✓ TMX-02: Tmux config at ~/.config/tmux/ — v1.0
- ✓ NVM-01: Lightweight Lua neovim config from scratch — v1.0
- ✓ NVM-02: Plugins via lazy.nvim (LSP, treesitter, telescope) — v1.0
- ✓ INS-01: Makefile-based install for macOS and Linux — v1.0
- ✓ INS-02: Minimal Brewfile with 8 essential packages — v1.0
- ✓ INS-03: GNU Stow with package-per-tool structure — v1.0
- ✓ INS-04: Idempotent installation — v1.0
- ✓ PLT-01: macOS support (Intel and Apple Silicon) — v1.0
- ✓ PLT-02: Linux support (Ubuntu/Debian) — v1.0
- ✓ PLT-03: WSL2 detection and support — v1.0
- ✓ STR-01: Package-per-tool layout (zsh/, git/, tmux/, nvim/) — v1.0
- ✓ STR-02: XDG Base Directory compliance — v1.0
- ✓ STR-03: Every file self-explanatory — v1.0
- ✓ CLN-01: Bash config removed — v1.0
- ✓ CLN-02: Unused tools config removed — v1.0
- ✓ CLN-03: Unused shell functions removed — v1.0
- ✓ CLN-04: macOS defaults scripts removed — v1.0
- ✓ CLN-05: Remote install script removed — v1.0
- ✓ CLN-06: Language package managers removed — v1.0
- ✓ QAL-01: GitHub Actions CI on Ubuntu and macOS — v1.0
- ✓ QAL-02: Automated fresh-install validation — v1.0

### Active

- [ ] WIN-01: PowerShell profile for Windows development
- [ ] WIN-02: Windows Terminal configuration
- [ ] WIN-03: Native Windows tool installation (winget/scoop)

### Out of Scope

- Bash support — zsh only, simplifies everything
- Node.js/NVM management — not a dotfiles concern
- Rust/Cargo management — not a dotfiles concern
- Python tooling — not a dotfiles concern
- Custom shell prompt framework — keep it simple, Zim handles this
- Alacritty/terminal emulator config — manage separately
- macOS defaults scripts — too fragile across versions, manage manually
- Homebrew cask apps — install GUI apps manually
- VS Code extensions management — VS Code handles this via sync
- Remote install script — complexity not worth it for personal use
- Oh My Zsh — 2000+ files, 1000ms+ startup, obscures config
- Heavy neovim distros (LazyVim, NvChad) — defeats simplification goal
- Auto-updating dotfiles — breaks workflows unexpectedly

## Context

**Shipped v1.0** with ~3,555 lines across shell, git, tmux, neovim configs, CI, tests, and docs.

**Tech stack:** Zsh + Zim framework, GNU Stow, lazy.nvim, gpakosz/.tmux, Homebrew, GitHub Actions + BATS.

**Structure:** 4 Stow packages under `stow/` (zsh, git, tmux, nvim), Makefile installer, BATS test suite, Docker-based CI.

**Remaining work:** Windows/PowerShell support is the only active requirement set. Everything else shipped in v1.0.

## Constraints

- **Shell**: Zsh only — no bash compatibility layer needed
- **Platforms**: macOS + Linux primary, Windows/PowerShell stretch goal
- **Simplicity**: Every file must be self-explanatory — no clever abstractions
- **Installation**: Makefile with brew/apt — no additional package manager dependencies
- **Structure**: Package-per-tool under stow/ with XDG compliance

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Zsh only, drop bash | Eliminates dual-shell complexity | ✓ Good — removed all bash config, single shell to maintain |
| Strip down vs rebuild | Preserves git history, iterative approach | ✓ Good — 6 phases of iterative cleanup worked well |
| Neovim over vim | Modern, Lua config, better plugin ecosystem | ✓ Good — lazy.nvim + LSP via mason |
| Keep Stow for symlinks | Already works, no reason to change | ✓ Good — 4 packages, clean structure |
| Windows as stretch goal | Lowest priority, different config surface | — Pending (deferred to v2) |
| Zim over Oh My Zsh | Lightweight, fast startup, modular | ✓ Good — shell starts in <100ms |
| ZDOTDIR for XDG compliance | Enables ~/.config/zsh/ location | ✓ Good — clean home directory |
| Inline platform detection | Eliminates bin/is-* scripts, self-contained | ✓ Good — uname-based, no dependencies |
| Packages under stow/ dir | Self-documenting, no .stow-local-ignore needed | ✓ Good — obvious structure |
| Docker for CI Ubuntu tests | Consistent environment, no host pollution | ✓ Good — reproducible testing |

---
*Last updated: 2026-02-14 after v1.0 milestone*
