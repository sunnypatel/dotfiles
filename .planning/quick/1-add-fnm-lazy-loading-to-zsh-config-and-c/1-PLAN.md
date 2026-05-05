---
phase: 1-add-fnm-lazy-loading-to-zsh-config-and-c
plan: 1
type: execute
wave: 1
depends_on: []
files_modified:
  - stow/zsh/.config/zsh/.zsh_path
  - stow/zsh/.config/zsh/.zsh_functions
autonomous: true

must_haves:
  truths:
    - "No NVM_DIR or commented-out nvm.sh references remain in zsh config files"
    - "fnm lazy-loads on first use of node/npm/npx — doesn't eval fnm env at shell start"
    - "FNM_PATH is exported and in PATH for fnm binary discovery"
  artifacts:
    - path: "stow/zsh/.config/zsh/.zsh_path"
      provides: "Clean PATH config without stale NVM references, with FNM_PATH"
    - path: "stow/zsh/.config/zsh/.zsh_functions"
      provides: "fnm lazy-loading function definitions"
  key_links:
    - from: ".zsh_path"
      to: ".zsh_functions"
      via: ".zshrc sources both"
      pattern: "source.*\\.zsh_(path|functions)"
    - from: ".zsh_functions"
      to: "fnm binary"
      via: "$commands[fnm] check, then fnm env --use-on-cd --shell zsh"
      pattern: "fnm env"
---

<objective>
Add fnm (Fast Node Manager) lazy loading to zsh config and clean up stale NVM references.

Purpose: Remove dead NVM configuration that's been commented out since v1.0 (CLN-06 — language version management out of scope). Replace with fnm lazy loading that defers `eval "$(fnm env ...)"` until node/npm/npx are actually used, keeping shell startup fast.
Output: Clean .zsh_path, fnm lazy-load in .zsh_functions
</objective>

<execution_context>
@/home/sunny/.config/opencode/get-shit-done/workflows/execute-plan.md
@/home/sunny/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@stow/zsh/.config/zsh/.zsh_path
@stow/zsh/.config/zsh/.zsh_functions
@stow/zsh/.config/zsh/.zshrc
</context>

<tasks>

<task type="auto">
  <name>Task 1: Clean up stale NVM references in .zsh_path</name>
  <files>stow/zsh/.config/zsh/.zsh_path</files>
  <action>
    In `stow/zsh/.config/zsh/.zsh_path`:

    1. Remove the entire NVM section (lines 26-32: the `# NVM` comment block, `export NVM_DIR` line, and the two commented-out sourcing lines).

    2. Add a new `# fnm (Fast Node Manager)` section in its place, after the Homebrew section and before the pnpm section:
       ```
       ###############################################################################
       # fnm (Fast Node Manager)
       ###############################################################################

       export FNM_PATH="$HOME/.local/share/fnm"
       if [[ -d "$FNM_PATH" ]]; then
         export PATH="$FNM_PATH:$PATH"
       fi
       ```

    Do NOT change anything else in the file. Keep the pnpm section, PATH construction, and other sections exactly as-is.
  </action>
  <verify>Run: grep -n 'NVM\|nvm' stow/zsh/.config/zsh/.zsh_path (should return nothing). Run: grep -n 'fnm' stow/zsh/.config/zsh/.zsh_path (should show the new section with FNM_PATH).</verify>
  <done>NVM_DIR and all NVM references are removed from .zsh_path. FNM_PATH export and PATH entry are added.</done>
</task>

<task type="auto">
  <name>Task 2: Add fnm lazy-loading function in .zsh_functions</name>
  <files>stow/zsh/.config/zsh/.zsh_functions</files>
  <action>
    Append to the end of `stow/zsh/.config/zsh/.zsh_functions`:

    ```
    ###############################################################################
    # fnm (Fast Node Manager) - Lazy Loading
    ###############################################################################
    # Defers fnm init until node/npm/npx/yarn are first called.
    # Without this, `eval "$(fnm env ...)"` runs on every shell start (~50ms).
    ###############################################################################

    if (( $+commands[fnm] )); then
      # Replace node, npm, npx, yarn with shim functions that:
      # 1. Remove themselves (unset -f) on first call
      # 2. Run `fnm env --use-on-cd` to set up the real environment
      # 3. Execute the original command with all arguments
      for __fnm_cmd in node npm npx yarn; do
        eval "
        $__fnm_cmd() {
          unset -f node npm npx yarn
          eval \"\$(fnm env --use-on-cd --shell zsh)\"
          $__fnm_cmd \"\$@\"
        }
        "
      done
    fi
    unset __fnm_cmd
    ```

    This uses the standard fnm lazy-loading pattern. The `$+commands[fnm]` check ensures it's a no-op if fnm isn't installed — safe for a shared dotfiles repo used across multiple machines.

    Key design choice: Using `unset -f` (removes the shim functions after first use) instead of a flag variable — cleaner, fewer moving parts.
  </action>
  <verify>Run: grep -n 'fnm\|lazy' stow/zsh/.config/zsh/.zsh_functions (should show the new fnm section). Run: zsh -n stow/zsh/.config/zsh/.zsh_functions (should produce no errors — validates syntax).</verify>
  <done>fnm lazy-loading function block is appended to .zsh_functions. `zsh -n` syntax check passes. On machines without fnm installed, the block is a no-op ($+commands[fnm] returns false).</done>
</task>

</tasks>

<verification>
1. [ ] `grep -i nvm stow/zsh/.config/zsh/.zsh_path` returns no output (all NVM references removed)
2. [ ] `grep FNM_PATH stow/zsh/.config/zsh/.zsh_path` shows the export (fnm path configured)
3. [ ] `grep -A 1 'FNM_PATH.*PATH' stow/zsh/.config/zsh/.zsh_path` shows PATH entry (fnm binary discoverable)
4. [ ] `grep 'fnm' stow/zsh/.config/zsh/.zsh_functions` returns multiple lines (lazy loading added)
5. [ ] `zsh -n stow/zsh/.config/zsh/.zsh_functions` exits with code 0 (syntax valid)
6. [ ] `zsh -n stow/zsh/.config/zsh/.zsh_path` exits with code 0 (syntax valid)
</verification>

<success_criteria>
- NVM_DIR and all commented-out nvm.sh references are gone from .zsh_path
- FNM_PATH is exported and prepended to PATH in .zsh_path
- fnm lazy-loading shim functions (node, npm, npx, yarn) are defined in .zsh_functions
- Both modified files pass `zsh -n` syntax validation
- On machines without fnm installed, the lazy-loading block is a silent no-op
</success_criteria>

<output>
After completion, create `.planning/quick/1-add-fnm-lazy-loading-to-zsh-config-and-c/1-SUMMARY.md`
</output>
