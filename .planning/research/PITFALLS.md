# Pitfalls Research: Dotfiles Simplification

**Domain:** Dotfiles Repository Simplification
**Researched:** 2026-02-13
**Confidence:** MEDIUM

## Critical Pitfalls

### Pitfall 1: Breaking Shell Startup Order When Removing Bash Support

**What goes wrong:**

When migrating from dual bash/zsh support to zsh-only, environment variables and PATH entries that were in `.bash_profile` or `.bashrc` may be lost or placed in the wrong zsh startup file. Zsh uses a different startup sequence than bash, and misplacing configuration can cause:
- Commands not found because PATH not set in non-interactive shells
- Environment variables unavailable to GUI applications or scripts
- tmux sessions still launching bash instead of zsh

**Why it happens:**

Bash uses `.bash_profile` (login shells) and `.bashrc` (interactive), while zsh has 5 startup files (`.zshenv`, `.zprofile`, `.zshrc`, `.zlogin`, `.zlogout`), each sourced at different times. Developers often dump everything into `.zshrc`, which is only sourced for interactive shells.

**How to avoid:**

- Place critical environment variables (PATH, XDG_*, etc.) in `.zshenv` (sourced on all invocations)
- Place aliases, functions, key bindings in `.zshrc` (interactive only)
- Update tmux `default-command` if it has hardcoded bash
- Test both interactive and non-interactive shells: `zsh -c 'echo $PATH'` vs interactive session

**Warning signs:**

- Scripts fail with "command not found" but commands work in terminal
- Cronjobs or non-interactive scripts break after migration
- tmux still launches bash sessions despite changing default shell
- GUI apps can't find commands in PATH

**Phase to address:**

Phase 1 (Shell Migration) - Must verify startup file sourcing order before removing bash files

---

### Pitfall 2: Stow Conflicts from Existing Files Not Cleaned Up

**What goes wrong:**

GNU Stow refuses to create symlinks if files already exist at the target location. When simplifying dotfiles, old config files that are being removed from the repo still exist in `$HOME`, causing stow to fail with "existing target is not a link" errors. The simplification appears to succeed in git, but the actual system continues using old configuration.

**Why it happens:**

Stow is conservative - it won't overwrite existing files. During simplification, files removed from the repo aren't automatically removed from `$HOME`. The Makefile's `stow */` command succeeds for new configs but silently skips conflicts.

**How to avoid:**

1. Before running stow, explicitly remove files being deleted:
   ```bash
   # Document what's being removed
   rm ~/.bashrc ~/.bash_profile
   rm ~/.config/alacritty  # if removing alacritty support
   ```

2. Use `stow --adopt` carefully (it overwrites repo files with system files - dangerous)

3. Create a migration script that:
   - Backs up conflicting files to `~/.dotfiles-backup-$(date +%s)/`
   - Lists what would conflict: `stow -nv */` (dry run)
   - Removes only files being deleted in this simplification

4. Don't use `stow */` blindly - be explicit about packages being stowed

**Warning signs:**

- Stow command completes without errors but configs don't change
- Running `ls -la ~/ | grep -v "^l"` shows regular files where symlinks expected
- Old aliases/functions still work despite being deleted from repo
- `stow -nv */` shows "WARNING: not replacing"

**Phase to address:**

Phase 2 (Stow Migration) - Must audit existing files before stowing

---

### Pitfall 3: Platform Detection Removal Breaking Multi-Platform Compatibility

**What goes wrong:**

When removing OS detection scripts (like `bin/is-macos`, `bin/is-wsl`), the Makefile and shell configs that depend on platform-specific behavior break. Installing on macOS tries to use Linux paths, or vice versa. Homebrew paths become incorrect (`/usr/local` on Apple Silicon, `/opt/homebrew` on Intel Mac, `/home/linuxbrew/.linuxbrew` on Linux).

**Why it happens:**

Existing dotfiles use conditional loading:
```bash
# In Makefile
OS := $(shell bin/is-supported bin/is-macos macos linux)
HOMEBREW_PREFIX := $(shell bin/is-supported bin/is-macos ...)

# In shell configs
[ "$(uname)" = "Darwin" ] && source .alias.macos
```

Removing these scripts without replacing the logic causes hardcoded paths or missing platform-specific configs.

**How to avoid:**

1. Replace script-based detection with inline shell checks:
   ```bash
   # Instead of bin/is-macos
   case "$(uname -s)" in
     Darwin*) export HOMEBREW_PREFIX=/opt/homebrew ;;
     Linux*)  export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew ;;
   esac
   ```

2. For Makefile, use built-in Make conditionals:
   ```makefile
   UNAME_S := $(shell uname -s)
   ifeq ($(UNAME_S),Darwin)
       HOMEBREW_PREFIX := /opt/homebrew
   else
       HOMEBREW_PREFIX := /home/linuxbrew/.linuxbrew
   endif
   ```

3. Test on ALL target platforms (macOS Intel, macOS ARM, Linux, WSL) before considering it done

4. Document which platforms are still supported vs stretch goals

**Warning signs:**

- Makefile fails with "command not found" on different platforms
- Homebrew paths point to non-existent directories
- Platform-specific aliases/functions missing on some systems
- Installation works on dev machine but fails on fresh macOS/Linux

**Phase to address:**

Phase 3 (Cross-Platform Cleanup) - Must verify on each platform after removal

---

### Pitfall 4: Git History Loss from Improper File Deletion/Reorganization

**What goes wrong:**

When simplifying by deleting files or reorganizing directory structure, git history becomes fragmented. `git log -- <file>` stops at the rename/move point. Git blame shows wrong authors. Contributors lose credit. Historical context for why configs existed is lost.

**Why it happens:**

Default `git mv` and `git rm` don't preserve history across renames. Git's rename detection works during `log`/`blame`, but only if invoked with `--follow` or `-C`. Many developers don't know this. Deleting files without documenting why loses tribal knowledge.

**How to avoid:**

1. Before deleting files, document their purpose:
   ```bash
   # Create REMOVED.md listing deleted files and why
   echo "## system/.java - Java-specific PATH setup" >> REMOVED.md
   echo "Removed: 2026-02-13. Reason: No longer using Java" >> REMOVED.md
   ```

2. For moves/renames, use `git log --follow <file>` to verify history preserved

3. For splits (one file -> multiple), use:
   ```bash
   # Preserve blame with -C flag
   git log -C --follow <new-file>
   ```

4. Add `.mailmap` if contributors' emails changed over time

5. Consider squash-merging feature branches to keep main branch clean but preserve branch history

**Warning signs:**

- `git log -- <file>` only shows recent commits
- Contributors missing from `git shortlog`
- Can't find why a config option was added
- Blame shows wrong author for old code

**Phase to address:**

All phases - Document deletions as they happen; create REMOVED.md in Phase 1

---

### Pitfall 5: Sourcing Order Dependencies Create Circular Loads

**What goes wrong:**

When consolidating shell configs, file A sources file B which sources file C which references a function from file A. Shell startup hangs, loops infinitely, or variables are undefined. Common with:
- `.zshenv` setting `$ZDOTDIR`, but `$ZDOTDIR/.zshenv` also getting sourced
- Functions calling other functions defined later
- PATH additions spread across multiple files sourced in wrong order

**Why it happens:**

Modular dotfiles split configs into many files (`.alias`, `.function`, `.path`, `.env`) and source them manually. During simplification, the sourcing order gets changed without understanding dependencies. Zsh sources `.zshenv` globally, and if it's symlinked wrong, gets sourced twice.

**How to avoid:**

1. Map dependencies before consolidating:
   ```
   .zshenv (must be first - sets $PATH)
     -> .path (adds to $PATH)
     -> .env (uses commands from $PATH)
   .zshrc (interactive)
     -> .alias (uses functions from .function)
     -> .function (standalone)
   ```

2. Test incremental loading:
   ```bash
   zsh -x  # Shows every line executed
   zsh -l  # Login shell
   zsh -i  # Interactive
   ```

3. Consolidate carefully:
   - Keep `.zshenv` minimal (PATH only)
   - Move everything else to `.zshrc`
   - Source order in `.zshrc` matters: env vars -> functions -> aliases

4. Avoid sourcing `.zshrc` from `.zshenv` (common mistake)

**Warning signs:**

- Shell startup takes >2 seconds
- Variables undefined despite being set
- "function not found" for functions that exist
- `echo $PATH` shows duplicates or wrong order
- Login shells behave differently than interactive

**Phase to address:**

Phase 1 (Shell Migration) - Test shell startup thoroughly before committing

---

### Pitfall 6: Makefile Idempotency Assumptions Fail on Re-runs

**What goes wrong:**

Running `make install` twice causes errors: packages already installed, symlinks already exist, files overwritten. The Makefile assumes fresh system but users re-run after fixing errors. Installations fail halfway, leave system in broken state, can't retry without manual cleanup.

**Why it happens:**

Make targets aren't idempotent. Common issues:
```makefile
brew install pkg  # Fails if pkg already installed
ln -s src dest    # Fails if dest exists
stow pkg          # Fails on conflicts
```

Dotfiles Makefiles often lack proper dependency tracking because they're not compiling code - they're system configuration.

**How to avoid:**

1. Make all targets idempotent:
   ```makefile
   brew install pkg || true  # Don't fail if exists
   brew list pkg &>/dev/null || brew install pkg  # Check first
   ln -sf src dest  # Force symlink (dangerous, test first)
   ```

2. Use `.PHONY` correctly:
   ```makefile
   .PHONY: install link packages
   # These aren't files, always run
   ```

3. Add dry-run mode:
   ```makefile
   check:
       @echo "Would install: ..."
       @stow -nv */
   ```

4. Document cleanup:
   ```makefile
   clean:
       stow -D */  # Unlink everything
       # List what would be uninstalled
   ```

5. Test re-running on same system multiple times

**Warning signs:**

- Second `make install` fails with "already exists"
- Partial installation leaves system broken
- Manual cleanup required between runs
- Errors don't clearly indicate how to recover
- No way to uninstall/rollback

**Phase to address:**

Phase 4 (Makefile Refactoring) - Test re-runs before considering complete

---

### Pitfall 7: Sensitive Data Accidentally Committed During Cleanup

**What goes wrong:**

When consolidating configs, `.env` files with secrets (API keys, tokens, credentials) get committed to the public repo. During simplification, developers merge previously separate files, and `.gitignore` patterns don't catch the new structure. Historical commits expose secrets even after deletion.

**Why it happens:**

Old structure might have:
```
system/.env      # Committed, generic
system/.env.local  # Gitignored, secrets
```

New simplified structure:
```
zsh/.zshenv  # Accidentally includes secrets from old .env.local
```

Developers forget to check git diff before committing bulk changes.

**How to avoid:**

1. Before simplification, audit for secrets:
   ```bash
   grep -r "API_KEY\|SECRET\|TOKEN\|PASSWORD" system/ runcom/
   git log -p | grep -i "password\|secret\|token"
   ```

2. Use a `.env.template` pattern:
   ```bash
   # .zshenv (committed)
   source ~/.zshenv.local  # Load secrets from gitignored file

   # .zshenv.local (gitignored, documented in README)
   export API_KEY="your_key_here"
   ```

3. Update `.gitignore` BEFORE moving files:
   ```gitignore
   **/.env.local
   **/.secrets
   **/zsh/.zshenv.local
   ```

4. Use `git diff --cached` before every commit

5. Consider using git-secrets or gitleaks pre-commit hooks

**Warning signs:**

- `.gitignore` not updated after restructuring
- Files with "local" or "secret" in name are tracked
- grep finds API keys or tokens in tracked files
- Old structure had separate secret files, new structure doesn't

**Phase to address:**

Phase 0 (Pre-flight) - Audit and protect secrets before any refactoring

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hardcoding `$HOME` paths instead of using variables | Simpler configs, no variable expansion | Breaks when testing with different user or paths | Never - always use `$HOME`, `$XDG_CONFIG_HOME` |
| Using `ln -sf` to force overwrite conflicts | Installation "just works" | Silently overwrites customizations, hard to debug what broke | Only in documented "nuke and pave" scripts |
| Combining all shell configs into single `.zshrc` | Fewer files, simpler structure | Can't selectively load, harder to debug, slower startup | Acceptable for <200 lines; beyond that, modularize |
| Skipping testing on other platforms | Faster development on primary machine | Silent breakage for other users/platforms | Only if explicitly single-platform (document this!) |
| Removing all comments during cleanup | Cleaner looking code | Lost context on why configs exist, newcomers confused | Never - comments explain the why, not the what |
| Using `stow */` for everything | One command to rule them all | Installs packages not wanted on this machine | Only for truly universal dotfiles; otherwise list explicitly |

## Integration Gotchas

Common mistakes when connecting to external services.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Homebrew paths | Hardcoding `/usr/local` (wrong on Apple Silicon) | Detect: `$(brew --prefix)` or check uname/arch |
| tmux + shell | Not updating tmux `default-shell` when removing bash | Set `set -g default-shell /bin/zsh` in tmux.conf |
| GNU Stow | Assuming `stow */` works universally | Explicitly list packages: `stow zsh git tmux` or handle .git conflicts |
| Neovim config location | Mixing `~/.vimrc` and `~/.config/nvim/init.lua` | XDG-compliant: use `$XDG_CONFIG_HOME/nvim/` only |
| Git config | Global `~/.gitconfig` vs XDG `~/.config/git/config` | Prefer XDG; document which is authoritative |
| Shell completions | Installing to wrong directory for different shells | Bash: `/usr/local/etc/bash_completion.d/`, Zsh: fpath |

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Sourcing large files on every shell startup | Shell startup >2 seconds, terminal feels sluggish | Lazy load: `alias vim='load_vim_env; vim'` or use zsh-defer | >500 lines in startup files |
| Running expensive commands in $PROMPT | Prompt lag after every command | Cache results, use async prompts (starship, powerlevel10k) | Git status in large repos |
| Adding too many entries to $PATH | Slow command execution | Keep PATH minimal, use version managers that modify PATH on-demand | >20 directories in PATH |
| Loading all completions eagerly | 1-2 second delay on first tab-complete | Use `compinit -C` or lazy load completions | >100 completion scripts |
| Deep symbolic link chains | File access slower, confusing errors | Stow to `~` directly, avoid stow-in-stow-in-stow | >3 levels of symlinks |

## Security Mistakes

Domain-specific security issues beyond general web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Committing SSH keys or GPG keys to dotfiles repo | Keys exposed publicly, compromised accounts | Use `ssh-keygen` on each machine; never commit `~/.ssh/` |
| Exposing sensitive ENV vars in public repo | API keys leaked, services compromised | Use `.local` files (gitignored), document in README template |
| World-readable files with secrets | Other users on shared systems can read | `chmod 600 ~/.zshenv.local ~/.ssh/config` |
| Syncing browser profiles with credentials | Passwords in plaintext in git | Never track `~/Library/Application Support/`, use separate password manager |
| Including work-specific configs in personal dotfiles | Proprietary info leaked | Separate repos: `dotfiles` (public) vs `dotfiles-work` (private) |

## UX Pitfalls

Common user experience mistakes in this domain.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| No installation instructions for different platforms | Users give up, can't install | Document `make install` for macOS/Linux/WSL separately |
| Silent failures in Makefile | Installation appears successful but broken | Add `set -e` to shell scripts, check exit codes, print success/failure |
| No dry-run mode | Fear of running install, might break system | Add `make check` that shows what would change without changing it |
| No uninstall/rollback option | Can't test safely, permanent changes | Add `make unlink` and document how to restore from backup |
| Requiring manual edits to Makefile | Users forget, installation fails | Use environment variables: `HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"` |
| No example configs for `.local` files | Users don't know what to put in gitignored files | Include `.zshenv.local.example` with placeholders |

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **Shell migration:** Tested non-interactive shells (`zsh -c 'echo $PATH'`), not just interactive
- [ ] **Stow setup:** Verified no conflicts on fresh system, not just on existing setup
- [ ] **Cross-platform:** Actually tested on macOS AND Linux, not just developed on one
- [ ] **Makefile:** Re-run `make install` on same system, verify idempotency
- [ ] **Git history:** Ran `git log --follow` on moved files, verified history preserved
- [ ] **Secrets:** Grepped for `API_KEY|TOKEN|PASSWORD`, verified nothing committed
- [ ] **Documentation:** README has install instructions for each platform, not generic
- [ ] **Cleanup:** Created REMOVED.md documenting deleted files and why
- [ ] **Rollback:** Tested `make unlink`, verified system reverts cleanly
- [ ] **Startup performance:** Measured shell startup time (`time zsh -ic exit`), under 500ms

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Committed secrets to git | HIGH | 1. `git filter-branch` to remove from history, 2. Rotate all exposed credentials, 3. Force push (if not public yet) or document breach |
| Lost git history on moved files | LOW | Use `git log --follow --all -- <file>` to find old history, document in comments |
| Broke shell startup (can't login) | MEDIUM | Boot recovery mode or SSH, `mv ~/.zshrc ~/.zshrc.broken`, restore from backup |
| Stow conflicts left system broken | LOW | `stow -D */` to unlink all, restore original dotfiles from `~/.dotfiles-backup/` |
| Platform detection broken | MEDIUM | Hardcode paths temporarily, fix detection logic, test on broken platform |
| Circular source dependencies hang shell | LOW | Comment out sources in `.zshrc`, relaunch shell, fix order, uncomment incrementally |
| Makefile not idempotent | LOW | Add `|| true` to failing commands, use pre-flight checks (`brew list pkg || install`) |

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Shell startup order breaking | Phase 1: Shell Migration | Test interactive + non-interactive + login shells |
| Stow conflicts from old files | Phase 2: Stow Migration | Run `stow -nv */`, verify no warnings |
| Platform detection removal breaking | Phase 3: Cross-Platform Cleanup | Test on macOS, Linux, WSL |
| Git history loss | All phases | Run `git log --follow` on moved files |
| Sourcing order circular dependencies | Phase 1: Shell Migration | `zsh -x` to trace execution, verify no loops |
| Makefile not idempotent | Phase 4: Makefile Refactoring | Run `make install` twice, verify success both times |
| Secrets committed | Phase 0: Pre-flight Audit | `git diff --cached` before every commit, grep for secrets |

## Sources

**HIGH confidence (official docs, established patterns):**
- [Shell Startup Sequence Explained](https://rickcogley.github.io/dotfiles/explanations/shell-startup.html) - Authoritative sourcing order
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html) - Official behavior documentation
- [Managing Dotfiles with GNU Stow](https://systemcrafters.net/managing-your-dotfiles/using-gnu-stow/) - Common patterns

**MEDIUM confidence (community tutorials, established practices):**
- [Migrating from bash to zsh](https://shuheikagawa.com/blog/2019/10/08/migrating-from-bash-to-zsh/) - Migration gotchas
- [The right way to migrate your bash_profile to zsh](https://carlosroso.com/the-right-way-to-migrate-your-bash-profile-to-zsh/) - File structure differences
- [How I manage my dotfiles using GNU Stow](https://tamerlan.dev/how-i-manage-my-dotfiles-using-gnu-stow/) - Stow conflicts and patterns
- [Cross-platform dotfile Management with dotbot](https://brianschiller.com/blog/2024/08/05/cross-platform-dotbot/) - Platform-specific symlink issues
- [Makefile for your dotfiles](https://polothy.github.io/post/2018-10-09-makefile-dotfiles/) - Idempotency patterns
- [Dotfiles were a mistake](https://hiphish.github.io/blog/2020/08/30/dotfiles-were-a-mistake/) - Critical perspective on complexity

**MEDIUM confidence (multiple sources agree):**
- [Atlassian Git Tutorial - Dotfiles](https://www.atlassian.com/git/tutorials/dotfiles) - Bare git repo patterns
- [ArchWiki - Dotfiles](https://wiki.archlinux.org/title/Dotfiles) - Platform differences and best practices
- [ZSH dotfiles management pitfalls - Fedora Discussion](https://discussion.fedoraproject.org/t/zsh-dotfiles-how-to-manage-integration-of-variables-paths-from-bash-pitfalls/46765) - Real-world migration issues

---

*Pitfalls research for: Dotfiles Simplification*
*Researched: 2026-02-13*
*Confidence: MEDIUM - Based on web research, community patterns, and codebase inspection. Specific to this project's context (removing bash, macOS defaults, OS detection).*
