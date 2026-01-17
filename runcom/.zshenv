# Skip system-wide compinit in /etc/zsh/zshrc (saves ~500ms on startup)
# Zim handles compinit itself with proper caching
skip_global_compinit=1

# Uncomment to troubleshoot completion system.  See https://github.com/zimfw/zimfw/wiki/Troubleshooting#completion-is-not-working
# autoload -Uz +X compinit
# functions[compinit]=$'print -u2 \'compinit being called at \'${funcfiletrace[1]}
# '${functions[compinit]}
