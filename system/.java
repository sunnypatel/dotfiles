# Java configuration

if is-macos; then
  # Set JAVA_HOME to the Homebrew-installed OpenJDK on macOS
  export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk"
  
  # Add Java binaries to the PATH
  prepend-path "$JAVA_HOME/bin"
  
  # For compilers to find openjdk
  export CPPFLAGS="-I$JAVA_HOME/include"
elif is-executable java; then
  # Set JAVA_HOME on Linux
  if [ -d /usr/lib/jvm/default-java ]; then
    export JAVA_HOME="/usr/lib/jvm/default-java"
  elif [ -d /usr/lib/jvm/java-11-openjdk-amd64 ]; then
    export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
  fi
  
  # Add Java binaries to the PATH if JAVA_HOME is set
  [ -n "$JAVA_HOME" ] && prepend-path "$JAVA_HOME/bin"
fi