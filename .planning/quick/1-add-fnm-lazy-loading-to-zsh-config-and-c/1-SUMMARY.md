# Quick Task 1: Add fnm lazy loading, cleanup NVM

**Date:** 2026-05-05

## Changes

### `stow/zsh/.config/zsh/.zsh_path`
- **Removed:** Entire NVM section (`NVM_DIR` export + two commented-out `nvm.sh` source lines)
- **Added:** fnm (Fast Node Manager) section with `FNM_PATH` export and conditional PATH prepend

### `stow/zsh/.config/zsh/.zsh_functions`
- **Added:** fnm lazy-loading shim functions for `node`, `npm`, `npx`, `yarn`
  - Defers `eval "$(fnm env --use-on-cd --shell zsh)"` until first use
  - Uses `unset -f` pattern to remove shims after initialization
  - Guarded by `$+commands[fnm]` — no-op if fnm isn't installed

## Verification
- [x] No NVM references remain in `.zsh_path`
- [x] `FNM_PATH` export and PATH entry present in `.zsh_path`
- [x] fnm lazy-loading block in `.zsh_functions`
- [x] Both files pass `zsh -n` syntax validation
