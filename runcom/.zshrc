###############################################################################
# Zim Initialization                                                          #
###############################################################################

ZIM_HOME=~/.zim
# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  if [ -f ${HOMEBREW_PREFIX}/opt/zimfw/share/zimfw.zsh ]; then
    source ${HOMEBREW_PREFIX}/opt/zimfw/share/zimfw.zsh init -q
  elif [ -f /usr/share/zimfw/zimfw.zsh ]; then
    source /usr/share/zimfw/zimfw.zsh init -q
  elif command -v curl >/dev/null 2>&1; then
    # Auto-install Zim if not present
    curl -fsSL https://raw.githubusercontent.com/zimfw/zimfw/master/zimfw.zsh -o ${ZIM_HOME}/zimfw.zsh 2>/dev/null && \
    zsh ${ZIM_HOME}/zimfw.zsh install -q 2>/dev/null || true
  fi
fi

# Initialize modules (only if Zim is installed)
if [ -f ${ZIM_HOME}/init.zsh ]; then
  # Optimize completion system for faster startup
  # Enable completion caching (Zim will respect these zstyle settings)
  zstyle ':completion:*' use-cache yes
  zstyle ':completion:*' cache-path "${ZDOTDIR:-${HOME}}/.zcompcache"
  # Skip security checks for faster compinit (acceptable for local dev)
  # This is done by setting the dumpfile to use -C flag behavior
  zstyle ':zim:completion' dumpfile "${ZDOTDIR:-${HOME}}/.zcompdump"
  
  source ${ZIM_HOME}/init.zsh
fi

###############################################################################
# User-Specific Configurations (Loaded After Zim)                             #
###############################################################################

# Source .bash_profile if it exists
if [ -f $HOME/.bash_profile ]; then
    source $HOME/.bash_profile
fi

