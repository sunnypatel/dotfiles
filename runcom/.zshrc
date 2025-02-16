###############################################################################
# Zim Initialization                                                          #
###############################################################################

ZIM_HOME=~/.zim
# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${HOMEBREW_PREFIX}/opt/zimfw/share/zimfw.zsh init -q
fi

# Initialize modules.
source ${ZIM_HOME}/init.zsh

###############################################################################
# User-Specific Configurations (Loaded After Zim)                             #
###############################################################################

# Source .bash_profile if it exists
if [ -f $HOME/.bash_profile ]; then
    source $HOME/.bash_profile
fi

