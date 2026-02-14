# Project Research Summary

**Project:** Minimal Dotfiles Simplification
**Domain:** Cross-platform dotfiles management
**Researched:** 2026-02-13
**Confidence:** HIGH

## Executive Summary

This project simplifies a bloated multi-tool dotfiles repository down to just zsh, neovim, tmux, and git configurations using GNU Stow for symlink management. Research shows the current structure is over-modularized with 7 top-level directories (runcom/, system/, config/, bin/, install/, macos/, test/) and 25+ shell configuration files, creating unnecessary complexity. The recommended approach consolidates to 4-5 Stow packages (zsh/, git/, tmux/, nvim/) with platform-specific logic embedded via conditional sourcing, reducing the complexity score from 7/10 to 2/10 while maintaining full macOS, Linux, and WSL2 support.

The canonical pattern is package-per-tool organization where each directory mirrors home directory structure exactly. GNU Stow is the industry standard - simpler and more maintainable than alternatives like chezmoi or yadm. For shell configuration, zcomet provides minimal plugin management without the 1000ms+ startup penalty of Oh My Zsh. Neovim should use kickstart.nvim as a starting point rather than full distributions like LazyVim. All tools should respect XDG Base Directory specification, placing configs in ~/.config/ rather than cluttering home directory.

Critical risks include breaking shell startup order when removing bash support (mitigated by testing non-interactive shells and proper .zshenv vs .zshrc separation), Stow conflicts from existing files not cleaned up (requires explicit removal before stowing), and platform detection removal breaking cross-platform compatibility (test on all three platforms before considering complete). The simplification must preserve git history using `git log --follow` and document all deletions in REMOVED.md to maintain institutional knowledge.

## Key Findings

### Recommended Stack

The minimal stack focuses on battle-tested, cross-platform tools that "just work" without framework overhead. GNU Stow (2.4+) handles symlink management with zero dependencies beyond Perl and works identically across all platforms. Homebrew (4.x) provides unified package management for macOS and Linux since the 2019 Linuxbrew merge. A Makefile orchestrates installation with platform detection, keeping complexity under 50 lines by delegating complex logic to shell scripts.

**Core technologies:**
- **GNU Stow 2.4+**: Symlink farm manager - Industry standard, simple, battle-tested, no dependencies. Explicitly avoid chezmoi (template complexity overkill) and yadm (clever but non-standard bare git approach).
- **Zsh 5.9+**: Primary shell - Modern, POSIX-compliant, cross-platform. Focus on zsh-only eliminates bash complexity. Use zcomet for plugin management, not Oh My Zsh (2000+ files, slow startup, obscures config).
- **Neovim 0.10+**: Text editor - Current stable with native LSP and Lua config. Use kickstart.nvim as starting point, not LazyVim/NvChad distributions that obscure configuration.
- **Tmux 3.5+**: Terminal multiplexer - Standard for session management with stable config format and modern features.
- **Git 2.47+**: Version control - Track dotfiles with recent credential manager improvements for cross-platform use.
- **Homebrew 4.x**: Package manager - Single Brewfile works cross-platform (except casks). Official Linux support since 2019.

**Supporting tools via Homebrew:**
- fzf, ripgrep, fd, bat, zoxide, delta, eza - Modern CLI replacements installed from Brewfile

**Version strategy:**
- Homebrew, Git, supporting tools: Use latest stable (evergreen)
- Neovim: Stick with stable releases (0.10.x), avoid nightly
- Zsh plugins: Pin to stable tags/commits for reproducibility

### Expected Features

The feature landscape reveals significant over-modularization in current implementation. Research shows minimal dotfiles need 5 core files per tool maximum, not 25+ shell snippets. Table stakes include shell prompt customization, command history, tab completion, git aliases, and symlink management. Differentiators include platform detection (macOS/Linux/WSL), XDG Base Directory compliance, fast startup (<100ms), and idempotent installation.

**Must have (table stakes):**
- Shell configuration (zsh with minimal plugins) - Core workflow
- Git configuration with aliases - Development workflow
- Tmux configuration with basic keybindings - Terminal multiplexing
- Makefile installation with platform detection - One-command setup
- Symlink automation with GNU Stow - Safe deployment
- PATH management and command history - Productivity basics
- Package installation automation - Brewfile/apt lists

**Should have (competitive):**
- Platform detection (macOS/Linux/WSL) - Single repo works everywhere
- XDG Base Directory compliance - Clean home directory
- Fast plugin management with lazy loading - Shell startup <100ms
- Idempotent installation - Can re-run make install safely
- Automated backup before symlink - Safety net prevents data loss
- CI testing on GitHub Actions - Confidence in fresh installs

**Defer (v2+):**
- PowerShell configuration for Windows - WSL covers Windows use case
- Advanced tmux plugins/themes - Current config works, avoid complexity
- Starship prompt - Zim provides good prompt without extra dependency
- Secrets templating - Current .exports pattern works, avoid over-engineering
- Multi-machine config variants - Platform detection handles most cases

**Anti-features to explicitly avoid:**
- Oh My Zsh with 50+ plugins - 1000ms+ startup, 90% unused features
- Neovim as full IDE (50+ plugins) - Slow startup, maintenance nightmare
- Multi-branch per machine - Merge conflicts, hard to share common changes
- Auto-updating dotfiles - Breaks workflows unexpectedly
- Complex custom symlink scripts - Fragile, doesn't handle edge cases

### Architecture Approach

The canonical Stow-based structure uses package-per-tool organization where directory structure inside each package mirrors exactly where files live in $HOME. This enables selective installation (install only git configs on servers) and clear boundaries. The current repository's separation of runcom/ and system/ directories is an anti-pattern - both are zsh configs and should be unified. Platform-specific differences should be handled via conditional sourcing within packages (aliases-darwin.zsh, aliases-linux.zsh) rather than separate top-level platform directories.

**Recommended final structure:**
```
dotfiles/
├── zsh/              # .zshrc, .zshenv, .config/zsh/
├── git/              # .config/git/
├── tmux/             # .config/tmux/
├── nvim/             # .config/nvim/ (optional)
├── bin/              # Utility scripts (not stowed)
├── bootstrap/        # Brewfile, aptfile (not stowed)
├── scripts/          # install-deps.sh (not stowed)
├── .stow-local-ignore
├── Makefile
└── README.md
```

**Major components:**
1. **Stow packages** (zsh/, nvim/, git/, tmux/) - Store configs mirroring home directory, isolated by design
2. **Installation orchestrator** (Makefile) - Detect platform, install dependencies, invoke stow
3. **Platform conditionals** - Handle OS-specific differences within packages via case statements
4. **.stow-local-ignore** - Define what Stow should skip (bin/, bootstrap/, scripts/, Makefile)

**Key architectural patterns:**
- Package-based organization for modularity and selective installation
- Platform-specific files within packages (not separate platform directories)
- Makefile orchestration under 50 lines, delegating complex logic to shell scripts
- Maximum 5 files per tool (not 25+ micro-files) - aliases.zsh, functions.zsh, env.zsh, completion.zsh, platform overrides

**Critical anti-patterns to avoid:**
- Over-modularization: 15+ tiny shell files (.alias, .alias.git, .alias.docker, etc.)
- Separate runcom/ and system/ directories - artificial separation requiring complex sourcing
- Platform separation at top level - duplicates common configs
- Makefile complexity >50 lines - use shell scripts for complex logic
- Using `stow */` blindly - be explicit about packages

### Critical Pitfalls

Research identified 7 critical pitfalls specific to dotfiles simplification, each with phase-specific prevention strategies. The most dangerous is breaking shell startup order when removing bash support - zsh has 5 startup files (.zshenv, .zprofile, .zshrc, .zlogin, .zlogout) with different sourcing contexts, and misplacing PATH or environment variables causes commands to work in interactive terminals but fail in scripts/cronjobs. Second most critical is Stow conflicts from existing files not cleaned up - GNU Stow won't overwrite existing files, causing silent failures where new configs aren't actually used.

1. **Breaking shell startup order** - Place PATH in .zshenv (all invocations), aliases in .zshrc (interactive only). Test both interactive (`zsh -ic`) and non-interactive (`zsh -c`) shells. Update tmux default-command if hardcoded to bash.

2. **Stow conflicts from existing files** - Explicitly remove files being deleted before running stow. Create migration script that backs up to ~/.dotfiles-backup-$(date +%s)/, runs `stow -nv */` to preview conflicts, removes only deleted files. Don't use `stow */` blindly - list packages explicitly.

3. **Platform detection removal breaking compatibility** - Replace bin/is-macos scripts with inline shell checks using `case "$(uname -s)"`. Test on ALL platforms (macOS Intel, macOS ARM, Linux, WSL) before considering complete. Document which platforms are supported vs stretch goals.

4. **Git history loss** - Document deletions in REMOVED.md before deleting files. Use `git log --follow` to verify history preserved on moved files. Add .mailmap if contributor emails changed. Consider squash-merging to keep main clean while preserving branch history.

5. **Sourcing order circular dependencies** - Map dependencies before consolidating (e.g., .zshrc sources .alias which uses functions from .function). Test incremental loading with `zsh -x`. Keep .zshenv minimal (PATH only), move everything else to .zshrc. Never source .zshrc from .zshenv.

6. **Makefile not idempotent** - Make all targets idempotent using `brew list pkg || brew install pkg` pattern. Use .PHONY correctly. Add dry-run mode (`make check`). Test re-running on same system multiple times. Document cleanup with `make clean`.

7. **Secrets accidentally committed** - Audit for secrets BEFORE simplification: `grep -r "API_KEY|SECRET|TOKEN|PASSWORD"`. Use .env.template pattern with gitignored .local files. Update .gitignore before moving files. Use `git diff --cached` before every commit. Consider git-secrets pre-commit hooks.

## Implications for Roadmap

Based on research findings, the simplification should follow a 6-phase approach that minimizes risk by testing incrementally and handling the most impactful changes first. Shell migration comes first because it eliminates bash support and consolidates the most complex part (25+ files to 5 files). Stow migration follows to establish the new package structure. Cross-platform cleanup ensures all platforms work before declaring victory. The order is designed to avoid dependencies and allow rollback at each stage.

### Phase 1: Shell Consolidation & Bash Removal
**Rationale:** Highest impact (eliminates 25+ files), highest risk (shell startup order). Must come first because other phases depend on working shell config.

**Delivers:** Single unified zsh package (zsh/.zshrc, zsh/.zshenv, zsh/.config/zsh/{aliases,functions,env,completion}.zsh) replacing runcom/ and system/ directories.

**Addresses:**
- Over-modularization anti-pattern (25+ files to 5)
- Shell startup order pitfall via proper .zshenv vs .zshrc separation
- Sourcing order circular dependencies via dependency mapping

**Avoids:**
- Breaking non-interactive shells (test `zsh -c` and `zsh -ic`)
- PATH duplication or wrong order
- Tmux still launching bash

**Research needed:** Standard pattern, skip research-phase

### Phase 2: Stow Package Migration
**Rationale:** Establishes canonical package-per-tool structure after shell consolidation. Requires working shell from Phase 1.

**Delivers:**
- git/, tmux/, (optionally nvim/) packages in XDG-compliant structure
- .stow-local-ignore configured to skip non-stowed directories
- Migration script with backup and conflict detection

**Uses:**
- GNU Stow 2.4+ for symlink management
- XDG Base Directory paths (~/.config/)

**Implements:** Package-based organization architecture pattern

**Avoids:**
- Stow conflicts via explicit file removal and backup
- Silent failures via `stow -nv` dry-run first
- Overwriting customizations via backup mechanism

**Research needed:** Standard pattern, skip research-phase

### Phase 3: Platform Detection Consolidation
**Rationale:** Simplifies platform handling after package structure established. Lower risk because shell and stow already working.

**Delivers:**
- Inline platform detection in .zshrc (replace bin/is-macos scripts)
- Platform-specific files within packages (aliases-darwin.zsh, aliases-linux.zsh)
- Makefile with native Make conditionals for platform detection

**Addresses:**
- Platform detection removal pitfall via inline checks
- Homebrew path differences (Intel vs ARM vs Linux)
- Cross-platform compatibility verification

**Avoids:**
- Hardcoded paths breaking on other platforms
- Missing platform-specific configs

**Research needed:** Standard pattern, skip research-phase

### Phase 4: Makefile Simplification
**Rationale:** Simplifies installation after core structure complete. Can safely refactor because manual stow commands work.

**Delivers:**
- Simplified Makefile under 50 lines
- Idempotent targets (can re-run safely)
- Shell scripts for complex dependency installation
- Dry-run mode (make check) and cleanup (make clean)

**Addresses:**
- Makefile idempotency pitfall via proper checks
- Installation complexity

**Avoids:**
- Errors on re-run via `|| true` and pre-flight checks
- Make syntax complexity via delegation to shell scripts

**Research needed:** Standard pattern, skip research-phase

### Phase 5: CI Testing Setup
**Rationale:** Validates all platforms work before declaring complete. Deferred until structure stable to avoid test churn.

**Delivers:**
- GitHub Actions workflow testing on Ubuntu and macOS
- Weekly scheduled tests on fresh installs
- Test script validating configs loaded correctly

**Addresses:**
- Cross-platform confidence gap
- Regression prevention

**Avoids:**
- Silent breakage on other platforms
- Installation failures on fresh systems

**Research needed:** May need GitHub Actions research for matrix builds

### Phase 6: Documentation & Cleanup
**Rationale:** Final polish after all functionality working. Updates README to reflect new structure and creates historical record.

**Delivers:**
- Updated README with new structure explanation
- REMOVED.md documenting all deleted files and rationale
- Installation instructions per platform
- Contributing guide for adding new tools

**Addresses:**
- Git history loss mitigation via documentation
- Onboarding for new users
- Institutional knowledge preservation

**Research needed:** None (documentation phase)

### Phase Ordering Rationale

- **Shell first** because it's the most complex and highest risk. Everything else depends on working shell.
- **Stow second** to establish package structure while shell config is fresh in mind.
- **Platform detection third** because it's lower risk and builds on established packages.
- **Makefile fourth** because manual stow commands work if automation breaks.
- **CI fifth** to validate all platforms after structure is stable.
- **Documentation last** to capture final state accurately.

Each phase is independently testable and reversible. Phases don't have hard dependencies (can skip CI or Makefile if desired). Platform-specific testing happens in Phase 3, not deferred to end.

### Research Flags

**Phases with standard patterns (skip research-phase):**
- **Phase 1:** Shell consolidation - well-documented zsh startup patterns
- **Phase 2:** Stow migration - canonical GNU Stow usage
- **Phase 3:** Platform detection - standard uname checks
- **Phase 4:** Makefile - established idempotency patterns
- **Phase 6:** Documentation - no technical research needed

**Phases possibly needing deeper research:**
- **Phase 5 (CI Testing):** May need GitHub Actions matrix build research if complex cross-platform testing required. Likely standard pattern, but flag for review during planning.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All recommendations verified with official docs (Stow manual, Homebrew docs, kickstart.nvim maintained by Neovim core). Versions checked against current releases. |
| Features | MEDIUM | Based on community consensus across multiple sources (dotfiles.github.io, awesome-dotfiles, multiple blog posts). Table stakes vs differentiators aligned with real-world examples. |
| Architecture | HIGH | GNU Stow patterns verified with official manual and multiple authoritative guides. Package-per-tool structure validated by thoughtbot/dotfiles and numToStr/dotfiles examples. Anti-patterns identified from multiple sources. |
| Pitfalls | MEDIUM | Based on web research, community patterns, and current codebase inspection. Shell startup order and Stow conflicts are well-documented. Platform-specific issues verified from cross-platform guides. Some pitfalls inferred from common mistakes. |

**Overall confidence:** HIGH

The stack and architecture recommendations have very high confidence - they're based on official documentation and established best practices with 10+ years of community validation. Feature prioritization has medium confidence but is well-informed by analyzing competitor repos and community consensus. Pitfall identification has medium confidence because it's specific to this project's context (removing bash, consolidating structure) but draws from documented migration issues and common mistakes.

### Gaps to Address

**Phase ordering validation:** Research suggests the proposed 6-phase order but doesn't validate dependencies empirically. During planning, verify that Stow migration (Phase 2) doesn't actually need platform detection (Phase 3) to work correctly on Linux/macOS differences.

**Neovim decision point:** Research assumes adding Neovim config but current repo doesn't have it. During Phase 2 planning, confirm whether to add nvim package or skip entirely. If skipping, adjust phase scope.

**Windows/PowerShell boundary:** Research clearly recommends WSL for Windows users and deferring native PowerShell to v2+, but current repo has some Windows considerations. During Phase 3 planning, explicitly decide cutoff - is WSL full support or stretch goal?

**Testing depth for CI:** Phase 5 flags CI testing but research doesn't specify test assertions beyond "configs loaded correctly." During Phase 5 planning, define specific validation: shell startup time, PATH contents, key aliases work, git config applied?

**XDG migration timing:** Research strongly recommends XDG Base Directory compliance but doesn't specify which phase. Could be Phase 2 (during Stow migration) or separate phase. Clarify during Phase 2 planning whether to migrate all tools to ~/.config/ or do incrementally.

## Sources

### PRIMARY (HIGH confidence)
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html) - Official behavior, ignore file syntax
- [Homebrew Official Docs](https://brew.sh/) - Cross-platform confirmation, Linux support since 2019
- [kickstart.nvim GitHub](https://github.com/nvim-lua/kickstart.nvim) - Neovim core team maintained starter
- [lazy.nvim GitHub](https://github.com/folke/lazy.nvim) - v11.17.5 stable confirmed
- [XDG Base Directory Spec (ArchWiki)](https://wiki.archlinux.org/title/XDG_Base_Directory) - Standard reference

### SECONDARY (MEDIUM confidence)
- [dotfiles.github.io](https://dotfiles.github.io/) - Community patterns and examples
- [awesome-dotfiles GitHub](https://github.com/webpro/awesome-dotfiles) - Curated resources
- [System Crafters - GNU Stow Guide](https://systemcrafters.net/managing-your-dotfiles/using-gnu-stow/) - Established patterns
- [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles) - Real-world minimal example
- [numToStr/dotfiles](https://github.com/numToStr/dotfiles) - Stow-based multi-tool example
- [Daytona Ultimate Guide to Dotfiles](https://www.daytona.io/dotfiles/ultimate-guide-to-dotfiles) - 2025/2026 best practices
- Multiple shell migration guides (bash to zsh) - Community consensus on startup order pitfalls
- [ArchWiki Dotfiles](https://wiki.archlinux.org/title/Dotfiles) - Platform differences and best practices

### TERTIARY (LOW confidence)
- Various blog posts on zsh plugin managers - Community rankings, needs validation against benchmarks
- Cross-platform dotfile management discussions - Patterns identified but not exhaustively tested
- Makefile idempotency patterns - Inferred from multiple sources, not single authoritative guide

---
*Research completed: 2026-02-13*
*Ready for roadmap: yes*
