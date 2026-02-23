---
status: investigating
trigger: "zimfw-compinit-warning"
created: "2024-07-25T19:42:01Z"
updated: "2024-07-25T19:52:00Z"
---

## Current Focus

hypothesis: The `nvm.sh` script, sourced from `.zsh_path`, is calling `compinit` (or sourcing another script that calls it) before Zimfw's completion module can run.
test: Comment out the line that sources `$NVM_DIR/nvm.sh` in `stow/zsh/.config/zsh/.zsh_path`.
expecting: The `zimfw-compinit-warning` will no longer appear when opening a new terminal.
next_action: Modify `stow/zsh/.config/zsh/.zsh_path` to comment out the `nvm.sh` sourcing line.

## Symptoms

expected: No errors or warnings when opening a new terminal.
actual: A warning about compinit is displayed.
errors: warning: completion was already initialized before completion module. Will call compinit again. See https://github.com/zimfw/zimfw/wiki/Troubleshooting#completion-is-not-working
reproduction: Open a new terminal.
started: Started after a recent, unrelated fix. It used to work.

## Eliminated
<!-- APPEND only - prevents re-investigating -->

- hypothesis: The `compinit` call is in one of the main zsh config files (`.zshrc`, `.zshenv`, `.zsh_aliases`, `.zsh_functions`).
  evidence: `grep` for `compinit` in the `stow/zsh` directory returned no results. Manual inspection of these files also did not reveal a direct `compinit` call.
  timestamp: 2024-07-25T19:46:00Z
- hypothesis: The NVM bash completion script (`bash_completion`), sourced from `.zsh_path`, was calling `compinit`.
  evidence: Commenting out the line that sources `$NVM_DIR/bash_completion` did not resolve the issue. The warning still appeared when simulating a new shell.
  timestamp: 2024-07-25T19:52:00Z

## Evidence
<!-- APPEND only - facts discovered -->

- timestamp: 2024-07-25T19:42:15Z
  checked: `stow/zsh` directory structure.
  found: The main user-editable zsh config files are `.zshenv` and files in `.config/zsh/`.
  implication: The investigation should focus on these files.
- timestamp: 2024-07-25T19:47:00Z
  checked: `stow/zsh/.config/zsh/.zshrc`
  found: It sources `~/.zim/init.zsh` which handles zimfw initialization and completion. It also sources `.zsh_aliases` and `.zsh_functions`.
  implication: The premature `compinit` must be happening before this file is fully sourced.
- timestamp: 2024-07-25T19:47:30Z
  checked: `stow/zsh/.zshenv`
  found: It sources `~/.config/zsh/.zsh_path`. It also sets `skip_global_compinit=1`, indicating an awareness of potential conflicts.
  implication: The problem likely lies within the sourced `.zsh_path` file, as it's executed before `.zshrc`.
- timestamp: 2024-07-25T19:48:01Z
  checked: `stow/zsh/.config/zsh/.zsh_path`
  found: The file sources two NVM-related scripts: `nvm.sh` and `bash_completion`.
  implication: One of these is the likely root cause.
- timestamp: 2024-07-25T19:51:00Z
  checked: stderr of a new zsh instance after commenting out the `bash_completion` script.
  found: The warning "completion was already initialized" was still present.
  implication: The `bash_completion` script was not the cause. The `nvm.sh` script is now the primary suspect.
