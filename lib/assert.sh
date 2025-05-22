#!/bin/bash
#
# Shared assertion functions for validating script prerequisites.
# Note: Save this file to /usr/local/lib/
#
# Usage:
#   source /usr/local/lib/assert.sh
#   assert_dir '/some/required/directory'
#   assert_file '/some/required/file'
#   assert_executable '/some/required/binary'
#
# These functions are used to enforce the presence of critical paths before
# a script proceeds, ensuring fail-fast behavior and easier debugging.
# All assertions print a clear error message to stderr and exit immediately
# if the condition is not met.
#
# Usage:
#   assert_dir <path>
#   assert_file <path>

# Asserts that the given directory exists.
assert_dir() {
  [[ -d "$1" ]] || {
    echo "[ERROR] ❌ Directory \"$1\" does not exist." >&2
    exit 1
  }
}

# Asserts that the given file exists and is a regular file.
assert_file() {
  [[ -f "$1" ]] || {
    echo "[ERROR] ❌ File \"$1\" does not exist." >&2
    exit 1
  }
}

# Asserts that the given path is an executable file.
assert_file_is_executable() {
  assert_file "$1"

  [[ -x "$1" ]] || {
    echo "[ERROR] ❌ \"$1\" is not executable." >&2
    exit 1
  }
}

# Asserts that the current user is root.
assert_root_user() {
  [[ "${EUID}" -eq 0 ]] || {
    echo '[ERROR] ❌ This script must be run as root.' >&2
    exit 1
  }
}

# Asserts that the given unit exists in systemd.
assert_unit_exists() {
  systemctl list-unit-files "$1" &>/dev/null || {
    echo "[ERROR] ❌ Unit \"$1\" does not exist." >&2
    exit 1
  }

  systemctl cat "$1" &>/dev/null || {
    echo "[ERROR] ❌ $1 is broken, unreadable, or failed to load." >&2
    exit 1
  }
}

# Asserts that the given command exists.
assert_command() {
  command -v "$1" &>/dev/null || {
    echo "[ERROR] ❌ Command \"$1\" not found." >&2
    exit 1
  }
}