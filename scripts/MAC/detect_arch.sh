# Sourced by the MAC bootstrap scripts.
#
# Apple Silicon: Homebrew for command line packages and for casks.
# Intel: MacPorts for command line packages (Homebrew no longer ships Intel
# bottles for most formulas, so it compiles them from source) and Homebrew
# only for casks (casks download the vendor's app, nothing is compiled).

# hw.optional.arm64 is 1 on Apple Silicon even when the shell runs under
# Rosetta, unlike `uname -m`. On Intel the key does not exist.
function is_apple_silicon {
  [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" = "1" ]
}

PORT_BIN="/opt/local/bin/port"
