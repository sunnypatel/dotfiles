# Codebase Concerns

**Analysis Date:** 2026-02-13

## Tech Debt

**Unsafe eval() usage in is-supported utility:**
- Issue: `is-supported` script uses `eval` to execute arbitrary commands, which is inherently unsafe
- Files: `bin/is-supported`
- Impact: Could allow command injection if user supplies untrusted input; difficult to audit; security risk
- Fix approach: Replace eval-based conditional execution with a safer approach. Consider using functions or conditional logic instead of eval. Validate inputs strictly.

**Temporary file handling in transfer() function:**
- Issue: `transfer()` creates temp files with predictable naming pattern `transferXXX`
- Files: `system/.function_network`
- Impact: Temporary file location is predictable; may fail on systems with restrictive temp policies; no cleanup on error
- Fix approach: Use `mktemp -p "$XDG_RUNTIME_DIR"` or secure tmpdir; add trap to ensure cleanup even on error

**Hard-coded paths in PATH configuration:**
- Issue: `system/.path` assumes specific Homebrew installation paths may exist but doesn't verify before adding to PATH
- Files: `system/.path`
- Impact: Adds non-existent directories to PATH; can slow shell startup; relies on Homebrew packages that might not be installed
- Fix approach: Verify directory existence before adding; check if Homebrew packages are actually installed before adding their paths

**Remote install script eval usage:**
- Issue: `remote-install.sh` uses `eval "$CMD"` to execute dynamically constructed commands
- Files: `remote-install.sh`
- Impact: Security risk if source is compromised; hard to debug; command is not validated
- Fix approach: Replace eval with direct function calls or script execution; use set -e for safety

## Security Considerations

**Command injection risk in shell functions:**
- Risk: Several shell functions don't quote variables properly, enabling command injection
- Files: `system/.function_network` (line 25: `$(basename $1)` and curl with unquoted variable), `bin/dot` (line 42, 43: unquoted `$VISUAL` and `$VISUAL_GIT`)
- Current mitigation: None - functions trust user input
- Recommendations: Quote all variables consistently; validate file paths before operations; use arrays for complex commands

**Unsafe curl/wget piping to bash:**
- Risk: The pattern `curl ... | bash` in remote-install.sh and installation scripts is vulnerable to man-in-the-middle attacks
- Files: `remote-install.sh` (line 87: Homebrew install), `Makefile` (line 135: bun install), `Makefile` (line 109: nvm install), `Makefile` (line 167: rustup install)
- Current mitigation: Uses `-fsSL` flags which help but don't eliminate risk
- Recommendations: Consider downloading, verifying checksums/signatures, then executing; use package managers where available; document the security tradeoff explicitly

**Unquoted variables in makefile and shell scripts:**
- Risk: Variables like `$HOMEBREW_PREFIX` and file paths are unquoted in several places, allowing word splitting and globbing
- Files: `Makefile` (multiple lines), `bin/dot`, `system/.path`
- Current mitigation: None
- Recommendations: Quote all variables: `"$VAR"` instead of `$VAR`

**Hardcoded computer name in macOS defaults:**
- Risk: `macos/defaults.sh` sets computer name to hardcoded value `"Sunny's MacBook Pro"` which won't match user's hardware
- Files: `macos/defaults.sh` (line 1)
- Current mitigation: User can edit file manually after installation
- Recommendations: Prompt for computer name during installation or make it configurable via environment variable

## Performance Bottlenecks

**Repeated OS detection checks:**
- Problem: Multiple scripts call `is-macos`, `is-wsl`, etc. on each shell invocation, running subprocesses repeatedly
- Files: `system/.path`, `system/.env`, shell rc files
- Cause: No caching of detection results; each shell startup checks OS multiple times
- Improvement path: Cache OS detection results in variables during shell initialization; use single detection run per shell session

**PATH deduplication via awk every shell startup:**
- Problem: `system/.path` removes duplicate PATH entries using awk on every shell invocation
- Files: `system/.path` (line 60)
- Cause: Assumes duplicates are normal; runs regex on entire PATH string
- Improvement path: Build PATH correctly the first time instead of deduplicating; only run dedup during installation or when manually adding paths

**Makefile recomputes OS and HOMEBREW_PREFIX for every target:**
- Problem: Makefile header evaluates shell commands for each make invocation
- Files: `Makefile` (lines 2-3)
- Cause: Make evaluates these at parse time, causing shell overhead
- Improvement path: Cache OS detection in a file; reference cached value instead of recomputing

## Fragile Areas

**Complex nested shell conditionals in Makefile:**
- Files: `Makefile` (lines 2-3, complex is-supported nesting)
- Why fragile: Hard to read, nested command substitutions are error-prone, difficult to debug, easy to break with spacing changes
- Safe modification: Break into separate helper targets or separate makefile includes; add comments explaining logic
- Test coverage: Makefile logic is tested only if full installation is run

**Path configuration assumes Homebrew on Linux:**
- Files: `system/.path`
- Why fragile: Checks for `/home/linuxbrew/.linuxbrew` but doesn't handle other package managers or installations; assumes Homebrew is the primary way to get GNU tools on Linux
- Safe modification: Add explicit checks for package manager availability; make order of checks match actual installation order
- Test coverage: Path configuration tested only during full installation

**macOS-specific script sourcing in bin/dot:**
- Files: `bin/dot` (sub_macos function)
- Why fragile: Sources all `macos/defaults*.sh` files in directory order; if a new file is added, it runs without explicit inclusion; error in any file breaks the whole sequence
- Safe modification: Explicitly list which scripts to run; add error handling with `set -e`; test each script independently
- Test coverage: No unit tests for individual defaults scripts

**Remote install script manual OS detection:**
- Files: `remote-install.sh`
- Why fragile: Duplicates OS detection logic that should be in `bin/is-*` utilities; inconsistent with Makefile detection
- Safe modification: Call the actual `bin/is-*` scripts from remote-install.sh instead of duplicating logic
- Test coverage: Tested only when installing from scratch; hard to test various network scenarios

**Test command prefix handling in verification:**
- Files: `test/verify-setup.sh`
- Why fragile: Uses `eval` to run arbitrary commands from test files; test syntax not validated before execution
- Safe modification: Use safer command execution (case statement or function dispatch); validate test syntax during parsing
- Test coverage: Tests check that commands exist but don't validate syntax

## Scaling Limits

**Shell startup time with many PATH entries:**
- Current capacity: PATH can reasonably contain ~50 directories before noticeable slowdown
- Limit: Beyond 100 PATH entries, shell startup becomes sluggish (awk dedup, getconf, multiple condition checks)
- Scaling path: Cache OS detection and PATH in separate files; lazy-load development tool paths

**Makefile parallelization not supported:**
- Current capacity: Makefile targets run sequentially; installation takes 10-30 minutes
- Limit: Some targets could run in parallel (npm and cargo installations, for example)
- Scaling path: Add `.PHONY` declarations (some present, some missing); restructure dependencies to allow parallel execution

**Configuration file proliferation:**
- Current capacity: ~5 system-wide config files load per shell startup
- Limit: Adding OS-specific configs for each platform multiplies files; maintenance burden increases
- Scaling path: Use a single configuration file with conditional logic; or use config generation approach instead of sourcing files

## Dependencies at Risk

**NVM version pinned to v0.40.1:**
- Risk: Hardcoded version in Makefile; no mechanism to update when new version released
- Files: `Makefile` (line 109, 161)
- Impact: Won't get bug fixes or new Node versions; security updates lag
- Migration plan: Use latest stable version (`$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.tag_name')`) or a release script to update

**Rustup install piped to bash:**
- Risk: Rust toolchain installation highly critical; any compromise here affects all Rust projects
- Files: `Makefile` (line 167)
- Impact: Total system compromise if source is compromised during installation
- Migration plan: Use platform package managers where available; verify signatures if piping to bash

**Bun installer not pinned:**
- Risk: Latest bun installer fetched on every installation, version not controllable
- Files: `Makefile` (line 135)
- Impact: Different bun versions installed on different machines; hard to debug version-specific issues
- Migration plan: Pin bun version; use package manager installation

## Missing Critical Features

**No rollback/recovery mechanism:**
- Problem: Installation creates backups (`.bak` files) but no automated rollback if something goes wrong
- Blocks: Can't easily revert to previous dotfiles state; users must manually restore backups
- Recommendation: Add `make rollback` target that restores all `.bak` files; document recovery process

**No validation of critical configuration:**
- Problem: Installation completes even if critical tools fail to install or configure
- Blocks: Users might not realize Git or shell configuration didn't work until later
- Recommendation: Add `make validate` target that checks installation completeness; fail loud if critical components missing

**Limited Linux distribution support:**
- Problem: Only tested on Ubuntu/Debian; other distributions have different package names and installation methods
- Blocks: Installation fails on Fedora, Arch, Alpine, etc.
- Recommendation: Add distribution detection; make package lists conditional on `is-ubuntu`, `is-fedora`, etc.

**No macOS version compatibility checking:**
- Problem: defaults scripts assume recent macOS; some settings may not exist in older versions
- Blocks: Script errors on older macOS versions even if most settings apply
- Recommendation: Add macOS version detection; skip incompatible settings; warn user about version gaps

## Test Coverage Gaps

**No integration tests for full installation flow:**
- What's not tested: Complete end-to-end installation with all targets
- Files: `test/verify-setup.sh`, `test/` directory (all test files)
- Risk: Installation might fail in real scenarios but tests pass
- Priority: High

**Remote install script not tested:**
- What's not tested: Curl/git clone path, tar extraction, OS detection in remote context
- Files: `remote-install.sh`
- Risk: Installation from URL might fail undetected
- Priority: High

**Path configuration not tested for actual tool availability:**
- What's not tested: Whether Homebrew actually provides the expected binaries at configured paths
- Files: `test/path-config.bats`, `system/.path`
- Risk: PATH has entries that don't work; tools fail to run
- Priority: Medium

**macOS defaults scripts untested:**
- What's not tested: Whether individual defaults apply correctly; whether defaults exist in target macOS version
- Files: `macos/defaults*.sh` (all three files)
- Risk: Defaults silently fail to apply; user experience degrades
- Priority: Medium

**Symlink logic not comprehensively tested:**
- What's not tested: Complex backup/restore logic in Makefile link target; edge cases with existing files
- Files: `Makefile` (link/unlink targets), `bin/append`
- Risk: Symlinks corrupt existing files; backup/restore fails
- Priority: Medium

**Shell compatibility not fully tested:**
- What's not tested: Bash 3.x compatibility (older macOS default); zsh-specific issues
- Files: All shell scripts
- Risk: Scripts fail on older shells; compatibility claims are false
- Priority: Low

---

*Concerns audit: 2026-02-13*
