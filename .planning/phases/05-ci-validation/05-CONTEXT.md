# Phase 5: CI Validation - Context

**Gathered:** 2026-02-14
**Status:** Ready for planning

<domain>
## Phase Boundary

Automated CI testing that validates fresh dotfiles installs on Ubuntu and macOS. Confirms shell startup time, aliases, functions, env vars, git config, PATH contents, and Stow symlink structure. Does NOT include deployment, release automation, or new testing frameworks beyond what CI needs.

</domain>

<decisions>
## Implementation Decisions

### Test scope
- Hard threshold: zsh startup must be under 100ms or build fails
- Full audit of shell functionality: all aliases/functions from config, every PATH entry, env vars (EDITOR, ZDOTDIR), plugin loading
- Verify Stow symlink structure after install (e.g., ~/.config/git/config symlinked correctly)

### Tool config validation
- Claude's discretion on whether to run smoke tests (nvim --headless, git config --get, tmux start-server) or just check file existence

### Workflow structure
- Docker containers for CI environment
- Claude's discretion on Docker for both platforms or Linux-only (macOS Docker in CI is limited)
- Dockerfile lives in the dotfiles repo (e.g., .github/ or test/)
- Claude's discretion on test logic organization (shell script, Makefile target, or both)

### Triggers
- Push to any branch
- Pull requests
- Manual dispatch (workflow_dispatch)
- No scheduled runs
- Notifications via default GitHub behavior only (check marks on commits/PRs)

### Claude's Discretion
- Tool config validation depth (smoke tests vs file existence)
- Docker strategy for macOS (native runner vs Docker)
- Test logic organization (test.sh, make test, or both)

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-ci-validation*
*Context gathered: 2026-02-14*
