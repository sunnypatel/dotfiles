# Java configuration

# Set JAVA_HOME to the Homebrew-installed OpenJDK
export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk"

# Add Java binaries to the PATH
prepend-path "$JAVA_HOME/bin"

# For compilers to find openjdk
export CPPFLAGS="-I$JAVA_HOME/include"
