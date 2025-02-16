# Case-insensitive globbing (used in pathname expansion)

setopt nocaseglob

# Recursive globbing with "**"

if [[ -n ${options[globstarshort]} ]]; then
  setopt globstarshort
fi

# Append to the Bash history file, rather than overwriting it

setopt histappend

# Autocorrect typos in path names when using `cd`

setopt correct
