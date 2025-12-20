# Dotfiles Repository Review & Cross-Platform Recommendations

## Repository Purpose & Current State

This is a well-structured dotfiles repository that provides:
- **Shell configuration** for Bash and Zsh (with Zim framework)
- **Package management** via Homebrew (macOS) and APT (Linux)
- **Symlink management** using GNU Stow
- **Development tools** setup (Node.js, Rust, Git, etc.)
- **Cross-platform support** for macOS and Linux (Ubuntu/Debian)

### Current Architecture

1. **Installation**: Makefile-based with `make macos` and `make linux` targets
2. **Shell Support**: Primary focus on Zsh (Zim), with Bash as fallback
3. **OS Detection**: Binary detection via `bin/is-macos` and `bin/is-arm64`
4. **Path Management**: Centralized in `system/.path` with OS-specific Homebrew paths
5. **Configuration**: Modular system files in `system/` directory, symlinked via Stow

---

## Current Issues & Gaps

### 1. **WSL Detection Missing**
- WSL is currently treated as regular Linux
- No special handling for WSL-specific paths or behaviors
- WSL has unique characteristics (Windows integration, different filesystem mounts)

### 2. **Windows PowerShell Not Supported**
- No PowerShell profile configuration
- No Windows-specific installation path
- Windows has fundamentally different shell and package management

### 3. **Path Configuration Issues**
- `system/.path` assumes Homebrew on Linux (line 6), but doesn't check if it's actually installed
- Some macOS-specific paths may not exist on Linux/WSL
- No conditional logic for WSL-specific paths

### 4. **OS Detection Limitations**
- Only detects macOS vs. Linux (binary choice)
- No granular detection for WSL, Windows, or specific Linux distributions
- No detection of shell type (Bash vs. Zsh vs. PowerShell)

### 5. **Installation Script Limitations**
- `remote-install.sh` only checks `OSTYPE` for darwin, everything else is "linux"
- No WSL-specific installation steps
- No Windows installation path

---

## Recommendations

### Priority 1: WSL Support (High Impact, Low Effort)

#### 1.1 Add WSL Detection Utility
Create `bin/is-wsl`:
```bash
#!/usr/bin/env bash
if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
  exit 0
else
  exit 1
fi
```

#### 1.2 Update Makefile OS Detection
```makefile
# Detect OS more granularly
OS := $(shell bin/is-supported bin/is-macos macos $(shell bin/is-supported bin/is-wsl wsl linux))
```

#### 1.3 Create WSL-Specific Installation Target
Add to Makefile:
```makefile
wsl: core-linux packages-linux link
	# WSL-specific optimizations
	# - Skip unnecessary services
	# - Optimize for Windows integration
```

#### 1.4 Update Path Configuration
Modify `system/.path` to handle WSL:
```bash
# Detect WSL and adjust paths accordingly
if is-wsl; then
  # WSL-specific paths (e.g., Windows executables via /mnt/c/Windows/System32)
  prepend-path "/mnt/c/Windows/System32"
  prepend-path "/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
fi
```

#### 1.5 Update Remote Install Script
Modify `remote-install.sh`:
```bash
# Detect WSL
if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
  make wsl
elif [[ "$OSTYPE" =~ ^darwin ]]; then
  make macos
else
  make linux
fi
```

### Priority 2: Enhanced Linux Distribution Support

#### 2.1 Add Distribution Detection
Create `bin/is-ubuntu`, `bin/is-debian`, etc.:
```bash
#!/usr/bin/env bash
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "$ID" = "ubuntu" ]; then
    exit 0
  fi
fi
exit 1
```

#### 2.2 Conditional Package Installation
Update `apt-packages` target to be distribution-aware:
```makefile
apt-packages: core-linux
ifeq ($(shell bin/is-supported bin/is-ubuntu true false),true)
	sudo apt-get install -y \
		# Ubuntu-specific packages
else
	sudo apt-get install -y \
		# Generic Debian packages
endif
```

### Priority 3: Windows PowerShell Support (If Not Heavy Lift)

#### 3.1 PowerShell Profile Structure
Create `runcom/Microsoft.PowerShell_profile.ps1`:
```powershell
# PowerShell profile for Windows
$DOTFILES_DIR = if (Test-Path "$env:USERPROFILE\.dotfiles") {
    "$env:USERPROFILE\.dotfiles"
} elseif (Test-Path "$env:USERPROFILE\projects\dotfiles") {
    "$env:USERPROFILE\projects\dotfiles"
}

if ($DOTFILES_DIR) {
    # Source common aliases and functions
    . "$DOTFILES_DIR\system\powershell\aliases.ps1"
    . "$DOTFILES_DIR\system\powershell\functions.ps1"
    . "$DOTFILES_DIR\system\powershell\path.ps1"
}
```

#### 3.2 PowerShell-Specific System Files
Create `system/powershell/` directory:
- `aliases.ps1` - PowerShell aliases (equivalent to Bash aliases)
- `functions.ps1` - PowerShell functions
- `path.ps1` - PATH management for Windows

#### 3.3 Windows Installation Target
Add to Makefile (if PowerShell is available):
```makefile
windows: link-powershell
	# Windows-specific setup
	# - Install Chocolatey packages
	# - Configure Windows Terminal
	# - Set up Git for Windows
```

#### 3.4 PowerShell Symlink Handling
Update `link` target to handle PowerShell profiles:
```makefile
link: stow-$(OS)
	# ... existing code ...
ifeq ($(OS),windows)
	# Symlink PowerShell profile
	mkdir -p "$(APPDATA)/Microsoft/Windows/PowerShell"
	# PowerShell profile location varies by version
endif
```

**Note**: PowerShell support requires:
- PowerShell 5.1+ or PowerShell Core 7+
- Understanding of PowerShell profile locations
- Windows-specific package manager (Chocolatey, Scoop, or winget)
- Different symlink approach (Windows uses junctions or hard links)

### Priority 4: Configuration Improvements

#### 4.1 Conditional Homebrew Path
Fix `system/.path` to properly detect Homebrew on Linux:
```bash
# Only set HOMEBREW_PREFIX if Homebrew is actually installed
if is-macos; then
  export HOMEBREW_PREFIX=$($DOTFILES_DIR/bin/is-supported $DOTFILES_DIR/bin/is-arm64 /opt/homebrew /usr/local)
elif [ -d /home/linuxbrew/.linuxbrew ]; then
  export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
else
  # Homebrew not installed, skip Homebrew paths
  export HOMEBREW_PREFIX=""
fi

# Only prepend Homebrew paths if HOMEBREW_PREFIX is set
if [ -n "$HOMEBREW_PREFIX" ]; then
  prepend-path "$HOMEBREW_PREFIX/bin"
  prepend-path "$HOMEBREW_PREFIX/sbin"
  # ... other Homebrew paths
fi
```

#### 4.2 OS-Specific System Files
Create conditional sourcing in `.bash_profile`:
```bash
# OS-specific configurations
if is-macos; then
  for DOTFILE in "$DOTFILES_DIR"/system/.{env,alias,function}.macos; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
elif is-wsl; then
  for DOTFILE in "$DOTFILES_DIR"/system/.{env,alias,function}.wsl; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
fi
```

#### 4.3 Update README
Add sections for:
- WSL installation instructions
- Windows PowerShell setup (if implemented)
- Troubleshooting for each platform

### Priority 5: Testing & Validation

#### 5.1 Add WSL to CI/CD
If using GitHub Actions, add WSL test runner:
```yaml
- name: Test WSL Installation
  uses: Vampire/setup-wsl@v2
  with:
    distribution: Ubuntu
```

#### 5.2 Add Test Cases
Create test files for:
- WSL detection
- Cross-platform path resolution
- PowerShell profile (if implemented)

---

## Implementation Priority

### Phase 1: WSL Support (Recommended First)
1. ✅ Add `bin/is-wsl` detection utility
2. ✅ Update Makefile OS detection
3. ✅ Create `wsl` installation target
4. ✅ Update `system/.path` for WSL
5. ✅ Update `remote-install.sh`
6. ✅ Test on WSL environment

**Estimated Effort**: 2-4 hours

### Phase 2: Enhanced Linux Support
1. Add distribution detection utilities
2. Make package installation distribution-aware
3. Test on multiple Linux distributions

**Estimated Effort**: 2-3 hours

### Phase 3: Windows PowerShell (Optional)
1. Create PowerShell profile structure
2. Port essential aliases/functions to PowerShell
3. Create Windows installation target
4. Test on Windows

**Estimated Effort**: 4-8 hours (depending on feature parity desired)

---

## Specific Code Changes Needed

### 1. Create `bin/is-wsl`
```bash
#!/usr/bin/env bash
# Detect if running in WSL
if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
  exit 0
elif [ -f /proc/sys/kernel/osrelease ] && grep -qi microsoft /proc/sys/kernel/osrelease; then
  exit 0
else
  exit 1
fi
```

### 2. Update Makefile (Line 2-3)
```makefile
OS := $(shell bin/is-supported bin/is-macos macos $(shell bin/is-supported bin/is-wsl wsl linux))
HOMEBREW_PREFIX := $(shell bin/is-supported bin/is-macos $(shell bin/is-supported bin/is-arm64 /opt/homebrew /usr/local) $(shell bin/is-supported bin/is-wsl /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew))
```

### 3. Add WSL Target to Makefile
```makefile
wsl: core-linux packages-linux link
	@echo "WSL installation complete"
```

### 4. Update `system/.path` (Lines 6, 19-25)
```bash
# Detect OS and set HOMEBREW_PREFIX accordingly
if is-macos; then
  export HOMEBREW_PREFIX=$($DOTFILES_DIR/bin/is-supported $DOTFILES_DIR/bin/is-arm64 /opt/homebrew /usr/local)
elif is-wsl || [ -d /home/linuxbrew/.linuxbrew ]; then
  export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
else
  export HOMEBREW_PREFIX=""
fi

# Only add Homebrew paths if HOMEBREW_PREFIX is set and exists
if [ -n "$HOMEBREW_PREFIX" ] && [ -d "$HOMEBREW_PREFIX" ]; then
  prepend-path "$HOMEBREW_PREFIX/bin"
  prepend-path "$HOMEBREW_PREFIX/sbin"
  prepend-path "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin"
  prepend-path "$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin"
  prepend-path "$HOMEBREW_PREFIX/opt/grep/libexec/gnubin"
  prepend-path "$HOMEBREW_PREFIX/opt/python/libexec/bin"
  prepend-path "$HOMEBREW_PREFIX/opt/ruby/bin"
fi
```

### 5. Update `remote-install.sh` (Lines 28-33)
```bash
# Run the appropriate installation based on OS
cd "$TARGET"
if [[ "$OSTYPE" =~ ^darwin ]]; then
  make macos
elif [ -f /proc/version ] && grep -qi microsoft /proc/version; then
  make wsl
else
  make linux
fi
```

---

## Additional Considerations

### WSL-Specific Optimizations
- **Performance**: WSL2 has different I/O characteristics
- **Windows Integration**: Access Windows executables via `/mnt/c/`
- **Git Credential Manager**: May need WSL-specific Git configuration
- **Docker**: WSL2 has Docker Desktop integration

### PowerShell Considerations
- **Profile Location**: Varies by PowerShell version
  - PowerShell 5.1: `$PROFILE` (usually `$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`)
  - PowerShell 7+: `$PROFILE` (usually `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`)
- **Package Managers**: Chocolatey, Scoop, or winget
- **Symlinks**: Windows requires admin privileges or developer mode
- **Path Separators**: Use backslashes or forward slashes (PowerShell handles both)

### Testing Strategy
1. Test on clean macOS installation
2. Test on clean Ubuntu installation
3. Test on WSL2 Ubuntu
4. Test on Windows PowerShell (if implemented)
5. Verify symlinks work correctly on each platform
6. Test package installations don't conflict

---

## Conclusion

The repository is well-structured and can be extended to support WSL and Windows PowerShell. The recommended approach:

1. **Start with WSL support** - It's the easiest win and most requested
2. **Enhance Linux distribution detection** - Improves reliability
3. **Consider PowerShell support** - Only if you actively use Windows

The current architecture (modular system files, Stow for symlinks, Makefile for installation) makes these additions straightforward without major refactoring.

