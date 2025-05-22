#!/bin/bash
#
# Shell behavior mode utilities for use in shell scripts.
# These functions should be explicitly called from scripts to control
# shell options consistently across your scripting environment.


# With these settings, certain common errors will cause the script to
# immediately fail, explicitly and loudly. Otherwise, you can get
# hidden bugs that are discovered only when they blow up in production.
#
# Flags:
# -e: exit immediately if a command fails
# -u: treat unset variables as an error
# -o pipefail: fail a pipeline if any command fails (not just the last)
enable_strict_mode() {
  set -euo pipefail
}


# -x: print all executed commands for debugging
enable_debug_mode() {
  set -x
}